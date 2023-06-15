import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/theme_config.dart';
import '../../custom_widgets/custom_buttons/custom_buttons.dart';
import '../../services/firestore_database.dart';
import '../../services/sizes.dart';
import '../../services/stream_providers.dart';
import '../models/user.dart';
import '../top_level_providers.dart';

class SendPoints extends StatefulWidget {
  User user;

  SendPoints({Key? key, required this.user}) : super(key: key);
  @override
  _SendPointsState createState() => _SendPointsState();
}

class _SendPointsState extends State<SendPoints> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  String _id = "";
  int _points = 0;
  @override
  void initState() {
    super.initState();
    _id = "";
    _pointsController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    // print("widget.content");
    var W = MediaQuery.of(context).size.width;
    var H = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Send Shebas'),
        titleTextStyle: GoogleFonts.aBeeZee(
          fontSize: 20,
          color: ThemeConfig.lightPrimary,
        ),
        centerTitle: false,
        foregroundColor: ThemeConfig.lightPrimary,
      ),
      body: MaterialApp(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Material(
          color: Colors.white,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(height(context) * 0.01),
              width: width(context) > 600 ? 600 : width(context),
              child: SizedBox(
                width: W * 0.9,
                height: height(context) * 0.8,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: H * 0.05,
                    ),
                    TextFormField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'User id',
                        hintText: 'User Id',
                      ),
                      autocorrect: false,
                    ),
                    SizedBox(
                      height: H * 0.02,
                    ),
                    TextFormField(
                      controller: _pointsController,
                      decoration: const InputDecoration(
                        labelText: 'Shebas',
                        hintText: 'Shebas you want to send',
                      ),
                      autocorrect: false,
                    ),
                    SizedBox(
                      height: H * 0.05,
                    ),
                    CustomRaisedButton(
                      child: const Text(
                        "Continue",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      borderRadius: 10,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        setState(() {
                          _id = _idController.text;
                          _points = int.tryParse(_pointsController.text) ?? 0;
                        });
                      },
                    ),
                    const Spacer(),
                    if (_idController.text != "")
                      SizedBox(
                          height: H * 0.4,
                          child: ReceiverView(
                            h: H,
                            w: W,
                            receiver_id: _id,
                            points: _points,
                            user: widget.user,
                            parent: context,
                          )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiverView extends ConsumerWidget {
  var h;
  var w;
  String receiver_id;
  int points;
  User user;
  BuildContext parent;
  ReceiverView(
      {Key? key,
      required this.h,
      required this.w,
      required this.receiver_id,
      required this.points,
      required this.user,
      required this.parent})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (points <= 0) {
      return const Text(
        "Invalid number of shebas",
        textAlign: ui.TextAlign.center,
      );
    }
    // print(user);

    if (points > user.currentPoints) {
      return const Text(
        "You do not have enough shebas to finish this transaction",
        textAlign: ui.TextAlign.center,
      );
    }
    final database = ref.read<FirestoreDatabase?>(databaseProvider)!;

    final receiver = ref.watch(userStreamProvider(receiver_id));
    // print(receiver);
    return receiver.when(
        data: (receiver) {
          return Container(
              child: Column(
            children: [
              Text(
                "You are about send $points shebas to ${receiver.name}",
                textAlign: ui.TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: h * 0.05,
              ),
              CustomRaisedButton(
                child: Text(
                  "Continue",
                  style: GoogleFonts.aBeeZee(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                borderRadius: 10,
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  user.currentPoints -= points;
                  receiver.currentPoints += points;
                  print(receiver);
                  database.setUser(user, user.id);
                  database.setUser(receiver, receiver.id);

                  final snackBar = SnackBar(
                    content: Text(
                        'You have successfully sent $points shebas to ${receiver.name}'),
                  );

                  // sleep(const Duration(seconds: 1));

                  ScaffoldMessenger.of(parent).showSnackBar(snackBar);
                  Navigator.pop(parent);
                },
              ),
            ],
          ));
        },
        error: (_, __) {
          print(_);
          return const Text(
            "Something went wrong with the request. Please check ifyou typed the Id correctly and try again later.",
            softWrap: true,
          );
        },
        loading: () => const Center(
              child: CircularProgressIndicator(),
            ));
  }
}
