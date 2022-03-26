part of 'signin_bloc.dart';

abstract class SigninEvent extends Equatable {
  const SigninEvent();

  @override
  List<Object> get props => [];
}
//checking if user has cached data or n


class SignInWithGoogleEvent extends SigninEvent{
  
@override
  String toString() => 'Google Sign in ';
}

class AppStarted extends SigninEvent {
  @override
  String toString() => 'AppStarted';
}

class LoggedIn extends SigninEvent {
  @override
  String toString() => 'LoggedIn';
}

class LoggedOut extends SigninEvent {
  @override
  String toString() => 'LoggedOut';
}
//verify otp
class SignInWithPhone extends SigninEvent {
    final String phoneNumber;

  SignInWithPhone({ this.phoneNumber});
}
//
class VerifyOtp extends SigninEvent {
  final String otp;

  VerifyOtp({ this.otp});
}

class OtpVerified extends SigninEvent {
  final User user;
  OtpVerified(
    { this.user,}
  );
}


class OtpVerificationFaild extends SigninEvent {
  final String msg;
  OtpVerificationFaild(
     this.msg,
  );
}

class OtpSendEvent extends SigninEvent {}

class GetUserDetailsFromCache extends SigninEvent {

}