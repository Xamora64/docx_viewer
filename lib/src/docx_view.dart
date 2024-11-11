import 'dart:io';
import 'package:docx_viewer/src/extract_text_from_docx.dart';
import 'package:docx_viewer/utils/support_type.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final String filePath; // The path to the DOCX file or URL
  final int fontSize; // Optional font size for displaying the text
  final Function(Exception)? onError; // Optional callback for handling errors

  /// Creates a [DocxView] widget.
  ///
  /// [filePath] is required, representing the path or URL of the DOCX file to display.
  /// [fontSize] is optional and defaults to 16 if not specified.
  /// [onError] is an optional callback for handling errors.
  const DocxView({
    super.key,
    required this.filePath,
    this.fontSize = 16,
    this.onError,
  });

  @override
  State<DocxView> createState() => _DocxViewState();
}

class _DocxViewState extends State<DocxView> {
  String? fileContent;
  bool isLoading = true;
  static const double _padding = 10.0;

  @override
  void initState() {
    _validateAndLoadDocxContent();
    super.initState();
  }

  /// Validates the file path, determines if it's a network or local file, and loads the DOCX content.
  Future<void> _validateAndLoadDocxContent() async {
    // Check if the file path is empty
    if (widget.filePath.isEmpty) {
      _handleError(Exception("File path is empty."));
      return;
    }

    // Check if the filePath is a network URL or a local file path
    if (widget.filePath.startsWith('http')) {
      // Load content from a network file
      await _loadDocxContentFromNetwork(widget.filePath);
    } else {
      // Load content from a local file
      final file = File(widget.filePath);
      if (!(await file.exists())) {
        _handleError(Exception("File not found: ${widget.filePath}"));
        return;
      }
      await _loadDocxContent(file);
    }
  }

  /// Loads the content from a DOCX file stored locally.
  Future<void> _loadDocxContent(File file) async {
    try {
      // check the file extension  to determine the file type
      final fileExtension = file.path.split('.').last.toLowerCase();

      // Check if the file extension is supported (DOCX or DOC)
      if (fileExtension != Supporttype.docx &&
          fileExtension != Supporttype.doc) {
        _handleError(Exception("Unsupported file type: .$fileExtension"));
        return;
      }

      final content = extractTextFromDocx(file);
      setState(() {
        fileContent = content;
        isLoading = false;
      });
    } catch (e) {
      _handleError(Exception("Error reading file: ${e.toString()}"));
    }
  }

  /// Loads the content from a DOCX file available over the network.
  Future<void> _loadDocxContentFromNetwork(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Write the network file to a temporary file
        final tempFile = File('${Directory.systemTemp.path}/temp.docx');
        await tempFile.writeAsBytes(response.bodyBytes);
        await _loadDocxContent(tempFile);
      } else {
        _handleError(Exception(
            "Failed to load file from network. Status code: ${response.statusCode}"));
      }
    } catch (e) {
      _handleError(Exception("Error downloading file: ${e.toString()}"));
    }
  }

  /// Handles errors by calling the [onError] callback if provided, or displaying the error message.
  void _handleError(Exception error) {
    if (widget.onError != null) {
      widget.onError!(error);
    } else {
      setState(() {
        fileContent = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Text(
                fileContent ?? 'No content to display.',
                style: TextStyle(fontSize: widget.fontSize.toDouble()),
              ),
            ),
    );
  }
}
