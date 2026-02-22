import 'package:flutter/material.dart';
import 'car_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F0B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7CFF7C),
          secondary: Color(0xFF9AA79A),
          surface: Color(0xFF101610),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFB8FFB8),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFB8FFB8),
          ),
          titleLarge: TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFFB8FFB8),
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF131A13),
          border: OutlineInputBorder(),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Car Price Prediction (ONNX)'),
          backgroundColor: const Color(0xFF121812),
          foregroundColor: const Color(0xFF7CFF7C),
          centerTitle: false,
        ),
        body: const CarForm(),
      ),
    );
  }
}
