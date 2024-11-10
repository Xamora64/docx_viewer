import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docx_viewer/docx_viewer.dart';

void main() {
  // Mock file data for testing
  const validFilePath = 'test/docs/sample.docx';
  const invalidFilePath = 'test/docs/invalid.txt';
  const unsupportedFilePath = 'test/docs/sample.pdf';

  testWidgets('Test DocxView widget with valid .docx file',
      (WidgetTester tester) async {
    // Creating a mock file to simulate valid file read
    final file = File(validFilePath);
    file.createSync();
    file.writeAsStringSync('This is a sample .docx file content.');

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocxView(
            filePath: validFilePath,
            onError: (error) {
              fail('Error callback should not be triggered for a valid file.');
            },
          ),
        ),
      ),
    );

    // Wait for the widget to load the content
    await tester.pumpAndSettle();

    // Verify the content is displayed
    expect(find.text('This is a sample .docx file content.'), findsOneWidget);

    // Clean up
    file.deleteSync();
  });

  testWidgets('Test DocxView widget with unsupported file type',
      (WidgetTester tester) async {
    // Build the widget with an unsupported file type
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocxView(
            filePath: unsupportedFilePath,
            onError: (error) {
              expect(error.toString(), contains('Unsupported file type'));
            },
          ),
        ),
      ),
    );

    // Wait for the widget to process the file
    await tester.pumpAndSettle();

    // Ensure the error message is displayed
    expect(find.text('Unsupported file type: .pdf'), findsOneWidget);
  });

  testWidgets('Test DocxView widget with non-existent file',
      (WidgetTester tester) async {
    // Build the widget with a non-existent file
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocxView(
            filePath: invalidFilePath,
            onError: (error) {
              expect(error.toString(), contains('File not found'));
            },
          ),
        ),
      ),
    );

    // Wait for the widget to process the file
    await tester.pumpAndSettle();

    // Ensure the error message is displayed
    expect(find.text('File not found: test/docs/invalid.txt'), findsOneWidget);
  });

  testWidgets('Test DocxView widget with empty file path',
      (WidgetTester tester) async {
    // Build the widget with an empty file path
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocxView(
            filePath: '',
            onError: (error) {
              expect(error.toString(), contains('File path is empty.'));
            },
          ),
        ),
      ),
    );

    // Wait for the widget to process the file
    await tester.pumpAndSettle();

    // Ensure the error message is displayed
    expect(find.text('File path is empty.'), findsOneWidget);
  });
}
