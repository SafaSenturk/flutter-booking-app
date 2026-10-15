import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../home/tab_cubit.dart';

/// Shown after a booking request is saved.
class BookingSuccessPage extends StatefulWidget {
  const BookingSuccessPage({super.key, required this.service, required this.start});

  final Service service;
  final DateTime start;

  static Route<void> route({required Service service, required DateTime start}) =>
      MaterialPageRoute(builder: (_) => BookingSuccessPage(service: service, start: start));

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final fade = CurvedAnimation(parent: _c, curve: const Interval(.4, 1, curve: Curves.easeOut));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox.square(
                dimension: 200,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, _) => CustomPaint(painter: _BloomPainter(_c.value)),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: fade,
                child: Column(
                  children: [
                    Text(l.bookingSentTitle, style: const TextStyle(fontFamily: Glow.serif, fontSize: 34)),
                    const SizedBox(height: 10),
                    Text(l.bookingSentBody,
                        textAlign: TextAlign.center, style: const TextStyle(color: Glow.inkSoft, height: 1.5)),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Glow.surface, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(14)),
                            child: Icon(serviceIcon(widget.service.icon), color: Glow.rose),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.service.name(context.lang),
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${context.longDate(widget.start)} · ${context.time(widget.start)}',
                                    style: const TextStyle(color: Glow.inkSoft, fontSize: 13)),
                              ],
                            ),
                          ),
                          const StatusChip(AppointmentStatus.pending),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  context.read<TabCubit>().show(HomeTab.appointments);
                  Navigator.pop(context);
                },
                child: Text(l.viewAppointments),
              ),
              const SizedBox(height: 10),
              OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l.backHome)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Petals that open around a check mark.
class _BloomPainter extends CustomPainter {
  _BloomPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final open = Curves.easeOutBack.transform((t / .6).clamp(0, 1));
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4 + t * .4;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -size.width * .26 * open), width: size.width * .2, height: size.width * .34 * open),
        Paint()..color = (i.isEven ? Glow.rose : const Color(0xFFD4927A)).withValues(alpha: .35),
      );
      canvas.restore();
    }
    canvas.drawCircle(c, size.width * .24 * open, Paint()..color = Glow.rose);
    final check = ((t - .45) / .35).clamp(0.0, 1.0);
    if (check > 0) {
      final r = size.width * .24;
      final path = Path()
        ..moveTo(c.dx - r * .42, c.dy + r * .02)
        ..lineTo(c.dx - r * .1, c.dy + r * .34)
        ..lineTo(c.dx + r * .46, c.dy - r * .3);
      final m = path.computeMetrics().first;
      canvas.drawPath(
        m.extractPath(0, m.length * check),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .16
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(_BloomPainter old) => old.t != t;
}
