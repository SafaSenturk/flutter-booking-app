import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeTab { book, appointments, salon, profile }

/// The selected bottom-navigation tab; lives above the navigator so pushed
/// pages (like the booking confirmation) can switch tabs too.
class TabCubit extends Cubit<HomeTab> {
  TabCubit() : super(HomeTab.book);

  void show(HomeTab tab) => emit(tab);
}
