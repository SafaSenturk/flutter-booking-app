import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../catalog/catalog_cubit.dart';
import 'appointments_cubit.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key, required this.onBookNew});

  final VoidCallback onBookNew;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.tabAppointments),
          bottom: TabBar(
            labelStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 15),
            indicatorColor: Glow.rose,
            labelColor: Glow.ink,
            unselectedLabelColor: Glow.inkSoft,
            tabs: [Tab(text: l.upcoming), Tab(text: l.past)],
          ),
        ),
        body: BlocBuilder<AppointmentsCubit, AppointmentsState>(
          builder: (context, state) {
            if (state.status == LoadStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.status == LoadStatus.failure) {
              return EmptyView(icon: Icons.cloud_off_rounded, title: l.errorLoad);
            }
            final now = DateTime.now();
            final upcoming = state.upcoming(now);
            final past = state.past(now);
            return TabBarView(
              children: [
                upcoming.isEmpty
                    ? EmptyView(
                        icon: Icons.event_available_rounded,
                        title: l.noUpcomingTitle,
                        body: l.noUpcomingBody,
                        action: FilledButton(
                          style: FilledButton.styleFrom(minimumSize: const Size(200, 52)),
                          onPressed: onBookNew,
                          child: Text(l.tabBook),
                        ),
                      )
                    : _List(items: upcoming, now: now),
                past.isEmpty ? EmptyView(icon: Icons.history_rounded, title: l.noPast) : _List(items: past, now: now),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.items, required this.now});

  final List<Appointment> items;
  final DateTime now;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => AppointmentCard(
          appointment: items[i],
          trailing: items[i].canCancel(now) ? _CancelButton(appointment: items[i]) : null,
        ),
      );
}

/// Date block + service, specialist, time and status. Shared with the salon panel.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, required this.appointment, this.trailing, this.showCustomer = false});

  final Appointment appointment;
  final Widget? trailing;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final muted = a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.declined;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: muted ? .6 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Glow.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text(context.monthShort(a.start),
                          style: const TextStyle(color: Glow.rose, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      Text('${a.start.day}', style: const TextStyle(fontFamily: Glow.serif, fontSize: 28, height: 1.1)),
                      Text(context.weekdayShort(a.start), style: const TextStyle(color: Glow.inkSoft, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        showCustomer ? a.customerName : a.serviceName(context.lang),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        showCustomer ? a.serviceName(context.lang) : context.l.withStaff(a.staffName),
                        style: const TextStyle(color: Glow.inkSoft, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 15, color: Glow.inkSoft),
                          const SizedBox(width: 4),
                          Text('${context.time(a.start)} – ${context.time(a.end)}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          if (showCustomer) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text('· ${a.staffName.split(' ').first}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Glow.inkSoft, fontSize: 13)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusChip(a.status),
                    const SizedBox(height: 8),
                    Text(context.money(a.price), style: const TextStyle(fontFamily: Glow.serif, fontSize: 18)),
                  ],
                ),
              ],
            ),
            if (a.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('“${a.note}”', style: const TextStyle(color: Glow.inkSoft, fontStyle: FontStyle.italic)),
              ),
            ],
            if (trailing != null) ...[const SizedBox(height: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
        onPressed: () async {
          final cubit = context.read<AppointmentsCubit>();
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text(l.cancelTitle),
              content: Text(l.cancelBody),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.keep)),
                TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.cancelBooking)),
              ],
            ),
          );
          if (ok ?? false) {
            try {
              await cubit.cancel(appointment);
            } catch (_) {
              if (context.mounted) context.toast(l.errorUnknown, error: true);
            }
          }
        },
        icon: const Icon(Icons.close_rounded, size: 18),
        label: Text(l.cancelBooking),
      ),
    );
  }
}
