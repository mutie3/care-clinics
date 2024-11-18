part of 'navigation_cubit.dart';

abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationUpdated extends NavigationState {
  final int index;

  NavigationUpdated(this.index);
}
