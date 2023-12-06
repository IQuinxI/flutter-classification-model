import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter interpreter;

  // Placeholder for input image data
  late List<List<List<double>>> inputData;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/best_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
    }
  }

  Future<void> runInference() async {
    try {
      await preprocessImage(); // Use image picker to select an image

      // Create input tensor
      var inputTensor =
          inputData; // Assuming inputData is already in the correct format

      // Create output tensor
      var outputTensor = List.filled(1 * 2, 0).reshape([1, 1]);

      // Run inference
      interpreter.run(inputTensor, outputTensor);

      // Access the output as needed
      processOutput(outputTensor);

      print('Inference complete');
    } catch (e) {
      print('Error during inference: $e');
    }
  }

  Future<void> preprocessImage() async {
    var imagePicker = ImagePicker();
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      img.Image image = img.decodeImage(File(imagePath).readAsBytesSync())!;

      // Resize image to match the model input size (150x150)
      img.Image resizedImage = img.copyResize(image, width: 150, height: 150);

      // Normalize pixel values to be in the range [0, 1]
      List<List<List<double>>> normalizedInput = [];
      for (int y = 0; y < resizedImage.height; y++) {
        List<List<double>> row = [];
        for (int x = 0; x < resizedImage.width; x++) {
          int pixel = resizedImage.getPixel(x, y);
          double normalizedValue = pixel / 255.0;
          row.add([normalizedValue, normalizedValue, normalizedValue]);
        }
        normalizedInput.add(row);
      }

      setState(() {
        inputData = normalizedInput;
      });
    } else {
      print('No image picked');
    }
  }

  void processOutput(List<dynamic> output) {
    // Process the model output based on your requirements
    // This will depend on the specifics of your model and the task it was trained for
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello, TensorFlow Lite!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: runInference,
              child: const Text('Run Inference'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => preprocessImage(),
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}
