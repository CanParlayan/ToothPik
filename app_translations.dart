import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'appTitle': 'Dental Recognition',
          'takePhoto': 'Take A Photo',
          'pickGallery': 'Pick From Gallery',
          'noImage': 'No Image Selected',
          "haveCavity": "Your teeth have cavity.",
          "haveNoCavity": "Your teeth are cavity-free.",
          "teethRes": "Teeth Classification Result",
          "ok": "OK",
          "noTeeth": "No Teeth Detected",
          "pTakePhoto": "Please take a photo of your teeth",
          "att": "ATTENTION!",
          "info":
              "When taking the photo, Please make sure your teeth are clearly visible and your camera's flash is on and the light does not cast a shadow.",
          "dShow": "Don't Show Again",
          "err": "Error",
          "zoom": "Pinch to Zoom"
        },
        'tr': {
          "appTitle": "Diş Tanıma",
          "takePhoto": "Fotoğraf Çek",
          "pickGallery": "Galeriden Seç",
          "noImage": "Resim Seçilmedi",
          "haveCavity": "Dişiniz Çürük",
          "haveNoCavity": "Dişinizde Çürük Yok",
          "teethRes": "Diş Analizi Sonucu",
          "ok": "Tamam",
          "noTeeth": "Diş Tespit Edilmedi",
          "pTakePhoto": "Lütfen, sadece dişinizin fotoğrafını çekin",
          "att": "DİKKAT!",
          "info":
              "Fotoğraf çekerken lütfen kameranızın flaşının açık olduğundan ve dişlerinizin net bir şekilde görünüp ışığın gölge yapmadığından emin olunuz.",
          "dShow": "Tekrar Gösterme",
          "err": "Hata",
          "zoom": "Yakınlaştırmak İçin Dokun"
        },
      };
}
