import 'package:bloc/bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print("BlocObserver $event");
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print("BlocObserver $transition");
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print("BlocObserver $error");
    super.onError(cubit, error, stackTrace);
  }
}
