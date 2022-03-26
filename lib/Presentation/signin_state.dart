part of 'signin_bloc.dart';

abstract class SigninState extends Equatable {


  @override
  List<Object> get props => [];
}

class SigninInitial extends SigninState {}

class SigninInitialized extends SigninState {}

class SigninLoading extends SigninState {
  @override

  List<Object> get props =>[];

}

class SigninAuthenticated extends SigninState {
  final User user;

  SigninAuthenticated({this.user});
}

class SigninUnAuthenticated extends SigninState {}


class LoadingState extends SigninState{}

class OtpSentState extends SigninState{}
class OtpExceptionState extends SigninState {
final String errorMsg;

  OtpExceptionState({ this.errorMsg});
}
class UserDetails extends SigninState{
  final User user;
  UserDetails(this.user);
}
