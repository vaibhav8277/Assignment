import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:log/ui/verify_phone.dart';
import 'package:log/ui/widget/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../Presentation/signin_bloc.dart';

class PhoneAuthInput extends StatefulWidget {
  const PhoneAuthInput({Key key}) : super(key: key);

  @override
  _PhoneAuthInputState createState() => _PhoneAuthInputState();
}

PhoneNumber number =
    PhoneNumber(isoCode: 'IN', dialCode: '+91', phoneNumber: '');

class _PhoneAuthInputState extends State<PhoneAuthInput> {
  String phoneNumberErrorMsg;
  bool isVaildNumber = false;
  String phoneNumber = '';
  void setPhoneValidationMsg({String errorMessage = "Invalid phone number"}) {
    setState(() {
      phoneNumberErrorMsg = errorMessage;
    });
  }

  SigninBloc signinBloc;
  @override
  void initState() {
    signinBloc = BlocProvider.of<SigninBloc>(context);
    super.initState();
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("My number is",
                              style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87.withOpacity(0.7))),
                        ),
                      ],
                    ),
                    SizedBox(height: 80),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: InternationalPhoneNumberInput(
                        initialValue: number,
                        maxLength: 10,
                        onInputChanged: (PhoneNumber numberx) {
                          //   print(numberx);
                          phoneNumber = numberx.phoneNumber ?? '';
                        },
                        onSubmit: () {
                          //on keyboard done option clicked
                          startVarfication();
                        },
                        onInputValidated: (bool value) {
                          setState(() {
                            isVaildNumber = value ? true : false;
                          });
                        },
                        selectorConfig: SelectorConfig(
                          selectorType: PhoneInputSelectorType.DIALOG,
                          trailingSpace: false,
                        ),
                        errorMessage: phoneNumberErrorMsg,
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: TextStyle(color: Colors.black),
                        autoFocus: true,
                        autoFocusSearch: true,
                        textStyle: GoogleFonts.montserrat(
                            color: Colors.black87,
                            fontSize: 20,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500),
                        inputDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF7F00FF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF7F00FF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Color(0xFF7F00FF), width: 1.5),
                            ),
                            contentPadding:
                                EdgeInsets.only(left: 8, right: 8, top: 4)),
                        formatInput: false,
                        keyboardType: TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        onSaved: (PhoneNumber number) {
                          print('On Saved: $number');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                                "When you tap \"Continue\" App will send a text with verification code. Message data rates may apply. The verified phone number can be used to log in.  ",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                    BlocListener<SigninBloc, SigninState>(
                      bloc: BlocProvider.of<SigninBloc>(context),
                      listener: (context, state) {
                        if (state is OtpSentState) {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifyPhone(
                                        phoneNumber: phoneNumber,
                                      )));
                        }
                      },
                      child: BlocBuilder<SigninBloc, SigninState>(
                        bloc: BlocProvider.of<SigninBloc>(context),
                        builder: (context, state) {
                          return CustomButton2(
                              disabled: !isVaildNumber,
                              isLoading: (state is LoadingState)
                                  ? true
                                  : (state is OtpSentState)
                                      ? false
                                      : false,
                              onTap: () {
                                startVarfication();
                              });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void startVarfication() async {
    print(phoneNumber);
    final signature = await SmsAutoFill().getAppSignature;
    print(signature);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("num", phoneNumber);
    signinBloc?.add(SignInWithPhone(phoneNumber: phoneNumber));
  }
}
