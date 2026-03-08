import 'package:equatable/equatable.dart';

class RecentSearchEntity extends Equatable {
  final String query;
  final DateTime timestamp;

  const RecentSearchEntity({required this.query, required this.timestamp});

  @override
  List<Object> get props => [query, timestamp];
}
