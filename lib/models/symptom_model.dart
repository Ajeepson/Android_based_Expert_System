class Symptom {
  final String id;
  final String name;
  final String description;
  final String affectedPart; // leaf, stem, root, fruit, etc
  final List<String> relatedDiseases;

  Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.affectedPart,
    required this.relatedDiseases,
  });

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      affectedPart: map['affectedPart'] ?? '',
      relatedDiseases: List<String>.from(map['relatedDiseases'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'affectedPart': affectedPart,
      'relatedDiseases': relatedDiseases,
    };
  }
}

class DiagnosisResult {
  final String diseaseId;
  final String diseaseName;
  final double confidence;
  final List<String> matchedSymptoms;
  final String recommendation;

  DiagnosisResult({
    required this.diseaseId,
    required this.diseaseName,
    required this.confidence,
    required this.matchedSymptoms,
    required this.recommendation,
  });
}
