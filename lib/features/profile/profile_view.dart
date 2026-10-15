import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../auth/auth_cubit.dart';
import 'settings_cubit.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final user = context.select((AuthCubit c) => c.state.user);
    final repo = context.read<AuthCubit>().repository;
    if (user == null) return const Center(child: CircularProgressIndicator());
    if (!_filled) {
      _filled = true;
      _name.text = user.name;
      _phone.text = user.phone;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: Glow.heroGradient),
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: const TextStyle(fontFamily: Glow.serif, fontSize: 42, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(user.email, style: const TextStyle(color: Glow.inkSoft))),
          if (user.isAdmin)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Glow.roseSoft, borderRadius: BorderRadius.circular(20)),
                child: Text(l.adminBadge, style: const TextStyle(color: Glow.roseDark, fontWeight: FontWeight.w700)),
              ),
            ),
          const SizedBox(height: 22),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.fullName, prefixIcon: const Icon(Icons.person_outline_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l.phone, prefixIcon: const Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await repo.updateProfile(user.uid, name: _name.text.trim(), phone: _phone.text.trim());
              if (context.mounted) context.toast(l.saved);
            },
            child: Text(l.save),
          ),
          const SizedBox(height: 26),
          Text(l.language, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'tr', label: Text('🇹🇷  Türkçe')),
              ButtonSegment(value: 'en', label: Text('🇬🇧  English')),
            ],
            selected: {context.lang},
            onSelectionChanged: (s) => context.read<SettingsCubit>().setLocale(Locale(s.first)),
          ),
          if (!user.isAdmin) ...[
            const SizedBox(height: 22),
            Container(
              decoration: BoxDecoration(color: Glow.surface, borderRadius: BorderRadius.circular(20)),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                activeThumbColor: Glow.rose,
                title: Text(l.demoOwnerTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(l.demoOwnerBody, style: const TextStyle(color: Glow.inkSoft, height: 1.35)),
                ),
                value: user.demoOwner,
                onChanged: (v) => repo.updateProfile(user.uid, demoOwner: v),
              ),
            ),
          ],
          const SizedBox(height: 26),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: repo.signOut,
            icon: const Icon(Icons.logout_rounded),
            label: Text(l.signOut),
          ),
        ],
      ),
    );
  }
}
