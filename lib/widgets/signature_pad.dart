import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Panel de firma que acepta lápiz/stylus, dedo o mouse.
///
/// FIX clave: si este widget vive dentro de un ListView/ScrollView, el
/// gesto de "arrastrar" del lápiz compite con el gesto de scroll del padre
/// y gana el scroll, así que el trazo se pierde y la pantalla se mueve.
/// La solución es avisar al padre (con [onDrawingChanged]) cuando el dedo/
/// lápiz toca el panel, para que el padre desactive su scroll mientras se
/// dibuja (ver ejemplo de uso en consent_tab.dart).
class SignaturePad extends StatefulWidget {
  final String label;
  final ValueChanged<bool>? onDrawingChanged;
  const SignaturePad({super.key, this.label = 'Firma', this.onDrawingChanged});

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final GlobalKey _boundaryKey = GlobalKey();
  final List<List<Offset>> _strokes = [];
  List<Offset>? _current;

  bool get isEmpty => _strokes.isEmpty;

  void clear() => setState(() => _strokes.clear());

  /// Exporta la firma actual como PNG en base64. Devuelve '' si está vacía.
  Future<String> exportPng() async {
    if (_strokes.isEmpty) return '';
    final boundary = _boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return '';
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return '';
    return base64Encode(byteData.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.draw_outlined, size: 18, color: primary),
            const SizedBox(width: 6),
            Text(widget.label,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: primary)),
          ],
        ),
        const SizedBox(height: 6),
        RepaintBoundary(
          key: _boundaryKey,
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: primary.withOpacity(0.35), width: 1.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Listener(
                // behavior: opaque asegura que este widget SIEMPRE reciba
                // el evento de puntero completo (down/move/up), sin
                // depender de si "gana" la arena de gestos frente al
                // scroll del padre — el padre lo desactiva mientras tanto.
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  widget.onDrawingChanged?.call(true);
                  setState(() {
                    _current = [e.localPosition];
                    _strokes.add(_current!);
                  });
                },
                onPointerMove: (e) => setState(() {
                  _current?.add(e.localPosition);
                }),
                onPointerUp: (_) {
                  _current = null;
                  widget.onDrawingChanged?.call(false);
                },
                onPointerCancel: (_) {
                  _current = null;
                  widget.onDrawingChanged?.call(false);
                },
                child: Stack(
                  children: [
                    if (_strokes.isEmpty)
                      Center(
                        child: Text(
                          'Firme aquí con el lápiz o el dedo',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                        ),
                      ),
                    CustomPaint(
                      painter: _SignaturePainter(_strokes),
                      size: Size.infinite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: clear,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Limpiar firma'),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
