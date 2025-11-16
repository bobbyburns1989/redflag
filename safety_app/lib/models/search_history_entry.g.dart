// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchHistoryEntryAdapter extends TypeAdapter<SearchHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  SearchHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryEntry(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      age: fields[4] as String?,
      state: fields[5] as String?,
      phoneNumber: fields[6] as String?,
      zipCode: fields[7] as String?,
      resultCount: fields[8] as int,
      results: (fields[9] as List).cast<Offender>(),
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.state)
      ..writeByte(6)
      ..write(obj.phoneNumber)
      ..writeByte(7)
      ..write(obj.zipCode)
      ..writeByte(8)
      ..write(obj.resultCount)
      ..writeByte(9)
      ..write(obj.results);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
