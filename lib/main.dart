import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'screens/pronunciation_practice_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppConstants.lightTheme,
      home: const PronunciationPracticePage(),
    );
  }
}
