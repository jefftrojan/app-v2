import 'dart:async';
import 'dart:convert';

import 'package:app/src/account/account_page.dart';
import 'package:app/src/home/contact_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../common_widgets/appbars.dart';
import '../../common_widgets/avatar.dart';
import '../../common_widgets/texts.dart';
import '../../constants/strings.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../services/sizes.dart';
import '../../services/stream_providers.dart';
import '../top_level_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: plainAppBar("Settings"), body: SettingsBody());
  }
}

class SettingsBody extends ConsumerWidget {
  const SettingsBody({
    Key? key,
  }) : super(key: key);
  Future<void> _signOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }

  Future<void> _confirmSignOut(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context, firebaseAuth);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final user = ref.watch(userStreamProvider(firebaseAuth.currentUser!.uid));
    print(firebaseAuth.currentUser!.displayName);
    return user.when(
        data: (user) {
          return Center(
            child: Container(
              width: width(context) > 600 ? 600 : width(context),
              padding: EdgeInsets.all(height(context) * 0.012),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: height(context) * 0.1,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AccountPage()));
                                      },
                                      child: Row(
                                        children: [
                                          Avatar(
                                            photoUrl: user.avatar != ""
                                                ? user.avatar
                                                : "https://firebasestorage.googleapis.com/v0/b/shebaplastic-e2364.appspot.com/o/avatars%2Favatar_image.png?alt=media&token=3c0cde21-7175-483a-b105-b36848550ce0",
                                            radius: height(context) * 0.045,
                                            borderColor: Colors.white,
                                            borderWidth: 1.0,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                data: user.name,
                                                fontSize:
                                                    height(context) * 0.02,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CustomText(
                                                    data:
                                                        '${user.currentPoints}',
                                                    fontSize:
                                                        height(context) * 0.02,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  CustomText(
                                                    data: 'Shebas',
                                                    fontSize:
                                                        height(context) * 0.015,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CustomText(
                                                    data:
                                                        '${user.pendingPoints}',
                                                    fontSize:
                                                        height(context) * 0.02,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  CustomText(
                                                    data: 'Pending Shebas',
                                                    fontSize:
                                                        height(context) * 0.015,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(),
                            ]),
                      ),
                      Divider(),
                      SizedBox(
                        height: height(context) * 0.02,
                      ),
                      Container(
                        height: height(context) * 0.8,
                        child: ListView(
                          children: [
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AccountPage()));
                              },
                              leading: Icon(Icons.account_circle_outlined),
                              title: Text("My Profile"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            ListTile(
                              onTap: () async {
                                {
                                  const url = "https://shebaplastic.com/";
                                  await _launchURL(url);
                                }
                              },
                              leading: Icon(Icons.info_outline),
                              title: Text("About Sheba"),
                              trailing: Icon(Icons.open_in_browser),
                            ),
                            ListTile(
                              onTap: (() async {
                                const url =
                                    "https://sites.google.com/view/shebaplastic/privacy";

                                await _launchURL(url);
                              }),
                              leading: Icon(Icons.privacy_tip_outlined),
                              title: Text("Privacy Policy"),
                              trailing: Icon(Icons.open_in_browser),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ContactSupport()));
                              },
                              leading: Icon(Icons.contact_support_outlined),
                              title: Text("Contact Support"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            ListTile(
                              onTap: () {
                                _confirmDeleteAccount(context, firebaseAuth);
                              },
                              leading: Icon(Icons.delete_forever),
                              title: Text("Account Deletion"),
                              trailing: Icon(Icons.navigate_next),
                            ),
                            Divider(),
                            Container(
                              padding: EdgeInsets.all(height(context) * 0.05),
                              alignment: Alignment.bottomCenter,
                              child: Center(
                                child: InkWell(
                                  onTap: () {
                                    _confirmSignOut(context, firebaseAuth);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        data: 'Logout',
                                        fontSize: 18,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.logout),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text("Something went wrong. Please try again."),
            ));
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestDeleteAccount = await showAlertDialog(
          context: context,
          title: "Delete My Account",
          content:
              "Are you sure you want to delete your account? All your data will be lost including your Shebas and pending Shebas. This action cannot be undone!",
          cancelActionText: Strings.cancel,
          defaultActionText: "Delete",
        ) ??
        false;
    if (didRequestDeleteAccount == true) {
      await _deleteUser(context, firebaseAuth);
    }
  }

  Future<void> _deleteUser(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final String? email = firebaseAuth.currentUser!.email;
    final String uid = firebaseAuth.currentUser!.uid;
    final String? name = firebaseAuth.currentUser!.displayName;

    // final CollectionReference userCollection =
    //     FirebaseFirestore.instance.collection('users');

    final snackBar = await SnackBar(
      content: Text(
          'Initializing account deletion. We will let you know via email once this is done.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // sleep(Duration(seconds: 3));
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        await firebaseAuth.signOut();
      } catch (e) {
        unawaited(showExceptionAlertDialog(
          context: context,
          title: "Something went wrong!",
          exception: e,
        ));
      }

      var dataString = '''
    {
      "userEmail" : "$email"
    }
    ''';
      final url = Uri.parse(
          "https://us-central1-shebaplastic-e2364.cloudfunctions.net/deleteUser");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'uid': uid}),
      );

      print(response.body);
      print(response.statusCode);

      // if (response.statusCode == 200) {
      //   mailUser(email, name);
      // }
    });

    // try {
    //   await firebaseAuth.signOut();
    // } catch (e) {
    //   unawaited(showExceptionAlertDialog(
    //     context: context,
    //     title: "Something went wrong!",
    //     exception: e,
    //   ));
    // }

    // var dataString = '''
    // {
    //   "userEmail" : "$email"
    // }
    // ''';
    // final url = Uri.parse(
    //     "https://us-central1-shebaplastic-e2364.cloudfunctions.net/deleteUser");

    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode({'uid': uid}),
    // );

    // print(response.body);

    // if (response.statusCode == 200) {
    //   mailUser(email, firebaseAuth.currentUser!.displayName);
    // }

    // final decodedJson = jsonDecode(dataString);
    // print(decodedJson);

    // try {
    //   final result = await FirebaseFunctions.instance
    //       .httpsCallable('deleteUser')
    //       .call(decodedJson);
    // } on FirebaseFunctionsException catch (error) {
    //   print('error');
    //   print(error.code);
    //   print(error.details);
    //   print(error.message);
    // }

    debugPrint(email);
    debugPrint(uid);
  }

  Future<void> mailUser(String? email, String? displayName) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': 'service_zyqt2jh',
          'template_id': 'template_nmzwq3e',
          'user_id': 'D26p8Ucq2ztAEt54a',
          'accessToken': 'T4ir0m-BWMp1YlePAcUMd',
          'template_params': {
            'to_name': displayName,
            'email': email,
          }
        }));

    print(response.body);
  }
}

_launchURL(url) async {
  if (!await launch(url)) throw 'Could not launch $url';
}
