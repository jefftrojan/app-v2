import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Product extends Equatable {
  Product({
    required this.id,
    required this.name,
    required this.seller,
    this.description = "",
    this.token = "",
    required this.points,
    required this.price,
  });
  final String id;
  final String name;
  String token;
  final int points;
  String description;
  String seller;
  double price;

  @override
  List<Object> get props => [id, name, token];

  @override
  bool get stringify => true;

  factory Product.fromMap(Map<String, dynamic>? data, String documentId) {
    // print(data!["name"]);
    // print('object');
    if (data == null) {
      throw StateError('missing data for productId: $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for productId: $documentId');
    }
    final token = data['token'] as String;
    final description = data['description'] as String;
    final price = data['price'] as double;
    final points = data['points'] as int;
    final seller = data["seller"] as String;

    return Product(
      id: documentId,
      name: name,
      seller: seller,
      description: description,
      price: price,
      token: token,
      points: points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'description': description,
      'price': price,
      'points': points,
      'seller': seller,
    };
  }

  void encrypt() {
    String payload =
        '{"name": "$name", "points": "$points", "id": "$id", "price": "$price" }';
    final encrypter = getEncrypter();
    final iv = IV.fromLength(16);

    token = encrypter.encrypt(payload, iv: iv).base64;
  }

  static decrypt(String token) {
    final encrypter = getEncrypter();
    final iv = IV.fromLength(16);

    try {
      String decrypted = encrypter.decrypt(Encrypted.fromBase64(token), iv: iv);
      // print(decrypted);
      return toJson(decrypted);
    } catch (e) {
      return null;
    }
  }

  static Encrypter getEncrypter() {
    var key = Key.fromUtf8("key secret that must be 32 bits.");

    final encrypter = Encrypter(AES(key));
    return encrypter;
  }

  static toJson(String decrypted) {
    // print(decrypted);

    var jsonified = jsonDecode(decrypted);
    // print(jsonified);
    return jsonified;
  }
}
