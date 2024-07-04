import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => ChatbotState();
}

class ChatbotState extends State<Chatbot> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _text = "";
  String responseText = "Hey there, How can I help you today?";

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8',
  );

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  Future<void> generateContent(String prompt) async {
    String conversationContext = "Continue the conversation as a therapist would and only answer the question. The person asks $prompt";
    final content = [Content.text(conversationContext)];
    final response = await model.generateContent(content);
    setState(() {
      responseText = response.text ?? "No response";
      _speak(responseText);
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            print('Recognized Words: $_text');  // Add this line for debugging
            generateContent(_text);
            _stopListening();
          }
        }),
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 5),
        localeId: 'en_US',
        onSoundLevelChange: (val) => print('Sound Level: $val'),  // Add this line for debugging
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      print('The user has denied the use of speech recognition.');
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff98bdde),
        shape: const CircleBorder(),
        child: Icon(_isListening ? CupertinoIcons.mic_off : CupertinoIcons.mic, color: Colors.white),
        onPressed: () {
          if (_isListening) {
            _stopListening();
          } else {
            _startListening();
          }
        },
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarGlow(
              child: Image(
                image: AssetImage("asset/logo.png"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                responseText,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
