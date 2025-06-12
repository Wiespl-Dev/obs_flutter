import "package:flutter/material.dart";
import 'package:tdf_media_handler/components/client.dart';
import 'package:tdf_media_handler/components/controls.dart';
import 'package:tdf_media_handler/components/obs_box.dart';
import 'package:tdf_media_handler/components/server_box.dart';
import 'dart:async';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  bool presenting = false;
  bool connected = false;
  bool presenter = false;
  bool live = false;
  bool recording = false;
  String current_scene = "";
  bool isLoading = true;
  bool serverDown = true;
  List apps = [];
  List scenes = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    assignData();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      assignData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> assignData() async {
    setState(() {
      isLoading = true;
    });

    const timeoutDuration = Duration(seconds: 10);
    final rConnected =
        await BaseClientAPI().askInfo("/is_connected_to_obs").timeout(
              timeoutDuration,
              onTimeout: () => {"Error": "true"},
            );

    setState(() {
      isLoading = false;
    });

    if (rConnected["Error"] == "true" || rConnected.isEmpty) {
      setState(() {
        serverDown = true;
        connected = false;
      });
      return;
    }

    setState(() {
      serverDown = false;
    });

    try {
      final rPresenting = await BaseClientAPI().askInfo("/presenting");
      final rPresenter = await BaseClientAPI().askInfo("/presenter");
      final rLive = await BaseClientAPI().askInfo("/get_streaming_status");
      final rRecording = await BaseClientAPI().askInfo("/get_recording_status");
      final rCurrentScene = await BaseClientAPI().askInfo("/get_current_scene");
      final rApps = await BaseClientAPI().askInfo("/get_open_windows");
      final rScenes = await BaseClientAPI().askInfo("/get_scenes");

      setState(() {
        presenting = _safeBoolParse(rPresenting["Data"]);
        presenter = _safeBoolParse(rPresenter["Data"]);
        apps = _safeListParse(rApps["Data"]);
        connected = true;
        live = _safeBoolParse(rLive["Data"]);
        recording = _safeBoolParse(rRecording["Data"]);
        current_scene = rCurrentScene["Data"] ?? "";
        scenes = _safeListParse(rScenes["Data"]);
      });
    } catch (e) {
      print("Error during fetching OBS data: $e");
    }
  }

  bool _safeBoolParse(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == "true";
    return false;
  }

  List _safeListParse(dynamic value) {
    if (value is List) return value;
    return []; // fallback in case the API returns a String or other type
  }

  @override
  Widget build(BuildContext context) {
    List<String> allScenes = List<String>.from(scenes.whereType<String>());

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : !serverDown
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ServerBox(
                          apps: apps,
                          serverDown: serverDown,
                          presenting: presenting,
                          connected: connected,
                          presenter: presenter,
                        ),
                        ObsBox(
                          connected: connected,
                          serverDown: serverDown,
                          live: live,
                          recording: recording,
                          current_scene: current_scene,
                          scenes: allScenes,
                        ),
                        ControlBox(
                          connected: connected,
                          serverDown: serverDown,
                          live: live,
                          recording: recording,
                          current_scene: current_scene,
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: 300,
                        padding: const EdgeInsets.all(25),
                        child: const Text(
                          "The app wasn't able to connect to the server. Please check if the server is up or not. If the problem persists, please inform the devs.",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            const Text(
                              "Trying to reconnect...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: assignData,
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              label: const Text(
                                "Retry Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
