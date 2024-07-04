import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => ChatbotState();
}

class ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  List<String> past = ["hii", "heyy there"];
  String responseText = "Heyy there, How can I help you today?";

  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8',
  );

  Future<void> generateContent(String prompt) async {
    past.add(prompt);
    String conversationContext = "";
    for (int i = 0; i < past.length - 1; i += 2) {
      conversationContext += "[ person : ${past[i]} ] [ gemini response : ${past[i+1]} ] ";
    }
    conversationContext += "Continue the conversation as a therapist would and only answer the question. The person asks $prompt";
    final content = [Content.text(conversationContext)];
    final response = await model.generateContent(content);
    setState(() {
      responseText = response.text ?? "No response";
    });
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Icon(Icons.headphones, color: Theme.of(context).colorScheme.onSecondary),
          onPressed: () {
            generateContent(_controller.text);
            _controller.clear();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.android,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 100,
          ),
          Container(
            height: height * 0.5,
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
            padding: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
            child: TextField(
              textInputAction: TextInputAction.go,
              controller: _controller,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(),
                  labelText: "Enter your text",
                  hintText: ""),
            ),
          ),
        ],
      ),
    );
  }
}
