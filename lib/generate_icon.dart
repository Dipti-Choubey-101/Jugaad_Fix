import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IconGenerator extends StatefulWidget {
  const IconGenerator({super.key});

  @override
  State<IconGenerator> createState() => _IconGeneratorState();
}

class _IconGeneratorState extends State<IconGenerator> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      await _saveIcon();
    });
  }

  Future<void> _saveIcon() async {
    final boundary = _key.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 4.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final file = File(
        'C:/Dipti/jugaad_fix/assets/images/app_icon.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Icon saved! ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: RepaintBoundary(
          key: _key,
          child: const JugaadFixIcon(),
        ),
      ),
    );
  }
}

class JugaadFixIcon extends StatelessWidget {
  const JugaadFixIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: CustomPaint(
        painter: _IconPainter(),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()..color = const Color(0xFFFF6B00);
    final bgRect =
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h),
            Radius.circular(w * 0.2));
    canvas.drawRRect(bgRect, bgPaint);

    // Inner ring
    final ringPaint = Paint()
      ..color = const Color(0xFFCC4400).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.01;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.9),
        Radius.circular(w * 0.17),
      ),
      ringPaint,
    );

    final white = Paint()..color = Colors.white;
    final orange = Paint()..color = const Color(0xFFFF6B00);
    final lightOrange = Paint()..color = const Color(0xFFFFB87A);

    // BULB
    final bulbCx = w * 0.5;
    final bulbCy = h * 0.37;
    final bulbRx = w * 0.3;
    final bulbRy = h * 0.28;

    // Bulb glass
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(bulbCx, bulbCy),
          width: bulbRx * 2,
          height: bulbRy * 2),
      white,
    );

    // Bulb neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            w * 0.42, h * 0.62, w * 0.16, h * 0.05),
        const Radius.circular(3),
      ),
      white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            w * 0.43, h * 0.67, w * 0.14, h * 0.04),
        const Radius.circular(3),
      ),
      lightOrange,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            w * 0.44, h * 0.71, w * 0.12, h * 0.03),
        const Radius.circular(3),
      ),
      lightOrange,
    );

    // Filament
    final filamentPaint = Paint()
      ..color = const Color(0xFFFF6B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final filamentPath = Path();
    filamentPath.moveTo(w * 0.42, h * 0.52);
    filamentPath.lineTo(w * 0.46, h * 0.42);
    filamentPath.lineTo(w * 0.50, h * 0.48);
    filamentPath.lineTo(w * 0.54, h * 0.42);
    filamentPath.lineTo(w * 0.58, h * 0.52);
    canvas.drawPath(filamentPath, filamentPaint);

    // Bulb shine
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.28);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.44, h * 0.31),
        width: w * 0.1,
        height: h * 0.14,
      ),
      shinePaint,
    );

    // WRENCH
    canvas.save();
    canvas.translate(w * 0.5, h * 0.72);
    canvas.rotate(0.785); // 45 degrees

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.055, w * 0.04,
            w * 0.11, w * 0.32),
        Radius.circular(w * 0.03),
      ),
      white,
    );

    // Head block
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.15, -w * 0.07,
            w * 0.30, w * 0.14),
        Radius.circular(w * 0.035),
      ),
      white,
    );

    // Left jaw cutout
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-w * 0.15, w * 0.0),
        width: w * 0.1,
        height: w * 0.07,
      ),
      orange,
    );

    // Right jaw cutout
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.15, w * 0.0),
        width: w * 0.1,
        height: w * 0.07,
      ),
      orange,
    );

    // Bottom round
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, w * 0.36),
        width: w * 0.1,
        height: w * 0.07,
      ),
      white,
    );

    canvas.restore();

    // Sparkles
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(0.35);
    canvas.drawCircle(Offset(w * 0.18, h * 0.18), w * 0.025, sparklePaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.16), w * 0.02, sparklePaint);
    canvas.drawCircle(Offset(w * 0.15, h * 0.72), w * 0.018, sparklePaint);
    canvas.drawCircle(Offset(w * 0.84, h * 0.70), w * 0.022, sparklePaint);

    // Text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'जुगाड़ Fix',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: w);
    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, h * 0.88),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}