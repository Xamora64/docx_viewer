import 'package:flutter/material.dart';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? filePath;

  // Function to pick a DOCX file from local storage
  Future<void> pickFile() async {
    // Use file_picker to select a DOCX file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      setState(() {
        // Store the path of the selected file
        filePath = result.files.single.path;
      });
    } else {
      // Handle when no file is selected
      debugPrint("No file selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Document Viewer'),
        ),
        body: Center(
          child: filePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No file selected"),
                    ElevatedButton(
                      onPressed: pickFile,
                      child: const Text("Pick a DOCX file"),
                    ),
                  ],
                )
              : DocxView(filePath: filePath!),
        ),
      ),
    );
  }
}
