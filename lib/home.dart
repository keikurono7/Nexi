import 'package:camera/camera.dart';
import 'package:chatbot1/chat.dart';
import 'package:chatbot1/depth.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MyHomePage({super.key, required this.title, required this.cameras});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentTab = 0;
  late List<Widget> screens;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    screens = [
      Chatbot(),
      Depth(cameras: widget.cameras),
    ];
    _pageController = PageController(initialPage: currentTab);
  }

  void onPageChanged(int index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: screens,
      ),
    );
  }
}
