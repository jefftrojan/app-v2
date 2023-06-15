import 'dart:io';
import 'dart:math';

import 'package:app/constants/keys.dart';
import 'package:app/constants/strings.dart';
import 'package:app/routing/app_router.dart';
import 'package:app/src/sign_in/google_sign_in.dart';
import 'package:app/src/sign_in/sign_in_button.dart';
import 'package:app/src/sign_in/sign_in_view_model.dart';
import 'package:app/src/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../custom_widgets/custom_buttons/custom_buttons.dart';
import 'apple_sign_in.dart';

final signInModelProvider = riverpod.ChangeNotifierProvider<SignInViewModel>(
  (ref) => SignInViewModel(auth: ref.watch(firebaseAuthProvider)),
);

class SignInPage extends riverpod.ConsumerWidget {
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final signInModel = ref.watch(signInModelProvider);
    ref.listen<SignInViewModel>(signInModelProvider, (_, model) async {
      if (model.error != null) {
        await showExceptionAlertDialog(
          context: context,
          title: Strings.signInFailed,
          exception: model.error,
        );
      }
    });
    return SignInPageContents(
      viewModel: signInModel,
      title: 'Sign In',
    );
  }
}

class SignInPageContents extends StatelessWidget {
  const SignInPageContents({Key? key, required this.viewModel, this.title = ''})
      : super(key: key);
  final SignInViewModel viewModel;
  final String title;

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key con = Key(Keys.continueWithGoogle);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      AppRoutes.emailPasswordSignInPage,
      arguments: () => navigator.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const Text(
      Strings.signIn,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 32.0),
              SizedBox(
                height: 50.0,
                child: _buildHeader(),
              ),
              const SizedBox(height: 32.0),
              SignInButton(
                key: emailPasswordButtonKey,
                text: Strings.signInWithEmailPassword,
                onPressed: viewModel.isLoading
                    ? null
                    : () => _showEmailPasswordSignInPage(context),
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
              const Text(
                Strings.or,
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ChangeNotifierProvider(
                create: (context) => GoogleSignInProvider(),
                child: GoogleSignInButton(),
              ),
              const SizedBox(height: 10),
              (Platform.isIOS)
                  ? Provider<AuthService>(
                      create: (_) => AuthService(), child: AppleSignInButton())
                  // Buttons.AppleDark, onPressed: () => authBloc.signinApple())
                  : Container(),
            ],
          ),
        );
      }),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  Future<void> _signInWithApple(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithApple();
      print('uid: ${user.uid}');
    } catch (e) {
      // TODO: Show alert here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomRaisedButton(
      color: Colors.black,
      borderRadius: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          FaIcon(
            FontAwesomeIcons.apple,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text('Continue with Apple',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
        ],
      ),
      onPressed: () => _signInWithApple(context),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomRaisedButton(
      onPressed: () {
        final provider =
            Provider.of<GoogleSignInProvider>(context, listen: false);
        provider.googleLogin();
      },
      color: Color(0xFF4285F4),
      borderRadius: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          FaIcon(
            FontAwesomeIcons.google,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text('Continue with Google',
              style: TextStyle(color: Colors.white, fontSize: 16.0)),
        ],
      ),
    );
  }
}
