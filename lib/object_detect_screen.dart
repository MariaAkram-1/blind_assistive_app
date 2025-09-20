import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class ObjectDetectScreen extends StatefulWidget {
  final String imagePath;
  const ObjectDetectScreen({super.key, required this.imagePath});

  @override
  State<ObjectDetectScreen> createState() => _ObjectDetectScreenState();
}

class _ObjectDetectScreenState extends State<ObjectDetectScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String detectedObject = "Detecting...";

  @override
  void initState() {
    super.initState();
    _detectObject();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> _detectObject() async {
    final inputImage = InputImage.fromFilePath(widget.imagePath);

    // Object detector options
    final options = ObjectDetectorOptions(
      mode: DetectionMode.single,
      classifyObjects: true,
      multipleObjects: false,
    );

    final objectDetector = ObjectDetector(options: options);

    final objects = await objectDetector.processImage(inputImage);

    if (objects.isNotEmpty) {
      final label = objects.first.labels.isNotEmpty
          ? objects.first.labels.first.text
          : "Unknown object";
      setState(() {
        detectedObject = "I see a $label";
      });
      await speak("I see a $label");
    } else {
      setState(() {
        detectedObject = "No object detected";
      });
      await speak("No object detected");
    }

    objectDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Object Detection")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(File(widget.imagePath),
                width: 300, height: 300, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(detectedObject, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
