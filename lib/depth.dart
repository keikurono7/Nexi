import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



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
  String responseText = "nothing";

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8',
  );

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

    // Prepare your API authentication
    final uname = 'acc_8f0ef6960cd9068';
    final pword = '571bbca97e4222db02150267af7c069c';
    final authn = 'Basic YWNjXzhmMGVmNjk2MGNkOTA2ODo1NzFiYmNhOTdlNDIyMmRiMDIxNTAyNjdhZjdjMDY5Yw==';
    
    // Define your API endpoint
    final url = Uri.parse('https://api.imagga.com/v2/tags');
    
    // Prepare the request headers and body
    final headers = {
      'Authorization': authn,
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'image_base64': base64Encode(imageData),
    };

    // Send the POST request to Imagga API
    final response = await http.post(url, headers: headers, body: body);

    // Handle response (print for now, you can update based on your needs)
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    final content = [Content.text("Only generate a single caption for the given data and don't use adjectives and instead of businessperson use person and instead of saying "+response.body)];
    final response2 = await model.generateContent(content);
    setState(() {
      responseText = response2.text ?? "No response";
      print(responseText);
    });

  } catch (e, stackTrace) {
    print("Error taking picture: $e");
    print(stackTrace);
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
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
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
              Icons.question_mark,
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
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    width: width * 0.9,
                    height: height * 0.87,
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
          Container(
            padding: EdgeInsets.all(width*0.05),
            color: Theme.of(context).colorScheme.secondaryContainer,
            height: responseText == "nothing"? 0 : 100,
            width: responseText == "nothing"? 0 : width,
            child: SingleChildScrollView(child: Center(child: Text(responseText))),
          )
        ],
      ),
    );
  }
}
