import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'widget/filter_selector.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Color selectedFilterColor = Colors.white; // warna filter
  XFile? capturedImage; // menyimpan

  final List<Color> _filters = [
    Colors.white, Colors.grey, Colors.blue, Colors.red, Colors.green
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onFilterChanged(Color filterColor) {
    setState(() {
      selectedFilterColor = filterColor;
    });
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    capturedImage = await _cameraController!.takePicture();
    setState(() {}); // update tampilan
  }

  Future<void> _retakePicture() async {
    setState(() {
      capturedImage = null; // hapus gambar dan kembali ke kamera
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("1122140108")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: capturedImage == null
                ? (_cameraController != null && _cameraController!.value.isInitialized
                    ? Stack(
                        children: [
                          CameraPreview(_cameraController!),
                          Container(
                            color: selectedFilterColor.withOpacity(0.3), // overlay filter
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()))
                : Stack(
                    children: [
                      Image.file(File(capturedImage!.path)),
                      Container(
                        color: selectedFilterColor.withOpacity(0.3), // overlay filter
                      ),
                    ],
                  ),
          ),

          if (capturedImage == null) 
            FilterSelector(
              filters: _filters,
              onFilterChanged: _onFilterChanged,
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: capturedImage == null
                ? ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text("ambil foto"),
                  )
                : ElevatedButton(
                    onPressed: _retakePicture,
                    child: const Text("ambil ulang"),
                  ),
          ),
        ],
      ),
    );
  }
}