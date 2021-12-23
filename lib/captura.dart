import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class CapturaPage extends StatefulWidget {
  const CapturaPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CapturaPageState();
}

class _CapturaPageState extends State<CapturaPage> {
  File? image;
  String? base64img;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  _openGallery() async {
    var selectImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 1);
    setState(() {
      image = File(selectImage!.path);
      // log(image!.path);
      // log(base64Encode(image!.readAsBytesSync()));
      base64img = base64Encode(image!.readAsBytesSync());
    });
    Navigator.of(context).pop();
  }

  _openCamera() async {
    var selectImage = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      image = File(selectImage!.path);
      // log(image!.path);
      // log(base64Encode(image!.readAsBytesSync()));
      base64img = base64Encode(image!.readAsBytesSync());
    });
    Navigator.of(context).pop();
  }

  Future<void> _showSelectDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona una opción'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Row(
                    children: const [
                      Text('Galería'),
                      Padding(padding: EdgeInsets.only(left: 16.0)),
                      Icon(Icons.photo_library)
                    ],
                  ),
                  onTap: () {
                    log('Clic en galería');
                    _openGallery();
                  },
                ),
                const Padding(padding: EdgeInsets.all(16.0)),
                GestureDetector(
                  child: Row(
                    children: const [
                      Text('Camara'),
                      Padding(padding: EdgeInsets.only(left: 16.0)),
                      Icon(Icons.camera_enhance)
                    ],
                  ),
                  onTap: () {
                    log('Clic en camara');
                    _openCamera();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      return Future.error('Locations services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Locations services are disabled per user');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _enviarRegistro() async {
    Position position = await _determinePosition();
    log(base64img!);
    log(titleController.text);
    log(descriptionController.text);
    log("${position.latitude}");
    log("${position.longitude}");

    var url = Uri.parse(
        'https://us-central1-cibi-40673.cloudfunctions.net/evidenciaapp');
    var response = await http.post(url, body: {
      'title': titleController.text,
      'description': descriptionController.text,
      'base64img': base64img,
      'latitude': "${position.latitude}",
      'longitude': "${position.longitude}",
    });
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        image = null;
        base64img = '';
        titleController.text = '';
        descriptionController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso de galería y camara'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              (image == null)
                  ? const Text('Sin imagen')
                  : Image.file(
                      image!,
                      width: 400,
                      height: 400,
                    ),
              ElevatedButton(
                onPressed: () {
                  _showSelectDialog();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Seleccionar:'),
                    Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Icon(Icons.image),
                    Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Icon(Icons.camera_alt)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _enviarRegistro();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Enviar registro'),
                    Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Icon(Icons.send_rounded)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
