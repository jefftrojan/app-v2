import 'dart:async';

import 'package:app/services/firestore_path.dart';
import 'package:app/src/models/articles.dart';
import 'package:app/src/models/product.dart';
import 'package:app/src/models/recyclable.dart';
import 'package:app/src/models/stats.dart';
import 'package:app/src/models/user.dart';

import '../custom_widgets/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({required this.uid});
  final String uid;

  final _service = FirestoreService.instance;

  Future<void> setCurrentUser(User user) => _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
      );
  Future<void> setUser(User user, String uid) => _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
      );

  Stream<User> userStream({required String userId}) => _service.documentStream(
        path: FirestorePath.user(userId),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<User>> usersStream() => _service.collectionStream(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<User>> topUsersStream() => _service.collectionStream(
        // sort: (user, _) => user.currentPoints,
        queryBuilder: (query) => query
            .where('seller', isEqualTo: false)
            .where('approver', isEqualTo: false)
            .where('public', isEqualTo: true)
            .orderBy('currentPoints', descending: true)
            .limit(10),
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Future<void> setProduct(String id, Product product) => _service.setData(
        path: FirestorePath.product(id),
        data: product.toMap(),
      );

  Stream<Product> productStream({required String productId}) =>
      _service.documentStream(
        path: FirestorePath.product(productId),
        builder: (data, documentId) => Product.fromMap(data, documentId),
      );

  Stream<List<Product>> productsStream() => _service.collectionStream(
        path: FirestorePath.products(),
        builder: (data, documentId) => Product.fromMap(data, documentId),
      );

  Stream<List<Product>> productsBySellerStream() => _service.collectionStream(
        queryBuilder: (query) => query.where('seller', isEqualTo: uid),
        path: FirestorePath.products(),
        builder: (data, documentId) => Product.fromMap(data, documentId),
      );

  deleteProduct(Product product) {
    _service.deleteData(path: FirestorePath.product(product.id));
  }

  Future<void> setRecyclable(String id, Recyclable recyclable) =>
      _service.setData(
        path: FirestorePath.recyclable(id),
        data: recyclable.toMap(),
      );

  Stream<Recyclable> recyclableStream({required String recyclableId}) =>
      _service.documentStream(
        path: FirestorePath.recyclable(recyclableId),
        builder: (data, documentId) => Recyclable.fromMap(data, documentId),
      );

  Stream<List<Recyclable>> recyclablesStream() => _service.collectionStream(
        path: FirestorePath.recyclables(),
        builder: (data, documentId) => Recyclable.fromMap(data, documentId),
      );

  Stream<List<Recyclable>> recyclablesBySellerStream() =>
      _service.collectionStream(
        queryBuilder: (query) => query.where('creator', isEqualTo: uid),
        path: FirestorePath.recyclables(),
        builder: (data, documentId) => Recyclable.fromMap(data, documentId),
      );

  deleteRecyclable(Recyclable recyclable) {
    _service.deleteData(path: FirestorePath.recyclable(recyclable.id));
  }

  Stream<Stat> statStream({required String statId}) => _service.documentStream(
        path: FirestorePath.stat(statId),
        builder: (data, documentId) => Stat.fromMap(data, documentId),
      );

  Stream<List<Article>> articlesStream() => _service.collectionStream(
        path: FirestorePath.articles(),
        builder: (data, documentId) => Article.fromMap(data, documentId),
      );
}
