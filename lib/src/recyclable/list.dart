import 'dart:async';
import 'dart:ui' as ui;
import 'package:app/services/sizes.dart';
import 'package:app/services/stream_providers.dart';
import 'package:app/src/recyclable/new.dart';
import 'package:app/src/recyclable/qrcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../constants/theme_config.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../services/firestore_database.dart';
import '../home/list_items_builder.dart';
import '../models/recyclable.dart';
import '../models/user.dart';
import '../top_level_providers.dart';

final recyclablesStreamProvider =
    StreamProvider.autoDispose<List<Recyclable>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.recyclablesStream();
});

class RecyclablesList extends ConsumerWidget {
  User user;
  ScreenshotController screenshotController = ScreenshotController();

  RecyclablesList({
    Key? key,
    required this.user,
  }) : super(key: key);

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Recyclable recyclable) async {
    final bool didRequestDelete = await showAlertDialog(
          context: context,
          title: "Delete",
          content: "Are you sure you want to delete this item",
          cancelActionText: "Cancel",
          defaultActionText: "Delete",
        ) ??
        false;
    if (didRequestDelete == true) {
      await _delete(context, ref, recyclable);
    }
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Recyclable recyclable) async {
    try {
      final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
      await database.deleteRecyclable(recyclable);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    // _toastInfo(info);
  }

  _saved(Uint8List imageFile, BuildContext context) async {
    final result = await ImageGallerySaver.saveImage(imageFile);
    print("File Saved to Gallery");
  }

  downloadMany(List<Recyclable> list, context) async {
    for (var recyclable in list) {
      var widget = Screenshot(
          controller: screenshotController,
          child: Container(
            child: qrFutureBuilder(recyclable.token),
          ));

      await screenshotController
          .captureFromWidget(widget)
          .then((capturedImage) async {
        print(capturedImage);
        await _saved(capturedImage, context);
      }).catchError((onError) {
        print(onError);
      });
    }
  }

  void deleteMany(
      List<Recyclable> list, WidgetRef ref, BuildContext context) async {
    final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
    var i = 0;
    for (var recyclable in list) {
      try {
        print(i);
        i += 1;
        await database.deleteRecyclable(recyclable);
      } catch (error) {
        print(error);
      }
      ;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Recyclables"),
          titleTextStyle: GoogleFonts.aBeeZee(
            fontSize: 20,
            color: ThemeConfig.lightPrimary,
          ),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add, color: ThemeConfig.lightPrimary),
              onPressed: () => EditRecyclablePage.show(context),
            ),
          ],
        ),
        body: Center(
          child: Container(
            width: width(context) > 600 ? 600 : width(context),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                      height: width(context) > 600
                          ? height(context) * 0.8
                          : height(context) * 0.7,
                      child: buildWidgets(context, ref, user)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextButton(
                              onPressed: () async {
                                _requestPermission();

                                final recyclables = ref
                                    .watch(recyclablessBySellerStreamProvider);
                                recyclables.when(
                                    data: (list) {
                                      downloadMany(list, context);
                                      const snackBar = SnackBar(
                                        content: Text(
                                          'Download in progress. Check the files in your gallery. Make sure that the app has access to you media library.',
                                          textAlign: ui.TextAlign.center,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    error: (_, __) {},
                                    loading: () {});
                              },
                              child: const Text("Download All Unrecycled")),
                        ),
                        Expanded(
                            child: TextButton(
                          onPressed: () async {
                            final recyclables =
                                ref.watch(recyclablessBySellerStreamProvider);

                            recyclables.when(
                                data: (list) {
                                  deleteMany(list, ref, context);
                                  const snackBar = SnackBar(
                                    content: Text(
                                      'Deleting in progress.',
                                      textAlign: ui.TextAlign.center,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                error: (_, __) {},
                                loading: () {});
                          },
                          child: const Text("Delete Recycled"),
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  ListItemsBuilder<Recyclable> buildWidgets(
      BuildContext context, WidgetRef ref, user) {
    final recyclables = ref.watch(recyclablessBySellerStreamProvider);
    final firebaseAuth = ref.watch(firebaseAuthProvider);

    return ListItemsBuilder<Recyclable>(
      direction: Axis.vertical,
      data: recyclables,
      itemBuilder: (context, recyclable) => Dismissible(
        key: Key('recyclable-${recyclable.id}'),
        background: Container(color: Theme.of(context).primaryColor),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => _confirmDelete(context, ref, recyclable),
        child: ListTile(
          title: Text(recyclable.name),
          subtitle: Text("${recyclable.points} Shebas"),
          trailing: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditRecyclablePage(
                              recyclable: recyclable,
                            )
                        // user: user),
                        ));
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              )),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RecyclableQRCode(
                          recyclable: recyclable,
                        )));
          },
        ),
      ),
    );
  }
}

qrFutureBuilder(message) => FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            data: message,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xff128760),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Color(0xff1a5441),
            ),
            // size: 320.0,
            embeddedImage: snapshot.data,
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: const Size.square(60),
            ),
          ),
        );
      },
    );

Future<ui.Image> _loadOverlayImage() async {
  final completer = Completer<ui.Image>();
  final byteData = await rootBundle.load('assets/sheba_logo.png');
  ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
  return completer.future;
}
