import 'dart:io';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:docx_viewer/utils/support_type.dart';
import 'package:flutter/material.dart';

class DocxView extends StatefulWidget {
  final String filePath;
  final int fontSize;
  final Function(Exception)? onError; // Callback to handle errors

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

  Future<void> _validateAndLoadDocxContent() async {
    // Check if the file path is valid
    if (widget.filePath.isEmpty) {
      _handleError(Exception("File path is empty."));
      return;
    }

    final fileExtension = widget.filePath.split('.').last.toLowerCase();

    // Check if the file extension is supported
    if (fileExtension != Supporttype.docx && fileExtension != Supporttype.doc) {
      _handleError(Exception("Unsupported file type: .$fileExtension"));
      return;
    }

    // Check if file exists
    final file = File(widget.filePath);
    if (!(await file.exists())) {
      _handleError(Exception("File not found: ${widget.filePath}"));
      return;
    }

    // Load the content
    await _loadDocxContent(file);
  }

  // Method to load .docx content
  Future<void> _loadDocxContent(File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final content = docxToText(fileBytes);

      setState(() {
        fileContent = content;
        isLoading = false;
      });
    } catch (e) {
      _handleError(Exception("Error reading file: ${e.toString()}"));
    }
  }

  // Centralized error handler
  void _handleError(Exception error) {
    if (widget.onError != null) {
      widget.onError!(error); // Pass the error to the provided callback
    } else {
      // Display a default error message if no callback is provided
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
