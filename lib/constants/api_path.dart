class APIPath {
  static String profile(String uid) => 'users/$uid/';
  static String users() => 'users/';

  static String businessProfile(String uid) => 'businesses/$uid/';
  static String businesses() => 'businesses/';
  static String businessCategories() => 'store_categories/';
  static String businessCategory(String value) => 'store_categories/$value';

  // Storage
  static String businessPhotos(String uid) => "$uid/business/";
}
