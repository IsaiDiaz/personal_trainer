import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'vision_detector_views/pose_detector_view.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

int iSeries = 0;
int iReps = 0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void _trainingConfigurations (){
      showDialog(
        context: context, 
        builder: ((context) {
          return AlertDialog(
          title: Text('Ingrese el entrenamiento que realizara hoy'),
          content: Column(
            children: [
              Container(
                height: 50,
              ),
              Text('Series:'),
              TextField(
                decoration: InputDecoration(
                  hintText: 'cantidad de series de su entrenamiento'
                ),
                onChanged: (value) {
                  iSeries = int.parse(value);
                  print(iSeries);
                },
              ),
              Container(
                height: 50,
              ),
              Text('Repeticiones:'),
              TextField(
                decoration: InputDecoration(
                  hintText: 'cantidad de repeticiones por serie'
                ),
                onChanged: ((value) {
                  iReps = int.parse(value);
                  print(iReps);
                }),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: Text('Aceptar'))
          ],
          );
        })
      );
    }

    void showToast(){
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Se debe configurar el entrenamiento antes de empezar'),
          action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar,),
          ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenador personal', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xff08c0ff),
        actions: [
          IconButton(
            onPressed: (() {
              _trainingConfigurations();
            }), 
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: Stack(
          children: [
            Container(
              color: Color(0xff002431),
            ),
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/images/fondoEditado.jpg'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: height * 0.25 + 125),
              padding: EdgeInsets.all(30.0),
              width: width,
              child: Column(
                children: [
                  SingleChildScrollView(
                    child: Tips('assets/images/pesa.png',Colors.orange , 'Hacer deporte le ayuda a mantener una vida larga y saludable'),
                    scrollDirection: Axis.horizontal,
                  ),
                  SingleChildScrollView(
                    child: Tips('assets/images/corriendo(1).png', Colors.cyan, 'El ejercicio incrementa la masa muscular y la densidad mineral osea'),
                    scrollDirection: Axis.horizontal,
                  ),
                  SingleChildScrollView(
                    child: Tips('assets/images/saludable.png', Colors.lightGreen, 'reduce la susceptibilidad al estrés, aumenta la autoestima'),
                    scrollDirection: Axis.horizontal,
                  ),      
                ],
              ),
            ),
            Container(
            margin: EdgeInsets.only(left: (width * 0.5) - 62.5, top: height * 0.25),
            height: 125,
            width: 125,
            decoration: BoxDecoration(
              color: Color(0xFF08c0FF),
              shape: BoxShape.circle
            ),
            child: TextButton(
                child: Image(
                  height: 75,
                  width: 75,
                  image: AssetImage('assets/images/corriendo.png'),
                  ),
                onPressed: () {
                  if(iReps > 0 && iSeries > 0){
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PoseDetectorView()));
                  }else{
                    showToast();
                  }
                },
              ),
            ),
          ],
          ),
    );
  }

  Widget Tips (image, color, text){
    return(
      Row(
        children: [
          Container(
            margin: EdgeInsets.all(10.0),
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(image)
              )
            ),
          ),
          Container(
            width: 20,
          ),
          Text(text, style: TextStyle(fontSize: 18, color: Colors.white))
        ],
      )
    );
  }

}
