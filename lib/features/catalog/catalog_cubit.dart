import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';

enum LoadStatus { loading, ready, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = LoadStatus.loading,
    this.services = const [],
    this.staff = const [],
    this.category,
  });

  final LoadStatus status;
  final List<Service> services;
  final List<Staff> staff;

  /// Null shows every category.
  final String? category;

  List<Service> get visibleServices =>
      category == null ? services : services.where((s) => s.category == category).toList();

  List<String> get categories => services.map((s) => s.category).toSet().toList();

  List<Staff> staffFor(Service service) => staff.where((s) => s.offers(service)).toList();

  CatalogState copyWith({
    LoadStatus? status,
    List<Service>? services,
    List<Staff>? staff,
    String? Function()? category,
  }) =>
      CatalogState(
        status: status ?? this.status,
        services: services ?? this.services,
        staff: staff ?? this.staff,
        category: category != null ? category() : this.category,
      );

  @override
  List<Object?> get props => [status, services, staff, category];
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repo) : super(const CatalogState()) {
    load();
  }

  final CatalogRepository _repo;
  final _subs = <StreamSubscription<Object?>>[];

  void load() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs
      ..clear()
      ..add(_repo.watchServices().listen(
            (list) => emit(state.copyWith(services: list, status: _statusWith(services: list))),
            onError: (_) => emit(state.copyWith(status: LoadStatus.failure)),
          ))
      ..add(_repo.watchStaff().listen(
            (list) => emit(state.copyWith(staff: list, status: _statusWith(staff: list))),
            onError: (_) => emit(state.copyWith(status: LoadStatus.failure)),
          ));
  }

  LoadStatus _statusWith({List<Service>? services, List<Staff>? staff}) =>
      (services ?? state.services).isNotEmpty && (staff ?? state.staff).isNotEmpty
          ? LoadStatus.ready
          : LoadStatus.loading;

  void selectCategory(String? category) => emit(state.copyWith(category: () => category));

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}
