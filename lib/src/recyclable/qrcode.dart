import 'dart:async';
import 'dart:ui' as ui;

import 'package:app/src/models/recyclable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

/// This is the screen that you'll see when the app starts
class RecyclableQRCode extends StatefulWidget {
  Recyclable recyclable;

  RecyclableQRCode({Key? key, required this.recyclable}) : super(key: key);
  @override
  _RecyclableQRCodeState createState() => _RecyclableQRCodeState();
}

class _RecyclableQRCodeState extends State<RecyclableQRCode> {
  late TextEditingController _copiesController;
  late Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  @override
  initState() {
    super.initState();
    _copiesController = TextEditingController();
    _requestPermission();
  }

  @override
  dispose() {
    _copiesController.dispose();
    super.dispose();
  }

  _saved(Uint8List imageFile) async {
    final result = await ImageGallerySaver.saveImage(imageFile);
    print("File Saved to Gallery");
    const snackBar = SnackBar(
      content: Text(
        'QR code saved to your gallery',
        textAlign: ui.TextAlign.center,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    // _toastInfo(info);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final qrFutureBuilder = FutureBuilder<ui.Image>(
      future: _loadOverlayImage(),
      builder: (ctx, snapshot) {
        final size = 280.0;
        if (!snapshot.hasData) {
          return Container(width: size, height: size);
        }
        return CustomPaint(
          size: Size.square(size),
          painter: QrPainter(
            data: widget.recyclable.token,
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
    // print("widget.content");
    return Scaffold(
      body: MaterialApp(
        title: 'QR.Flutter',
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Material(
          color: Colors.white,
          child: SafeArea(
            top: true,
            bottom: true,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        width: 280,
                        child: qrFutureBuilder,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40)
                          .copyWith(bottom: 40),
                  child: Column(
                    children: [
                      Text("Name: ${widget.recyclable.name}"),
                      Text("Shebas: ${widget.recyclable.points}"),
                      Text("Recycled: ${widget.recyclable.recycled}"),
                      Text("Approved: ${widget.recyclable.approved}")
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      screenshotController
                          .capture(delay: Duration(milliseconds: 10))
                          .then((capturedImage) async {
                        print(capturedImage!);
                        setState(() {
                          _imageFile = capturedImage;
                        });

                        await _saved(_imageFile);
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                    child: const Text('Download the Code')),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                TextButton(
                    onPressed: () async {
                      final input = await showCopiesDialog();
                      var copies = int.tryParse(input ?? '0') ?? 0;
                      if (copies != 0) {
                        var db = FirebaseFirestore.instance;
                        WriteBatch batch = db.batch();
                        for (var i = 0; i < copies; i++) {
                          var docRef = db.collection("recyclables").doc();
                          var r = Recyclable(
                              id: docRef.id,
                              creator: widget.recyclable.creator,
                              name: widget.recyclable.name,
                              points: widget.recyclable.points);
                          print(i);
                          print(r);
                          await r.encrypt();
                          print(r);
                          batch.set(docRef, r.toMap());

                          // Firebase committing limit is 500 read/write operations per transcation
                          if (i % 499 == 0) {
                            print("Committing");
                            await batch.commit();
                            batch = db.batch();
                          }
                        }
                        print(batch);
                        await batch.commit();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Replicate this item')),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                    )),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> showCopiesDialog() => showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Number of copies"),
            content: TextField(
              autofocus: true,
              controller: _copiesController,
              decoration: const InputDecoration(
                  hintText: 'Similar copies with unique codes to generate',
                  hintMaxLines: 2),
            ),
            actions: [
              TextButton(onPressed: submit, child: const Text("Submit"))
            ],
          ));

  void submit() {
    Navigator.of(context).pop(_copiesController.text);
  }

  Future<ui.Image> _loadOverlayImage() async {
    final completer = Completer<ui.Image>();
    final byteData = await rootBundle.load('assets/sheba_logo.png');
    ui.decodeImageFromList(byteData.buffer.asUint8List(), completer.complete);
    return completer.future;
  }
}

class ReplicateRecyclable extends StatelessWidget {
  Recyclable item;
  ReplicateRecyclable({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Replicate an Item"),
      ),
      body: Center(
        child: Container(),
      ),
    );
  }
}
