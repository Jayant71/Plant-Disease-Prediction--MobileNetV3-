import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  File? _image;
  Interpreter? interpreter;
  List<String> labels = [];
  int resultIndex = -1;
  List<List<List<num>>> imageMatrixF = [];

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 100);

    if (pickedImage != null) {
      _image = File(pickedImage.path);
      imageMatrixF = await convertImageToMatrix(_image!);
      // print(imageMatrixF.shape);
    } else {
      debugPrint('No image selected.');
    }
    setState(() {});
  }

  Future _captureImage() async {
    final picker = ImagePicker();
    final capturedImage = await picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 100);

    if (capturedImage != null) {
      _image = File(capturedImage.path);
      imageMatrixF = await convertImageToMatrix(_image!);
      print(imageMatrixF.shape);
    } else {
      debugPrint('No image captured.');
    }
    setState(() {});
  }

  // Convert image to matrix
  Future<List<List<List<num>>>> convertImageToMatrix(File imageFile) async {
    // Load the image
    final image = img.decodeImage(await imageFile.readAsBytes())!;

    List<List<List<num>>> imageMatrix = [];

    for (int y = 0; y < image.height; y++) {
      List<List<num>> row = [];
      for (int x = 0; x < image.width; x++) {
        // Get the pixel color
        var pixelColor = image.getPixel(x, y);

        // Break the color into RGBA components
        int red = pixelColor.r.toInt();
        int green = pixelColor.g.toInt();
        int blue = pixelColor.b.toInt();
        // int alpha = pixelColor.a.toInt();

        // Add the components to the row
        row.add([red, green, blue]);
      }
      // Add the row to the matrix
      imageMatrix.add(row);
    }
    debugPrint(imageMatrix.length.toString());
    return imageMatrix;
  }

  // Load model
  Future<void> _loadModel() async {
    final options = InterpreterOptions();
    const modelPath = 'assets/model_MobileNetv3L_finetuned.tflite';
    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 224, 224, 3]
    // var inputTensor = interpreter!.getInputTensors().first;
    // Get tensor output shape [1, 1001]
    // var outputTensor = interpreter!.getOutputTensors().first;
    // debugPrint('Input tensor shape: ${inputTensor.shape}');
    // debugPrint('Output tensor shape: ${outputTensor.shape}');
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString("assets/labels.txt");
    labels = labelTxt.split('\n');
  }

  // Run inference
  Future<int> runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    // Tensor input [1, 224, 224, 3]
    final input = [imageMatrix];
    // Tensor output [1, 1001]
    final output = [List<double>.filled(39, 0)];
    // print(input.shape);
    // print(output.shape);
    // Run inference
    interpreter!.run(input, output);

    // Get first output tensor
    final result = output.first;
    // Get index with highest score
    final index = result
        .indexOf(result.reduce((curr, next) => curr > next ? curr : next));
    print(labels[index]);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow.withOpacity(0.2),
          title: const Center(child: Text('Plant Disease Detection')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                color: Colors.grey,
                child: _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Text('Your image appears here'),
                      ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _captureImage,
                child: const Text('Capture Image'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_image == null) {
                    debugPrint('No image selected.');
                    // show snackbar to select image
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No image selected.'),
                      ),
                    );
                    return;
                  }
                  // show loading dialog
                  showDialog(
                    context: context,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  resultIndex = await runInference(imageMatrixF);
                  // dismiss loading dialog
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  setState(() {});
                },
                child: const Text('Run inference'),
              ),
              const SizedBox(height: 10),
              const Text("OUTPUT:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (resultIndex != -1)
                Text(
                  labels[resultIndex],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
            ],
          ),
        ),
      ),
    );
  }
}
