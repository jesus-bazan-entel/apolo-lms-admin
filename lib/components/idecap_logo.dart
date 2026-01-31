import 'package:flutter/material.dart';
import 'package:lms_admin/constants/idecap_colors.dart';

/// Logo completo de IDECAP para pantalla de splash
class IdecapLogo extends StatelessWidget {
  const IdecapLogo({super.key, this.showText = true, this.size = 100});

  final bool showText;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo IDECAP con texto
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icono del logo (escudo azul con estrellas)
            IdecapLogoIcon(size: size),

            if (showText) ...[
              const SizedBox(width: 12),

              // Texto del logo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "CENTRO DE IDIOMAS" - texto pequeño
                  Text(
                    'CENTRO DE IDIOMAS',
                    style: TextStyle(
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.w500,
                      color: IdecapColors.primaryDark,
                      letterSpacing: 1.0,
                    ),
                  ),

                  // "IDECAP" - texto grande
                  Text(
                    'IDECAP',
                    style: TextStyle(
                      fontSize: size * 0.45,
                      fontWeight: FontWeight.bold,
                      color: IdecapColors.accent,
                      letterSpacing: 2.0,
                      height: 1.0,
                    ),
                  ),

                  // "Idioma portugués" - subtítulo
                  Text(
                    'Idioma portugués',
                    style: TextStyle(
                      fontSize: size * 0.14,
                      fontStyle: FontStyle.italic,
                      color: IdecapColors.secondaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Icono del logo IDECAP (escudo azul con estrellas)
class IdecapLogoIcon extends StatelessWidget {
  const IdecapLogoIcon({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(
        painter: _IdecapLogoPainter(),
        size: Size(size, size * 1.1),
      ),
    );
  }
}

class _IdecapLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Colores
    final bluePaint = Paint()
      ..color = IdecapColors.accent
      ..style = PaintingStyle.fill;

    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Dibujar la forma de U (escudo)
    final path = Path();

    // Parte superior (rectángulo con esquinas redondeadas arriba)
    path.moveTo(w * 0.1, h * 0.1);
    path.lineTo(w * 0.1, h * 0.6);

    // Curva inferior de la U
    path.quadraticBezierTo(w * 0.1, h * 0.95, w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.9, h * 0.95, w * 0.9, h * 0.6);

    // Subir por el lado derecho
    path.lineTo(w * 0.9, h * 0.1);

    // Cerrar arriba
    path.lineTo(w * 0.1, h * 0.1);
    path.close();

    canvas.drawPath(path, bluePaint);

    // Dibujar el hueco interno de la U
    final innerPath = Path();
    innerPath.moveTo(w * 0.3, h * 0.35);
    innerPath.lineTo(w * 0.3, h * 0.55);
    innerPath.quadraticBezierTo(w * 0.3, h * 0.75, w * 0.5, h * 0.75);
    innerPath.quadraticBezierTo(w * 0.7, h * 0.75, w * 0.7, h * 0.55);
    innerPath.lineTo(w * 0.7, h * 0.35);
    innerPath.lineTo(w * 0.3, h * 0.35);
    innerPath.close();

    canvas.drawPath(innerPath, whitePaint);

    // Dibujar estrellas pequeñas
    _drawStar(canvas, Offset(w * 0.25, h * 0.18), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.4, h * 0.18), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.55, h * 0.18), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.7, h * 0.18), w * 0.04, starPaint);

    _drawStar(canvas, Offset(w * 0.2, h * 0.28), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.35, h * 0.28), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.65, h * 0.28), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.8, h * 0.28), w * 0.04, starPaint);

    _drawStar(canvas, Offset(w * 0.18, h * 0.45), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.82, h * 0.45), w * 0.04, starPaint);

    _drawStar(canvas, Offset(w * 0.18, h * 0.6), w * 0.04, starPaint);
    _drawStar(canvas, Offset(w * 0.82, h * 0.6), w * 0.04, starPaint);

    // Elemento decorativo superior (bandera)
    final flagPaint = Paint()
      ..color = IdecapColors.accent
      ..style = PaintingStyle.fill;

    final flagPath = Path();
    flagPath.moveTo(w * 0.35, h * 0.0);
    flagPath.lineTo(w * 0.35, h * 0.08);
    flagPath.lineTo(w * 0.65, h * 0.08);
    flagPath.lineTo(w * 0.65, h * 0.0);
    flagPath.lineTo(w * 0.35, h * 0.0);
    flagPath.close();

    canvas.drawPath(flagPath, flagPaint);

    // Líneas de la bandera
    final flagLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.015
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.42, h * 0.02),
      Offset(w * 0.42, h * 0.06),
      flagLinePaint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.02),
      Offset(w * 0.5, h * 0.06),
      flagLinePaint,
    );
    canvas.drawLine(
      Offset(w * 0.58, h * 0.02),
      Offset(w * 0.58, h * 0.06),
      flagLinePaint,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Dibujar una estrella simple (4 puntas)
    final path = Path();

    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
