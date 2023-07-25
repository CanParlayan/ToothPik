import 'package:flutter/material.dart';
import 'home.dart';
import 'package:get/get.dart';
import 'app_translations.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      title: 'Dental Recognition',
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}