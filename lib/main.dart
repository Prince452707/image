
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name on Image App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NameOnImagePage(),
    );
  }
}

class NameOnImagePage extends StatefulWidget {
  @override
  _NameOnImagePageState createState() => _NameOnImagePageState();
}

class _NameOnImagePageState extends State<NameOnImagePage> {
  String _name = '';
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List? _imageFile;

  Future<void> _generateImage() async {
    final imageFile = await screenshotController.capture();
    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _downloadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please generate an image first.')),
      );
      return;
    }

    try {
      // For Android 10 and above
      if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted) {
          String directory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_PICTURES);
          String fileName = 'name_on_image_${DateTime.now().millisecondsSinceEpoch}.png';
          String filePath = '$directory/$fileName';

          File file = File(filePath);
          await file.writeAsBytes(_imageFile!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image saved to $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission denied')),
          );
        }
      } 
      // For iOS and older Android versions
      else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'name_on_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${directory.path}/$fileName';

        File file = File(filePath);
        await file.writeAsBytes(_imageFile!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $filePath')),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while saving the image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Name on Image'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Screenshot(
                controller: screenshotController,
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateImage,
                child: Text('Generate Image'),
              ),
              SizedBox(height: 20),
              if (_imageFile != null) ...[
                Image.memory(_imageFile!, width: 300, height: 200),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _downloadImage,
                  child: Text('Download Image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}