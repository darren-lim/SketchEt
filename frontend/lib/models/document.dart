import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ProjectDocument {
  final String id;
  final String projectId;
  final QuillController controller;

  ProjectDocument({
    required this.id,
    required this.projectId,
    required this.controller,
  });

  factory ProjectDocument.create(String projectId) {
    return ProjectDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: projectId,
      controller: QuillController.basic(),
    );
  }

  void dispose() {
    controller.dispose();
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
  });
} 