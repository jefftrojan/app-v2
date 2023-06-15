import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class User extends Equatable {
  User(
      {required this.id,
      required this.email,
      required this.avatar,
      required this.name,
      required this.seller,
      required this.approver,
      this.phoneNumber = "",
      this.username = "",
      this.address = "",
      this.about = "",
      this.public = false,
      this.currentPoints = 0,
      this.earnedPoints = 0,
      this.pendingPoints = 0,
      this.recycledBottles = 0});
  final String id;
  final String email;
  final String avatar;
  final bool seller;
  final bool approver;
  String name;
  String phoneNumber;
  String username;
  String address;
  String about;
  bool public;
  int currentPoints;
  int earnedPoints;
  int pendingPoints;
  int recycledBottles;

  @override
  List<Object> get props => [id, name, email];

  @override
  bool get stringify => true;

  factory User.fromMap(Map<String, dynamic>? data, String documentId) {
    // print(data!["name"]);
    // print('object');
    if (data == null) {
      throw StateError('missing data for userId: $documentId');
    }
    final name = data['name'] as String?;
    if (name == null) {
      throw StateError('missing name for userId: $documentId');
    }
    final email = data['email'] as String;
    final avatar = data['avatar'] as String;
    final phoneNumber = data['phoneNumber'] as String;
    final address = data['address'] as String;
    final about = data['about'] as String;
    final username = data['username'] as String;
    final recycledBottles = data['recycledBottles'] as int;
    final pendingPoints = data['pendingPoints'] as int;
    final earnedPoints = data['earnedPoints'] as int;
    final currentPoints = data['currentPoints'] as int;
    final seller = data["seller"] as bool;
    final approver = data["approver"] as bool;
    final public = data["public"] as bool;
    return User(
      id: documentId,
      name: name,
      email: email,
      seller: seller,
      avatar: avatar,
      phoneNumber: phoneNumber,
      address: address,
      username: username,
      about: about,
      currentPoints: currentPoints,
      earnedPoints: earnedPoints,
      pendingPoints: pendingPoints,
      approver: approver,
      recycledBottles: recycledBottles,
      public: public,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'address': address,
      'avatar': avatar,
      'about': about,
      'phoneNumber': phoneNumber,
      'earnedPoints': earnedPoints,
      'currentPoints': currentPoints,
      'recycledBottles': recycledBottles,
      'seller': seller,
      'pendingPoints': pendingPoints,
      'approver': approver,
      'public': public,
    };
  }
}
