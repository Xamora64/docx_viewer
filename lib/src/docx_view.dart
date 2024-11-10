import 'dart:io'; // Import the dart:io package for file handling
import 'package:docx_to_text/docx_to_text.dart'; // Import the docx_to_text package for extracting text from .docx files
import 'package:docx_viewer/utils/support_type.dart'; // Import support types for file extensions (e.g., .docx, .doc)
import 'package:flutter/material.dart'; // Import Flutter material design package

// Widget to display DOCX file content in a scrollable view.
class DocxView extends StatefulWidget {
  final String filePath; // The path of the DOCX file to load
  final int fontSize; // The font size to display the text
  final Function(Exception)?
      onError; // Optional callback function for error handling

  const DocxView({
    super.key, // Required for widget identification
    required this.filePath, // Required parameter: file path to the DOCX file
    this.fontSize = 16, // Optional parameter: default font size is 16
    this.onError, // Optional error callback
  });

  @override
  State<DocxView> createState() =>
      _DocxViewState(); // Create state for the widget
}

class _DocxViewState extends State<DocxView> {
  String? fileContent; // Variable to hold the extracted text from DOCX
  bool isLoading = true; // Boolean to manage the loading state of the widget

  static const double _padding = 10.0; // Padding for the widget's content

  @override
  void initState() {
    super.initState();
    _validateAndLoadDocxContent(); // Validate and load DOCX content when the widget initializes
  }

  // Method to validate the file path and extension, and load the content
  Future<void> _validateAndLoadDocxContent() async {
    // Check if the file path is empty
    if (widget.filePath.isEmpty) {
      _handleError(Exception(
          "File path is empty.")); // Call error handler if path is empty
      return;
    }

    // Get the file extension (e.g., docx, doc) and convert to lowercase
    final fileExtension = widget.filePath.split('.').last.toLowerCase();

    // Check if the file extension is supported (either .docx or .doc)
    if (fileExtension != Supporttype.docx && fileExtension != Supporttype.doc) {
      _handleError(Exception(
          "Unsupported file type: .$fileExtension")); // Call error handler if unsupported extension
      return;
    }

    // Check if the file exists at the specified path
    final file = File(widget.filePath);
    if (!(await file.exists())) {
      _handleError(Exception(
          "File not found: ${widget.filePath}")); // Call error handler if file doesn't exist
      return;
    }

    // If all checks pass, proceed to load the file content
    await _loadDocxContent(file);
  }

  // Method to load .docx content from the file
  Future<void> _loadDocxContent(File file) async {
    try {
      // Read the file as bytes
      final fileBytes = await file.readAsBytes();
      // Convert the bytes to text using the docx_to_text package
      final content = docxToText(fileBytes);

      // Update the state with the extracted content
      setState(() {
        fileContent = content; // Set the extracted content
        isLoading = false; // Mark loading as complete
      });
    } catch (e) {
      // In case of any error during reading or conversion, handle the error
      _handleError(Exception("Error reading file: ${e.toString()}"));
    }
  }

  // Centralized error handling method
  void _handleError(Exception error) {
    // If an onError callback is provided, pass the error to the callback
    if (widget.onError != null) {
      widget.onError!(error);
    } else {
      // If no callback is provided, handle the error locally by displaying the error message
      setState(() {
        fileContent = error.toString(); // Display error message as file content
        isLoading = false; // Mark loading as complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
          _padding), // Apply padding around the widget's content
      child: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loading spinner while content is being loaded
          : SingleChildScrollView(
              child: Text(
                fileContent ??
                    'No content to display.', // Display the loaded content or a default message
                style: TextStyle(
                    fontSize: widget.fontSize
                        .toDouble()), // Set the text style based on the provided font size
              ),
            ),
    );
  }
}
