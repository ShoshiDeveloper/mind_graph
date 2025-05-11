import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CanvasPage(),
    );
  }
}

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

extension boolext on bool {
  int get positive => this ? 1 : -1;
}

class _CanvasPageState extends State<CanvasPage> {
  final controller = TransformationController();

  Offset blockPosition = Offset(200, 200);
  Offset blockSize = Offset(100, 100);
  final GlobalKey _stackKey = GlobalKey();
  double scale = 1;

  Offset scaledBlockSize(double scale) => Offset(blockSize.dx * scale, blockSize.dy * scale);
  Offset feedbackOffset(double scale) => Offset((blockSize.dx / 2) * scale, (blockSize.dy / 2) * scale);
  Offset get blocPositionOfEnd => Offset(blockPosition.dx + blockSize.dx, blockPosition.dy + blockSize.dy);

  bool dragStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite Canvas')),
      body: InteractiveViewer(
        transformationController: controller,
        // boundaryMargin: const EdgeInsets.all(0),
        minScale: 0.1,
        maxScale: 1,
        constrained: false, // отключаем ограничение по размеру экрана
        onInteractionEnd: (details) {
          setState(() {
            scale = controller.value.getMaxScaleOnAxis();
          });
        },
        child: Stack(
          key: _stackKey,
          children: [
            // Пример: большой фон
            Container(
              width: 5000,
              height: 5000,
              color: Colors.grey.shade200,
            ),
            for (int i = 0; i < 10; i++) _buildDivier(i * 100),

            // Добавим пару элементов
            Positioned(
              left: blockPosition.dx,
              top: blockPosition.dy,
              child: Draggable(
                onDragStarted: () => setState(() => dragStarted = true),
                onDragEnd: (details) {
                  // Получаем RenderBox Stack'а
                  final RenderBox renderBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                  // Конвертируем глобальные координаты в локальные
                  final localOffset = renderBox.globalToLocal(details.offset);
                  setState(() {
                    blockPosition = localOffset;
                    dragStarted = false;
                  });
                },
                feedback: _block(scale: scale),
                feedbackOffset: feedbackOffset(scale),
                childWhenDragging: const SizedBox.shrink(),
                child: _block(),
              ),
            ),
            Positioned(
              left: 800,
              top: 800,
              child: _block(color: Colors.green),
            ),
            if (!dragStarted)
              CustomPaint(
                painter: LinePainter(from: blocPositionOfEnd, to: Offset(800, 800)),
                // size: Size.infinite,
              )
          ],
        ),
      ),
    );
  }

  Widget _block({Color color = Colors.blue, double scale = 1}) {
    final size = scaledBlockSize(scale);
    return Material(
      child: Container(
        color: Colors.green,
        child: Container(
          width: size.dx,
          height: size.dy,
          color: color,
          alignment: Alignment.center,
          child: const Text("Block", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDivier(double top) {
    return Positioned(
      top: top,
      width: 2500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(top.toString()), Expanded(child: Divider(height: 2, color: Colors.amber))],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset from;
  final Offset to;

  LinePainter({required this.from, required this.to});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    // canvas.drawLine(from, to, paint);

    final difference = to - from;
    final centerX = difference.dx / 2;

    final firstLineFrom = from;
    final firstLineTo = Offset(from.dx + centerX, from.dy);
    canvas.drawLine(firstLineFrom, firstLineTo, paint);

    final secondLineFrom = firstLineTo;
    final secondLineTo = Offset(firstLineTo.dx, to.dy);
    canvas.drawLine(secondLineFrom, secondLineTo, paint);

    final thirdLineFrom = secondLineTo;
    final thirdLineTo = to;
    canvas.drawLine(thirdLineFrom, thirdLineTo, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => from != oldDelegate.from || to != oldDelegate.to;
}
