import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_translations.dart';
import 'home_screen.dart';
import 'home_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeViewModel());

    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('tr', ''),
      fallbackLocale: const Locale('en', 'US'),
      home: HomeScreen(),
    );
  }
}
