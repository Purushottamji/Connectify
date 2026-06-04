import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  List<UserModel> users = [];

  UserModel? me;

  UserBloc(this.userService) : super(UserInitial()) {
    on<FetchUsersEvent>(_fetchUsers);

    on<FetchMeEvent>(_fetchMe);
  }

  Future<void> _fetchUsers(
      FetchUsersEvent event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserLoading());

      final data = await userService.getUsers();

      users =
          data
              .map<UserModel>(
                (e) => UserModel.fromJson(e),
          )
              .toList();

      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _fetchMe(
      FetchMeEvent event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserLoading());

      final data =
      await userService.getUserById(event.id);

      me = UserModel.fromJson(data);

      emit(MeLoaded(me!));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}