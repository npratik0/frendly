class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:5050';

  static const String baseUrl = 'http://192.168.1.74:5050';

  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Batch Endpoints ============
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String students = '/students';
  static const String studentLogin = '/students/login';
  static const String studentRegister = '/students/register';
  static String studentById(String id) => '/students/$id';
  static String studentPhoto(String id) => '/students/$id/photo';

  // ============ Item Endpoints ============
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemClaim(String id) => '/items/$id/claim';

  // ============ Comment Endpoints ============
  static const String comments = '/comments';
  static String commentById(String id) => '/comments/$id';
  static String commentsByItem(String itemId) => '/comments/item/$itemId';
  static String commentLike(String id) => '/comments/$id/like';

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String whoami = '/api/auth/whoami';
  static const String updateProfile = '/api/auth/profile';
  static const String updateProfilePicture = '/api/auth/profile-picture';
  static const String changePassword = '/api/auth/change-password';

  // Post Endpoints
  static const String posts = '/api/posts';
  static const String feed = '/api/posts/feed';
  static String userPosts(String userId) => '/api/posts/user/$userId';
  static String likePost(String postId) => '/api/posts/$postId/like';
  static String addComment(String postId) => '/api/posts/$postId/comment';
  static String deleteComment(String postId, String commentId) =>
      '/api/posts/$postId/comment/$commentId';
  static String deletePost(String postId) => '/api/posts/$postId';
  static const String savedPosts = '/api/posts/saved';

  // User Endpoints
  static const String searchUsers = '/api/auth/search';
  static const String getSavedPosts = '/api/auth/saved-posts';
  static String savePost(String postId) => '/api/auth/posts/$postId/save';
  static String unsavePost(String postId) => '/api/auth/posts/$postId/unsave';
  static String getUserProfile(String userId) => '/api/auth/$userId';
  static String followUser(String userId) => '/api/auth/$userId/follow';
  static String unfollowUser(String userId) => '/api/auth/$userId/unfollow';

  // Message Endpoints
  static const String conversations = '/api/messages/conversations';
  static String getMessages(String userId) => '/api/messages/user/$userId';
  static const String sendMessage = '/api/messages';
  static String markAsRead(String conversationId) =>
      '/api/messages/$conversationId/read';
  static String deleteMessage(String messageId) => '/api/messages/$messageId';
  static const String searchMessages = '/api/messages/search';
}
