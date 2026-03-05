import 'package:hive_flutter/hive_flutter.dart';
import '../../../../../core/constants/hive_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../models/post_api_model.dart';
import '../../models/post_hive_model.dart';

abstract class PostLocalDataSource {
  Future<List<PostHiveModel>> getCachedFeed();
  Future<void> cacheFeed(List<PostApiModel> posts);
  Future<void> cachePost(PostApiModel post);
  Future<void> updatePost(PostApiModel post);
  Future<void> deletePost(String postId);
  Future<List<String>> getBookmarkedPostIds();
  Future<void> addBookmarkedPostId(String postId);
  Future<void> removeBookmarkedPostId(String postId);
  Future<void> queueOfflineAction(Map<String, dynamic> action);
  Future<List<Map<String, dynamic>>> getOfflineActions();
  Future<void> clearOfflineActions();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  @override
  Future<List<PostHiveModel>> getCachedFeed() async {
    try {
      final box = await Hive.openBox<PostHiveModel>(HiveConstants.postBox);
      return box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached feed: $e');
    }
  }

  @override
  Future<void> cacheFeed(List<PostApiModel> posts) async {
    try {
      final box = await Hive.openBox<PostHiveModel>(HiveConstants.postBox);
      
      // Clear existing cache
      await box.clear();
      
      // Cache new posts
      for (var post in posts) {
        final hiveModel = PostHiveModel.fromApiModel(post);
        await box.put(post.id, hiveModel);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache feed: $e');
    }
  }

  @override
  Future<void> cachePost(PostApiModel post) async {
    try {
      final box = await Hive.openBox<PostHiveModel>(HiveConstants.postBox);
      final hiveModel = PostHiveModel.fromApiModel(post);
      await box.put(post.id, hiveModel);
    } catch (e) {
      throw CacheException(message: 'Failed to cache post: $e');
    }
  }

  @override
  Future<void> updatePost(PostApiModel post) async {
    try {
      final box = await Hive.openBox<PostHiveModel>(HiveConstants.postBox);
      final hiveModel = PostHiveModel.fromApiModel(post);
      await box.put(post.id, hiveModel);
    } catch (e) {
      throw CacheException(message: 'Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final box = await Hive.openBox<PostHiveModel>(HiveConstants.postBox);
      await box.delete(postId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete post: $e');
    }
  }

  @override
  Future<List<String>> getBookmarkedPostIds() async {
    try {
      final box = await Hive.openBox(HiveConstants.bookmarkedPostsBox);
      final List<dynamic> bookmarkedIds =
          box.get(HiveConstants.bookmarkedPostIdsKey, defaultValue: []);
      return List<String>.from(bookmarkedIds);
    } catch (e) {
      throw CacheException(message: 'Failed to get bookmarked post IDs: $e');
    }
  }

  @override
  Future<void> addBookmarkedPostId(String postId) async {
    try {
      final box = await Hive.openBox(HiveConstants.bookmarkedPostsBox);
      final List<String> bookmarkedIds = await getBookmarkedPostIds();
      
      if (!bookmarkedIds.contains(postId)) {
        bookmarkedIds.add(postId);
        await box.put(HiveConstants.bookmarkedPostIdsKey, bookmarkedIds);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to add bookmarked post ID: $e');
    }
  }

  @override
  Future<void> removeBookmarkedPostId(String postId) async {
    try {
      final box = await Hive.openBox(HiveConstants.bookmarkedPostsBox);
      final List<String> bookmarkedIds = await getBookmarkedPostIds();
      
      bookmarkedIds.remove(postId);
      await box.put(HiveConstants.bookmarkedPostIdsKey, bookmarkedIds);
    } catch (e) {
      throw CacheException(message: 'Failed to remove bookmarked post ID: $e');
    }
  }

  @override
  Future<void> queueOfflineAction(Map<String, dynamic> action) async {
    try {
      final box = await Hive.openBox(HiveConstants.offlineActionsBox);
      
      // Add timestamp to action
      action['timestamp'] = DateTime.now().toIso8601String();
      
      // Get existing actions
      final List<dynamic> actions = box.get('actions', defaultValue: []);
      actions.add(action);
      
      await box.put('actions', actions);
    } catch (e) {
      throw CacheException(message: 'Failed to queue offline action: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOfflineActions() async {
    try {
      final box = await Hive.openBox(HiveConstants.offlineActionsBox);
      final List<dynamic> actions = box.get('actions', defaultValue: []);
      
      return actions.map((action) => Map<String, dynamic>.from(action)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get offline actions: $e');
    }
  }

  @override
  Future<void> clearOfflineActions() async {
    try {
      final box = await Hive.openBox(HiveConstants.offlineActionsBox);
      await box.delete('actions');
    } catch (e) {
      throw CacheException(message: 'Failed to clear offline actions: $e');
    }
  }
}
