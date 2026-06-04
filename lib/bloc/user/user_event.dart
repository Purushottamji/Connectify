abstract class UserEvent {}

class FetchUsersEvent extends UserEvent {}

class FetchMeEvent extends UserEvent {
  final int id;

  FetchMeEvent(this.id);
}