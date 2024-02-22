class APIPath {
  static String profile(String uid) => 'users/$uid/';
  static String users() => 'users/';

  static String storeProfile(String uid) => 'stores/$uid/';
  static String stores() => 'stores/';
  static String storeCategories() => 'store_categories/';
  static String storeCategory(String value) => 'store_categories/$value';

  // Storage
  static String storePhotos(String uid) => "$uid/store/";
}
