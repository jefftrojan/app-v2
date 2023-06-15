import 'package:app/services/sizes.dart';
import 'package:app/src/home/homepage.dart';
import 'package:app/src/product/list.dart';
import 'package:app/src/product/scanner.dart';
import 'package:app/src/recyclable/approve.dart';
import 'package:app/src/recyclable/list.dart';
import 'package:app/src/recyclable/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../services/stream_providers.dart';
import '../account/account.dart';
import '../models/user.dart' as user_model;
import '../top_level_providers.dart';

class Base extends ConsumerStatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends ConsumerState<Base> {
  // int currentIndex = 0;
  late PersistentTabController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    // _hideNavBar = false;
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    print(width(context));
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    // firebaseAuth.signOut();
    final firestoreUser =
        ref.watch(userStreamProvider(firebaseAuth.currentUser!.uid));

    return firestoreUser.when(
        data: (user) {
          final screens;
          if (user.approver) {
            screens = [
              HomePage(),
              RecyclablesList(user: user),
              RecyclableApproval(user: user),
              SettingsPage()
            ];
          } else {
            if (user.seller) {
              screens = [HomePage(), ProductsList(user: user), SettingsPage()];
            } else {
              screens = [
                HomePage(),
                RecyclableScanner(),
                ProductScanner(),
                SettingsPage()
              ];
            }
          }

          return Container(
              width: width(context) > 600 ? 600 : width(context),
              color: Colors.white,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark
                      .copyWith(statusBarColor: Colors.black),
                  child: SafeArea(
                    child: SizedBox(
                      width: width(context) > 600 ? 600 : width(context),
                      child:
                          Scaffold(
                        body:
                            screens[currentIndex],
                        bottomNavigationBar: BottomNavigationBar(
                          showUnselectedLabels: false,
                          type: BottomNavigationBarType.fixed,
                          selectedItemColor: Theme.of(context).primaryColor,
                          unselectedItemColor: Colors.grey,
                          backgroundColor: Colors.white,
                          selectedLabelStyle: GoogleFonts.aBeeZee(),
                          currentIndex: currentIndex,
                          elevation: 0,
                          onTap: (index) => setState(() {
                            currentIndex = index;
                          }),
                          items: bottomNavigationItems(user),
                        ),
                      ),
                    ),
                  )));
          // ));
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Scaffold(
              body: Center(
                child: Text("Something went wrong. Please try again. $_ "),
              ),
            ));
  }
}

List<BottomNavigationBarItem> bottomNavigationItems(user_model.User user) {
  if (user.approver) {
    return [
      BottomNavigationBarItem(
        icon: Icon(
          Icons.home_outlined,
        ),
        label: "Home",
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.recycling_outlined), label: "Recyclables"),
      BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline_outlined), label: "Approve"),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.account_circle_outlined,
          ),
          label: "Account"),
    ];
  } else {
    if (user.seller) {
      return [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.payment,
            ),
            label: "Products"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            label: "Account"),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.recycling_outlined), label: "Recycle"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.payment,
            ),
            label: "Pay"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            label: "Account"),
      ];
    }
  }
}
