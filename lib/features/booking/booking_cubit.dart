import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../domain/availability.dart';

enum BookingError { slotTaken, failed }

class BookingState extends Equatable {
  const BookingState({
    required this.day,
    this.staff,
    this.slots = const [],
    this.loadingSlots = true,
    this.time,
    this.submitting = false,
    this.error,
    this.bookedId,
    this.bookedStart,
  });

  /// Null means "any specialist".
  final Staff? staff;
  final DateTime day;
  final List<TimeSlot> slots;
  final bool loadingSlots;
  final DateTime? time;
  final bool submitting;
  final BookingError? error;

  /// Set once the booking request was saved.
  final String? bookedId;

  /// Start of the saved booking (the live slot list no longer offers it).
  final DateTime? bookedStart;

  bool get canSubmit => time != null && !submitting;

  BookingState copyWith({
    Staff? Function()? staff,
    DateTime? day,
    List<TimeSlot>? slots,
    bool? loadingSlots,
    DateTime? Function()? time,
    bool? submitting,
    BookingError? Function()? error,
    String? bookedId,
    DateTime? bookedStart,
  }) =>
      BookingState(
        staff: staff != null ? staff() : this.staff,
        day: day ?? this.day,
        slots: slots ?? this.slots,
        loadingSlots: loadingSlots ?? this.loadingSlots,
        time: time != null ? time() : this.time,
        submitting: submitting ?? this.submitting,
        error: error != null ? error() : this.error,
        bookedId: bookedId ?? this.bookedId,
        bookedStart: bookedStart ?? this.bookedStart,
      );

  @override
  List<Object?> get props => [staff, day, slots, loadingSlots, time, submitting, error, bookedId, bookedStart];
}

/// Drives the booking screen: specialist → day → time → confirm.
/// Availability updates live, so a slot booked by someone else disappears.
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required this.service,
    required this.specialists,
    required BookingRepository repository,
    DateTime Function()? clock,
    SalonHours hours = const SalonHours(),
  })  : _repo = repository,
        _clock = clock ?? DateTime.now,
        _hours = hours,
        super(BookingState(day: _firstOpenDay((clock ?? DateTime.now)(), hours))) {
    _watchDay();
  }

  final Service service;

  /// Everyone who offers [service].
  final List<Staff> specialists;
  final BookingRepository _repo;
  final DateTime Function() _clock;
  final SalonHours _hours;
  StreamSubscription<Map<String, Set<String>>>? _sub;
  Map<String, Set<String>> _taken = const {};

  List<DateTime> get days => Availability.bookableDays(_clock(), hours: _hours);
  bool isOpen(DateTime day) => _hours.isOpen(day);

  static DateTime _firstOpenDay(DateTime now, SalonHours hours) {
    var d = DateTime(now.year, now.month, now.day);
    // After closing time today, start from tomorrow.
    if (now.hour >= hours.closeHour - 1) d = d.add(const Duration(days: 1));
    while (!hours.isOpen(d)) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  void selectStaff(Staff? staff) {
    emit(state.copyWith(staff: () => staff, time: () => null, error: () => null));
    _recompute();
  }

  void selectDay(DateTime day) {
    if (day == state.day) return;
    emit(state.copyWith(day: day, time: () => null, loadingSlots: true, slots: const [], error: () => null));
    _watchDay();
  }

  void selectTime(DateTime time) => emit(state.copyWith(time: () => time, error: () => null));

  void _watchDay() {
    _sub?.cancel();
    _sub = _repo.watchTakenSlots(state.day).listen((taken) {
      _taken = taken;
      _recompute();
    }, onError: (_) => emit(state.copyWith(loadingSlots: false)));
  }

  void _recompute() {
    final slots = Availability.forDay(
      day: state.day,
      now: _clock(),
      durationMin: service.durationMin,
      staffIds: [if (state.staff != null) state.staff!.id else ...specialists.map((s) => s.id)],
      taken: _taken,
      hours: _hours,
    );
    // Drop the chosen time if it was just taken by someone else.
    final stillFree = state.time != null && slots.any((s) => s.start == state.time && s.available);
    emit(state.copyWith(slots: slots, loadingSlots: false, time: stillFree ? null : () => null));
  }

  Future<void> submit(AppUser user, {String note = ''}) async {
    final time = state.time;
    if (time == null) return;
    final slot = state.slots.firstWhere((s) => s.start == time);
    // "Any specialist": take the first one who is free at that time.
    final staff = state.staff ?? specialists.firstWhere((s) => slot.staffIds.contains(s.id));
    emit(state.copyWith(submitting: true, error: () => null));
    try {
      final id = await _repo.book(user: user, service: service, staff: staff, start: time, note: note);
      emit(state.copyWith(submitting: false, bookedId: id, bookedStart: time));
    } on SlotTakenException {
      emit(state.copyWith(submitting: false, time: () => null, error: () => BookingError.slotTaken));
    } catch (_) {
      emit(state.copyWith(submitting: false, error: () => BookingError.failed));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
