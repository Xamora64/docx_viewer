import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:docx_viewer/docx_viewer.dart';

void main() {
  test('adds one to input values', () {
    DocxView(
      filePath: 'docs/sample.docx',
      onError: (error) {
        debugPrint(error.toString());
      },
    );

    DocxView(
      filePath: 'docs/sample.pdf',
      onError: (error) {
        debugPrint(error.toString());
      },
    );
  });
}
