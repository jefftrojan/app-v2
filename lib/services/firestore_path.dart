class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
  static String product(String productId) => 'products/$productId';
  static String products() => 'products';
  static String recyclable(String recyclableId) => 'recyclables/$recyclableId';
  static String recyclables() => 'recyclables';
  static String stats() => 'stats';
  static String stat(String statId) => 'stats/$statId';
  static String articles() => 'articles';
  static String article(String articleId) => 'articles/$articleId';
}
