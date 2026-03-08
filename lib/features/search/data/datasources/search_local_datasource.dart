import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../models/recent_search_hive_model.dart';

abstract class SearchLocalDataSource {
  Future<List<RecentSearchHiveModel>> getRecentSearches();
  Future<void> saveRecentSearch(String query);
  Future<void> deleteRecentSearch(String query);
  Future<void> clearRecentSearches();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  static const int maxRecentSearches = 10;

  @override
  Future<List<RecentSearchHiveModel>> getRecentSearches() async {
    try {
      final box = await Hive.openBox<RecentSearchHiveModel>(
        HiveConstants.recentSearchesBox,
      );

      // Get all searches and sort by timestamp (newest first)
      final searches = box.values.toList();
      searches.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return searches.take(maxRecentSearches).toList();
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    try {
      final box = await Hive.openBox<RecentSearchHiveModel>(
        HiveConstants.recentSearchesBox,
      );

      // Remove existing entry with same query
      final existingKeys = box.keys.where((key) {
        final search = box.get(key);
        return search?.query.toLowerCase() == query.toLowerCase();
      }).toList();

      for (var key in existingKeys) {
        await box.delete(key);
      }

      // Add new search
      final newSearch = RecentSearchHiveModel(
        query: query,
        timestamp: DateTime.now(),
      );

      await box.add(newSearch);

      // Keep only last N searches
      if (box.length > maxRecentSearches) {
        final searches = box.values.toList();
        searches.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Delete oldest ones
        final toDelete = searches.take(box.length - maxRecentSearches);
        for (var search in toDelete) {
          await search.delete();
        }
      }
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  @override
  Future<void> deleteRecentSearch(String query) async {
    try {
      final box = await Hive.openBox<RecentSearchHiveModel>(
        HiveConstants.recentSearchesBox,
      );

      final keysToDelete = box.keys.where((key) {
        final search = box.get(key);
        return search?.query.toLowerCase() == query.toLowerCase();
      }).toList();

      for (var key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      print('Error deleting recent search: $e');
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    try {
      final box = await Hive.openBox<RecentSearchHiveModel>(
        HiveConstants.recentSearchesBox,
      );
      await box.clear();
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }
}
