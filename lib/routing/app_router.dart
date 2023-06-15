import 'package:app/src/home/base.dart';
import 'package:app/src/models/product.dart';
import 'package:app/src/models/user.dart' as user_model;
import 'package:app/src/product/processing.dart';
import 'package:app/src/recyclable/approve.dart';
import 'package:app/src/sign_in/sign_in_page.dart';
import 'package:app/src/sign_in_ui/email_password_sign_in_page.dart';
// import 'package:email_password_sign_in_ui/email_password_sign_in_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../src/account/edit_user_info.dart';
import '../src/models/recyclable.dart';
import '../src/product/new.dart';
import '../src/recyclable/approve.dart' as approve_recyclable;
import '../src/recyclable/new.dart';

class AppRoutes {
  static const emailPasswordSignInPage = '/email-password-sign-in-page';
  static const signInPage = '/sign-in-page';
  static const editUserPage = '/edit-user-page';
  static const editRecyclablePage = '/edit-recyclable-page';
  static const editProductPage = '/edit-product-page';
  static const entryPage = '/entry-page';
  static const accountPage = '/account-page';
  static const productProcessing = '/product-processing-page';
  static const approveRecyclable = '/approve-recyclable';
  static const approveRecyclableProcessing = '/approve-recyclable-processing';
  static const base = 'homepage';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(
      RouteSettings settings, FirebaseAuth firebaseAuth) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EmailPasswordSignInPage.withFirebaseAuth(firebaseAuth,
              onSignedIn: args as void Function()),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.editUserPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditUserPage(user: args as user_model.User?),
          settings: settings,
          fullscreenDialog: true,
        );

      case AppRoutes.editRecyclablePage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditRecyclablePage(
            recyclable: args as Recyclable?,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.editProductPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => EditProductPage(
            product: args as Product?,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.productProcessing:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Charge(
            user: args as user_model.User,
            data: args as Map<String, dynamic>?,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.signInPage:
        return MaterialPageRoute<dynamic>(
          builder: (_) => SignInPage(),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.approveRecyclable:
        return MaterialPageRoute<dynamic>(
          builder: (_) => RecyclableApproval(
            user: args as user_model.User,
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.approveRecyclableProcessing:
        return MaterialPageRoute<dynamic>(
          builder: (_) => approve_recyclable.Processing(data: args),
          settings: settings,
          fullscreenDialog: true,
        );
      case AppRoutes.base:
        return MaterialPageRoute<dynamic>(
          builder: (_) => Base(),
          settings: settings,
          fullscreenDialog: true,
        );
      default:
        // TODO: Throw
        return null;
    }
  }
}
