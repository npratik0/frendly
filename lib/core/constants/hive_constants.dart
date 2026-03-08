class HiveConstants {
  // Box names
  static const String authBox = 'auth_box';
  static const String postBox = 'post_box';
  static const String userBox = 'user_box';
  static const String offlineActionsBox = 'offline_actions_box';
  static const String bookmarkedPostsBox = 'bookmarked_posts_box';

  // Keys
  static const String tokenKey = 'token';
  static const String currentUserKey = 'current_user';
  static const String feedPostsKey = 'feed_posts';
  static const String bookmarkedPostIdsKey = 'bookmarked_post_ids';

  // Offline action types
  static const String actionTypeLike = 'LIKE';
  static const String actionTypeUnlike = 'UNLIKE';
  static const String actionTypeComment = 'COMMENT';
  static const String actionTypeBookmark = 'BOOKMARK';
  static const String actionTypeUnbookmark = 'UNBOOKMARK';
  static const String actionTypeCreatePost = 'CREATE_POST';

  // Type adapters IDs
  static const int postHiveModelTypeId = 10;
  static const int commentHiveModelTypeId = 11;
  static const int userHiveModelTypeId = 2;
  static const int offlineActionTypeId = 3;

  static const String recentSearchesBox = 'recent_searches_box';
  static const int recentSearchHiveModelTypeId = 20;
}
