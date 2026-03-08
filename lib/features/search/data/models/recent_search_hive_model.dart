import 'package:hive/hive.dart';
import '../../domain/entities/recent_search_entity.dart';

part 'recent_search_hive_model.g.dart';

@HiveType(typeId: 20)
class RecentSearchHiveModel extends HiveObject {
  @HiveField(0)
  final String query;

  @HiveField(1)
  final DateTime timestamp;

  RecentSearchHiveModel({required this.query, required this.timestamp});

  RecentSearchEntity toEntity() {
    return RecentSearchEntity(query: query, timestamp: timestamp);
  }

  factory RecentSearchHiveModel.fromEntity(RecentSearchEntity entity) {
    return RecentSearchHiveModel(
      query: entity.query,
      timestamp: entity.timestamp,
    );
  }
}
