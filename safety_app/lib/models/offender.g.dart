// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offender.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OffenderAdapter extends TypeAdapter<Offender> {
  @override
  final int typeId = 0;

  @override
  Offender read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offender(
      id: fields[0] as String,
      fullName: fields[1] as String,
      age: fields[2] as int?,
      city: fields[3] as String?,
      state: fields[4] as String?,
      offenseDescription: fields[5] as String?,
      registrationDate: fields[6] as String?,
      distance: fields[7] as double?,
      address: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Offender obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.offenseDescription)
      ..writeByte(6)
      ..write(obj.registrationDate)
      ..writeByte(7)
      ..write(obj.distance)
      ..writeByte(8)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OffenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
