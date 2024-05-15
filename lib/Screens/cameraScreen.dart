import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:madhu_smrithi/main.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  bool _isCameraInitialized = false;
  bool _isRecordingInProgress = false;
  final bool _isVideoCameraSelected = true;
  VideoPlayerController? videoController;
  late Timer timer;
  var _videoFile;

  void onNewCameraSelected(CameraDescription camdesc) async {
    final previousCameraController = controller;
    final CameraController cameraController = CameraController(
        camdesc, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg);
    await previousCameraController?.dispose();
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print("Error initialising Camera:$e");
    }
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    onNewCameraSelected(cameras[0]);
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  void didChangeAppLifeCycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController != null || cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> startRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || cameraController.value.isRecordingVideo) {
      return;
    }
    try {
      await cameraController.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print('Recording started');
      });
      timer = Timer(const Duration(seconds: 10), () {
        stopVideoRecording().catchError((error) {
          print('Error stopping recording: $error');
        });
      });
    } on CameraException catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        print('Recording stopped');
      });
      timer.cancel();
      return file;
    } on CameraException catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        _isCameraInitialized
            ? AspectRatio(
                aspectRatio: 1 / controller!.value.aspectRatio,
                child: controller!.buildPreview(),
              )
            : const Text("Camera ledu ra unga"),
        Row(
          children: [
            InkWell(
              onTap: () async {
                if (_isRecordingInProgress) {
                  XFile? rawVideo = await stopVideoRecording();
                  File videoFile = File(rawVideo!.path);
                  int currentUnix = DateTime.now().millisecondsSinceEpoch;
                  final dir = await getApplicationDocumentsDirectory();
                  String fileFormat = videoFile.path.split('.').last;
                  _videoFile = await videoFile
                      .copy("${dir.path}/$currentUnix.$fileFormat");
                  _startVideoPlayer();
                } else {
                  await startRecording();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color:
                        _isVideoCameraSelected ? Colors.white : Colors.white38,
                    size: 80,
                  ),
                  Icon(
                    Icons.circle,
                    color: _isVideoCameraSelected ? Colors.red : Colors.white,
                    size: 65,
                  ),
                  _isVideoCameraSelected && _isRecordingInProgress
                      ? const Icon(
                          Icons.stop_rounded,
                          color: Colors.white,
                          size: 32,
                        )
                      : Container(),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.white, width: 2)),
              child: videoController != null &&
                      videoController!.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: AspectRatio(
                        aspectRatio: videoController!.value.aspectRatio,
                        child: VideoPlayer(videoController!),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ],
    ));
  }
}
