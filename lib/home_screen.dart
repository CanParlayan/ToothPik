import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel _viewModel = Get.find();

  HomeScreen({Key? key}) : super(key: key);

  Widget _buildInteractiveViewer(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: GestureDetector(
          onTap: () {
            _viewModel.setPinchToZoomOverlayVisible(false);
          },
          child: Stack(
            children: [
              Center(
                child: Obx(() => _viewModel.loading
                    ? const CircularProgressIndicator()
                    : _viewModel.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                _viewModel
                                    .setPinchToZoomOverlayVisible(false);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: InteractiveViewer(
                                  maxScale: 7.0,
                                  child: Image.file(
                                    _viewModel.image!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              ('noImage'.tr),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          )),
              ),
              Obx(() => _viewModel.pinchToZoomOverlayVisible
                  ? _buildPinchToZoomOverlay(BorderRadius.circular(50))
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinchToZoomOverlay(BorderRadius borderRadius) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: _viewModel.loading || !_viewModel.pinchToZoomOverlayVisible,
        child: GestureDetector(
          onTap: () {
            _viewModel.setPinchToZoomOverlayVisible(false);
          },
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Center(
              child: Text(
                'zoom'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text(
          'appTitle'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 23,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _viewModel.changeLanguage('en', 'US'),
            icon: SvgPicture.asset(
              'assets/flags/gb.svg',
              width: 24,
              height: 24,
            ),
          ),
          IconButton(
            onPressed: () => _viewModel.changeLanguage('tr', ''),
            icon: SvgPicture.asset(
              'assets/flags/tr.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromRGBO(68, 190, 255, 0.8),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 50),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              _buildInteractiveViewer(context),
              const SizedBox(height: 30),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _viewModel
                          .resetResultTextAndPickImage(ImageSource.camera);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'takePhoto'.tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _viewModel
                          .resetResultTextAndPickImage(ImageSource.gallery);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 200,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'pickGallery'.tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
        Obx(() => Text(_viewModel.resultText.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  )
        ),
                ],
              ),
              const SizedBox(
    height:
    20), // Add some space between the main content and the disclaimer
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
    'disclaimer'.tr,
    textAlign: TextAlign.center,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 8,
    ),
    ),
    ),

            ],
          ),
        ),
      ),
    );
  }
}
