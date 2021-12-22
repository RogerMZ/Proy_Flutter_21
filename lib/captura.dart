import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CapturaPage extends StatefulWidget {
  const CapturaPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CapturaPageState();
}

class _CapturaPageState extends State<CapturaPage> {
  File? image;

  _openGallery() async {
    var selectImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
    setState(() {
      image = File(selectImage!.path);
      // log(image!.path);
      // log(base64Encode(image!.readAsBytesSync()));
    });
    Navigator.of(context).pop();
  }

  _openCamera() async {
    var selectImage = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      image = File(selectImage!.path);
      // log(image!.path);
      // log(base64Encode(image!.readAsBytesSync()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uso de galería y camara'),
      ),
      body: Center(
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
                decoration: const InputDecoration(
                  labelText: 'Titulo',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // _showSelectDialog();
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
    );
  }
}
