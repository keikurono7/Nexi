import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class Depth extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Depth({super.key, required this.cameras});

  @override
  State<Depth> createState() => _DepthState();
}

class _DepthState extends State<Depth> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  Uint8List? imageData;
  bool isRearCamera = true;
  String responseText = "no caption yet";

  @override
  void initState() {
    super.initState();
    startCamera(0);
    loadModel();
  }

  @override
  void dispose() {
    cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print(res);
  }

  Future<void> takePicture() async {
    if (cameraController.value.isTakingPicture || !cameraController.value.isInitialized) {
      return;
    }

    try {
      XFile image = await cameraController.takePicture();
      Uint8List imageData = await image.readAsBytes();
      setState(() {
        this.imageData = imageData;
      });

      // Save image to temporary file
      String imagePath = await saveImage(imageData);

      // Run TFLite model inference
      runModelOnImage(imagePath);

    } catch (e, stackTrace) {
      print("Error taking picture: $e");
      print(stackTrace);
    }
  }

  Future<String> saveImage(Uint8List imageData) async {
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Pictures';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';
    File(filePath).writeAsBytesSync(imageData);
    return filePath;
  }

  Future<void> runModelOnImage(String imagePath) async {
    var output = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 5,
      threshold: 0.5,
    );

    setState(() {
      responseText = output?.map((e) => e['label']).join(', ') ?? "No response";
      print(responseText);
    });
  }

  void startCamera(int camera) {
    cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.high,
      enableAudio: false,
    );
    cameraValue = cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            backgroundColor: Color(0xff98bdde),
            shape: const CircleBorder(),
            onPressed: takePicture,
            child: const Icon(
              CupertinoIcons.camera,
              size: 40,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff80e0e0), Color(0xff736cc7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(width*0.05),
              height: height*0.095,
              width: width*0.9,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 150, 144, 214),
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: SingleChildScrollView(child: Center(child: Text(responseText))),
            ),
            FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: width * 0.9,
                      height: height * 0.75,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: CameraPreview(cameraController),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
