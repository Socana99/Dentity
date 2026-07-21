import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Numeración FDI de dientes permanentes, organizada como en el formulario:
/// fila superior 18→11 | 21→28, fila inferior 48→41 | 31→38.
/// (Para piezas deciduales 55-51/61-65/85-81/71-75 basta con agregar otra
/// fila reutilizando el mismo _toothTile — están comentadas más abajo.)
const _upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
const _upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
const _lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
const _lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];
const _allUpper = [..._upperRight, ..._upperLeft];
const _allLower = [..._lowerRight, ..._lowerLeft];
const _allTeeth = [..._allUpper, ..._allLower];

/// Tamaño del lienzo compartido por las dos vistas (grilla y arco), para
/// que la animación entre una y otra tenga espacio de sobra sin recortarse.
const _canvasSize = Size(950, 470);
const _tileSize = 52.0;

enum OdontogramMode { simbolo, lapiz }

/// Tipo anatómico de la pieza, derivado de la posición FDI (último dígito):
/// 1-2 incisivo, 3 canino, 4-5 premolar, 6-8 molar. Se usa solo para
/// dibujar una silueta distinta por tipo, no cambia la numeración clínica.
enum ToothType { incisor, canine, premolar, molar }

ToothType _toothType(int fdi) {
  final pos = fdi % 10;
  if (pos <= 2) return ToothType.incisor;
  if (pos == 3) return ToothType.canine;
  if (pos == 4 || pos == 5) return ToothType.premolar;
  return ToothType.molar;
}

const symbolLabels = {
  OdontoSymbol.caries: 'Caries',
  OdontoSymbol.obturado: 'Obturado',
  OdontoSymbol.extraccionIndicada: 'Extracción indicada',
  OdontoSymbol.perdidaPorCaries: 'Pérdida por caries',
  OdontoSymbol.perdidaOtraCausa: 'Pérdida (otra causa)',
  OdontoSymbol.sellanteNecesario: 'Sellante necesario',
  OdontoSymbol.sellanteRealizado: 'Sellante realizado',
  OdontoSymbol.endodoncia: 'Endodoncia',
  OdontoSymbol.corona: 'Corona',
  OdontoSymbol.protesisFija: 'Prótesis fija',
  OdontoSymbol.protesisRemovible: 'Prótesis removible',
  OdontoSymbol.protesisTotal: 'Prótesis total',
  OdontoSymbol.ninguno: 'Ninguno / limpiar',
};

const symbolGlyph = {
  OdontoSymbol.caries: '●',
  OdontoSymbol.obturado: '■',
  OdontoSymbol.extraccionIndicada: '✕',
  OdontoSymbol.perdidaPorCaries: '✕',
  OdontoSymbol.perdidaOtraCausa: '□',
  OdontoSymbol.sellanteNecesario: '▢',
  OdontoSymbol.sellanteRealizado: '▣',
  OdontoSymbol.endodoncia: '△',
  OdontoSymbol.corona: '◯',
  OdontoSymbol.protesisFija: '┄',
  OdontoSymbol.protesisRemovible: '╌',
  OdontoSymbol.protesisTotal: '═',
  OdontoSymbol.ninguno: '',
};

/// Odontograma completo. Mantiene un [ToothMark] por número de diente.
///
/// FIX de gestos: la fila de dientes va dentro de un SingleChildScrollView
/// horizontal. Si mientras se dibuja con el lápiz ese scroll sigue activo,
/// se roba el trazo. Por eso el scroll horizontal se BLOQUEA justo mientras
/// el puntero está tocando un diente en modo "Lápiz" (ver _scrollLocked).
class OdontogramWidget extends StatefulWidget {
  final Map<int, ToothMark> initialMarks; // toothNumber -> mark
  final String patientId;
  final void Function(ToothMark mark) onMarkChanged;

  const OdontogramWidget({
    super.key,
    required this.initialMarks,
    required this.patientId,
    required this.onMarkChanged,
  });

  @override
  State<OdontogramWidget> createState() => _OdontogramWidgetState();
}

