import 'package:app/src/home/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../common_widgets/appbars.dart';
import '../../services/stream_providers.dart';
import '../models/recyclable.dart';
import '../models/user.dart' as user_model;
import '../top_level_providers.dart';

final recyclableStreamProvider =
    StreamProvider.autoDispose.family<Recyclable, String>((ref, id) {
  final database = ref.watch(databaseProvider)!;
  return database.recyclableStream(recyclableId: id);
});

class RecyclableScanner extends ConsumerStatefulWidget {
  RecyclableScanner({Key? key}) : super(key: key);

  @override
  ConsumerState<RecyclableScanner> createState() => _RecyclableScannerState();
}

class _RecyclableScannerState extends ConsumerState<RecyclableScanner> {
  String? _code = "";
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
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final user = ref.watch(userStreamProvider(firebaseAuth.currentUser!.uid));
    return user.when(
        data: (user) {
          return Scaffold(
            appBar: plainAppBar("Recycle"),
            body: Center(
              child: SizedBox(
                height: 500,
                child: Column(
                  children: [
                    SizedBox(
                      height: (MediaQuery.of(context).size.height * 0.35 < 350)
                          ? MediaQuery.of(context).size.height * 0.35
                          : 400,
                      width: (MediaQuery.of(context).size.height * 0.35 < 350)
                          ? MediaQuery.of(context).size.height * 0.35
                          : 400,
                      child: MobileScanner(onDetect: onDetect
                      // (barcode, args) {
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
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (parent) => Processing(
                      //                     data: data!,
                      //                     user: user,
                      //                     parent: context,
                      //                   )));
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
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text("Something went wrong. Please try again."),
            ));
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
  BuildContext parent;
  user_model.User user;
  Processing(
      {Key? key, required this.data, required this.parent, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widg = earnPoints(context, data);
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
      )),
    );
  }

  Future<Map<String, String>> earnPoints(BuildContext context, data) async {
    var item =
        FirebaseFirestore.instance.collection('recyclables').doc(data["id"]);
    var snapshot = await item.get();
    if (snapshot.exists) {
      var recyclable = Recyclable.fromMap(snapshot.data(), item.id);
      try {
        if (recyclable.recycled) {
          return {"exist": "This item is already recycled"};
        } else {
          await invalidateItem(recyclable);
          await setRecycler(recyclable, user);
          await incrementItems();
          return {
            "success":
                "You have recycled ${recyclable.name} and will earn ${recyclable.points} shebas once this product is recycled"
          };
        }
      } catch (e) {
        return {"error": "Something Went wrong. Please try again. $e"};
      }
    } else {
      return {"error": "Something Went wrong. Please try again."};
    }
  }

  setRecycler(Recyclable recyclable, user_model.User user) async {
    var itemRef =
        FirebaseFirestore.instance.collection('recyclables').doc(recyclable.id);
    await itemRef.update({"recycler": user.id});

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.id);
    await userRef.update({
      "pendingPoints": FieldValue.increment(recyclable.points),
      "recycledBottles": FieldValue.increment(1)
    });
  }

  invalidateItem(Recyclable recyclable) {
    var itemRef =
        FirebaseFirestore.instance.collection('recyclables').doc(recyclable.id);
    itemRef.update({"recycled": true});
  }

  incrementItems() async {
    await FirebaseFirestore.instance
        .collection('stats')
        .doc('stats1')
        .update({'recycled_items': FieldValue.increment(1)});
  }
}
