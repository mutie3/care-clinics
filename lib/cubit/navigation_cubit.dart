import 'package:bloc/bloc.dart';

part 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  int _currentIndex = 0;

  NavigationCubit() : super(NavigationInitial());

  int get currentIndex => _currentIndex;

  void updateIndex(int newIndex) {
    _currentIndex = newIndex;
    emit(NavigationUpdated(newIndex));
  }
}
