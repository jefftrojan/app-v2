import 'dart:async';

import 'package:app/src/home/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../services/firestore_database.dart';
import '../models/product.dart';
import '../models/user.dart' as user_model;
import '../top_level_providers.dart';

final userStreamProvider =
    StreamProvider.autoDispose.family<user_model.User, String>((ref, userId) {
  final database = ref.watch(databaseProvider)!;
  return database.userStream(userId: userId);
});

final productStreamProvider =
    StreamProvider.autoDispose.family<Product, String>((ref, pid) {
  final database = ref.watch(databaseProvider)!;
  return database.productStream(productId: pid);
});

class Charge extends ConsumerWidget {
  final data;
  final user;

  Charge({required this.data, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: Container(child: spendPoints(context, ref, data)),
    );
  }

  Widget spendPoints(BuildContext context, WidgetRef ref, data) {
    final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
    final firebaseAuth = ref.watch(firebaseAuthProvider);

    var item = ref.watch(productStreamProvider(data["id"]));

    return item.when(
      data: (product) {
        try {
          _spend(context, ref, user, product);
          creditSeller(product);
          return Center(
            child: Text(
              "You've successfully spend ${product.points} shebas on ${product.name}",
              textAlign: TextAlign.center,
            ),
          );
        } catch (e) {
          return Center(
            child: Text("Something Went wrong. Please try again. $e"),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, es) => Center(
        child: Text("Something Went wrong. Please try again. $e"),
      ),
    );
  }

  Future<void> _spend(BuildContext context, WidgetRef ref, user_model.User user,
      Product product) async {
    try {
      var userRef = FirebaseFirestore.instance.collection('users').doc(user.id);

      await userRef
          .update({"currentPoints": FieldValue.increment(-(product.points))});
      const Text("Success");
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: 'Operation failed',
        exception: e,
      ));
    }
  }
}

creditSeller(Product product) async {
  var sellerRef =
      FirebaseFirestore.instance.collection('users').doc(product.seller);

  await sellerRef
      .update({"currentPoints": FieldValue.increment(product.points)});
}
