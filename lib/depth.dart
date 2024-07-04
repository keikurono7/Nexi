import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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

  Future<void> takePicture() async {
    if (cameraController.value.isTakingPicture || !cameraController.value.isInitialized) {
      return;
    }

    try {
      XFile image = await cameraController.takePicture();
      imageData = await image.readAsBytes();
      setState(() {
        // Update UI or any state changes if needed
      });

      await uploadImageToFirebase(imageData!, path.basename(image.path));

    } catch (e, stackTrace) {
      print("Error taking picture: $e");
      print(stackTrace);
    }
  }

  Future<void> uploadImageToFirebase(Uint8List imageBytes, String fileName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = storage.ref().child('images/$fileName');

      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Download URL: $downloadUrl');

      // Now you can use the downloadUrl as needed
      // e.g., save it to Firestore, display it in your app, etc.

    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
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
    Firebase.initializeApp().then((_) {
      startCamera(0); // Initialize camera after Firebase is initialized
    });
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            onPressed: takePicture,
            child: const Icon(
              Icons.camera_alt,
              size: 40,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          FutureBuilder(
            future: cameraValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: width * 0.9,
                    height: height * 0.87,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
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
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7, bottom: 75),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageData != null
                          ? Padding(
                              padding: const EdgeInsets.all(2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  imageData!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
