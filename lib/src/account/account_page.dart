import 'dart:async';
import 'dart:io';
// import 'dart:html';
// import 'dart:io';
import 'dart:ui' as ui;

import 'package:app/common_widgets/texts.dart';
import 'package:app/routing/app_router.dart';
import 'package:app/services/firestore_database.dart';
import 'package:app/services/sizes.dart';
import 'package:app/src/account/edit_user_info.dart';
import 'package:app/src/account/menu_items.dart';
import 'package:app/src/models/user.dart' as user_model;
import 'package:app/src/top_level_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rv;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common_widgets/avatar.dart';
import '../../constants/strings.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../services/stream_providers.dart';
import '../models/product.dart';
import '../models/recyclable.dart';

final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.productsStream();
});

final recyclablesStreamProvider =
    StreamProvider.autoDispose<List<Recyclable>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.recyclablesStream();
});

class AccountPage extends ConsumerWidget {
  const AccountPage({foundation.Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    // firebaseAuth.signOut();
    if (firebaseAuth.currentUser == null) {
      // Navigator.
      print("user logged out");
      Navigator.popAndPushNamed(context, AppRoutes.signInPage);
    }
    final user = firebaseAuth.currentUser!;
    final firestoreUser = ref.watch(userStreamProvider(user.uid));
    final database = ref.watch(databaseProvider)!;

    return firestoreUser.when(
      data: (user) => Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<MenuItem>(
                onSelected: ((value) async {
                  switch (value) {
                    case MenuItems.edit:
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserPage(user: user),
                            ));
                      }

                      ;
                      break;
                    case MenuItems.share:
                      {
                        Share.share(
                            'I have recycled ${user.recycledBottles} items and earned ${user.currentPoints} with Sheba App');
                      }
                      ;
                      break;
                    case MenuItems.copy:
                      {
                        Clipboard.setData(ClipboardData(text: user.id))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("ID ${user.id} copied to clipboard")));
                        });
                      }
                      break;
                    case MenuItems.delete:
                      {
                        _confirmDeleteAccount(context, firebaseAuth);
                      }
                      ;
                      break;
                  }
                }),
                itemBuilder: (context) => [
                      ...MenuItems.firstItems.map(menuBuilder),
                    ])
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130.0),
            child: _buildUserInfo(user, context, database),
          ),
        ),
        body: userWallBuilder(user, context),
      ),
      loading: () => Container(),
      error: (_, __) => Container(),
    );
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestDeleteAccount = await showAlertDialog(
          context: context,
          title: "Delete My Account",
          content:
              "Are you sure you want to delete your account? This action cannot be undone!",
          cancelActionText: Strings.cancel,
          defaultActionText: "Delete",
        ) ??
        false;
    if (didRequestDeleteAccount == true) {
      await _deleteUser(context, firebaseAuth);
    }
  }

  Future<bool?> _confirmChangeProfilePicture(context) async {
    final bool didRequestSpend = await showAlertDialog(
          context: context,
          title: "Change Avatar",
          content: "Press continue to upload a new avatar",
          cancelActionText: "Cancel",
          defaultActionText: "Continue",
        ) ??
        false;
    if (didRequestSpend == true) {
      return true;
    } else {
      return false;
    }
  }

  handleAvatarClick() {}

  Widget _buildUserInfo(
      user_model.User user, BuildContext context, FirestoreDatabase database) {
    String imageDownloadUrl;
    return Column(
      children: [
        InkWell(
          onTap: () async {
            bool? changeProfile = await _confirmChangeProfilePicture(context);
            if (changeProfile!) {
              var downloadUrl = await getImageUrl();
              var oldAvatar = user.avatar;
              var userRef =
                  FirebaseFirestore.instance.collection('users').doc(user.id);
              userRef.update({
                "avatar": downloadUrl,
              });
              var oldAvatarRef = FirebaseStorage.instance.refFromURL(oldAvatar);
              oldAvatarRef.delete().whenComplete(
                () {
                  print("deleted file");
                },
              ).catchError((onError) {
                debugPrint("onFailure: did not delete file");
              });
            }
          },
          child: Avatar(
            photoUrl: user.avatar != ""
                ? user.avatar
                : "https://firebasestorage.googleapis.com/v0/b/shebaplastic-e2364.appspot.com/o/avatars%2Favatar_image.png?alt=media&token=3c0cde21-7175-483a-b105-b36848550ce0",
            radius: 50,
            borderColor: Colors.white,
            borderWidth: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Text(
              " | ",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              "${user.currentPoints} Shebas",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget userWallBuilder(user_model.User user, BuildContext context) {
    return Center(
      child: Container(
        width: width(context) > 600 ? 600 : width(context),
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: SizedBox(
            height: height(context) * 0.75,
            child: userInfoBlock(user, context)),
      ),
    );
  }

  Container userInfoBlock(user_model.User user, BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              child: Text(user.about,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'RaleWay',
                    fontFamilyFallback: <String>[
                      'Noto Sans CJK SC',
                      'Noto Color Emoji',
                    ],
                    color: ui.Color.fromARGB(255, 2, 70, 97),
                  ),
                  textAlign: ui.TextAlign.justify,
                  softWrap: true),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            if (user.address != "") ...[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.location_pin,
                    color: ui.Color.fromARGB(255, 2, 70, 97)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      user.address,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'RaleWay',
                        fontFamilyFallback: <String>[
                          'Noto Sans CJK SC',
                          'Noto Color Emoji',
                        ],
                        color: ui.Color.fromARGB(255, 2, 70, 97),
                      ),
                      textAlign: ui.TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                )
              ]),
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            if (user.phoneNumber != "") ...[
              SizedBox(
                child: Center(
                  child: SizedBox(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call,
                              color: ui.Color.fromARGB(255, 2, 70, 97)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                user.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'RaleWay',
                                  fontFamilyFallback: <String>[
                                    'Noto Sans CJK SC',
                                    'Noto Color Emoji',
                                  ],
                                  color: ui.Color.fromARGB(255, 2, 70, 97),
                                ),
                                textAlign: ui.TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          )
                        ]),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
            ],
            if (user.public) ...[
              Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.topLeft,
                  child: CustomText(data: 'Your profile is public')),
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }

  Container userInfoSection(String s) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Text(
        s,
        style: const TextStyle(fontSize: 18),
        textAlign: ui.TextAlign.justify,
        overflow: TextOverflow.ellipsis,
        maxLines: 4,
        softWrap: false,
      ),
    );
  }

  Future getImageUrl() async {
    var downloadUrl = "";
    //Check Permissions
    PermissionStatus permissionStatus;
    if (Platform.isIOS) {
      await Permission.photos.request();
      await Permission.storage.request();

      permissionStatus = await Permission.storage.status;
      print(permissionStatus);
      if (permissionStatus.isGranted) {
        //Select Image
        downloadUrl = await getDownloadUrl();
      } else {
        await _requestPermission();

        print('Grant Permissions and try again');
      }
    } else {
      downloadUrl = await getDownloadUrl();
    }
    return downloadUrl;
  }

  getDownloadUrl() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    XFile? image;
    var downloadUrl = "";
    image = await _picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
    // getImage(source: );
    var file = File(image!.path);
    print('about file');
    print(image.readAsBytes());

    if (image != null) {
      //Upload to Firebase
      var snapshot =
          await _storage.ref().child('avatars/${file.path}').putFile(file);

      // .onComplete;

      downloadUrl = await snapshot.ref.getDownloadURL();
    } else {
      print('No Path Received');
    }
    return downloadUrl;
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    // _toastInfo(info);
  }

  PopupMenuEntry<MenuItem> menuBuilder(MenuItem item) {
    return PopupMenuItem(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: ui.Color.fromARGB(255, 2, 70, 97),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              item.text,
              style: TextStyle(
                color: ui.Color.fromARGB(255, 2, 70, 97),
              ),
            ),
          ],
        ));
  }

  _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  Future<void> _deleteUser(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final String? email = firebaseAuth.currentUser!.email;
    final String uid = firebaseAuth.currentUser!.uid;

    // final CollectionReference userCollection =
    //     FirebaseFirestore.instance.collection('users');

    // final snackBar = SnackBar(
    //   content: Text('Initializing account deletion...'),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Navigator.pop(context);
    // try {
    //   await firebaseAuth.signOut();
    // } catch (e) {
    //   unawaited(showExceptionAlertDialog(
    //     context: context,
    //     title: Strings.logoutFailed,
    //     exception: e,
    //   ));
    // }

    // await firebaseAuth.currentUser?.delete();
    // await userCollection.doc(uid).delete();

    final result =
        await FirebaseFunctions.instance.httpsCallable('addMessage').call();

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('deleteUser')
          .call({"userEmail": email.toString()});
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
    }

    // debugPrint(email);
    // debugPrint(uid);
  }
}
