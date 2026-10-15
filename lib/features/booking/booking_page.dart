import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../domain/availability.dart';
import '../auth/auth_cubit.dart';
import 'booking_cubit.dart';
import 'booking_success_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.service});

  final Service service;

  static Route<void> route(Service service, List<Staff> specialists) => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => BookingCubit(
            service: service,
            specialists: specialists,
            repository: context.read<BookingRepository>(),
          ),
          child: BookingPage(service: service),
        ),
      );

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final cubit = context.read<BookingCubit>();
    final service = widget.service;

    return BlocConsumer<BookingCubit, BookingState>(
      listenWhen: (a, b) => a.error != b.error || a.bookedId != b.bookedId,
      listener: (context, state) {
        if (state.bookedId != null) {
          Navigator.of(context).pushReplacement(BookingSuccessPage.route(
            service: service,
            start: state.bookedStart!,
          ));
        } else if (state.error != null) {
          HapticFeedback.heavyImpact();
          context.toast(state.error == BookingError.slotTaken ? l.slotTaken : l.bookingFailed, error: true);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Row(
              children: [
                Hero(
                  tag: 'service-${service.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(20)),
                    child: Icon(serviceIcon(service.icon), color: Glow.rose, size: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name(context.lang), style: const TextStyle(fontFamily: Glow.serif, fontSize: 26)),
                      Text('${l.minutes(service.durationMin)} · ${context.money(service.price)}',
                          style: const TextStyle(color: Glow.inkSoft, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            _Section(l.chooseSpecialist),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SpecialistOption(
                    selected: state.staff == null,
                    onTap: () => cubit.selectStaff(null),
                    avatar: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(color: Glow.sageSoft, shape: BoxShape.circle),
                      child: const Icon(Icons.groups_rounded, color: Glow.sage),
                    ),
                    title: l.anySpecialist,
                    subtitle: l.anySpecialistHint,
                  ),
                  for (final s in cubit.specialists)
                    _SpecialistOption(
                      selected: state.staff == s,
                      onTap: () => cubit.selectStaff(s),
                      avatar: StaffAvatar(staff: s),
                      title: s.name.split(' ').first,
                      subtitle: '★ ${s.rating}',
                    ),
                ],
              ),
            ),
            _Section(l.pickDate),
            SizedBox(
              height: 86,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final d in cubit.days)
                    _DayChip(
                      day: d,
                      selected: d == state.day,
                      open: cubit.isOpen(d),
                      onTap: () => cubit.selectDay(d),
                    ),
                ],
              ),
            ),
            _Section(l.availableTimes),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, ?current],
              ),
              child: _TimeGrid(key: ValueKey(state.day), state: state, onPick: cubit.selectTime),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _note,
              maxLines: 2,
              maxLength: 200,
              decoration: InputDecoration(hintText: l.noteHint),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
            decoration: const BoxDecoration(color: Glow.surface, border: Border(top: BorderSide(color: Glow.line))),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.money(service.price), style: const TextStyle(fontFamily: Glow.serif, fontSize: 24)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        state.time == null ? l.minutes(service.durationMin) : '${context.shortDate(state.time!)} · ${context.time(state.time!)}',
                        key: ValueKey(state.time),
                        style: const TextStyle(color: Glow.inkSoft, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: state.canSubmit
                        ? () {
                            final user = context.read<AuthCubit>().state.user;
                            if (user != null) cubit.submit(user, note: _note.text);
                          }
                        : null,
                    child: state.submitting
                        ? const SizedBox.square(
                            dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(l.requestBooking),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      );
}

class _SpecialistOption extends StatelessWidget {
  const _SpecialistOption({
    required this.selected,
    required this.onTap,
    required this.avatar,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget avatar;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 96,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? Glow.roseSoft : Glow.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? Glow.rose : Glow.line, width: selected ? 2 : 1),
            ),
            child: Column(
              children: [
                avatar,
                const SizedBox(height: 4),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Glow.inkSoft, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected, required this.open, required this.onTap});

  final DateTime day;
  final bool selected;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : (open ? Glow.ink : Glow.inkSoft.withValues(alpha: .5));
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 62,
          decoration: BoxDecoration(
            color: selected ? Glow.ink : (open ? Glow.surface : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? Glow.ink : Glow.line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.weekdayShort(day), style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${day.day}', style: TextStyle(fontFamily: Glow.serif, fontSize: 26, color: fg)),
              Text(context.monthShort(day), style: TextStyle(color: fg, fontSize: 10, letterSpacing: 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({super.key, required this.state, required this.onPick});

  final BookingState state;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (state.loadingSlots) {
      return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
    }
    if (state.slots.isEmpty) return _Note(l.closedDay, Icons.event_busy_rounded);
    if (!state.slots.any((s) => s.available)) return _Note(l.fullyBooked, Icons.hourglass_disabled_rounded);

    final groups = <String, List<TimeSlot>>{
      l.morning: state.slots.where((s) => s.start.hour < 12).toList(),
      l.afternoon: state.slots.where((s) => s.start.hour >= 12 && s.start.hour < 16).toList(),
      l.evening: state.slots.where((s) => s.start.hour >= 16).toList(),
    }..removeWhere((_, v) => v.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: label, value: slots) in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(label, style: const TextStyle(color: Glow.inkSoft, fontWeight: FontWeight.w600)),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in slots)
                _TimeChip(
                  slot: s,
                  selected: state.time == s.start,
                  onTap: s.available ? () => onPick(s.start) : null,
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.slot, required this.selected, this.onTap});

  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = slot.available;
    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Glow.rose : (available ? Glow.surface : Glow.line.withValues(alpha: .4)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Glow.rose : Glow.line),
          boxShadow: selected
              ? [BoxShadow(color: Glow.rose.withValues(alpha: .35), blurRadius: 12, offset: const Offset(0, 6))]
              : null,
        ),
        child: Text(
          context.time(slot.start),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : (available ? Glow.ink : Glow.inkSoft.withValues(alpha: .45)),
            decoration: available ? null : TextDecoration.lineThrough,
          ),
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Icon(icon, color: Glow.rose),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
