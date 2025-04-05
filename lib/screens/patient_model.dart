class Patient {
  final String id;
  final String name;
  final int age;
  final int? heartRate;
  final String? bloodPressure;
  final int? oxygenSaturation;
  final double? temperature;
  final int? respiratoryRate;
  final int? bloodGlucose;
  final int? cholesterol;
  final double? hemoglobin;
  final Map<String, double>? electrolytes; // Stores Sodium, Potassium, etc.
  final List<String>? imageUrls; // ✅ Changed to a list of image URLs

  Patient({
    required this.id,
    required this.name,
    required this.age,
    this.heartRate,
    this.bloodPressure,
    this.oxygenSaturation,
    this.temperature,
    this.respiratoryRate,
    this.bloodGlucose,
    this.cholesterol,
    this.hemoglobin,
    this.electrolytes,
    this.imageUrls, // ✅ Changed to a list of image URLs
  });

  // Convert a Patient object to a map (for Firestore or database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'oxygenSaturation': oxygenSaturation,
      'temperature': temperature,
      'respiratoryRate': respiratoryRate,
      'bloodGlucose': bloodGlucose,
      'cholesterol': cholesterol,
      'hemoglobin': hemoglobin,
      'electrolytes': electrolytes,
      'imageUrls': imageUrls, // ✅ Save list of image URLs
    };
  }

  // ✅ Add toJson() method (same as toMap())
  Map<String, dynamic> toJson() => toMap();

  // Convert a map to a Patient object (for retrieving data)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      heartRate: map['heartRate'],
      bloodPressure: map['bloodPressure'],
      oxygenSaturation: map['oxygenSaturation'],
      temperature: map['temperature']?.toDouble(),
      respiratoryRate: map['respiratoryRate'],
      bloodGlucose: map['bloodGlucose'],
      cholesterol: map['cholesterol'],
      hemoglobin: map['hemoglobin']?.toDouble(),
      electrolytes: (map['electrolytes'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []), // ✅ Load list of image URLs
    );
  }

  // ✅ Add fromJson() method
  factory Patient.fromJson(Map<String, dynamic> json) => Patient.fromMap(json);
}