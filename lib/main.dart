import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ObsControlScreen(),
  ));
}

class ObsControlScreen extends StatefulWidget {
  const ObsControlScreen({Key? key}) : super(key: key);

  @override
  State<ObsControlScreen> createState() => _ObsControlScreenState();
}

class _ObsControlScreenState extends State<ObsControlScreen> {
  final String baseUrl = 'http://127.0.0.1:5000'; // Use your local IP if needed
  bool isRecording = false;
  bool isConnected = false;
  List<String> scenes = [];
  String? selectedScene;

  @override
  void initState() {
    super.initState();
    checkConnection();
    fetchScenes();
  }

  Future<void> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/status'));
      final data = jsonDecode(response.body);
      setState(() {
        isConnected = data['connected'] ?? false;
      });
    } catch (e) {
      setState(() => isConnected = false);
    }
  }

  Future<void> startRecording() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/start_recording'));
      final data = jsonDecode(response.body);
      if (data['status'] != null) {
        setState(() => isRecording = true);
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stop_recording'));
      final data = jsonDecode(response.body);
      if (data['status'] != null) {
        setState(() => isRecording = false);
      }
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  Future<void> fetchScenes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/scenes'));
      final data = jsonDecode(response.body);
      if (data is List) {
        setState(() => scenes = List<String>.from(data));
      }
    } catch (e) {
      print("Error fetching scenes: $e");
    }
  }

  Future<void> switchScene(String sceneName) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/switch_scene/$sceneName'));
      final data = jsonDecode(response.body);
      if (data['status'] != null) {
        setState(() => selectedScene = sceneName);
      }
    } catch (e) {
      print("Error switching scene: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBS Controller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              isConnected ? '✅ Connected to OBS' : '❌ Not connected to OBS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: checkConnection,
              child: const Text('Check OBS Connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRecording ? stopRecording : startRecording,
              child: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRecording ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedScene,
              hint: const Text("Select a scene"),
              items: scenes.map((scene) {
                return DropdownMenuItem(
                  value: scene,
                  child: Text(scene),
                );
              }).toList(),
              onChanged: (scene) {
                if (scene != null) {
                  switchScene(scene);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
