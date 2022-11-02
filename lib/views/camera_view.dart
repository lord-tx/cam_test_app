import 'package:cam_test_app/views/camera_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'dart:io';

import 'captured_image.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraViewModel>.reactive(
      onModelReady: (viewModel) => viewModel.init(),
      onDispose: (viewModel) => viewModel.dispose(),
      viewModelBuilder: () => CameraViewModel(),
      builder: (context, viewModel, nRChild){
        // if (viewModel.controller.value.isInitialized) {
        //   return Container();
        // }

        return Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  iconSize: 40,
                  onPressed: (){
                    viewModel.onFlashClick();
                  },
                  icon: Icon(
                    viewModel.flashIcon ?? Icons.flash_off,
                    color: Colors.white,
                  )
              ),
              IconButton(
                  iconSize: 100,
                  onPressed: () {
                    viewModel.onTakePictureButtonPressed(context);
                  },
                  icon: const Icon(
                    Icons.camera,
                    color: Colors.white,
                  )
              ),
              viewModel.sessionImages.isEmpty ? IconButton(
                  iconSize: 40,
                  onPressed: (){},
                  icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                  )
              ) :
              Hero(
                tag: "captured-image",
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CapturedImages(images: viewModel.sessionImages.reversed.toList())));
                  },
                  child: Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.all(5),
                      width: 40,
                      height: 60,
                      child: Image.file(File(viewModel.sessionImages.last.path))
                  ),
                ),
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          body: GestureDetector(
            onVerticalDragEnd: (DragEndDetails details){
              // debugPrint(details.toString());
              // NOTE: This is for a drag up motion and has a fixed value
              if (details.velocity.pixelsPerSecond.dy < 500){
                debugPrint("Switch Camera");
                viewModel.switchCamera();
              }
            },
            child: Container(
              color: viewModel.isBusy ? Colors.white : Colors.transparent,
              padding: viewModel.isBusy ? const EdgeInsets.all(5) : EdgeInsets.zero,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: viewModel.initialised ?
                CameraPreview(viewModel.controller!)
                : Container()
            ),
          ),
        );
      },
      fireOnModelReadyOnce: true,
    );
  }
}
