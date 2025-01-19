import 'package:flutter/material.dart';
import 'screens/login.dart'; // Corrigez le chemin ici

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), // L'écran de connexion est la page d'accueil
    );
  }
}
