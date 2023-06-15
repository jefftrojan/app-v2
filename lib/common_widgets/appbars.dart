import 'package:app/constants/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

plainAppBar(title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Text(title),
    titleTextStyle: GoogleFonts.aBeeZee(
      fontSize: 20,
      color: ThemeConfig.lightPrimary,
    ),
    centerTitle: false,
  );
}
