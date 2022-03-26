import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:log/ui/phone_auth_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Presentation/signin_bloc.dart';
import 'home_page.dart';

class AuthMain extends StatefulWidget {
  AuthMain({Key key}) : super(key: key);

  @override
  _AuthMainState createState() => _AuthMainState();
}

class _AuthMainState extends State<AuthMain> {
  SigninBloc bloc = SigninBloc();

  @override
  void initState() {
    BlocProvider.of<SigninBloc>(context).add(AppStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    // var controller = Get.find<Login>();
    Widget _buildLogo() {
      return Container(
          margin: EdgeInsets.only(top: screenHeight / 4.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Ionicons.logo_xing,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Task",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ));
    }

    //building login buttons - Google, fb, otp auth
    Widget _buildLoginOptions() {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(26.0),
            child: Column(
              children: [
                LoginOptionButton(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneAuthInput()));
                  },
                  label: 'LOG IN WITH PHONE NUMBER',
                  logoImgPath: 'assets/chat.png',
                ),
                SizedBox(height: 24),
                Text("Terms & Condition",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          ));
    }

    Widget _buildLoading() {
      return Center(
          child: Container(
              child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )));
    }

    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE100FF),
          Color(0xFF7F00FF),
        ],
      )),
      child: SafeArea(
        child: BlocListener<SigninBloc, SigninState>(
          listener: (context, state) async {
            if (state is SigninAuthenticated) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              // ignore: non_constant_identifier_names
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DashDesign()));
            }
          },
          child: BlocBuilder<SigninBloc, SigninState>(
            bloc: BlocProvider.of<SigninBloc>(context),
            builder: (context, state) {
              if (state is SigninLoading) {
                return _buildLoading();
              } else if (state is SigninUnAuthenticated) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLogo(),
                    _buildLoginOptions(),
                  ],
                );
              } else {
                return _buildLoading();
              }
            },
          ),
        ),
      ),
    ));
  }
}

class LoginOptionButton extends StatelessWidget {
  final String label;
  final String logoImgPath;
  final VoidCallback onTap;

  const LoginOptionButton(
      {Key key,
      this.label = 'LOG IN WITH GOOGLE',
      this.logoImgPath = 'assets/google.png',
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(left: 16),
                height: 20,
                width: 20,
                child: Image.asset(logoImgPath),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.button?.copyWith(
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
