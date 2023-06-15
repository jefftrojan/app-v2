import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Recyclable extends Equatable {
  Recyclable({
    required this.id,
    required this.name,
    this.token = "",
    this.recycled = false,
    this.approved = false,
    required this.points,
    required this.creator,
    this.recycler = "",
  });
  final String id;
  final String name;
  String token;
  final int points;
  bool recycled;
  bool approved;
  String creator;
  String recycler;

  @override
  List<Object> get props => [id, name, token];

  @override
  bool get stringify => true;

  factory Recyclable.fromMap(Map<String, dynamic>? data, String documentId) {
    // print(data!["name"]);
    // print('object');
    if (data == null) {
      throw StateError('missing data for recyclableId: $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for recyclableId: $documentId');
    }
    final token = data['token'] as String;
    final recycled = data['recycled'] as bool;
    final approved = data['approved'] as bool;
    final points = data['points'] as int;
    final creator = data["creator"] as String;
    final recycler = data["recycler"] as String;
    return Recyclable(
      id: documentId,
      name: name,
      recycled: recycled,
      approved: approved,
      token: token,
      points: points,
      creator: creator,
      recycler: recycler,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'token': token,
      'approved': approved,
      'recycled': recycled,
      'points': points,
      'creator': creator,
      'recycler': recycler,
    };
  }

  encrypt() {
    String payload = '{"name": "$name", "points": "$points", "id": "$id"}';
    // print(payload);

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
    var key = Key.fromUtf8("secret key that must be 32 bits.");

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
