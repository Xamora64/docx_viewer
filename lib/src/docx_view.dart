import 'dart:io';
import 'package:docx_viewer/src/extract_text_from_docx.dart';
import 'package:docx_viewer/utils/support_type.dart';
import 'package:flutter/material.dart';

/// A widget for displaying Word documents, including .doc and .docx file types.
///
/// The [DocxView] widget takes a [filePath], an optional [fontSize], and an optional [onError] callback function.
/// It reads the content of the DOCX file and displays it as text within a Flutter application.
///
/// Supported document types:
/// - DOCX: Displayed as text after converting from DOCX binary format using the [docx_to_text] package.
///
/// Example usage:
/// ```dart
/// DocxView(filePath: '/path/to/your/document.docx')
/// ```
class DocxView extends StatefulWidget {
  final String filePath; // The path to the DOCX file you want to display
  final int fontSize; // Optional font size for displaying the text
  final Function(Exception)? onError; // Optional callback for handling errors

  /// Creates a [DocxView] widget.
  ///
  /// [filePath] is required, representing the path of the DOCX file to display.
  /// [fontSize] is optional and defaults to 16 if not specified.
  /// [onError] is an optional callback for handling errors.
  const DocxView({
    super.key,
    required this.filePath, // File path is required to load the DOCX file
    this.fontSize = 16, // Default font size if not provided
    this.onError, // Optional error callback
  });

  @override
  State<DocxView> createState() => _DocxViewState();
}

class _DocxViewState extends State<DocxView> {
  String? fileContent; // Variable to hold the text content of the DOCX file
  bool isLoading = true; // Boolean to track if the content is loading

  static const double _padding = 10.0; // Padding for the widget

  @override
  void initState() {
    _validateAndLoadDocxContent(); // Validate and load DOCX content on widget initialization
    super.initState();
  }

  /// Validates the file path and file extension, then loads the DOCX content.
  ///
  /// This method checks if the file path is not empty, if the file type is either .doc or .docx,
  /// and if the file exists. If any of these conditions fail, an error is triggered.
  Future<void> _validateAndLoadDocxContent() async {
    // Check if the file path is empty
    if (widget.filePath.isEmpty) {
      _handleError(Exception(
          "File path is empty.")); // Trigger error if the path is empty
      return;
    }

    final fileExtension = widget.filePath.split('.').last.toLowerCase();

    // Check if the file extension is supported (DOCX or DOC)
    if (fileExtension != Supporttype.docx && fileExtension != Supporttype.doc) {
      _handleError(Exception(
          "Unsupported file type: .$fileExtension")); // Trigger error for unsupported file types
      return;
    }

    // Create a File object and check if the file exists
    final file = File(widget.filePath);
    if (!(await file.exists())) {
      _handleError(Exception(
          "File not found: ${widget.filePath}")); // Trigger error if file doesn't exist
      return;
    }

    // Proceed to load the DOCX content if the file is valid
    await _loadDocxContent(file);
  }

  /// Loads the content from the DOCX file.
  ///
  /// This method reads the DOCX file as bytes and converts it to text using the [docx_to_text] package.
  /// If an error occurs during this process, it is caught and handled.
  Future<void> _loadDocxContent(File file) async {
    try {
      // Read the file as bytes
      // Convert the bytes to text using the docx_to_text package

      final content = extractTextFromDocx(file);

      // Update the state to display the loaded content
      setState(() {
        fileContent = content;
        isLoading = false; // Set loading to false once the content is loaded
      });
    } catch (e) {
      // If there's an error during file reading, handle it
      _handleError(Exception("Error reading file: ${e.toString()}"));
    }
  }

  /// Handles errors by calling the [onError] callback if provided, or displaying the error message.
  ///
  /// If the [onError] callback is provided, it is invoked with the error.
  /// If not, the error message is displayed in the widget's content.
  void _handleError(Exception error) {
    if (widget.onError != null) {
      widget.onError!(error); // Pass the error to the provided callback
    } else {
      // Display the error message if no callback is provided
      setState(() {
        fileContent = error.toString();
        isLoading = false; // Set loading to false when error is handled
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(_padding), // Apply padding around the content
      child: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while content is loading
          : SingleChildScrollView(
              child: Text(
                fileContent ??
                    'No content to display.', // Display the file content or an error message
                style: TextStyle(
                    fontSize: widget.fontSize
                        .toDouble()), // Set font size based on user input
              ),
            ),
    );
  }
}
