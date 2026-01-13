class Disease {
  final String id;
  final String name;
  final String cropId;
  final String description;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> preventiveMeasures;
  final String severity; // mild, moderate, severe
  final String causativeAgent; // fungal, bacterial, viral, pest, etc
  final String imageUrl;

  Disease({
    required this.id,
    required this.name,
    required this.cropId,
    required this.description,
    required this.symptoms,
    required this.treatments,
    required this.preventiveMeasures,
    required this.severity,
    required this.causativeAgent,
    required this.imageUrl,
  });

  factory Disease.fromMap(Map<String, dynamic> map) {
    return Disease(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cropId: map['cropId'] ?? '',
      description: map['description'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      treatments: List<String>.from(map['treatments'] ?? []),
      preventiveMeasures: List<String>.from(map['preventiveMeasures'] ?? []),
      severity: map['severity'] ?? 'moderate',
      causativeAgent: map['causativeAgent'] ?? 'unknown',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cropId': cropId,
      'description': description,
      'symptoms': symptoms,
      'treatments': treatments,
      'preventiveMeasures': preventiveMeasures,
      'severity': severity,
      'causativeAgent': causativeAgent,
      'imageUrl': imageUrl,
    };
  }
}
