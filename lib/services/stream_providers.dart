import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/models/articles.dart';
import '../src/models/product.dart';
import '../src/models/recyclable.dart';
import '../src/models/stats.dart';
import '../src/models/user.dart' as user_model;
import '../src/top_level_providers.dart';

final userStreamProvider =
    StreamProvider.autoDispose.family<user_model.User, String>((ref, userId) {
  final database = ref.watch(databaseProvider)!;
  return database.userStream(userId: userId);
});

final usersStreamProvider =
    StreamProvider.autoDispose<List<user_model.User>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.topUsersStream();
});

final productsBySellerStreamProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.productsBySellerStream();
});

final recyclablessBySellerStreamProvider =
    StreamProvider.autoDispose<List<Recyclable>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.recyclablesBySellerStream();
});

final statStreamProvider =
    StreamProvider.autoDispose.family<Stat, String>((ref, statId) {
  final database = ref.watch(databaseProvider)!;
  return database.statStream(statId: statId);
});

final articlesStreamProvider = StreamProvider.autoDispose<List<Article>>((ref) {
  final database = ref.watch(databaseProvider)!;
  return database.articlesStream();
});
