import 'package:app/common_widgets/texts.dart';
import 'package:app/constants/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupport extends StatelessWidget {
  const ContactSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(icon: Icon(Icons.arrow_back_ios_new), ) ,),
        title: Text(
          'Contact Support',
        ),
        titleTextStyle: GoogleFonts.aBeeZee(
            fontSize: 20, color: Theme.of(context).primaryColor),
        centerTitle: false,
        foregroundColor: ThemeConfig.lightPrimary,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.mail),
                SizedBox(
                  width: 10,
                ),
                CustomText(data: "Email us at info@shebaplastic.tech")
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.call),
                SizedBox(
                  width: 10,
                ),
                CustomText(data: "Call us on +250784206989")
              ]),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              TextButton(
                  onPressed: () async {
                    const url =
                        "https://sites.google.com/view/shebaplastic/privacy";

                    await _launchURL(url);
                  },
                  child: Text("Privacy Policy"))
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }
}
