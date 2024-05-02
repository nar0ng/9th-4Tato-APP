import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'ResultView.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<CameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  List<String> _imagePaths = [];
  Timer? _timer; // 타이머
  int _count = 0; // 촬영된 사진의 수
  int _remainingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // 카메라 초기화 및 권한 요청
  Future<void> _initializeCamera() async {
    // 카메라 권한 확인 및 요청
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      // 권한이 거부된 경우 처리
      return;
    }

    // 카메라 초기화
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();

      setState(() {
        _isReady = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();
        final imagePath = image.path;

        setState(() {
          _imagePaths.add(imagePath);
          _count++;
          _remainingSeconds = 5;
        });

        if (_count >= 4) {
          _timer?.cancel();
          _count = 0;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Result(imagePaths: _imagePaths),
            ),
          );
        }
      } catch (e) {
        print('사진 촬영 실패: $e');
      }
    }
  }

  void _startAutoCapture() {
    // 남은 시간을 5초로 설정
    _remainingSeconds = 5;
    //찍은 사진 저장하던 배열 초기화
    _imagePaths = [];
    _count = 0;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }

        if (_remainingSeconds == 0) {
          _takePicture();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: SafeArea(
        child: _isReady
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.8,
                      child: CameraPreview(_controller!),
                    ),
                    ElevatedButton(
                      onPressed: _startAutoCapture,
                      child: Text("자동 촬영 시작"),
                    ),
                    Text("현재 찍힌 사진 : $_count"),
                    Text("다음 사진까지 남은 시간 : $_remainingSeconds"),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("준비 중"),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러 및 타이머 해제
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
