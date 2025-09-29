import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'object_detect_screen.dart';
import 'voice_register_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const BlindAssistiveApp());
}

class BlindAssistiveApp extends StatelessWidget {
  const BlindAssistiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blind Assistive App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

/// 👇 Ye class missing thi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  void openCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: cameras.first),
      ),
    );
  }

  void openVoiceRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceRegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blind Assistive App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 70),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: openVoiceRegister,
              child: const Text("Register with Voice"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(300, 70),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: openCamera,
              child: const Text("Capture"),
            ),
          ],
        ),
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({super.key, required this.camera});

  @override
  State<TakePictureScreen> createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      final file = await _controller.takePicture();
      await file.saveTo(path);

      await speak("Photo captured");

      // Navigate to ObjectDetectScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ObjectDetectScreen(imagePath: path),
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
      await speak("Error capturing photo");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Photo')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _takePicture,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
