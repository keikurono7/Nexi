import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => ChatbotState();
}

class ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  List<String> past = ["hii", "heyy there"];
  String responseText = "Heyy there, How can I help you today?";
  final String apiKey = 'AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8'; 

  Future<void> generateContent(String prompt) async {
    past.add(prompt);

    String conversationContext = "";
    for (int i = 0; i < past.length - 1; i += 2) {
      conversationContext +=
          "[ person : ${past[i]} ] [ gemini response : ${past[i + 1]} ] ";
    }
    conversationContext +=
        "Continue the conversation as a therapist would and only answer the question. The person asks $prompt";

    final headers = {
      'Content-Type': 'application/json',
    };

    final json_data = {
      'contents': [
        {
          'parts': [
            {
              'text': conversationContext,
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey'),
        headers: headers,
        body: json.encode(json_data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final generatedText =
            responseBody["candidates"][0]["content"]["parts"][0]["text"];
        past.add(generatedText);

        setState(() {
          responseText = generatedText ?? "No response";
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        responseText = "Error occurred. Please try again.";
      });
    }
  }

  Widget buildResponse(String text) {
    List<TextSpan> textSpans = [];

    List<String> parts = text.split('*');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        textSpans.add(TextSpan(text: parts[i], style: TextStyle(color: Colors.black)));
      } else {
        textSpans.add(TextSpan(text: parts[i], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)));
      }
    }

    return RichText(
      text: TextSpan(children: textSpans),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: Icon(CupertinoIcons.pen, color: Theme.of(context).colorScheme.onSecondary),
        onPressed: () {
          generateContent(_controller.text);
          _controller.clear();
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AvatarGlow(
              child: SizedBox(
                height: height * 0.25,
                child: Image(
                  image: AssetImage("asset/logo.png"),
                ),
              ),
            ),
            Container(
              height: height * 0.2,
              width: width * 0.8,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: SingleChildScrollView(
                child: buildResponse(responseText),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                textInputAction: TextInputAction.go,
                controller: _controller,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(),
                  labelText: "Enter your text",
                  hintText: "",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
