import 'package:app/src/models/user.dart' as user_model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print("Sign in aborded by user");
        }
        return;
      }
      _user = googleUser;
    } catch (e, es) {
      if (kDebugMode) {
        print("Error signing in with google $e $es");
      }
      return;
    }

    final googleAuth = await _user!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    var newUser = false;
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      if (value.additionalUserInfo!.isNewUser) newUser = true;
      // print('Successfully signed in with Google!');
    }).catchError((onError) {
      print('Error signing in with Google $onError');
    });

    var userInstance = FirebaseAuth.instance.currentUser;
    // var docRef =
    //     FirebaseFirestore.instance.collection("users").doc(userInstance?.uid);
    // userInstance!.metadata.creationTime == userInstance.metadata.lastSignInTime
    //     ? print('new user ')
    //     :
    //     // doc.data() will be undefined in this case
    //     print('not new user');
    // print(userInstance!.metadata.creationTime);
    // print(userInstance.metadata.lastSignInTime);

    // var firestoreUser = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userInstance?.uid);

    // print(firestoreUser);
    if (newUser) {
      var userObject = user_model.User(
          id: userInstance!.uid,
          avatar: userInstance.photoURL ?? '',
          email: userInstance.email ?? '',
          name: userInstance.displayName ?? '',
          seller: false,
          approver: false);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userInstance.uid)
          .set(userObject.toMap());
      await FirebaseFirestore.instance
          .collection('stats')
          .doc('stats1')
          .update({'total_users': FieldValue.increment(1)});
    }
    // print(user);
    if (kDebugMode) {
      print(FirebaseAuth.instance.currentUser?.uid);
    }
    // notifyListeners();
  }
}
