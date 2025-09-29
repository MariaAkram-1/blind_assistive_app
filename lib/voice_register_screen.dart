import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceRegisterScreen extends StatefulWidget {
  const VoiceRegisterScreen({super.key});

  @override
  State<VoiceRegisterScreen> createState() => _VoiceRegisterScreenState();
}

class _VoiceRegisterScreenState extends State<VoiceRegisterScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  String name = "";
  String age = "";
  String gender = "";
  String phone = "";

  int currentStep = 0; // 0=Name, 1=Age, 2=Gender, 3=Phone
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _startRegistration();
  }

  Future<void> _startRegistration() async {
    await _speak("Welcome to registration. Please say your name.");
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);

    // Jab bolna khatam ho jaye to listen start ho jaye
    flutterTts.setCompletionHandler(() {
      _listen();
    });
  }

  Future<void> _listen() async {
    bool available = await speech.initialize(
      onStatus: (status) => debugPrint("Status: $status"),
      onError: (error) => debugPrint("Error: $error"),
    );

    if (available) {
      setState(() => isListening = true);
      speech.listen(
        listenFor: const Duration(seconds: 10), // timeout fix
        onResult: (result) {
          if (result.finalResult) {
            _processResult(result.recognizedWords);
          }
        },
      );
    } else {
      await _speak("Speech recognition not available");
    }
  }

  void _processResult(String text) async {
    setState(() => isListening = false);
    speech.stop();

    if (currentStep == 0) {
      setState(() => name = text);
      currentStep = 1;
      await _speak("Got it. Please say your age.");
    } else if (currentStep == 1) {
      setState(() => age = text);
      currentStep = 2;
      await _speak("Thank you. Please say your gender.");
    } else if (currentStep == 2) {
      setState(() => gender = text);
      currentStep = 3;
      await _speak("Okay. Please say your phone number.");
    } else if (currentStep == 3) {
      setState(() => phone = text);
      currentStep = 4;
      await _speak("Registration complete. Welcome $name.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Registration")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Registration Form (Voice Filled)",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextFormField(
              decoration: const InputDecoration(labelText: "Name"),
              readOnly: true,
              controller: TextEditingController(text: name),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Age"),
              readOnly: true,
              controller: TextEditingController(text: age),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Gender"),
              readOnly: true,
              controller: TextEditingController(text: gender),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Phone Number"),
              readOnly: true,
              controller: TextEditingController(text: phone),
            ),

            const Spacer(),

            // Optional backup button (agar chaho to hata do)
            if (currentStep < 4)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 60),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: _listen,
                icon: const Icon(Icons.mic),
                label: Text(isListening ? "Listening..." : "Speak Again"),
              ),
          ],
        ),
      ),
    );
  }
}
