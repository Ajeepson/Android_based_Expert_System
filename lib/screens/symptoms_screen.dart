import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../models/disease_model.dart';
import '../models/symptom_model.dart';
import '../services/firebase_service.dart';
import '../services/inference_engine.dart';

class SymptomsScreen extends StatefulWidget {
  final Crop? crop;

  const SymptomsScreen({super.key, this.crop});

  @override
  State<SymptomsScreen> createState() => _SymptomsScreenState();
}

class _SymptomsScreenState extends State<SymptomsScreen> {
  late FirebaseService _firebaseService;
  late InferenceEngine _inferenceEngine;
  
  Crop? _selectedCrop;
  List<Symptom> _allSymptoms = [];
  List<Disease> _possibleDiseases = [];
  final Set<String> _selectedSymptomIds = {}; // Changed to Set for proper handling
  
  int _currentSymptomIndex = 0;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _inferenceEngine = InferenceEngine();
    _selectedCrop = widget.crop;
    
    if (_selectedCrop != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final symptoms = await _firebaseService.getAllSymptoms();
      final diseases = await _firebaseService.getDiseasesByCropId(_selectedCrop!.id);

      setState(() {
        _allSymptoms = symptoms;
        _possibleDiseases = diseases;
        _currentSymptomIndex = 0;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _diagnose() async {
    if (_selectedSymptomIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    final results = await _inferenceEngine.diagnoseByCriterias(
      selectedSymptomIds: _selectedSymptomIds.toList(),
      possibleDiseases: _possibleDiseases,
    );

    if (mounted) {
      Navigator.pushNamed(
        context,
        '/diagnosis_result',
        arguments: {
          'results': results,
          'crop': _selectedCrop,
          'diseases': _possibleDiseases,
          'selectedSymptomIds': _selectedSymptomIds.toList(),
        },
      );
    }
  }

  void _toggleSymptom(String symptomId) {
    setState(() {
      if (_selectedSymptomIds.contains(symptomId)) {
        _selectedSymptomIds.remove(symptomId);
      } else {
        _selectedSymptomIds.add(symptomId);
      }
    });
  }

  void _goToNextSymptom() {
    if (_currentSymptomIndex < _allSymptoms.length - 1) {
      setState(() {
        _currentSymptomIndex++;
      });
    } else {
      // All symptoms reviewed, proceed to diagnosis
      _diagnose();
    }
  }

  void _goToPreviousSymptom() {
    if (_currentSymptomIndex > 0) {
      setState(() {
        _currentSymptomIndex--;
      });
    }
  }

  Widget _buildCropSelectionView() {
    return FutureBuilder<List<Crop>>(
      future: _firebaseService.getAllCrops(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final crops = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: crops.length,
          itemBuilder: (context, index) {
            final crop = crops[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.grain, color: Colors.green.shade700),
                title: Text(crop.name),
                subtitle: Text(crop.scientificName),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  setState(() {
                    _selectedCrop = crop;
                  });
                  _loadData();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosisView() {
    if (_allSymptoms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No symptoms available', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    final currentSymptom = _allSymptoms[_currentSymptomIndex];
    final isSelected = _selectedSymptomIds.contains(currentSymptom.id);
    final progress = ((_currentSymptomIndex + 1) / _allSymptoms.length * 100).toStringAsFixed(0);

    return Column(
      children: [
        // Header with crop info
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade600],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.grain, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCrop!.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Question ${_currentSymptomIndex + 1} of ${_allSymptoms.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCrop = null;
                        _selectedSymptomIds.clear();
                        _currentSymptomIndex = 0;
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentSymptomIndex + 1) / _allSymptoms.length,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
        // Question card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '❓ Does your plant have this symptom?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // Symptom card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_florist,
                                color: Colors.green.shade700,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSymptom.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      'Affects: ${currentSymptom.affectedPart}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: Colors.orange.shade100,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentSymptom.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Yes/No buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _toggleSymptom(currentSymptom.id);
                                  _goToNextSymptom();
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Yes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _goToNextSymptom,
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('No'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  side: BorderSide(color: Colors.red.shade600, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedSymptomIds.length} symptom(s) selected so far',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _currentSymptomIndex > 0 ? _goToPreviousSymptom : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedSymptomIds.isNotEmpty ? _diagnose : null,
                icon: const Icon(Icons.check_circle),
                label: const Text('Diagnose Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: const Text('Symptom-Based Diagnosis'),
        elevation: 0,
      ),
      body: _selectedCrop == null
          ? _buildCropSelectionView()
          : _buildDiagnosisView(),
      floatingActionButton: _selectedCrop != null && _selectedSymptomIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _diagnose,
              icon: const Icon(Icons.check_circle),
              label: Text(
                'Diagnose (${_selectedSymptomIds.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green.shade700,
            )
          : null,
    );
  }
}
