import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      'appTitle': 'Dental Recognition',
      'takePhoto': 'Take A Photo',
      'pickGallery': 'Pick From Gallery',
      'noImage': 'No Image Selected',
      "hasCavity": "Your teeth have cavity.",
      "hasNoCavity": "Your teeth are cavity-free.",
      "teethRes": "Teeth Classification Result",
      "ok": "OK",
      "noTeeth": "No Teeth Detected",
      "pTakePhoto": "Please take a photo of your teeth",
      "att": "ATTENTION!",
      "info":
      "When taking the photo, Please make sure your teeth are clearly visible and your camera's flash is on and the light does not cast a shadow.",
      "dShow": "Don't Show Again",
      "err": "Error",
      "zoom": "Pinch to Zoom",
  "internet" : "No internet connection. Please connect to the internet."
},
    'tr': {
      "appTitle": "Diş Tanıma",
      "takePhoto": "Fotoğraf Çek",
      "pickGallery": "Galeriden Seç",
      "noImage": "Resim Seçilmedi",
      "hasCavity": "Dişiniz Çürük",
      "hasNoCavity": "Dişinizde Çürük Yok",
      "teethRes": "Diş Analizi Sonucu",
      "ok": "Tamam",
      "noTeeth": "Diş Tespit Edilmedi",
      "pTakePhoto": "Lütfen, sadece dişinizin fotoğrafını çekin",
      "att": "DİKKAT!",
      "info":
      "Fotoğraf çekerken lütfen kameranızın flaşının açık olduğundan ve dişlerinizin net bir şekilde görünüp ışığın gölge yapmadığından emin olunuz.",
      "dShow": "Tekrar Gösterme",
      "err": "Hata",
      "zoom": "Yakınlaştır",
       "internet":"İnternet bağlantısı yok. Lütfen internete bağlanın."  },
  };
}
