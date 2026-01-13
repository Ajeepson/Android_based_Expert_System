import '../models/disease_model.dart';
import '../models/symptom_model.dart';
import '../models/crop_model.dart';

class InferenceEngine {
  /// Match symptoms to diseases and return diagnosis results
  /// Uses a scoring system based on symptom overlap
  Future<List<DiagnosisResult>> diagnoseByCriterias({
    required List<String> selectedSymptomIds,
    required List<Disease> possibleDiseases,
  }) async {
    List<DiagnosisResult> results = [];

    for (var disease in possibleDiseases) {
      // Count matching symptoms
      int matchCount = 0;
      List<String> matchedSymptoms = [];

      for (var symptomId in selectedSymptomIds) {
        // You would need to link symptoms to diseases in your Firestore model
        // This is a simplified version - you'll need to adjust based on your data structure
        matchedSymptoms.add(symptomId);
        matchCount++;
      }

      // Calculate confidence based on match percentage
      double confidence = (matchCount / disease.symptoms.length) * 100;

      // Only include results with reasonable confidence (>30%)
      if (confidence >= 30) {
        results.add(DiagnosisResult(
          diseaseId: disease.id,
          diseaseName: disease.name,
          confidence: confidence,
          matchedSymptoms: matchedSymptoms,
          recommendation: _generateRecommendation(disease, confidence),
        ));
      }
    }

    // Sort by confidence (highest first)
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  /// Generate recommendation based on disease and confidence
  String _generateRecommendation(Disease disease, double confidence) {
    if (confidence >= 80) {
      return 'High confidence diagnosis. ${disease.treatments.isNotEmpty ? "Recommended treatment: ${disease.treatments.first}" : "Consult a plant pathologist."}';
    } else if (confidence >= 50) {
      return 'Moderate confidence. Please provide more symptoms or consider image diagnosis for better accuracy.';
    } else {
      return 'Low confidence. More symptoms needed for accurate diagnosis. Consider using image diagnosis feature.';
    }
  }

  /// Get followup questions based on crop and already selected symptoms
  List<String> getFollowUpQuestions({
    required Crop crop,
    required List<String> selectedSymptomIds,
    required List<Symptom> allSymptoms,
  }) {
    // Filter symptoms that haven't been selected yet
    List<String> questions = [];

    for (var symptom in allSymptoms) {
      if (!selectedSymptomIds.contains(symptom.id)) {
        questions.add('Does ${crop.name} show ${symptom.name}? (${symptom.affectedPart})');
      }
    }

    return questions.take(5).toList(); // Return top 5 follow-up questions
  }

  /// Generate detailed diagnosis report
  String generateDiagnosisReport({
    required DiagnosisResult result,
    required Disease disease,
    required Crop crop,
  }) {
    StringBuffer report = StringBuffer();

    report.writeln('=== DIAGNOSIS REPORT ===\n');
    report.writeln('Crop: ${crop.name}');
    report.writeln('Suspected Disease: ${result.diseaseName}');
    report.writeln('Confidence Level: ${result.confidence.toStringAsFixed(1)}%\n');

    report.writeln('--- Disease Information ---');
    report.writeln('Description: ${disease.description}\n');

    report.writeln('Causative Agent: ${disease.causativeAgent}');
    report.writeln('Severity: ${disease.severity}\n');

    if (disease.symptoms.isNotEmpty) {
      report.writeln('--- Common Symptoms ---');
      for (var symptom in disease.symptoms) {
        report.writeln('• $symptom');
      }
      report.writeln('');
    }

    if (disease.treatments.isNotEmpty) {
      report.writeln('--- Recommended Treatments ---');
      for (var treatment in disease.treatments) {
        report.writeln('• $treatment');
      }
      report.writeln('');
    }

    if (disease.preventiveMeasures.isNotEmpty) {
      report.writeln('--- Preventive Measures ---');
      for (var measure in disease.preventiveMeasures) {
        report.writeln('• $measure');
      }
      report.writeln('');
    }

    report.writeln('Note: For confirmation, please use the image diagnosis feature.');

    return report.toString();
  }
}
