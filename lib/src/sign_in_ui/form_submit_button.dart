import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../custom_widgets/custom_buttons/custom_buttons.dart';

class FormSubmitButton extends CustomRaisedButton {
  FormSubmitButton({
    Key? key,
    required String text,
    bool loading = false,
    VoidCallback? onPressed,
  }) : super(
            key: key,
            child: Text(
              text,
              style: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 18),
            ),
            height: 44.0,
            color: Colors.teal,
            textColor: Colors.black87,
            loading: loading,
            onPressed: onPressed,
            borderRadius: 5);
}
