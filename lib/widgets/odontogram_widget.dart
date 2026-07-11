import 'package:flutter/material.dart';
import '../models/models.dart';

/// Numeración FDI de dientes permanentes, organizada como en el formulario:
/// fila superior 18→11 | 21→28, fila inferior 48→41 | 31→38.
/// (Para piezas deciduales 55-51/61-65/85-81/71-75 basta con agregar otra
/// fila reutilizando el mismo _toothBox — están comentadas más abajo.)
const _upperRight = [18, 17, 16, 15, 14, 13, 12, 11];
const _upperLeft = [21, 22, 23, 24, 25, 26, 27, 28];
const _lowerRight = [48, 47, 46, 45, 44, 43, 42, 41];
const _lowerLeft = [31, 32, 33, 34, 35, 36, 37, 38];

enum OdontogramMode { simbolo, lapiz }

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
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Se bloquea justo mientras el lápiz está dibujando sobre
              // un diente, para que no se robe el trazo (ver más arriba).
              physics: _scrollLocked
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Row(children: [
                    ..._upperRight.map(_toothBox),
                    const SizedBox(width: 16),
                    ..._upperLeft.map(_toothBox),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    ..._lowerRight.map(_toothBox),
                    const SizedBox(width: 16),
                    ..._lowerLeft.map(_toothBox),
                  ]),
                ],
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

  Widget _toothBox(int tooth) {
    final mark = _markFor(tooth);
    const size = 52.0;
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        children: [
          Text('$tooth',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: primary.withOpacity(0.7))),
          GestureDetector(
            onTap: mode == OdontogramMode.simbolo
                ? () => _openSymbolPicker(tooth)
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
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withOpacity(0.4)),
                  color: Colors.white,
                ),
                child: CustomPaint(
                  painter: _ToothPainter(mark),
                  child: Center(
                    child: Text(
                      symbolGlyph[mark.symbol] ?? '',
                      style: TextStyle(
                        fontSize: 20,
                        color:
                            mark.color == 'rojo' ? Colors.red : Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (mark.movilidad > 0)
            Text('M${mark.movilidad}', style: const TextStyle(fontSize: 8)),
          if (mark.recesion)
            const Text('Rec', style: TextStyle(fontSize: 8)),
        ],
      ),
    );
  }
}

class _ToothPainter extends CustomPainter {
  final ToothMark mark;
  _ToothPainter(this.mark);

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
  bool shouldRepaint(covariant _ToothPainter oldDelegate) => true;
}