class _OdontogramWidgetState extends State<OdontogramWidget> {
  late Map<int, ToothMark> marks;
  OdontogramMode mode = OdontogramMode.simbolo;
  String activeColor = 'rojo'; // rojo = patología actual, azul = tratamiento
  bool _scrollLocked = false;
  int? _pressedTooth;
  bool _archView = false;

  @override
  void initState() {
    super.initState();
    marks = Map.of(widget.initialMarks);
  }

  ToothMark _markFor(int tooth) {
    return marks[tooth] ??
        ToothMark(
          id: '${widget.patientId}_$tooth',
          patientId: widget.patientId,
          toothNumber: tooth,
          surface: 'general',
          color: activeColor,
        );
  }

  void _updateMark(ToothMark m) {
    setState(() => marks[m.toothNumber] = m);
    widget.onMarkChanged(m);
  }

  Future<void> _openSymbolPicker(int tooth) async {
    final current = _markFor(tooth);
    OdontoSymbol selected = current.symbol;
    int movilidad = current.movilidad;
    bool recesion = current.recesion;
    String color = current.color;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Pieza $tooth'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: symbolLabels.entries.map((e) {
                    return ChoiceChip(
                      label: Text('${symbolGlyph[e.key]} ${e.value}'),
                      selected: selected == e.key,
                      onSelected: (_) => setLocal(() => selected = e.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Color: '),
                    ChoiceChip(
                      label: const Text('Rojo (patología actual)'),
                      selected: color == 'rojo',
                      onSelected: (_) => setLocal(() => color = 'rojo'),
                    ),
                    const SizedBox(width: 6),
                    ChoiceChip(
                      label: const Text('Azul (tratamiento realizado)'),
                      selected: color == 'azul',
                      onSelected: (_) => setLocal(() => color = 'azul'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Movilidad: '),
                    for (int i = 0; i <= 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ChoiceChip(
                          label: Text('$i'),
                          selected: movilidad == i,
                          onSelected: (_) => setLocal(() => movilidad = i),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: recesion,
                      onChanged: (v) => setLocal(() => recesion = v ?? false),
                    ),
                    const Text('Recesión'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                _updateMark(ToothMark(
                  id: current.id,
                  patientId: current.patientId,
                  toothNumber: tooth,
                  surface: 'general',
                  symbol: selected,
                  movilidad: movilidad,
                  recesion: recesion,
                  color: color,
                  freehandStrokes: current.freehandStrokes,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addFreehandPoint(int tooth, Offset localPoint, {required bool newStroke}) {
    final current = _markFor(tooth);
    final strokes = List<List<Offset2D>>.from(
        current.freehandStrokes.map((s) => List<Offset2D>.from(s)));
    if (newStroke || strokes.isEmpty) {
      strokes.add([Offset2D(localPoint.dx, localPoint.dy)]);
    } else {
      strokes.last.add(Offset2D(localPoint.dx, localPoint.dy));
    }
    marks[tooth] = ToothMark(
      id: current.id,
      patientId: current.patientId,
      toothNumber: tooth,
      surface: 'general',
      symbol: current.symbol,
      movilidad: current.movilidad,
      recesion: current.recesion,
      color: current.color,
      freehandStrokes: strokes,
    );
    setState(() {});
  }

  void _commitFreehand(int tooth) => widget.onMarkChanged(marks[tooth]!);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.grid_view_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text('Odontograma',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const Divider(height: 20),
            _buildToolbar(),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 10),
            _buildRingSummary(),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Se bloquea justo mientras el lápiz está dibujando sobre
              // un diente, para que no se robe el trazo (ver más arriba).
              physics: _scrollLocked
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutCubic,
                width: _canvasSize.width,
                height: _archView ? _canvasSize.height : 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int i = 0; i < _allTeeth.length; i++)
                      _positionedTooth(i),
                  ],
                ),
              ),
            ),
            if (mode == OdontogramMode.lapiz)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Consejo: cambia a modo "Símbolo" para desplazarte por '
                  'todas las piezas; en modo "Lápiz" el desplazamiento se '
                  'bloquea mientras dibujas para no perder el trazo.',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<OdontogramMode>(
          segments: const [
            ButtonSegment(
                value: OdontogramMode.simbolo,
                icon: Icon(Icons.touch_app),
                label: Text('Símbolo')),
            ButtonSegment(
                value: OdontogramMode.lapiz,
                icon: Icon(Icons.edit),
                label: Text('Lápiz')),
          ],
          selected: {mode},
          onSelectionChanged: (s) => setState(() => mode = s.first),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
                value: false,
                icon: Icon(Icons.grid_view_rounded),
                label: Text('Grilla')),
            ButtonSegment(
                value: true,
                icon: Icon(Icons.emoji_emotions_outlined),
                label: Text('Boca')),
          ],
          selected: {_archView},
          onSelectionChanged: (s) => setState(() => _archView = s.first),
        ),
        if (mode == OdontogramMode.lapiz) ...[
          ChoiceChip(
            label: const Text('Rojo'),
            avatar: const CircleAvatar(backgroundColor: Colors.red),
            selected: activeColor == 'rojo',
            onSelected: (_) => setState(() => activeColor = 'rojo'),
          ),
          ChoiceChip(
            label: const Text('Azul'),
            avatar: const CircleAvatar(backgroundColor: Colors.blue),
            selected: activeColor == 'azul',
            onSelected: (_) => setState(() => activeColor = 'azul'),
          ),
        ],
      ],
    );
  }

  /// Pequeña leyenda de los símbolos clínicos, para poder leer la grilla
  /// sin tener que abrir cada pieza.
  Widget _buildLegend() {
    final entries = symbolLabels.entries.where((e) => e.key != OdontoSymbol.ninguno);
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: entries.map((e) {
        return Text(
          '${symbolGlyph[e.key]} ${e.value}',
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
        );
      }).toList(),
    );
  }

  /// Posición del diente en la vista de grilla (dos filas rectas), dentro
  /// del lienzo compartido [_canvasSize].
  Offset _gridPos(int index) {
    final row = index < 16 ? 0 : 1;
    final col = index % 16;
    final x = col * 58.0 + (col >= 8 ? 16.0 : 0.0);
    final y = row * 104.0;
    return Offset(x, y);
  }

  /// Posición del diente en la vista de "boca": dos arcos (superior e
  /// inferior) alrededor de un óvalo, con los incisivos en los extremos
  /// verticales y los molares hacia las esquinas — como el contorno de
  /// una boca abierta.
  Offset _archPos(int index) {
    final row = index < 16 ? 0 : 1;
    final col = index % 16;
    const cx = 460.0, cy = 180.0, rx = 420.0, ry = 140.0;
    final t = col / 15.0;
    final thetaDeg = 20 + t * 140; // 20°..160°
    final rad = thetaDeg * pi / 180;
    final x = cx + rx * cos(rad) - _tileSize / 2;
    final y = (row == 0 ? cy - ry * sin(rad) : cy + ry * sin(rad)) -
        _tileSize / 2;
    return Offset(x, y);
  }

  Widget _positionedTooth(int index) {
    final tooth = _allTeeth[index];
    final pos = _archView ? _archPos(index) : _gridPos(index);
    return AnimatedPositioned(
      key: ValueKey(tooth),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      left: pos.dx,
      top: pos.dy,
      child: SizedBox(width: _tileSize, child: _toothTile(tooth)),
    );
  }

  /// Tira compacta con SOLO los 32 anillos numerados (sin la silueta del
  /// diente), para ver el estado de toda la boca de un vistazo.
  Widget _buildRingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen rápido',
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Wrap(children: _allUpper.map(_ringBadge).toList()),
        Wrap(children: _allLower.map(_ringBadge).toList()),
      ],
    );
  }

  Widget _ringBadge(int tooth) {
    final mark = _markFor(tooth);
    final primary = Theme.of(context).colorScheme.primary;
    final hasSymbol = mark.symbol != OdontoSymbol.ninguno;
    final hasFreehand = mark.freehandStrokes.isNotEmpty;
    final statusColor = mark.color == 'azul' ? Colors.blue : Colors.red;
    return GestureDetector(
      onTap: () => _openSymbolPicker(tooth),
      child: Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasSymbol ? statusColor.withOpacity(0.85) : Colors.white,
          border: (hasSymbol || hasFreehand)
              ? Border.all(color: statusColor, width: 2.0)
              : null,
          boxShadow: [
            BoxShadow(
                color: (hasSymbol ? statusColor : primary).withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          '$tooth',
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: hasSymbol ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  Widget _toothTile(int tooth) {
    final mark = _markFor(tooth);
    final type = _toothType(tooth);
    final primary = Theme.of(context).colorScheme.primary;
    const size = _tileSize;

    final hasSymbol = mark.symbol != OdontoSymbol.ninguno;
    final hasFreehand = mark.freehandStrokes.isNotEmpty;
    final statusColor = mark.color == 'azul' ? Colors.blue : Colors.red;

    final Color fillColor = hasSymbol
        ? statusColor.withOpacity(0.16)
        : Colors.white;
    final Color strokeColor = (hasSymbol || hasFreehand)
        ? statusColor
        : primary.withOpacity(0.45);
    final double strokeWidth = (hasSymbol || hasFreehand) ? 2.2 : 1.4;

    final pressed = _pressedTooth == tooth;

    return Column(
        children: [
          GestureDetector(
            onTap: mode == OdontogramMode.simbolo
                ? () => _openSymbolPicker(tooth)
                : null,
            onTapDown: mode == OdontogramMode.simbolo
                ? (_) => setState(() => _pressedTooth = tooth)
                : null,
            onTapUp: mode == OdontogramMode.simbolo
                ? (_) => setState(() => _pressedTooth = null)
                : null,
            onTapCancel: mode == OdontogramMode.simbolo
                ? () => setState(() => _pressedTooth = null)
                : null,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: mode == OdontogramMode.lapiz
                  ? (e) {
                      setState(() => _scrollLocked = true);
                      _addFreehandPoint(tooth, e.localPosition,
                          newStroke: true);
                    }
                  : null,
              onPointerMove: mode == OdontogramMode.lapiz
                  ? (e) => _addFreehandPoint(tooth, e.localPosition,
                      newStroke: false)
                  : null,
              onPointerUp: mode == OdontogramMode.lapiz
                  ? (_) {
                      _commitFreehand(tooth);
                      setState(() => _scrollLocked = false);
                    }
                  : null,
              onPointerCancel: mode == OdontogramMode.lapiz
                  ? (_) => setState(() => _scrollLocked = false)
                  : null,
              child: AnimatedScale(
                scale: pressed ? 0.90 : 1.0,
                duration: const Duration(milliseconds: 90),
                curve: Curves.easeOut,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(size, size),
                        painter: _ToothShapePainter(
                          type: type,
                          fillColor: fillColor,
                          strokeColor: strokeColor,
                          strokeWidth: strokeWidth,
                        ),
                      ),
                      CustomPaint(
                        size: const Size(size, size),
                        painter: _FreehandPainter(mark),
                      ),
                      if (symbolGlyph[mark.symbol]?.isNotEmpty ?? false)
                        Text(
                          symbolGlyph[mark.symbol]!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Anillo con el número de la pieza (como en las cartillas
          // odontológicas impresas).
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: primary.withOpacity(0.28),
                    blurRadius: 5,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              '$tooth',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
          if (mark.movilidad > 0)
            Text('M${mark.movilidad}', style: const TextStyle(fontSize: 8)),
          if (mark.recesion)
            const Text('Rec', style: TextStyle(fontSize: 8)),
        ],
      );
  }
}

/// Dibuja una silueta simplificada de diente según su tipo anatómico
/// (incisivo, canino, premolar, molar), en vez del cuadrado genérico.
class _ToothShapePainter extends CustomPainter {
  final ToothType type;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  _ToothShapePainter({
    required this.type,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  Path _pathFor(Size s) {
    final w = s.width, h = s.height;
    final p = Path();
    switch (type) {
      case ToothType.incisor:
        // Borde incisal recto arriba, cuerpo angosto y redondeado abajo.
        p.moveTo(w * 0.30, h * 0.10);
        p.lineTo(w * 0.70, h * 0.10);
        p.quadraticBezierTo(w * 0.82, h * 0.14, w * 0.78, h * 0.34);
        p.quadraticBezierTo(w * 0.72, h * 0.78, w * 0.58, h * 0.94);
        p.quadraticBezierTo(w * 0.50, h * 1.00, w * 0.42, h * 0.94);
        p.quadraticBezierTo(w * 0.28, h * 0.78, w * 0.22, h * 0.34);
        p.quadraticBezierTo(w * 0.18, h * 0.14, w * 0.30, h * 0.10);
        p.close();
        break;
      case ToothType.canine:
        // Cúspide puntiaguda al centro (forma clásica de "colmillo").
        p.moveTo(w * 0.50, h * 0.05);
        p.lineTo(w * 0.68, h * 0.24);
        p.quadraticBezierTo(w * 0.82, h * 0.32, w * 0.78, h * 0.50);
        p.quadraticBezierTo(w * 0.72, h * 0.82, w * 0.56, h * 0.95);
        p.quadraticBezierTo(w * 0.50, h * 1.00, w * 0.44, h * 0.95);
        p.quadraticBezierTo(w * 0.28, h * 0.82, w * 0.22, h * 0.50);
        p.quadraticBezierTo(w * 0.18, h * 0.32, w * 0.32, h * 0.24);
        p.close();
        break;
      case ToothType.premolar:
        // Dos cúspides suaves arriba (vestibular + palatina/lingual).
        p.moveTo(w * 0.18, h * 0.26);
        p.quadraticBezierTo(w * 0.28, h * 0.08, w * 0.40, h * 0.22);
        p.quadraticBezierTo(w * 0.50, h * 0.12, w * 0.60, h * 0.22);
        p.quadraticBezierTo(w * 0.72, h * 0.08, w * 0.82, h * 0.26);
        p.quadraticBezierTo(w * 0.90, h * 0.40, w * 0.82, h * 0.58);
        p.quadraticBezierTo(w * 0.76, h * 0.86, w * 0.58, h * 0.96);
        p.quadraticBezierTo(w * 0.50, h * 1.00, w * 0.42, h * 0.96);
        p.quadraticBezierTo(w * 0.24, h * 0.86, w * 0.18, h * 0.58);
        p.quadraticBezierTo(w * 0.10, h * 0.40, w * 0.18, h * 0.26);
        p.close();
        break;
      case ToothType.molar:
        // Corona ancha con varias cúspides (superficie oclusal amplia).
        p.moveTo(w * 0.08, h * 0.32);
        p.quadraticBezierTo(w * 0.14, h * 0.10, w * 0.28, h * 0.20);
        p.quadraticBezierTo(w * 0.38, h * 0.06, w * 0.50, h * 0.18);
        p.quadraticBezierTo(w * 0.62, h * 0.06, w * 0.72, h * 0.20);
        p.quadraticBezierTo(w * 0.86, h * 0.10, w * 0.92, h * 0.32);
        p.quadraticBezierTo(w * 0.98, h * 0.48, w * 0.88, h * 0.64);
        p.quadraticBezierTo(w * 0.80, h * 0.88, w * 0.58, h * 0.97);
        p.quadraticBezierTo(w * 0.50, h * 1.00, w * 0.42, h * 0.97);
        p.quadraticBezierTo(w * 0.20, h * 0.88, w * 0.12, h * 0.64);
        p.quadraticBezierTo(w * 0.02, h * 0.48, w * 0.08, h * 0.32);
        p.close();
        break;
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _pathFor(size);
    // Claymorphism: sombra suave difusa debajo de la silueta, para que se
    // vea "inflada" como si fuera de plastilina, en vez de plana.
    canvas.drawShadow(path, strokeColor.withOpacity(0.55), 3, false);
    canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ToothShapePainter old) =>
      old.type != type ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor ||
      old.strokeWidth != strokeWidth;
}

/// Trazos de lápiz dibujados a mano libre sobre la pieza.
class _FreehandPainter extends CustomPainter {
  final ToothMark mark;
  _FreehandPainter(this.mark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mark.color == 'rojo' ? Colors.red : Colors.blue
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in mark.freehandStrokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(
          Offset(stroke[i].dx, stroke[i].dy),
          Offset(stroke[i + 1].dx, stroke[i + 1].dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FreehandPainter oldDelegate) => true;
}
