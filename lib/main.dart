import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("Token: $fcmToken");
  TorchController().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String messageTitle = "No Notice";
  String messageContent = "No body";
  String _text = "turn off";
  final torchController = TorchController();
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    torchController.initialize();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      setState(() {
        messageTitle = message.notification!.title!;
        messageContent = message.notification!.body!;
        toggleFlash();
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Opened from background message: ${message.notification?.title}");
      setState(() {
        messageTitle = message.notification!.title!;
        messageContent = message.notification!.body!;
        toggleFlash();
      });
    });
  }

  void toggleFlash() {
    _flashTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        torchController.toggle();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              messageTitle,
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              messageContent,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _text,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minRadius: 30,
              maxRadius: 35,
              child: Transform.scale(
                scale: 1.2,
                child: IconButton(
                  onPressed: () {
                    torchController.toggle();
                    if (_flashTimer != null && _flashTimer!.isActive) {
                      _flashTimer!.cancel();
                    }
                    setState(() {
                      if (_text == "turn off") {
                        _text = "turn on";
                      } else if (_text == "turn on") {
                        _text = "turn off";
                      }
                    });
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
