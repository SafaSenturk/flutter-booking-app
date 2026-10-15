import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../../domain/availability.dart';
import '../appointments/appointments_view.dart';
import '../catalog/catalog_cubit.dart';
import 'admin_cubit.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  bool _showSchedule = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final cubit = context.read<AdminCubit>();
        return Scaffold(
          appBar: AppBar(title: Text(l.salonPanel)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              if (!cubit.user.isAdmin)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Glow.sageSoft, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.science_outlined, color: Glow.sage),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l.demoBanner, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              Row(
                children: [
                  _Stat(value: '${state.pending.length}', label: l.statPending, highlight: state.pending.isNotEmpty),
                  const SizedBox(width: 10),
                  _Stat(value: '${state.activeToday.length}', label: l.statToday),
                  const SizedBox(width: 10),
                  _Stat(value: context.money(state.expectedRevenue), label: l.statRevenue),
                ],
              ),
              const SizedBox(height: 18),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text('${l.requests} (${state.pending.length})')),
                  ButtonSegment(value: true, label: Text(l.schedule)),
                ],
                selected: {_showSchedule},
                onSelectionChanged: (s) => setState(() => _showSchedule = s.first),
              ),
              const SizedBox(height: 14),
              if (_showSchedule) ...[
                _DayStrip(selected: state.day, onSelect: cubit.selectDay),
                const SizedBox(height: 14),
                if (state.status == LoadStatus.loading)
                  const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                else if (state.schedule.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(l.noBookingsDay, style: const TextStyle(color: Glow.inkSoft))),
                  )
                else
                  for (final a in state.schedule) ...[
                    _TimelineRow(appointment: a, state: state),
                    const SizedBox(height: 10),
                  ],
              ] else if (state.pending.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text(l.noRequests, style: const TextStyle(color: Glow.inkSoft, fontSize: 16))),
                )
              else
                for (final a in state.pending) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: AppointmentCard(
                      key: ValueKey(a.id),
                      appointment: a,
                      showCustomer: true,
                      trailing: _Decision(appointment: a, busy: state.busyIds.contains(a.id)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.highlight = false});

  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: highlight ? Glow.heroGradient : null,
            color: highlight ? null : Glow.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(value,
                    style: TextStyle(fontFamily: Glow.serif, fontSize: 26, color: highlight ? Colors.white : Glow.ink)),
              ),
              Text(label,
                  style: TextStyle(
                    color: highlight ? Colors.white70 : Glow.inkSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      );
}

class _Decision extends StatelessWidget {
  const _Decision({required this.appointment, required this.busy});

  final Appointment appointment;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<AdminCubit>();
    if (busy) return const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator());
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
            onPressed: () {
              HapticFeedback.lightImpact();
              cubit.decline(appointment);
            },
            child: Text(l.decline),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46), backgroundColor: Glow.sage),
            onPressed: () {
              HapticFeedback.mediumImpact();
              cubit.approve(appointment);
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(l.approve),
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.appointment, required this.state});

  final Appointment appointment;
  final AdminState state;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final (_, color) = statusColors(a.status);
    final canComplete = a.status == AppointmentStatus.confirmed && a.start.isBefore(DateTime.now());
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Text(context.time(a.start), style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Container(width: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Glow.surface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.customerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${a.serviceName(context.lang)} · ${a.staffName.split(' ').first}',
                            style: const TextStyle(color: Glow.inkSoft, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (canComplete)
                    TextButton(
                      onPressed: () => context.read<AdminCubit>().complete(a),
                      child: Text(context.l.markDone),
                    )
                  else
                    StatusChip(a.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = Availability.bookableDays(DateTime.now()).take(14);
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final d in days)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${context.weekdayShort(d)} ${d.day}'),
                selected: d == selected,
                onSelected: (_) => onSelect(d),
              ),
            ),
        ],
      ),
    );
  }
}
