import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;

  /// The profile document; null while it is still being created after sign-up.
  final AppUser? user;

  @override
  List<Object?> get props => [status, user];
}

/// Follows Firebase Auth and the signed-in user's profile document.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState()) {
    _authSub = _repo.authStateChanges().listen((user) {
      _profileSub?.cancel();
      if (user == null) {
        emit(const AuthState(status: AuthStatus.signedOut));
        return;
      }
      emit(const AuthState(status: AuthStatus.signedIn));
      _profileSub = _repo.watchProfile(user.uid).listen(
            (profile) => emit(AuthState(status: AuthStatus.signedIn, user: profile)),
            onError: (_) {},
          );
    });
  }

  final AuthRepository _repo;
  StreamSubscription<Object?>? _authSub;
  StreamSubscription<Object?>? _profileSub;

  AuthRepository get repository => _repo;

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    await _profileSub?.cancel();
    return super.close();
  }
}
