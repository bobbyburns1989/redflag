import 'package:hive/hive.dart';

part 'offender.g.dart';

@HiveType(typeId: 0)
class Offender {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final int? age;

  @HiveField(3)
  final String? city;

  @HiveField(4)
  final String? state;

  @HiveField(5)
  final String? offenseDescription;

  @HiveField(6)
  final String? registrationDate;

  @HiveField(7)
  final double? distance;

  @HiveField(8)
  final String? address;

  Offender({
    required this.id,
    required this.fullName,
    this.age,
    this.city,
    this.state,
    this.offenseDescription,
    this.registrationDate,
    this.distance,
    this.address,
  });

  factory Offender.fromJson(Map<String, dynamic> json) {
    return Offender(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      age: json['age'] as int?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      offenseDescription: json['offenseDescription'] as String?,
      registrationDate: json['registrationDate'] as String?,
      distance: json['distance']?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'city': city,
      'state': state,
      'offenseDescription': offenseDescription,
      'registrationDate': registrationDate,
      'distance': distance,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'Offender{id: $id, fullName: $fullName, city: $city, state: $state}';
  }
}
