import 'dart:async';

import 'package:app/src/product/processing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../common_widgets/appbars.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../models/product.dart';
import '../top_level_providers.dart';

final productStreamProvider =
    StreamProvider.autoDispose.family<Product, String>((ref, id) {
  final database = ref.watch(databaseProvider)!;
  return database.productStream(productId: id);
});

class ProductScanner extends ConsumerStatefulWidget {
  ProductScanner({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductScanner> createState() => _ProductScannerState();
}

class _ProductScannerState extends ConsumerState<ProductScanner> {
  late bool validToken = true;
  String? _code = "";
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
              appBar: plainAppBar("Pay"),
              body: Center(
                child: SizedBox(
                  height: 500,
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            (MediaQuery.of(context).size.height * 0.35 < 350)
                                ? MediaQuery.of(context).size.height * 0.35
                                : 400,
                        width: (MediaQuery.of(context).size.height * 0.35 < 350)
                            ? MediaQuery.of(context).size.height * 0.35
                            : 400,
                        child: MobileScanner(onDetect: 
                        onDetect
                        // (barcode, args) async {
                        //   if (_code != barcode.rawValue) {
                        //     setState(() {
                        //       _code = barcode.rawValue;
                        //     });
                        //     debugPrint('Barcode found! $_code');

                        //     var data = Product.decrypt(_code!);

                        //     if (data == null) {
                        //       setState(() {
                        //         validToken = false;
                        //       });
                        //     } else {
                        //       print(data);
                        //       if (int.parse(data["points"]) >
                        //           user.currentPoints) {
                        //         WidgetsBinding.instance
                        //             .addPostFrameCallback((_) {
                        //           unawaited(showExceptionAlertDialog(
                        //             context: context,
                        //             title: 'Insufficient funds',
                        //             exception:
                        //                 "You do not have enough shebas to complete this transaction",
                        //           ));
                        //         });
                        //       } else {
                        //         var confirmedSpending =
                        //             await _confirmSpend(data);
                        //         print(confirmedSpending);
                        //         if (confirmedSpending!) {
                        //           Navigator.of(context).pushAndRemoveUntil(
                        //               MaterialPageRoute(
                        //                   builder: (parent) =>
                        //                       Charge(data: data, user: user)),
                        //               ModalRoute.withName("/account-page"));
                        //         }
                        //       }
                        //     }
                        //   }
                        // }
                        ),
                      ),
                      Spacer(),
                      validToken
                          ? const Center(child: CircularProgressIndicator())
                          : invalidToken(context, user.id,
                              "Could not verify the item scanned")
                    ],
                  ),
                ),
              ));
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text("Something went wrong. Please try again."),
            ));
  }

  Future<bool?> _confirmSpend(data) async {
    final bool didRequestSpend = await showAlertDialog(
          context: context,
          title: "Confirm",
          content:
              "You are about to spend ${data['points']} shebas on this item",
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
}

Center invalidToken(BuildContext context, String uid, String message) {
  return Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(message),
    ]),
  );
}
