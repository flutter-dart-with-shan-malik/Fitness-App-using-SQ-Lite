import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIHelper {
  static appText(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
