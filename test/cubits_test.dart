import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowbooking/data/models.dart';
import 'package:glowbooking/data/repositories.dart';
import 'package:glowbooking/features/appointments/appointments_cubit.dart';
import 'package:glowbooking/features/booking/booking_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

const haircut = Service(
  id: 'mens-cut',
  category: 'hair',
  nameEn: "Men's haircut",
  nameTr: 'Erkek saç kesimi',
  durationMin: 30,
  price: 500,
  icon: 'content_cut',
);
const elena = Staff(
  id: 'elena', name: 'Elena Ruiz', roleEn: '', roleTr: '', rating: 5, colorIndex: 0, services: ['mens-cut']);
const zeynep = Staff(
  id: 'zeynep', name: 'Zeynep Aksoy', roleEn: '', roleTr: '', rating: 5, colorIndex: 1, services: ['mens-cut']);
const user = AppUser(uid: 'u1', name: 'Deniz Arslan', email: 'deniz@example.com');

Appointment appointment(AppointmentStatus status) => Appointment(
      id: 'a1',
      uid: 'u1',
      customerName: 'Deniz',
      serviceId: 'mens-cut',
      serviceNameEn: '',
      serviceNameTr: '',
      staffId: 'elena',
      staffName: 'Elena',
      start: DateTime(2026, 10, 17, 10),
      durationMin: 30,
      price: 500,
      status: status,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(user);
    registerFallbackValue(haircut);
    registerFallbackValue(elena);
  });

  // Friday 07:00, so the whole day is still bookable.
  DateTime clock() => DateTime(2026, 10, 16, 7);

  group('BookingCubit', () {
    late MockBookingRepository repo;
    late StreamController<Map<String, Set<String>>> taken;

    setUp(() {
      repo = MockBookingRepository();
      taken = StreamController.broadcast();
      when(() => repo.watchTakenSlots(any())).thenAnswer((_) => taken.stream);
    });

    BookingCubit build() =>
        BookingCubit(service: haircut, specialists: const [elena, zeynep], repository: repo, clock: clock);

    test('starts on the first open day and computes slots from live data', () async {
      final cubit = build();
      expect(cubit.state.day, DateTime(2026, 10, 16));
      taken.add({'elena': {'1000'}});
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.loadingSlots, isFalse);
      // "Any" stays free at 10:00 because Zeynep is.
      expect(cubit.state.slots.firstWhere((s) => s.start.hour == 10 && s.start.minute == 0).available, isTrue);
      cubit.selectStaff(elena);
      expect(cubit.state.slots.firstWhere((s) => s.start.hour == 10 && s.start.minute == 0).available, isFalse);
      await cubit.close();
    });

    test('drops the chosen time when someone else books it', () async {
      final cubit = build()..selectStaff(elena);
      taken.add({});
      await Future<void>.delayed(Duration.zero);
      cubit.selectTime(DateTime(2026, 10, 16, 14));
      expect(cubit.state.canSubmit, isTrue);
      taken.add({'elena': {'1400'}});
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.time, isNull);
      await cubit.close();
    });

    test('"any specialist" books the first one who is free', () async {
      when(() => repo.book(
            user: any(named: 'user'),
            service: any(named: 'service'),
            staff: any(named: 'staff'),
            start: any(named: 'start'),
            note: any(named: 'note'),
          )).thenAnswer((_) async => 'new-id');
      final cubit = build();
      taken.add({'elena': {'1400'}});
      await Future<void>.delayed(Duration.zero);
      cubit.selectTime(DateTime(2026, 10, 16, 14));
      await cubit.submit(user);
      expect(cubit.state.bookedId, 'new-id');
      expect(cubit.state.bookedStart, DateTime(2026, 10, 16, 14));
      verify(() => repo.book(
            user: user,
            service: haircut,
            staff: zeynep,
            start: DateTime(2026, 10, 16, 14),
            note: '',
          )).called(1);
      await cubit.close();
    });

    test('reports a race lost to another customer', () async {
      when(() => repo.book(
            user: any(named: 'user'),
            service: any(named: 'service'),
            staff: any(named: 'staff'),
            start: any(named: 'start'),
            note: any(named: 'note'),
          )).thenThrow(const SlotTakenException());
      final cubit = build();
      taken.add({});
      await Future<void>.delayed(Duration.zero);
      cubit.selectTime(DateTime(2026, 10, 16, 15));
      await cubit.submit(user);
      expect(cubit.state.error, BookingError.slotTaken);
      expect(cubit.state.time, isNull);
      await cubit.close();
    });
  });

  group('AppointmentsCubit', () {
    test('notifies when the salon confirms a pending booking', () async {
      final repo = MockBookingRepository();
      final stream = StreamController<List<Appointment>>();
      when(() => repo.watchMine('u1')).thenAnswer((_) => stream.stream);
      final changed = <AppointmentStatus>[];
      final cubit = AppointmentsCubit(repo, 'u1', onStatusChanged: (a) => changed.add(a.status));

      stream.add([appointment(AppointmentStatus.pending)]);
      await Future<void>.delayed(Duration.zero);
      expect(changed, isEmpty); // first load never notifies
      stream.add([appointment(AppointmentStatus.confirmed)]);
      await Future<void>.delayed(Duration.zero);
      expect(changed, [AppointmentStatus.confirmed]);
      await cubit.close();
    });

    blocTest<AppointmentsCubit, AppointmentsState>(
      'splits upcoming and past bookings',
      setUp: () {},
      build: () {
        final repo = MockBookingRepository();
        when(() => repo.watchMine('u1')).thenAnswer((_) => Stream.value([
              appointment(AppointmentStatus.confirmed),
              appointment(AppointmentStatus.cancelled),
            ]));
        return AppointmentsCubit(repo, 'u1');
      },
      wait: const Duration(milliseconds: 10),
      verify: (cubit) {
        final now = DateTime(2026, 10, 16);
        expect(cubit.state.upcoming(now), hasLength(1));
        expect(cubit.state.past(now), hasLength(1));
      },
    );
  });

  test('customers can cancel only until two hours before', () {
    final a = appointment(AppointmentStatus.confirmed);
    expect(a.canCancel(DateTime(2026, 10, 17, 7)), isTrue);
    expect(a.canCancel(DateTime(2026, 10, 17, 8, 30)), isFalse);
  });
}
