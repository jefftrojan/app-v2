
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Stat extends Equatable {
  Stat({
    required this.id,
    required this.points,
    required this.total_users,
    required this.recycled_items,
    required this.approved_items,
  });
  final String id;
  final int points;
  final int total_users;
  final int recycled_items;
  final int approved_items;

  @override
  List<Object> get props =>
      [id, points, total_users, recycled_items, approved_items];

  @override
  bool get stringify => true;

  factory Stat.fromMap(Map<String, dynamic>? data, String documentId) {
    // print(data!["name"]);
    // print('object');
    if (data == null) {
      throw StateError('missing data for statId: $documentId');
    }
    print(data);
    final recycled_items = data['recycled_items'] as int;
    final approved_items = data['approved_items'] as int;
    final points = data['points'] as int;
    final total_users = data["total_users"] as int;
    return Stat(
      id: documentId,
      points: points,
      approved_items: approved_items,
      recycled_items: recycled_items,
      total_users: total_users,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'approved_items': approved_items,
      'recycled_itemse': recycled_items,
      'points': points,
      'total_users': total_users,
    };
  }
}
