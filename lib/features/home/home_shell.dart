import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../admin/admin_cubit.dart';
import '../admin/admin_view.dart';
import '../appointments/appointments_cubit.dart';
import '../appointments/appointments_view.dart';
import '../catalog/catalog_cubit.dart';
import '../catalog/services_view.dart';
import '../profile/profile_view.dart';
import 'tab_cubit.dart';

/// Bottom navigation for a signed-in user. The salon tab appears for the
/// owner, or for anyone who switched on demo owner mode.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    Notifier.instance.requestPermission();
  }

  void _notify(Appointment a) {
    if (!mounted) return;
    final l = context.l;
    final service = a.serviceName(context.lang);
    final date = '${context.shortDate(a.start)} ${context.time(a.start)}';
    final confirmed = a.status == AppointmentStatus.confirmed;
    Notifier.instance.show(
      a.id,
      confirmed ? l.notifConfirmedTitle : l.notifDeclinedTitle,
      confirmed ? l.notifConfirmedBody(service, date) : l.notifDeclinedBody(service, date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final user = widget.user;
    final bookings = context.read<BookingRepository>();
    final owner = user.seesOwnerTools;

    final tabs = [HomeTab.book, HomeTab.appointments, if (owner) HomeTab.salon, HomeTab.profile];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CatalogCubit(context.read<CatalogRepository>())),
        BlocProvider(
          key: ValueKey('appointments-${user.uid}'),
          create: (_) => AppointmentsCubit(bookings, user.uid, onStatusChanged: _notify),
        ),
        if (owner)
          BlocProvider(
            key: ValueKey('admin-${user.uid}-${user.role}-${user.demoOwner}'),
            create: (_) => AdminCubit(bookings, user),
          ),
      ],
      child: BlocBuilder<TabCubit, HomeTab>(
        builder: (context, tab) {
          final index = tabs.contains(tab) ? tabs.indexOf(tab) : 0;
          Widget page(HomeTab t) => switch (t) {
                HomeTab.book => const ServicesView(),
                HomeTab.appointments =>
                  AppointmentsView(onBookNew: () => context.read<TabCubit>().show(HomeTab.book)),
                HomeTab.salon => const AdminView(),
                HomeTab.profile => const ProfileView(),
              };
          return Scaffold(
            body: IndexedStack(index: index, children: [for (final t in tabs) page(t)]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => context.read<TabCubit>().show(tabs[i]),
              destinations: [
                for (final t in tabs)
                  switch (t) {
                    HomeTab.book => NavigationDestination(
                        icon: const Icon(Icons.spa_outlined),
                        selectedIcon: const Icon(Icons.spa_rounded, color: Glow.rose),
                        label: l.tabBook,
                      ),
                    HomeTab.appointments => NavigationDestination(
                        icon: const Icon(Icons.event_note_outlined),
                        selectedIcon: const Icon(Icons.event_note_rounded, color: Glow.rose),
                        label: l.tabAppointments,
                      ),
                    HomeTab.salon => NavigationDestination(
                        icon: const _PendingBadge(child: Icon(Icons.storefront_outlined)),
                        selectedIcon: const _PendingBadge(child: Icon(Icons.storefront_rounded, color: Glow.rose)),
                        label: l.tabSalon,
                      ),
                    HomeTab.profile => NavigationDestination(
                        icon: const Icon(Icons.person_outline_rounded),
                        selectedIcon: const Icon(Icons.person_rounded, color: Glow.rose),
                        label: l.tabProfile,
                      ),
                  },
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final count = context.select((AdminCubit c) => c.state.pending.length);
    return Badge.count(count: count, isLabelVisible: count > 0, backgroundColor: Glow.rose, child: child);
  }
}
