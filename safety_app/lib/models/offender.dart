class Offender {
  final String id;
  final String fullName;
  final int? age;
  final String? city;
  final String? state;
  final String? offenseDescription;
  final String? registrationDate;
  final double? distance;
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
