import 'package:chatbot1/home.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nexi',
      theme: ThemeData(
        fontFamily: 'Museo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo.shade100),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Chatbot 1',cameras: cameras),
    );
  }
}

//AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8