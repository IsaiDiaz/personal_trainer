import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:just_audio/just_audio.dart';
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
  late AudioPlayer playerBell;
  late AudioPlayer playerHalf;
  late AudioPlayer playerUno;
  late AudioPlayer playerDos;
  late AudioPlayer playerTres;
  late AudioPlayer playerCuatro;
  late AudioPlayer playerCinco;
  late AudioPlayer playerSeis;
  late AudioPlayer playerSiete;
  late AudioPlayer playerOcho;
  late AudioPlayer playerNueve;
  late AudioPlayer playerDiez;


  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  int counter = iReps;
  int actualSerie = 0;
  String? _text;


  @override
  void initState(){
    super.initState();
    playerBell = AudioPlayer();
    playerHalf = AudioPlayer();
    playerUno = AudioPlayer();
    playerDos = AudioPlayer();
    playerTres = AudioPlayer();
    playerCuatro = AudioPlayer();
    playerCinco = AudioPlayer();
    playerSeis = AudioPlayer();
    playerSiete = AudioPlayer();
    playerOcho = AudioPlayer();
    playerNueve = AudioPlayer();
    playerDiez = AudioPlayer();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    playerBell.dispose();
    playerHalf.dispose();
    playerUno.dispose();
    playerDos.dispose();
    playerTres.dispose();
    playerCuatro.dispose();
    playerCinco.dispose();
    playerSeis.dispose();
    playerSiete.dispose();
    playerOcho.dispose();
    playerNueve.dispose();
    playerDiez.dispose();
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

  void playBell() async {
    await playerBell.setAsset('assets/sounds/campana2.mp3');
    playerBell.play();
  }

  void playHalf() async {
    await playerHalf.setAsset('assets/sounds/campana3.mp3');
    playerHalf.play();
  }

  void playOne() async {
    await playerUno.setAsset('assets/sounds/Uno.ogg');
    playerUno.play();
  }

  void playTwo() async {
    await playerDos.setAsset('assets/sounds/Dos.ogg');
    playerDos.play();
  }

  void playThree() async {
    await playerTres.setAsset('assets/sounds/Tres.ogg');
    playerTres.play();
  }

  void playFour() async {
    await playerCuatro.setAsset('assets/sounds/Cuatro.ogg');
    playerCuatro.play();
  }

  void playFive() async {
    await playerCinco.setAsset('assets/sounds/Cinco.ogg');
    playerCinco.play();
  }

  void playSix() async {
    await playerSeis.setAsset('assets/sounds/Seis.ogg');
    playerSeis.play();
  }

  void playSeven() async {
    await playerSiete.setAsset('assets/sounds/Siete.ogg');
    playerSiete.play();
  }

  void playEight() async {
    await playerOcho.setAsset('assets/sounds/Ocho.ogg');
    playerOcho.play();
  }

  void playNine() async {
    await playerNueve.setAsset('assets/sounds/Nueve.ogg');
    playerNueve.play();
  }

  void playTen() async {
    await playerDiez.setAsset('assets/sounds/Diez.ogg');
    playerDiez.play();
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
          counter -= 1;
          widget.abajo = true;
        }
        if(widget.abajo == true && hombroIzq.y <= 450 && hombroDer.y <= 450){
          widget.abajo = false;
        }

        if (counter == 0){
          counter = iReps;
          actualSerie ++;
        }

        if(counter - 1 <= iReps/2) {
          if(counter - 1 == (iReps/2).round()){
            playHalf();
          }else{
            switch (counter - 1) {
              case 1:
                playOne();
                break;
              case 2:
                playTwo();
                break;
              case 3:
                playThree();
                break;
              case 4:
                playFour();
                break;
              case 5:
                playFive();
                break;
              case 6:
                playSix();
                break;
              case 7:
                playSeven();
                break;
              case 8:
                playEight();
                break;
              case 9:
                playNine();
                break;
              case 10:
                playTen();
                break;
            }
          }
        }

        if(actualSerie == iSeries){
          playBell();
          counter = iReps;
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
