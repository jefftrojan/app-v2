import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:app/src/models/user.dart' as user_model;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<User> signInWithApple(
      {List<Scope> scopes = const [Scope.email, Scope.fullName]}) async {
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        var newUser = false;
        var firebaseUser;
        await _firebaseAuth.signInWithCredential(credential).then((value) {
          if (value.additionalUserInfo!.isNewUser) newUser = true;
          firebaseUser = value.user;

          print('Successfully signed in with Apple!');
        }).catchError((onError) {
          print('Error signing in with Apple $onError');
        });
        // final firebaseUser = userCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        var userInstance = FirebaseAuth.instance.currentUser;

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
        } else {
          print('returning user');
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }
}
