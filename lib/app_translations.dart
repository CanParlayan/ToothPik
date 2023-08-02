import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'appTitle': 'ToothPik',
          'takePhoto': 'Take A Photo',
          'pickGallery': 'From Gallery',
          'noImage': 'No Image Selected',
          "teethRes": "Teeth Classification Result",
          "ok": "OK",
          "noTeeth": "No Teeth Detected",
          "pTakePhoto": "Please take a photo of your teeth",
          "att": "ATTENTION!",
          "info":
              "When taking the photo, Please make sure your teeth are clearly visible and your camera's flash is on and the light does not cast a shadow.",
          "dShow": "Don't Show Again",
          "err": "Error",
          "errMsg":
              "An error occurred. Please report the error to the developer.",
          "zoom": "Zoom",
          "internet": "No internet connection. Please connect to the internet.",
          "notHealthyRes": "Although we could not detect the problem, we are sure that your teeth are unhealthy.",
          "healthyRes": "Your teeth are healthy. Please continue to take care of your teeth.",
          "calculusRes": "Your teeth have calculus.",
          "ulcerRes": "Your teeth have mouth ulcer.",
          "decayRes": "Your teeth have tooth decay.",
          "disclaimer": "Please consult a dentist for a more accurate result.",
          "and":"and",
  "doctor":"Please consult a dentist."
        },
        'tr': {
          "appTitle": "ÇekDiş",
          "takePhoto": "Fotoğraf Çek",
          "pickGallery": "Galeriden Seç",
          "noImage": "Resim Seçilmedi",
          "hasCavity": "Dişiniz çürük",
          "hasNoCavity": "Dişinizde çürük yok",
          "teethRes": "Diş Analizi Sonucu",
          "ok": "Tamam",
          "noTeeth": "Diş Tespit Edilmedi",
          "pTakePhoto": "Lütfen, sadece dişinizin fotoğrafını çekin",
          "att": "DİKKAT!",
          "info":
              "Fotoğraf çekerken lütfen kameranızın flaşının açık olduğundan ve dişlerinizin net bir şekilde görünüp ışığın gölge yapmadığından emin olunuz.",
          "dShow": "Tekrar Gösterme",
          "err": "Hata",
          "errMsg": "Bir hata oluştu. Lütfen hatayı geliştiriciye rapor edin.",
          "zoom": "Yakınlaştır",
          "internet": "İnternet bağlantısı yok. Lütfen internete bağlanın.",
              "notHealthyRes":"Sorunu tespit edemedik ama dişlerinizin sağlıksız olduğundan eminiz. Lütfen bir diş hekimine danışınız.",
          "healthyRes":"Dişleriniz sağlıklı. Lütfen dişlerinize dikkat etmeye devam ediniz.",
              "calculusRes":"Diş taşınız(tartarınız) var.",
          "ulcerRes":"Ağız ülseriniz var.",
          "decayRes":"Diş çürüğünüz var.",
  "disclaimer": "Kesin sonuç için lütfen bir diş hekimine danışınız.",
          "and":"ve",
          "doctor":"Lütfen bir diş hekimine danışınız."
        },
      };
}
