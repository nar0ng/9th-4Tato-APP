import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class Result extends StatefulWidget {
  final List<String> imagePaths;
  const Result({Key? key, required this.imagePaths}) : super(key: key);

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  int _currentBackgroundIndex = 0;
  final GlobalKey _boundaryKey = GlobalKey();
  final List<Decoration> _backgrounds = [
    BoxDecoration(
      color: Colors.blue,
    ),
    BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red, Colors.orange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/logo1.png'),
        fit: BoxFit.cover,
      ),
    ),
    BoxDecoration(
      color: Colors.red,
    ),
  ];

  // 이미지 캡처 및 파일 저장 메서드
  Future<void> _captureAndSaveImage() async {
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      ui.Image capturedImage = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData =
          await capturedImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final directory = await getApplicationDocumentsDirectory();

        // 고유한 파일 이름을 만들기 위해 현재 시간을 사용
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath =
            '${directory.path}/captured_image_$timestamp.png'; // 파일 경로를 고유하게 지정

        // 파일 경로를 지정하고, 파일을 저장
        final file = File(filePath);
        // 바이트 데이터를 파일로 쓰기
        await file.writeAsBytes(byteData.buffer.asUint8List());

        print("이미지가 파일에 저장되었습니다: $filePath");

        showImageViewer(context, filePath);
      }
    } catch (e) {
      print("이미지 캡처 또는 저장 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('촬영한 이미지'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: Container(
                decoration: _backgrounds[_currentBackgroundIndex],
                padding: EdgeInsets.all(30), // 내부 여백
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 한 행당 열의 수 (2열)
                    mainAxisSpacing: 10, // 행 간격 (위아래)
                    crossAxisSpacing: 10, // 열 간격 (좌우)
                    childAspectRatio: 0.8, //비율
                  ),
                  itemCount: widget.imagePaths.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      child: Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_currentBackgroundIndex < 3) {
                  _currentBackgroundIndex = _currentBackgroundIndex + 1;
                } else {
                  _currentBackgroundIndex = 0;
                }
              });
            },
            child: Text("스타일 변경"),
          ),
          ElevatedButton(
            onPressed: _captureAndSaveImage,
            child: Text("저장하기"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("다시 찍기"),
          ),
          ElevatedButton(
            onPressed: () {
              // 홈으로 버튼 동작
            },
            child: Text("홈으로"),
          ),
        ],
      ),
    );
  }
}

class ImageViewerScreen extends StatelessWidget {
  final String imagePath;

  const ImageViewerScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이미지 보기'),
      ),
      body: Center(
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

void showImageViewer(BuildContext context, String imagePath) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImageViewerScreen(imagePath: imagePath),
    ),
  );
}
