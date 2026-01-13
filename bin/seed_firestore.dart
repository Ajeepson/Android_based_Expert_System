import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  // Sample Sahel Crops Data
  final crops = [
    {
      'id': 'maize_001',
      'name': 'Maize (Corn)',
      'scientificName': 'Zea mays',
      'description': 'A staple cereal crop widely grown in the Sahel region.',
      'growingSeasons': ['May-October'],
      'imageUrl': '',
      'characteristics': {
        'maturityDays': 90,
        'optimalTemp': '25-30°C',
        'waterNeeds': 'High',
      },
    },
    {
      'id': 'groundnut_001',
      'name': 'Groundnut (Peanut)',
      'scientificName': 'Arachis hypogaea',
      'description': 'An important legume crop in Sahel farming systems.',
      'growingSeasons': ['June-November'],
      'imageUrl': '',
      'characteristics': {
        'maturityDays': 120,
        'optimalTemp': '20-30°C',
        'waterNeeds': 'Moderate',
      },
    },
    {
      'id': 'sorghum_001',
      'name': 'Sorghum',
      'scientificName': 'Sorghum bicolor',
      'description':
          'Drought-resistant cereal crop well-suited to Sahel conditions.',
      'growingSeasons': ['June-September'],
      'imageUrl': '',
      'characteristics': {
        'maturityDays': 100,
        'optimalTemp': '20-35°C',
        'waterNeeds': 'Low',
      },
    },
    {
      'id': 'millet_001',
      'name': 'Millet',
      'scientificName': 'Pennisetum glaucum',
      'description':
          'A hardy cereal crop, highly resilient to Sahel drought conditions.',
      'growingSeasons': ['May-August'],
      'imageUrl': '',
      'characteristics': {
        'maturityDays': 90,
        'optimalTemp': '25-35°C',
        'waterNeeds': 'Very Low',
      },
    },
  ];

  // Sample Diseases
  final diseases = [
    {
      'id': 'maize_disease_001',
      'name': 'Maize Leaf Blight',
      'cropId': 'maize_001',
      'description':
          'A fungal disease causing brown lesions on maize leaves, reducing photosynthesis.',
      'symptoms': [
        'Brown/tan lesions on leaves',
        'Lesions have concentric rings',
        'Affected leaves wither and die',
        'Reduced grain yield',
      ],
      'treatments': [
        'Use disease-resistant varieties',
        'Apply fungicides like Mancozeb',
        'Remove infected plant parts',
        'Crop rotation for 2-3 years',
      ],
      'preventiveMeasures': [
        'Use certified disease-free seeds',
        'Plant in well-drained fields',
        'Maintain proper plant spacing',
        'Avoid over-watering',
        'Remove crop debris after harvest',
      ],
      'severity': 'moderate',
      'causativeAgent': 'fungal',
      'imageUrl': '',
    },
    {
      'id': 'maize_disease_002',
      'name': 'Maize Streak Virus',
      'cropId': 'maize_001',
      'description':
          'A viral disease spread by leafhoppers causing yellowing streaks on leaves.',
      'symptoms': [
        'Yellow/white streaks on leaves',
        'Streaks run parallel to leaf veins',
        'Stunted plant growth',
        'Poor cob and grain development',
      ],
      'treatments': [
        'Remove infected plants immediately',
        'Control leafhopper vectors with insecticides',
        'No chemical cure for viral infection',
        'Use resistant varieties if available',
      ],
      'preventiveMeasures': [
        'Plant resistant maize varieties',
        'Control leafhoppers with neem oil or insecticides',
        'Remove weeds that harbor leafhoppers',
        'Quarantine infected fields',
      ],
      'severity': 'severe',
      'causativeAgent': 'viral',
      'imageUrl': '',
    },
    {
      'id': 'groundnut_disease_001',
      'name': 'Aflatoxin (Groundnut Contamination)',
      'cropId': 'groundnut_001',
      'description':
          'Fungal contamination producing aflatoxins, a health hazard.',
      'symptoms': [
        'Black/moldy appearance on pods',
        'Premature pod decay',
        'Discoloration of kernels',
        'Poor storability',
      ],
      'treatments': [
        'Dry pods properly (to <10% moisture)',
        'Store in cool, dry conditions',
        'Sort and remove infected pods',
        'Use proper storage containers',
      ],
      'preventiveMeasures': [
        'Harvest at proper maturity',
        'Avoid field drought stress',
        'Use disease-resistant varieties',
        'Proper drying and storage',
        'Timely harvest to prevent in-field contamination',
      ],
      'severity': 'severe',
      'causativeAgent': 'fungal',
      'imageUrl': '',
    },
    {
      'id': 'sorghum_disease_001',
      'name': 'Sorghum Smut',
      'cropId': 'sorghum_001',
      'description': 'A fungal disease converting grain to black sooty spores.',
      'symptoms': [
        'Black powdery mass in grain head',
        'Complete grain loss in severe cases',
        'Deformed panicles',
        'Poor grain development',
      ],
      'treatments': [
        'Remove infected plants and heads',
        'Use fungicide seed treatment',
        'Apply systemic fungicides at boot stage',
        'Burn infected crop residue',
      ],
      'preventiveMeasures': [
        'Use resistant varieties',
        'Use treated seeds',
        'Avoid planting in contaminated soil',
        'Proper crop rotation',
        'Maintain good field sanitation',
      ],
      'severity': 'moderate',
      'causativeAgent': 'fungal',
      'imageUrl': '',
    },
    {
      'id': 'millet_disease_001',
      'name': 'Millet Blast',
      'cropId': 'millet_001',
      'description':
          'A fungal disease affecting panicles and leaves causing significant yield loss.',
      'symptoms': [
        'Gray/brown spots on leaves',
        'Panicle rot and discoloration',
        'Grain abortion',
        'Premature crop maturity',
      ],
      'treatments': [
        'Apply fungicides at flowering',
        'Remove and burn infected material',
        'Use resistant varieties',
        'Improve field drainage',
      ],
      'preventiveMeasures': [
        'Select resistant millet varieties',
        'Proper crop spacing for air circulation',
        'Avoid excessive nitrogen fertilization',
        'Timely irrigation management',
        'Sanitation of tools and equipment',
      ],
      'severity': 'moderate',
      'causativeAgent': 'fungal',
      'imageUrl': '',
    },
  ];

  // Sample Symptoms
  final symptoms = [
    {
      'id': 'symptom_001',
      'name': 'Brown/Tan Leaf Lesions',
      'description':
          'Brownish or tan-colored spots or lesions appearing on leaves.',
      'affectedPart': 'leaf',
      'relatedDiseases': ['maize_disease_001'],
    },
    {
      'id': 'symptom_002',
      'name': 'Yellow Leaf Streaks',
      'description': 'Yellow or whitish streaks running along leaf veins.',
      'affectedPart': 'leaf',
      'relatedDiseases': ['maize_disease_002'],
    },
    {
      'id': 'symptom_003',
      'name': 'Stunted Growth',
      'description':
          'Plant appears much smaller than healthy plants of same age.',
      'affectedPart': 'stem',
      'relatedDiseases': ['maize_disease_002'],
    },
    {
      'id': 'symptom_004',
      'name': 'Leaf Wilting',
      'description': 'Leaves appear droopy and lack turgidity.',
      'affectedPart': 'leaf',
      'relatedDiseases': ['maize_disease_001'],
    },
    {
      'id': 'symptom_005',
      'name': 'Black Sooty Coating',
      'description': 'Black powdery or sooty appearance on grains or panicles.',
      'affectedPart': 'fruit',
      'relatedDiseases': ['sorghum_disease_001'],
    },
    {
      'id': 'symptom_006',
      'name': 'Moldy Pod Appearance',
      'description': 'Pods show mold growth and black discoloration.',
      'affectedPart': 'fruit',
      'relatedDiseases': ['groundnut_disease_001'],
    },
    {
      'id': 'symptom_007',
      'name': 'Panicle Rot',
      'description': 'Flowering head shows rot and discoloration.',
      'affectedPart': 'flower',
      'relatedDiseases': ['millet_disease_001'],
    },
    {
      'id': 'symptom_008',
      'name': 'Poor Grain Development',
      'description': 'Grains appear shriveled, underdeveloped, or aborted.',
      'affectedPart': 'fruit',
      'relatedDiseases': ['maize_disease_002', 'millet_disease_001'],
    },
  ];

  try {
    print('🌾 Starting Firestore seeding for Sahel Crop Expert System...\n');

    // Upload crops
    print('📌 Uploading Crops...');
    for (var crop in crops) {
      await firestore.collection('crops').doc(crop['id'] as String).set(crop);
      print('  ✓ ${crop['name']}');
    }

    // Upload diseases
    print('\n🦠 Uploading Diseases...');
    for (var disease in diseases) {
      await firestore
          .collection('diseases')
          .doc(disease['id'] as String)
          .set(disease);
      print('  ✓ ${disease['name']}');
    }

    // Upload symptoms
    print('\n🔍 Uploading Symptoms...');
    for (var symptom in symptoms) {
      await firestore
          .collection('symptoms')
          .doc(symptom['id'] as String)
          .set(symptom);
      print('  ✓ ${symptom['name']}');
    }

    print('\n✅ Firestore seeding completed successfully!');
    print('📊 Summary:');
    print('   - Crops: ${crops.length}');
    print('   - Diseases: ${diseases.length}');
    print('   - Symptoms: ${symptoms.length}');
  } catch (e) {
    print('❌ Error seeding Firestore: $e');
  }

  exit(0);
}
