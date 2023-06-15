import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'google_sign_in.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Login",
        theme: ThemeData.dark().copyWith(
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.green)),
        home: const LoginView(),
      ));
}

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  // const ({ Key? key }) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final provider =
            Provider.of<GoogleSignInProvider>(context, listen: false);
        provider.googleLogin();
      },
      icon: const FaIcon(FontAwesomeIcons.google),
      label: const Text("Continue with Google"),
    );
  }
}
