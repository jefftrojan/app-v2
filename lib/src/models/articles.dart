
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Article extends Equatable {
  Article(
      {required this.id,
      required this.headline,
      required this.body,
      required this.cover_image,
      required this.creation_time});
  final String id;
  final String headline;
  final String body;
  final String cover_image;
  final DateTime creation_time;

  @override
  List<Object> get props => [id, headline, cover_image];

  @override
  bool get stringify => true;

  factory Article.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for articleId: $documentId');
    }
    final headline = data['headline'] as String;
    final body = data['body'] as String;
    final cover_image = data['cover_image'] as String;
    final creation_time = data['creation_time'].toDate();
    return Article(
      id: documentId,
      headline: headline,
      body: body,
      cover_image: cover_image,
      creation_time: creation_time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'headline': headline,
      'body': body,
      'cover_image': cover_image,
      'creation_time': creation_time,
    };
  }
}
