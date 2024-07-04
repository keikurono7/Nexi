import 'package:camera/camera.dart';
import 'package:chatbot1/chat.dart';
import 'package:chatbot1/depth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const MyHomePage({super.key, required this.title, required this.cameras});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentTab = 1;
  late List<Widget> screens;
  late Widget currentScreen;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    screens = [
      Chatbot(),
      Depth(cameras: widget.cameras),
    ];
    currentScreen = screens[currentTab];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      child: Scaffold(
        body: PageStorage(bucket: bucket, child: currentScreen),
        bottomNavigationBar: BottomAppBar(
          height: 55,
          padding: EdgeInsets.all(0),
          color: currentTab == 1 ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(left: 20, right: 20, top: 0),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  minWidth: width*0.3,
                  onPressed: () {
                    setState(() {
                      currentScreen = screens[0];
                      currentTab = 0;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.circle,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        "Nexi",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  minWidth: width*0.3,
                  onPressed: () {
                    setState(() {
                      currentScreen = screens[1];
                      currentTab = 1;
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_call,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        "visual",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
