import '../../models/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> users;

  UserLoaded(this.users);
}

class MeLoaded extends UserState {
  final UserModel me;

  MeLoaded(this.me);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}