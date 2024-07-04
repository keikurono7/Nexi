import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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
  String responseText = "no caption yet";

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
            backgroundColor: Color(0xff80e0e0),
            shape: const CircleBorder(),
            onPressed: takePicture,
            child: const Icon(
              CupertinoIcons.camera,
              size: 40,
              color: Colors.black87,
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
