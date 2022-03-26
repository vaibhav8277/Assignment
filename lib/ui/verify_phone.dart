import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../Presentation/signin_bloc.dart';
import 'home_page.dart';

class VerifyPhone extends StatefulWidget {
  final String phoneNumber;
  const VerifyPhone({Key key,  this.phoneNumber}) : super(key: key);

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

PhoneNumber number =
    PhoneNumber(isoCode: 'IN', dialCode: '+91', phoneNumber: '');

class _VerifyPhoneState extends State<VerifyPhone> {
  bool verifyOtp(String otp) {
    signinBloc?.add(verifyOtp(otp));
    return true;
  }

  Bloc signinBloc;
  @override
  void initState() {
    _listOPT();
    super.initState();
  }

  _listOPT() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocListener<SigninBloc, SigninState>(
                      bloc: BlocProvider.of<SigninBloc>(context),
                      listener: (context, state) async {
                        if (state is SigninAuthenticated) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => DashDesign()));
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back_ios,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Verify Account",
                                style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87.withOpacity(0.7))),
                          ),
                          SizedBox(height: 80),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  "Enter the OTP sent to ${widget.phoneNumber}",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(Icons.edit,
                                        color: Colors.grey, size: 16),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: PinFieldAutoFill(
                        autoFocus: true,
                        onCodeSubmitted: (String value) {
                          BlocProvider.of<SigninBloc>(context)
                              .add(VerifyOtp(otp: value));
                        },
                        cursor: Cursor(color: Color(0xFF7F00FF)),
                        decoration: UnderlineDecoration(
                          //  errorText: "Invlid code",

                          textStyle: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                          colorBuilder:
                              FixedColorBuilder(Colors.black.withOpacity(0.3)),
                        ),
                      ),
                    ),

                    BlocBuilder<SigninBloc, SigninState>(
                      bloc: BlocProvider.of<SigninBloc>(context),
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              (state is OtpExceptionState)
                                  ? _buildError('Invalid verification code')
                                  : Container(),
                              (state is LoadingState)
                                  ? _buildLoading()
                                  : (state is OtpVerificationFaild &&
                                          state is OtpVerified)
                                      ? Container()
                                      : Container()
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Didn't receive OTP?",
                            style: GoogleFonts.montserrat(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () {
                            context.read<SigninBloc>().add(SignInWithPhone(
                                phoneNumber: widget.phoneNumber));
                          },
                          child: Text("RESEND",
                              style: GoogleFonts.montserrat(
                                  color: Color(0xFF7F00FF), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    //   CustomButton2(onTap: () {}, label: 'Verify'),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLoading() {
    return Container(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7F00FF))));
  }

  Widget _buildError(String errorMSg) {
    return Row(
      children: [
        Icon(Icons.error, color: Colors.red),
        SizedBox(
          width: 8,
        ),
        Text(
          "Invalid verification code",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      ],
    );
  }
}
