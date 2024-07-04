import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Depth extends StatefulWidget {
  final List<CameraDescription> cameras;
  const Depth({Key? key, required this.cameras}) : super(key: key);

  @override
  State<Depth> createState() => _DepthState();
}

class _DepthState extends State<Depth> {
  late CameraController cameraController;
  late Future<void> cameraValue;
  Uint8List? imageData;
  String responseText = "No caption yet";

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

      final url = Uri.parse('http://10.0.2.2:5000/predict');
      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes('image', imageData, filename: 'image.jpg'));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200 && responseData != null) {
        setState(() {
          responseText = responseData['generated_text'] ?? "No caption generated";
        });
      } else {
        setState(() {
          responseText = "Failed to get caption";
        });
      }
    } catch (e, stackTrace) {
      print("Error taking picture: $e");
      print(stackTrace);
      setState(() {
        responseText = "Error taking picture";
      });
    }
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
  void initState() {
    super.initState();
    startCamera(0);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
        width: double.infinity,
        height: double.infinity,
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
              padding: EdgeInsets.all(width * 0.05),
              height: height * 0.095,
              width: width * 0.9,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 150, 144, 214),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Center(child: Text(responseText)),
              ),
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
