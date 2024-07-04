import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(CupertinoIcons.mic, color: Theme.of(context).colorScheme.onSecondary),
          onPressed: () {
            generateContent(_controller.text);
            _controller.clear();
          }),
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
            Image(
              image: AssetImage(
                "asset/logo.png"
              )
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
      ),
    );
  }
}
