import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'user_repository.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  SigninBloc() : super(SigninInitial());
  UserRepository _userRepository = UserRepository();

  StreamSubscription subscription;
  String verID = "";

  User get getUser => _userRepository.getUser;
  @override
  Stream<SigninState> mapEventToState(
    SigninEvent event,
  ) async* {
    if (event is AppStarted) {
      print("AppStarted event");
      //Checks existing user token
      yield* _mapAppStartedToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    } else if (event is GetUserDetailsFromCache) {
      yield UserDetails(_userRepository.getUser);
    } else if (event is SignInWithGoogleEvent) {
      yield* _mapAppGoogleSignInToState();
    } else if (event is SignInWithPhone) {
      yield LoadingState();

      subscription = sendOtp(event.phoneNumber).listen((event) {
        //Notifies the [Bloc] of a new [event] which triggers [mapEventToState].
        //If [close] has already been called,
        // any subsequent calls to [add] will be ignored and
        //will not result in any subsequent state changes.
        add(event);
      });
    } else if (event is OtpSendEvent) {
      yield OtpSentState();
    } else if (event is VerifyOtp) {
      yield LoadingState();

      try {
        UserCredential _userCredential =
            await _userRepository.verifyAndLogin(verID, event.otp);
        if (_userCredential.user != null) {
          yield SigninAuthenticated(user: _userCredential.user);
        } else {
          yield OtpExceptionState(errorMsg: 'Invalid otp');
        }
      } on Exception catch (e) {
        yield OtpExceptionState(errorMsg: 'Invalid otp');
      }
    }
  }

  @override
  void onEvent(SigninEvent event) {
    super.onEvent(event);
    print(event);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    print(stacktrace);
  }

  //! Otp Authentication
  Stream<SigninEvent> sendOtp(String phoneNumber) async* {
    //stream for streaming otp evenets 😁
    StreamController<SigninEvent> eventStream = StreamController();

    final PhoneVerificationCompleted = (AuthCredential credential) {
      User user = _userRepository.getUser;
      if (user != null) {
        eventStream.add(OtpVerified(user: user));
      }
      eventStream.close();
    };

    final PhoneVerificationFailed = (FirebaseAuthException authException) {
      print(authException.message);
      eventStream.add(OtpVerificationFaild(onError.toString()));
      eventStream.close();
    };

    final PhoneCodeSent = (String verId, [int forceResent]) {
      this.verID = verId;
      eventStream.add(OtpSendEvent());
    };

    final PhoneCodeAutoRetrievalTimeout = (String verid) {
      this.verID = verid;
      eventStream.close();
    };

    await _userRepository.signInWithPhone(
        phoneNumber,
        Duration(seconds: 1),
        PhoneVerificationFailed,
        PhoneVerificationCompleted,
        PhoneCodeSent,
        PhoneCodeAutoRetrievalTimeout);

    yield* eventStream.stream;
  }

  //? cached login logic
  Stream<SigninState> _mapAppStartedToState() async* {
    try {
      yield SigninLoading();
      final isSignedIn = _userRepository.isSignedIn;
      if (isSignedIn) {
        final User user = _userRepository.getUser;
        print(user?.displayName);
        yield SigninAuthenticated(user: user);
      } else {
        yield SigninUnAuthenticated();
      }
    } catch (_) {
      yield SigninUnAuthenticated();
    }
  }

//! Login with google sign in
  Stream<SigninState> _mapAppGoogleSignInToState() async* {
    try {
      UserCredential userCreds = await _userRepository.signInWithGoogle();
      yield SigninAuthenticated(user: userCreds.user);
    } catch (_) {
      yield SigninUnAuthenticated();
    }
  }

  Stream<SigninState> _mapLoggedInToState() async* {
    //  yield SigninAuthenticated(await _userRepository.getUser());
  }

//! Log out
  Stream<SigninState> _mapLoggedOutToState() async* {
    await _userRepository.signOut();
    yield SigninUnAuthenticated();
  }
}
