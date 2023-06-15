import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends Text {
  CustomText({
    required String data,
    int maxLines = 1,
    double fontSize = 14,
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.normal,
    color = Colors.black,
  }) : super(
          data,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: maxLines,
          style: GoogleFonts.aBeeZee(
              fontSize: fontSize, color: color, fontStyle: fontStyle),
        );
}


// statsNumbers(color)