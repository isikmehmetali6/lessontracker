import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import '../../core/theme/app_colors.dart';

/// Drawing stroke data for serialization
class DrawingStroke {
  final List<PointVector> points;
  final Color color;
  final double size;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((p) => {'x': p.x, 'y': p.y}).toList(),
      'color': color.toARGB32(),
      'size': size,
    };
  }

  factory DrawingStroke.fromMap(Map<String, dynamic> map) {
    return DrawingStroke(
      points: (map['points'] as List)
          .map((p) => PointVector(p['x'] as double, p['y'] as double))
          .toList(),
      color: Color(map['color'] as int),
      size: map['size'] as double,
    );
  }
}

/// Single stroke rendered with perfect_freehand for smooth Apple Pencil feel
class StrokeWidget extends StatelessWidget {
  final DrawingStroke stroke;

  const StrokeWidget({super.key, required this.stroke});

  @override
  Widget build(BuildContext context) {
    if (stroke.points.isEmpty) return const SizedBox.shrink();

    final outlinePoints = getStroke(
      stroke.points,
      options: StrokeOptions(
        size: stroke.size,
        thinning: 0.5,
        smoothing: 0.5,
        streamline: 0.5,
        start: StrokeEndOptions.start(
          taperEnabled: true,
          cap: true,
        ),
        end: StrokeEndOptions.end(
          taperEnabled: true,
          cap: true,
        ),
      ),
    );

    return CustomPaint(
      painter: _StrokePainter(
        outlinePoints: outlinePoints,
        color: stroke.color,
      ),
      size: Size.infinite,
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<Offset> outlinePoints;
  final Color color;

  _StrokePainter({required this.outlinePoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (outlinePoints.isEmpty) return;

    final path = Path();
    final first = outlinePoints.first;
    path.moveTo(first.dx, first.dy);

    for (int i = 1; i < outlinePoints.length; i++) {
      path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) {
    return oldDelegate.outlinePoints != outlinePoints ||
        oldDelegate.color != color;
  }
}

/// Main drawing canvas with Apple Pencil support
class DrawingCanvas extends StatefulWidget {
  final List<DrawingStroke> strokes;
  final Color currentColor;
  final double currentSize;
  final ValueChanged<List<DrawingStroke>>? onStrokesChanged;
  final Color backgroundColor;

  const DrawingCanvas({
    super.key,
    required this.strokes,
    this.currentColor = Colors.black,
    this.currentSize = 4.0,
    this.onStrokesChanged,
    this.backgroundColor = Colors.white,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<PointVector> _currentPoints = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPoints = [
        PointVector(details.localPosition.dx, details.localPosition.dy),
      ];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(
        PointVector(details.localPosition.dx, details.localPosition.dy),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.isEmpty) return;

    final newStroke = DrawingStroke(
      points: List.from(_currentPoints),
      color: widget.currentColor,
      size: widget.currentSize,
    );

    widget.onStrokesChanged?.call([...widget.strokes, newStroke]);
    setState(() {
      _currentPoints = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            // Existing strokes
            ...widget.strokes.map((s) => StrokeWidget(stroke: s)),
            // Current stroke being drawn
            if (_currentPoints.isNotEmpty) ...[
              StrokeWidget(
                stroke: DrawingStroke(
                  points: _currentPoints,
                  color: widget.currentColor,
                  size: widget.currentSize,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Toolbar for drawing tools
class DrawingToolbar extends StatelessWidget {
  final Color selectedColor;
  final double selectedSize;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onSizeChanged;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final bool isDark;

  const DrawingToolbar({
    super.key,
    required this.selectedColor,
    required this.selectedSize,
    required this.onColorChanged,
    required this.onSizeChanged,
    required this.onUndo,
    required this.onClear,
    required this.isDark,
  });

  static const List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.white,
  ];

  static const List<double> sizes = [2.0, 4.0, 8.0, 12.0, 20.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkElevated : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: onUndo,
            color: isDark ? Colors.white : Colors.black87,
          ),
          // Clear
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onClear,
            color: Colors.red,
          ),
          const VerticalDivider(width: 24),
          // Colors
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: colors.map((color) {
                  final isSelected = selectedColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: color == Colors.white
                            ? [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  blurRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const VerticalDivider(width: 24),
          // Sizes
          ...sizes.map((size) {
            final isSelected = (selectedSize - size).abs() < 0.5;
            return GestureDetector(
              onTap: () => onSizeChanged(size),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Center(
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Export canvas to image
Future<ui.Image?> exportCanvasToImage(
  List<DrawingStroke> strokes,
  Size size,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw white background
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    Paint()..color = Colors.white,
  );

  // Draw all strokes
  for (final stroke in strokes) {
    if (stroke.points.isEmpty) continue;

    final outlinePoints = getStroke(
      stroke.points,
      options: StrokeOptions(
        size: stroke.size,
        thinning: 0.5,
        smoothing: 0.5,
        streamline: 0.5,
        start: StrokeEndOptions.start(taperEnabled: true, cap: true),
        end: StrokeEndOptions.end(taperEnabled: true, cap: true),
      ),
    );

    final path = Path();
    if (outlinePoints.isNotEmpty) {
      path.moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
      for (int i = 1; i < outlinePoints.length; i++) {
        path.lineTo(outlinePoints[i].dx, outlinePoints[i].dy);
      }
      path.close();
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill,
    );
  }

  final picture = recorder.endRecording();
  return picture.toImage(size.width.toInt(), size.height.toInt());
}
