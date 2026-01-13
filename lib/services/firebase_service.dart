import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_model.dart';
import '../models/disease_model.dart';
import '../models/symptom_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String cropsCollection = 'crops';
  static const String diseasesCollection = 'diseases';
  static const String symptomsCollection = 'symptoms';

  // ==================== CROP OPERATIONS ====================
  
  /// Get all crops
  Future<List<Crop>> getAllCrops() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(cropsCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => Crop.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching crops: $e');
    }
  }

  /// Get a specific crop by ID
  Future<Crop?> getCropById(String cropId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(cropsCollection)
          .doc(cropId)
          .get();
      
      if (doc.exists) {
        return Crop.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching crop: $e');
    }
  }

  /// Search crops by name
  Future<List<Crop>> searchCrops(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(cropsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      
      return snapshot.docs
          .map((doc) => Crop.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching crops: $e');
    }
  }

  // ==================== DISEASE OPERATIONS ====================

  /// Get all diseases for a specific crop
  Future<List<Disease>> getDiseasesByCropId(String cropId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(diseasesCollection)
          .where('cropId', isEqualTo: cropId)
          .get();
      
      return snapshot.docs
          .map((doc) => Disease.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching diseases: $e');
    }
  }

  /// Get a specific disease by ID
  Future<Disease?> getDiseaseById(String diseaseId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(diseasesCollection)
          .doc(diseaseId)
          .get();
      
      if (doc.exists) {
        return Disease.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching disease: $e');
    }
  }

  /// Search diseases by name
  Future<List<Disease>> searchDiseases(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(diseasesCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();
      
      return snapshot.docs
          .map((doc) => Disease.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching diseases: $e');
    }
  }

  // ==================== SYMPTOM OPERATIONS ====================

  /// Get all symptoms
  Future<List<Symptom>> getAllSymptoms() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(symptomsCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => Symptom.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching symptoms: $e');
    }
  }

  /// Get symptoms by related disease
  Future<List<Symptom>> getSymptomsByDiseaseId(String diseaseId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(symptomsCollection)
          .where('relatedDiseases', arrayContains: diseaseId)
          .get();
      
      return snapshot.docs
          .map((doc) => Symptom.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching symptoms: $e');
    }
  }

  /// Get a specific symptom by ID
  Future<Symptom?> getSymptomById(String symptomId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(symptomsCollection)
          .doc(symptomId)
          .get();
      
      if (doc.exists) {
        return Symptom.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching symptom: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Add a new crop
  Future<String> addCrop(Crop crop) async {
    try {
      final docRef = await _firestore
          .collection(cropsCollection)
          .add(crop.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding crop: $e');
    }
  }

  /// Add a new disease
  Future<String> addDisease(Disease disease) async {
    try {
      final docRef = await _firestore
          .collection(diseasesCollection)
          .add(disease.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding disease: $e');
    }
  }

  /// Add a new symptom
  Future<String> addSymptom(Symptom symptom) async {
    try {
      final docRef = await _firestore
          .collection(symptomsCollection)
          .add(symptom.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding symptom: $e');
    }
  }

  /// Update crop
  Future<void> updateCrop(String cropId, Crop crop) async {
    try {
      await _firestore
          .collection(cropsCollection)
          .doc(cropId)
          .update(crop.toMap());
    } catch (e) {
      throw Exception('Error updating crop: $e');
    }
  }

  /// Update disease
  Future<void> updateDisease(String diseaseId, Disease disease) async {
    try {
      await _firestore
          .collection(diseasesCollection)
          .doc(diseaseId)
          .update(disease.toMap());
    } catch (e) {
      throw Exception('Error updating disease: $e');
    }
  }

  /// Delete crop
  Future<void> deleteCrop(String cropId) async {
    try {
      await _firestore
          .collection(cropsCollection)
          .doc(cropId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting crop: $e');
    }
  }

  /// Delete disease
  Future<void> deleteDisease(String diseaseId) async {
    try {
      await _firestore
          .collection(diseasesCollection)
          .doc(diseaseId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting disease: $e');
    }
  }
}
