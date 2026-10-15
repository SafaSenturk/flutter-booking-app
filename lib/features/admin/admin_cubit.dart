import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../catalog/catalog_cubit.dart';

class AdminState extends Equatable {
  const AdminState({
    required this.day,
    this.status = LoadStatus.loading,
    this.schedule = const [],
    this.pending = const [],
    this.busyIds = const {},
  });

  final DateTime day;
  final LoadStatus status;

  /// Bookings on [day], by start time.
  final List<Appointment> schedule;

  /// All requests waiting for an answer.
  final List<Appointment> pending;

  /// Bookings with an update in flight (their buttons show a spinner).
  final Set<String> busyIds;

  List<Appointment> get activeToday => schedule
      .where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.completed)
      .toList();

  int get expectedRevenue => activeToday.fold(0, (sum, a) => sum + a.price);

  AdminState copyWith({
    DateTime? day,
    LoadStatus? status,
    List<Appointment>? schedule,
    List<Appointment>? pending,
    Set<String>? busyIds,
  }) =>
      AdminState(
        day: day ?? this.day,
        status: status ?? this.status,
        schedule: schedule ?? this.schedule,
        pending: pending ?? this.pending,
        busyIds: busyIds ?? this.busyIds,
      );

  @override
  List<Object?> get props => [day, status, schedule, pending, busyIds];
}

/// The salon owner's panel. A real admin sees every booking; in demo owner mode
/// the same screens work on the user's own bookings only (enforced by the rules).
class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._repo, this.user, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(AdminState(day: _today((clock ?? DateTime.now)()))) {
    _listen();
  }

  final BookingRepository _repo;
  final AppUser user;
  final DateTime Function() _clock;
  final _subs = <StreamSubscription<Object?>>[];
  List<Appointment> _mine = const [];

  static DateTime _today(DateTime now) => DateTime(now.year, now.month, now.day);

  void _listen() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    void fail(Object _) => emit(state.copyWith(status: LoadStatus.failure));

    if (user.isAdmin) {
      _subs
        ..add(_repo.watchDay(state.day).listen(
              (list) => emit(state.copyWith(schedule: list, status: LoadStatus.ready)),
              onError: fail,
            ))
        ..add(_repo.watchPending().listen((list) => emit(state.copyWith(pending: list)), onError: fail));
    } else {
      _subs.add(_repo.watchMine(user.uid).listen((list) {
        _mine = list;
        _emitDemo();
      }, onError: fail));
    }
  }

  void _emitDemo() {
    final day = state.day;
    bool sameDay(DateTime t) => t.year == day.year && t.month == day.month && t.day == day.day;
    emit(state.copyWith(
      status: LoadStatus.ready,
      schedule: _mine.where((a) => sameDay(a.start)).toList()..sort((a, b) => a.start.compareTo(b.start)),
      pending: _mine.where((a) => a.status == AppointmentStatus.pending && a.end.isAfter(_clock())).toList()
        ..sort((a, b) => a.start.compareTo(b.start)),
    ));
  }

  void selectDay(DateTime day) {
    emit(state.copyWith(day: day, status: LoadStatus.loading));
    if (user.isAdmin) {
      _listen();
    } else {
      _emitDemo();
    }
  }

  Future<void> approve(Appointment a) => _update(a, AppointmentStatus.confirmed);
  Future<void> decline(Appointment a) => _update(a, AppointmentStatus.declined);
  Future<void> complete(Appointment a) => _update(a, AppointmentStatus.completed);

  Future<void> _update(Appointment a, AppointmentStatus status) async {
    emit(state.copyWith(busyIds: {...state.busyIds, a.id}));
    try {
      await _repo.setStatus(a, status);
    } finally {
      emit(state.copyWith(busyIds: {...state.busyIds}..remove(a.id)));
    }
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}
