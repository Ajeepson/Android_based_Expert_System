import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/crop_model.dart';
import '../services/firebase_service.dart';

class ImageDiagnosisScreen extends StatefulWidget {
  final Crop? crop;

  const ImageDiagnosisScreen({super.key, this.crop});

  @override
  State<ImageDiagnosisScreen> createState() => _ImageDiagnosisScreenState();
}

class _ImageDiagnosisScreenState extends State<ImageDiagnosisScreen> {
  late FirebaseService _firebaseService;
  late GenerativeModel _model;

  Crop? _selectedCrop;
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String? _error;

  final ImagePicker _imagePicker = ImagePicker();

  // Replace with your actual Gemini API key
  static const String _apiKey = 'AIzaSyD4zXMOZ6l6h7LDIK5iWGxtBbjYhMQn0XU';

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
    _selectedCrop = widget.crop;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    if (_selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      // Read image bytes
      final imageBytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Prepare prompt for Gemini
      final prompt = '''
Analyze this image of a ${_selectedCrop!.name} plant and provide a detailed diagnosis.

Please provide:
1. Plant Health Status: (Healthy/Diseased)
2. Possible Diseases: (List any identified diseases)
3. Symptoms Observed: (Describe what you see)
4. Severity Level: (Mild/Moderate/Severe)
5. Recommended Actions: (Treatment/Prevention measures)
6. Confidence Level: (0-100%)

Format your response clearly with these sections.
''';

      // Send to Gemini
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        setState(() {
          _analysisResult = response.text;
        });
      } else {
        setState(() {
          _error = 'No response from AI model';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error analyzing image: $e';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Image-Based Diagnosis'),
        elevation: 0,
      ),
      body: _selectedCrop == null
          ? _buildCropSelectionView()
          : _buildImageDiagnosisView(),
    );
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
                leading: Icon(Icons.grain, color: Colors.blue.shade700),
                title: Text(crop.name),
                subtitle: Text(crop.scientificName),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  setState(() {
                    _selectedCrop = crop;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageDiagnosisView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Crop Info
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.grain, color: Colors.blue.shade700, size: 32),
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
                        ),
                      ),
                      Text(
                        _selectedCrop!.scientificName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCrop = null;
                      _selectedImage = null;
                      _analysisResult = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Image Selection/Preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plant Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedImage == null)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue.shade50,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.blue.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No image selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.image),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Analyze Button
          if (_selectedImage != null && !_isAnalyzing && _analysisResult == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.smart_toy),
                label: const Text('Analyze with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Analyzing image with AI...'),
                ],
              ),
            ),
          // Analysis Result
          if (_analysisResult != null && !_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Analysis Result',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _analysisResult!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
