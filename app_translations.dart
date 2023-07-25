import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'appTitle': 'Dental Recognition',
          'takePhoto': 'Take A Photo',
          'pickGallery': 'Pick From Gallery',
          'noImage': 'No Image Selected',
        },
        'tr': {
          'appTitle': 'Diş Tanıma',
          'takePhoto': 'Fotoğraf Çek',
          'pickGallery': 'Galeriden Seç',
          'noImage': 'Resim Seçilmedi',
        },
      };
}
