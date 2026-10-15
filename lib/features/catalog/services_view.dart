import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/models.dart';
import '../auth/auth_cubit.dart';
import '../booking/booking_page.dart';
import 'catalog_cubit.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final user = context.select((AuthCubit c) => c.state.user);
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state.status == LoadStatus.failure) {
          return EmptyView(
            icon: Icons.cloud_off_rounded,
            title: l.errorLoad,
            action: TextButton(onPressed: context.read<CatalogCubit>().load, child: Text(l.retry)),
          );
        }
        if (state.status == LoadStatus.loading) return const Center(child: CircularProgressIndicator());

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.greeting(user?.firstName ?? ''),
                          style: const TextStyle(color: Glow.inkSoft, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(l.homeTitle, style: const TextStyle(fontFamily: Glow.serif, fontSize: 34, height: 1.1)),
                      const SizedBox(height: 18),
                      const _SalonCard(),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(22, 14, 14, 6),
                  children: [
                    for (final c in [null, ...state.categories])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c == null ? l.categoryAll : context.category(c)),
                          selected: state.category == c,
                          onSelected: (_) => context.read<CatalogCubit>().selectCategory(c),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
              sliver: SliverList.separated(
                itemCount: state.visibleServices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final service = state.visibleServices[i];
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(service.id),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, t, child) =>
                        Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child)),
                    child: _ServiceCard(service: service, specialists: state.staffFor(service)),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
                child: Text(l.ourTeam, style: const TextStyle(fontFamily: Glow.serif, fontSize: 24)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                  itemCount: state.staff.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _StaffCard(staff: state.staff[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SalonCard extends StatelessWidget {
  const _SalonCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: Glow.heroGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Glow.rose.withValues(alpha: .3), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l.appName,
                      style: const TextStyle(fontFamily: Glow.serif, color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 6),
                  _line(Icons.place_outlined, context.l.salonAddress),
                  const SizedBox(height: 4),
                  _line(Icons.schedule_rounded, context.l.openHours),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.star_rounded, color: Colors.white),
                  Text('4.9', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _line(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.specialists});

  final Service service;
  final List<Staff> specialists;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: Glow.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(BookingPage.route(service, specialists)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: 'service-${service.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(18)),
                  child: Icon(serviceIcon(service.icon), color: Glow.rose),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name(context.lang),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${context.category(service.category)} · ${l.minutes(service.durationMin)}',
                      style: const TextStyle(color: Glow.inkSoft, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.money(service.price),
                      style: const TextStyle(fontFamily: Glow.serif, fontSize: 20, color: Glow.roseDark)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: Glow.ink, borderRadius: BorderRadius.circular(12)),
                    child: Text(l.book,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.staff});

  final Staff staff;

  @override
  Widget build(BuildContext context) => Container(
        width: 128,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Glow.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          children: [
            StaffAvatar(staff: staff, size: 58),
            const SizedBox(height: 8),
            Text(staff.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(staff.role(context.lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Glow.inkSoft, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 15, color: Glow.gold),
                Text(' ${staff.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ],
        ),
      );
}
