
import 'package:app/routing/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../common_widgets/appbars.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../home/base.dart';
import '../models/recyclable.dart';
import '../models/user.dart' as user_model;
import '../top_level_providers.dart';

final recyclableStreamProvider =
    StreamProvider.autoDispose.family<Recyclable, String>((ref, id) {
  final database = ref.watch(databaseProvider)!;
  return database.recyclableStream(recyclableId: id);
});

class RecyclableApproval extends StatefulWidget {
  final user_model.User user;
  RecyclableApproval({Key? key, required this.user}) : super(key: key);

  @override
  State<RecyclableApproval> createState() => _RecyclableApprovalState();
}

class _RecyclableApprovalState extends State<RecyclableApproval> {
  bool scanned = false;
  String? _code;
  bool isLoading = false;
  late bool validToken = true;
  Barcode? barcode;
  BarcodeCapture? capture;
Future<void> onDetect(BarcodeCapture barcode) async {
    capture = barcode;
    setState(() => this.barcode = barcode.barcodes.first);
  }

  @override
  void initState() {
    super.initState();
    scanned = false;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: plainAppBar("Approve"),
      body: Center(
        child: SizedBox(
          height: 500,
          child: Column(
            children: [
              SizedBox(
                height: 300,
                width: 300,
                child: MobileScanner(onDetect: onDetect
                // (barcode, args) async {
                //   if (_code != barcode.rawValue) {
                //     setState(() {
                //       _code = barcode.rawValue;
                //     });

                //     debugPrint('Barcode found! $_code');
                //     var data = Recyclable.decrypt(_code!);
                //     if (data == null) {
                //       setState(() {
                //         validToken = false;
                //       });
                //     } else {
                //       var approveRecyclable =
                //           await _approveRecyclable(context, data);

                //       if (approveRecyclable) {
                //         Navigator.popAndPushNamed(
                //             context, AppRoutes.approveRecyclableProcessing,
                //             arguments: [data, context]);
                //       } else {
                //         Navigator.pop(context);
                //       }
                //     }
                //   }
                // }
                ),
              ),
              const Spacer(),
              validToken
                  ? const Center(child: CircularProgressIndicator())
                  : invalidToken("Could not verify the item scanned")
            ],
          ),
        ),
      ),
    );
  }
}

Center invalidToken(String message) {
  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(message),
    ]),
  );
}

class Processing extends StatelessWidget {
  final data;
  const Processing({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widg = approvePoints(data[0]);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Processing"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (parent) => Base()),
                      ModalRoute.withName("/homepage"));
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ))
          ],
        ),
        body: Container(
            child: FutureBuilder<Map<String, String>>(
          future: widg,
          builder: (context, snapshot) {
            var res = snapshot.data!.entries.first;
            var response = res.key;
            var message = res.value;
            switch (response) {
              case "loading":
                return const Center(child: CircularProgressIndicator());
              default:
                return Center(
                    child: Text(
                  message,
                  textAlign: TextAlign.center,
                ));
            }
          },
          initialData: const {"loading": "loading"},
        )
            //  Center(child: approvePoints(data, firebaseAuth, ref, context)),
            ));
  }

  Future<Map<String, String>> approvePoints(data) async {
    var item =
        FirebaseFirestore.instance.collection('recyclables').doc(data["id"]);
    return item.get().then((value) async {
      var recyclable = Recyclable.fromMap(value.data(), item.id);

      try {
        if (recyclable.approved) {
          return {"exist": "This item has already been approved"};
        } else {
          if (recyclable.recycled) {
            if (recyclable.recycler == "") {
              return {"error": "Something Went wrong. Please try again."};
            }
            approveWithRecycler(recyclable);
            await incrementItems(recyclable.points);
            return {
              "success": "Item approved successfully and credited the recycler"
            };
          } else {
            approveWithNoRecycler(recyclable);
            await incrementItems(recyclable.points);

            return {"success": "Item approved successfully with no recycler"};
          }
        }
      } catch (e) {
        print(e);
        return {"error": "Something Went wrong. Please try again. "};
      }
    }).catchError(
        (onError) => {"error": "Something Went wrong. Please try again."});
  }

  void approveWithNoRecycler(Recyclable recyclable) async {
    var itemRef =
        FirebaseFirestore.instance.collection('recyclables').doc(recyclable.id);
    await itemRef.update({"recycled": true, "approved": true});
  }

  void approveWithRecycler(Recyclable recyclable) async {
    var itemRef =
        FirebaseFirestore.instance.collection('recyclables').doc(recyclable.id);
    await itemRef.update({"approved": true});
    var userRef =
        FirebaseFirestore.instance.collection('users').doc(recyclable.recycler);
    await userRef.update({
      "earnedPoints": FieldValue.increment(recyclable.points),
      "currentPoints": FieldValue.increment(recyclable.points),
      "pendingPoints": FieldValue.increment(-recyclable.points),
      "recycledBottles": FieldValue.increment(1)
    });
  }

  incrementItems(points) async {
    await FirebaseFirestore.instance
        .collection('stats')
        .doc('stats1')
        .update({'approved_items': FieldValue.increment(1)});
    await FirebaseFirestore.instance
        .collection('stats')
        .doc('stats1')
        .update({'points': FieldValue.increment(points)});
  }
}

Future<bool> _approveRecyclable(BuildContext context, data) async {
  final bool didRequestSpend = await showAlertDialog(
        context: context,
        title: "Confirm",
        content:
            "Approve this product ${data['name']} for ${data['points']} shebas",
        cancelActionText: "Cancel",
        defaultActionText: "Approve",
      ) ??
      false;
  if (didRequestSpend == true) {
    return true;
  } else {
    return false;
  }
}
