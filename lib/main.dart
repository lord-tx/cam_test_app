import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'app.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CameraApp());
}

