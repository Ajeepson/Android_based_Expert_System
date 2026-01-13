import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/symptoms_screen.dart';
import 'screens/image_diagnosis_screen.dart';
import 'screens/diagnosis_result_screen.dart';
import 'models/crop_model.dart';
import 'models/disease_model.dart';
import 'models/symptom_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Disease Expert System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        return _buildRoute(settings);
      },
    );
  }

  Route? _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case '/symptoms':
        final crop = settings.arguments as Crop?;
        return MaterialPageRoute(
          builder: (_) => SymptomsScreen(crop: crop),
        );
      
      case '/image_diagnosis':
        final crop = settings.arguments as Crop?;
        return MaterialPageRoute(
          builder: (_) => ImageDiagnosisScreen(crop: crop),
        );
      
      case '/diagnosis_result':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DiagnosisResultScreen(
            results: args['results'] as List<DiagnosisResult>,
            crop: args['crop'] as Crop,
            diseases: args['diseases'] as List<Disease>,
            selectedSymptomIds: args['selectedSymptomIds'] as List<String>,
          ),
        );
      
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
