// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentSearchHiveModelAdapter extends TypeAdapter<RecentSearchHiveModel> {
  @override
  final int typeId = 20;

  @override
  RecentSearchHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentSearchHiveModel(
      query: fields[0] as String,
      timestamp: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentSearchHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.query)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentSearchHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
