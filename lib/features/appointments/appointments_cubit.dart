import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../catalog/catalog_cubit.dart';

class AppointmentsState extends Equatable {
  const AppointmentsState({this.status = LoadStatus.loading, this.items = const []});

  final LoadStatus status;

  /// Newest first.
  final List<Appointment> items;

  List<Appointment> upcoming(DateTime now) =>
      items.where((a) => a.isUpcoming(now)).toList()..sort((a, b) => a.start.compareTo(b.start));

  List<Appointment> past(DateTime now) => items.where((a) => !a.isUpcoming(now)).toList();

  @override
  List<Object?> get props => [status, items];
}

/// The signed-in customer's bookings, live. Calls [onStatusChanged] when the
/// salon confirms or declines one, so the app can notify the user.
class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit(this._repo, this.uid, {this.onStatusChanged}) : super(const AppointmentsState()) {
    _sub = _repo.watchMine(uid).listen(_onData, onError: (_) => emit(const AppointmentsState(status: LoadStatus.failure)));
  }

  final BookingRepository _repo;
  final String uid;
  final void Function(Appointment)? onStatusChanged;
  StreamSubscription<List<Appointment>>? _sub;
  Map<String, AppointmentStatus>? _known;

  void _onData(List<Appointment> list) {
    final known = _known;
    if (known != null) {
      for (final a in list) {
        final before = known[a.id];
        if (before == AppointmentStatus.pending &&
            (a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.declined)) {
          onStatusChanged?.call(a);
        }
      }
    }
    _known = {for (final a in list) a.id: a.status};
    emit(AppointmentsState(status: LoadStatus.ready, items: list));
  }

  Future<void> cancel(Appointment a) => _repo.setStatus(a, AppointmentStatus.cancelled);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
