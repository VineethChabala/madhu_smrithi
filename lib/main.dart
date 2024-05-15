import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:camera/camera.dart';
import 'package:madhu_smrithi/Screens/cameraScreen.dart';

List<CameraDescription> cameras=[];
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(background: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      title: const Text(
        "Madhu Smriti",
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
      ),
    );
  }

  Widget buildMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "MENU",
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 15),
        const ProfilePicture(
          name: "Vineeth Babu",
          radius: 60,
          fontsize: 20,
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Profile Settings",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget buildCheckWidget(
      String imagePath, String buttonText, VoidCallback onPressed) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset(imagePath),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildMenu(),
            buildCheckWidget(
                'D:\\SEM\\Sem 8\\Samarth\\madhu_smrithi\\assets\\Images\\checkppg.jpg',
                "Check PPG", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraApp()),
              );
            }),
            buildCheckWidget(
                'D:\\SEM\\Sem 8\\Samarth\\madhu_smrithi\\assets\\Images\\checkdiabetes.jpg',
                "Check Glucose",
                () {}),
            buildCheckWidget(
                'D:\\SEM\\Sem 8\\Samarth\\madhu_smrithi\\assets\\Images\\analyzediabetes.jpg',
                "Analyze Glucose",
                () {}),
          ],
        ),
      ),
    );
  }
}
