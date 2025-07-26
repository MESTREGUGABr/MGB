import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Importe sua nova página de login
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Removi o 'const' porque MyApp não é mais const
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Removi o 'const' daqui também
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MGB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Um tema visual mais moderno para os campos de texto
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // A tela inicial agora é a nossa LoginPage!
      home: const LoginPage(),
    );
  }
}
