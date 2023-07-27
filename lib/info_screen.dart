import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  InfoScreenState createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('att'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("info".tr),
          CheckboxListTile(
            title: Text("dShow".tr),
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (_isChecked) {
              _saveInfoScreenPreference();
            }
          },
          child: Text('ok'.tr),
        ),
      ],
    );
  }

  void _saveInfoScreenPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showInfoScreen', false);
  }
}
