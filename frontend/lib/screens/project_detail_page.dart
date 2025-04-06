import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/document.dart';
import '../models/project.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late ProjectDocument _document;
  List<DrawingPoint> _currentDrawing = [];
  List<List<DrawingPoint>> _drawings = [];
  bool _isDrawing = false;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isDrawingMode = false;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _document = ProjectDocument.create(widget.project.id);
  }

  @override
  void dispose() {
    _document.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startDrawing(DrawingPoint point) {
    setState(() {
      _isDrawing = true;
      _currentDrawing = [point];
    });
  }

  void _updateDrawing(DrawingPoint point) {
    if (_isDrawing) {
      setState(() {
        _currentDrawing.add(point);
      });
    }
  }

  void _endDrawing() {
    if (_isDrawing) {
      setState(() {
        _drawings.add(List.from(_currentDrawing));
        _currentDrawing = [];
        _isDrawing = false;
      });
    }
  }

  void _clearDrawings() {
    setState(() {
      _drawings.clear();
    });
  }

  void _toggleDrawingMode() {
    setState(() {
      _isDrawingMode = !_isDrawingMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isDrawingMode ? Icons.edit : Icons.draw),
            onPressed: _toggleDrawingMode,
            tooltip: _isDrawingMode ? 'Switch to Text Mode' : 'Switch to Drawing Mode',
          ),
          if (_isDrawingMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearDrawings,
              tooltip: 'Clear Drawings',
            ),
        ],
      ),
      body: Stack(
        children: [
          if (!_isDrawingMode)
            QuillEditor(
              configurations: QuillEditorConfigurations(
                controller: _document.controller,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
              focusNode: _focusNode,
              scrollController: _scrollController,
            ),
          if (_isDrawingMode)
            GestureDetector(
              onPanStart: (details) {
                _startDrawing(DrawingPoint(
                  offset: details.localPosition,
                  color: _selectedColor,
                  strokeWidth: _strokeWidth,
                ));
              },
              onPanUpdate: (details) {
                _updateDrawing(DrawingPoint(
                  offset: details.localPosition,
                  color: _selectedColor,
                  strokeWidth: _strokeWidth,
                ));
              },
              onPanEnd: (_) => _endDrawing(),
              child: CustomPaint(
                painter: DrawingPainter(
                  drawings: _drawings,
                  currentDrawing: _currentDrawing,
                ),
                child: Container(),
              ),
            ),
          if (_isDrawingMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white.withOpacity(0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildColorButton(Colors.black),
                    _buildColorButton(Colors.red),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.green),
                    IconButton(
                      icon: const Icon(Icons.brush),
                      onPressed: () {
                        setState(() {
                          _strokeWidth = _strokeWidth == 3.0 ? 6.0 : 3.0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isDrawingMode
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Add any additional actions for text mode
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> drawings;
  final List<DrawingPoint> currentDrawing;

  DrawingPainter({
    required this.drawings,
    required this.currentDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawing in drawings) {
      _drawPoints(canvas, drawing);
    }
    _drawPoints(canvas, currentDrawing);
  }

  void _drawPoints(Canvas canvas, List<DrawingPoint> points) {
    if (points.isEmpty) return;

    final path = Path();
    path.moveTo(points[0].offset.dx, points[0].offset.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].offset.dx, points[i].offset.dy);
    }

    final paint = Paint()
      ..color = points[0].color
      ..strokeWidth = points[0].strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
} 