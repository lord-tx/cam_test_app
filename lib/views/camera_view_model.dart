import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class CameraViewModel extends BaseViewModel{

  late List<CameraDescription> _cameras;
  CameraController? controller;
  List<XFile> sessionImages = [];
  bool primaryCamera = true;

  /// Flash Control Variables
  static const int inactiveState = 0;
  static const int activeState = 1;
  static const int autoState = 2;

  IconData? flashIcon;
  List<int> flashState = [inactiveState, activeState, autoState];
  late int currentFlashState = flashState.first; // NOTE: Or last saved flash state
  /// End of Flash Control Variables


  Future setCameraController() async {
    // Sets busy to true before starting future and sets it to false after executing
    // You can also pass in an object as the busy object. Otherwise it'll use the ViewModel
    var result = await runBusyFuture(prepareCamera());
    if (result == true){
      debugPrint("Stack got here");
      setInitialised(true);
      notifyListeners();
    }
  }

  Future prepareCamera({CameraDescription? selectedCamera}) async {
    _cameras = await availableCameras();
    debugPrint("Stack got prepare ${_cameras}");
    primaryCamera = !primaryCamera;
    print(primaryCamera);
    try {
      controller = CameraController(selectedCamera ?? _cameras.first, ResolutionPreset.ultraHigh);
    } catch (e) {
      print(e.runtimeType);
    }

    controller?.initialize().then((_) {
      // NOTE: Camera would not start if this is not called.
      notifyListeners();
    }).catchError((Object e) {
      print(e);
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('User denied camera access.');
            break;
          default:
            debugPrint('Handle other errors.');
            break;
        }
      }
    });
    return true;
  }

  void switchCamera(){
    primaryCamera
    ? prepareCamera(selectedCamera: _cameras.first) :
    prepareCamera(selectedCamera: _cameras.last);
  }


  Future<XFile?> takePicture(context) async {
    final CameraController? cameraController = controller;
    if (!(cameraController?.value.isInitialized ?? false)) {
      showInSnackBar('Error: select a camera first.', context);
      return null;
    }

    if ((cameraController?.value.isTakingPicture ?? true)) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile? file = await cameraController?.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e, context);
      return null;
    }
  }

  void showInSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e, context) {
    // _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}', context);
  }

  void onTakePictureButtonPressed(BuildContext context) {
    setBusy(true);
    takePicture(context).then((XFile? file) {
      // if (mounted) {
        // setState(() {
        //
        //   videoController?.dispose();
        //   videoController = null;
        // });
        if (file != null) {
          sessionImages.add(file);
          print(sessionImages);
          showInSnackBar('Picture saved to ${file.path}', context);
        }
        notifyListeners();
        setBusy(false);
      // }
    });
  }

  void init() async {
    setCameraController();
  }

  void onFlashClick(){
    currentFlashState = changeFlashState();
    debugPrint(currentFlashState.toString());
    switch (currentFlashState){
      case inactiveState:
        flashIcon = Icons.flash_off;
        controller?.setFlashMode(FlashMode.off);
        break;

      case activeState:
        flashIcon = Icons.flash_on;
        controller?.setFlashMode(FlashMode.torch);
        break;

      case autoState:
        flashIcon = Icons.flash_auto;
        controller?.setFlashMode(FlashMode.auto);
        break;
    }
    notifyListeners();
  }

  int changeFlashState(){
    /// 🥸
    return ++currentFlashState % flashState.length;
  }

  @override
  void dispose(){
    super.dispose();
    controller?.dispose();
  }
}