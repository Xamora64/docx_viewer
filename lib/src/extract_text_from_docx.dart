import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';

/// Extracts text content from a DOCX file.
String extractTextFromDocx(File file) {
  final List<String> extractedText = [];

  // Read and decode the DOCX file as a ZIP archive
  final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());

  // Find the main document file in the DOCX archive
  final documentFile = archive.files.firstWhere(
    (file) => file.isFile && file.name == 'word/document.xml',
    orElse: () => throw Exception('Document.xml not found in DOCX file'),
  );

  // Parse the XML content of the document
  final fileContent = utf8.decode(documentFile.content);
  final document = xml.XmlDocument.parse(fileContent);

  // Extract paragraphs and format them with numbering if applicable
  String? lastNumId;
  int number = 0;

  for (final paragraph in document.findAllElements('w:p')) {
    // Extract and join all text nodes within the paragraph
    final textContent =
        paragraph.findAllElements('w:t').map((node) => node.innerText).join();

    // Check for numbering information in the paragraph
    final numIdNode = paragraph.findElements('w:numId').firstOrNull;
    final numId = numIdNode?.getAttribute('w:val');

    // Manage numbering: increment or reset based on numId changes
    if (numId != null && numId != lastNumId) {
      lastNumId = numId;
      number = 1;
    } else if (numId != null) {
      number++;
    }

    // Add numbering if applicable
    final formattedText =
        (numId != null) ? '$number. $textContent' : textContent;
    extractedText.add(formattedText);
  }

  return extractedText.join('\n');
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
