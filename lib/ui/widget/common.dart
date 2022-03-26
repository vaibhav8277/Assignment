import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class CustomButton2 extends StatelessWidget {
  final Function onTap;
  final String label;
  final IconData trailingIcon;
  final bool disabled;
  final EdgeInsetsGeometry margin;
  final bool isLoading;
  const CustomButton2({
    Key key,
     this.onTap,
    this.label = "Continue",
    this.isLoading = false,
    this.trailingIcon = LineIcons.arrowRight,
    this.disabled = false,
    this.margin =
        const EdgeInsets.only(top: 0, left: 16, bottom: 50, right: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        height: 50,
        width: double.infinity,
        margin: margin,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: !disabled ? LinearGradient(
              // begin: Alignment.topLeft,
              // end: Alignment.bottomRight,
              colors: [
                Color(0xFF7F00FF),
                Color(0xFFE100FF),
              ],
            ) : null,
            color: !disabled ? Colors.white : Colors.black12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Center(child: isLoading ? _buildLoading() : _buildButtonLabel()),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
  }

  Widget _buildButtonLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label ?? '',
          style: GoogleFonts.poppins(
              color: !disabled ? Colors.white : Colors.black38,
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ),
        SizedBox(
          width: 8,
        ),
        Icon(
          trailingIcon,
          color: !disabled ? Colors.white : Colors.black38,
        )
      ],
    );
  }
}
