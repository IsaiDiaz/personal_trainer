import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:personal_trainer/vision_detector_views/painters/coordinates_translator.dart';

import 'camera_view.dart';
import 'painters/pose_painter.dart';

import 'package:personal_trainer/main.dart';

class PoseDetectorView extends StatefulWidget {
  bool abajo = false;
  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  int counter = 0;
  int actualSerie = 0;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Entrenador',
      customPaint: _customPaint,
      counter: counter,
      actualSerie: actualSerie,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  void showToast(){
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Entrenamiento Terminado! BIEN HECHO!'),
          action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar,),
          ),
      );
    }

  void exerciseDetector(poses){
    if(poses.length > 0){
        var pose = poses[0];
        PoseLandmark hombroIzq = pose.landmarks[PoseLandmarkType.leftShoulder]!;
        PoseLandmark hombroDer = pose.landmarks[PoseLandmarkType.rightShoulder]!;
        if(hombroIzq.y >= 450 && hombroIzq.y <= 550 && hombroDer.y >= 450 && hombroDer.y <= 550 && widget.abajo == false){
          counter += 1;
          widget.abajo = true;
        }
        if(widget.abajo == true && hombroIzq.y <= 450 && hombroDer.y <= 450){
          widget.abajo = false;
        }

        if (counter == iReps){
          counter = 0;
          actualSerie ++;
        }

        if(actualSerie == iSeries){
          counter = 0;
          actualSerie = 0;
          showToast();
        }
        //print('Izq: ${hombroIzq.y}:${hombroIzq.x}, Der: ${hombroDer.y}:${hombroIzq.x}');
      }
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);
    exerciseDetector(poses);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
