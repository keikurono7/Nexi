import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => ChatbotState();
}

class ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyBlbaYo1uoMCYz2FGoFfvilZ9oPmy-Mcw8',
  );

  String responseText = "Heyy there, How can I help you today?";

  Future<void> generateContent(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    setState(() {
      responseText = response.text ?? "No response";
    });
  }

  Widget buildResponse(String text) {
    List<TextSpan> textSpans = [];

    // Split text based on * to determine bold sections
    List<String> parts = text.split('*');
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Normal text
        textSpans.add(TextSpan(text: parts[i], style: TextStyle(color: Colors.black)));
      } else {
        // Bold text
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        leading: Icon(Icons.android, color: Colors.white,),
        title: Text(
          "NEXI",
          style: TextStyle(color: Colors.white, fontFamily: 'Grandstander'),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Icon(Icons.send, color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () {
                generateContent(_controller.text);
                _controller.clear();
              }),
          FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Icon(Icons.headphones, color: Theme.of(context).colorScheme.onSecondary),
              onPressed: () {
                generateContent(_controller.text);
                _controller.clear();
              }),
        ],
      ),
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
