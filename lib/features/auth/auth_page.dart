import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../core/ui.dart';
import '../../data/repositories.dart';
import 'auth_cubit.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _googleBusy = false;

  AuthRepository get _repo => context.read<AuthCubit>().repository;

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {bool google = false}) async {
    setState(() => google ? _googleBusy = true : _busy = true);
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted && e.kind != AuthErrorKind.cancelled) context.toast(context.authError(e), error: true);
    } catch (e) {
      if (mounted) context.toast(context.authError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = _googleBusy = false);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _run(() => _signUp
        ? _repo.signUp(name: _name.text, email: _email.text, password: _password.text)
        : _repo.signIn(_email.text, _password.text));
  }

  Future<void> _forgot() async {
    if (!_emailPattern.hasMatch(_email.text.trim())) {
      context.toast(context.l.invalidEmail, error: true);
      return;
    }
    await _run(() async {
      await _repo.sendPasswordReset(_email.text);
      if (mounted) context.toast(context.l.resetSent(_email.text.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Editorial hero with soft floating circles.
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: Glow.heroGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  const Positioned(top: -40, right: -30, child: _Bubble(180, .14)),
                  const Positioned(bottom: 30, left: -50, child: _Bubble(140, .10)),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.spa_rounded, color: Colors.white, size: 40),
                          const SizedBox(height: 18),
                          Text(l.appName,
                              style: const TextStyle(fontFamily: Glow.serif, fontSize: 48, color: Colors.white, height: 1)),
                          const SizedBox(height: 10),
                          Text(l.tagline,
                              style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: false, label: Text(l.signIn)),
                        ButtonSegment(value: true, label: Text(l.signUp)),
                      ],
                      selected: {_signUp},
                      onSelectionChanged: (s) => setState(() => _signUp = s.first),
                    ),
                    const SizedBox(height: 18),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _signUp
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: _name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: l.fullName, prefixIcon: const Icon(Icons.person_outline_rounded)),
                                validator: (v) => _signUp && (v?.trim().isEmpty ?? true) ? l.required : null,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(hintText: l.email, prefixIcon: const Icon(Icons.mail_outline_rounded)),
                      validator: (v) => _emailPattern.hasMatch(v?.trim() ?? '') ? null : l.invalidEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      onFieldSubmitted: (_) => _submit(),
                      decoration:
                          InputDecoration(hintText: l.password, prefixIcon: const Icon(Icons.lock_outline_rounded)),
                      validator: (v) => (v ?? '').length < 6 ? l.passwordLength : null,
                    ),
                    if (!_signUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: _forgot, child: Text(l.forgotPassword)),
                      )
                    else
                      const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Text(_signUp ? l.signUp : l.signIn),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l.or, style: const TextStyle(color: Glow.inkSoft)),
                        ),
                        const Expanded(child: Divider()),
                      ]),
                    ),
                    OutlinedButton.icon(
                      onPressed: _googleBusy ? null : () => _run(_repo.signInWithGoogle, google: true),
                      icon: _googleBusy
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF4285F4))),
                      label: Text(l.continueWithGoogle),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.size, this.opacity);

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: opacity)),
      );
}
