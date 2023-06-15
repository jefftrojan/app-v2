import 'dart:async';
import 'package:app/common_widgets/avatar.dart';
import 'package:app/common_widgets/texts.dart';
import 'package:app/constants/theme_config.dart';
import 'package:app/src/models/articles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/strings.dart';
import '../../custom_widgets/alert_dialogs/alert_dialogs.dart';
import '../../services/sizes.dart';
import '../../services/stream_providers.dart';
import '../account/share_points.dart';
import '../top_level_providers.dart';
import '../models/user.dart' as user_model;
import 'list_items_builder.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Future<void> _signOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }

  Future<void> _confirmSignOut(
      BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context, firebaseAuth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final user = ref.watch(userStreamProvider(firebaseAuth.currentUser!.uid));
    return user.when(
        data: (user) {
          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.white,
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        _confirmSignOut(context, firebaseAuth);
                      },
                      icon: Icon(
                        Icons.logout,
                        color: ThemeConfig.lightPrimary,
                      ),
                    ),
                  ],
                  elevation: 0,
                  title: Row(
                    children: [
                      Avatar(
                        photoUrl: user.avatar != ""
                            ? user.avatar
                            : "https://firebasestorage.googleapis.com/v0/b/shebaplastic-e2364.appspot.com/o/avatars%2Favatar_image.png?alt=media&token=3c0cde21-7175-483a-b105-b36848550ce0",
                        radius: 20,
                        borderColor: Colors.white,
                        borderWidth: 1.0,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.aBeeZee(
                                color: Colors.grey, fontSize: 16),
                          ),
                          Text(
                            '${user.currentPoints} Shebas',
                            style: GoogleFonts.aBeeZee(
                                color: Colors.grey, fontSize: 16),
                          )
                        ],
                      ),
                    ],
                  ),
                  centerTitle: false),
              body: Center(
                child: Container(
                  width: width(context) > 600 ? 600 : width(context),
                  padding: EdgeInsets.all(height(context) * 0.01),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Stats',
                            style: GoogleFonts.aBeeZee(fontSize: 18),
                          ),
                          SizedBox(
                            height: height(context) * 0.01,
                          ),
                          Center(
                            child: Container(
                              height: height(context) * 0.2,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    height(context) * 0.01,
                                  ),
                                ),
                                child: SizedBox(
                                    width: width(context) * 0.98,
                                    height: height(context) * 0.2,
                                    child: GridView.count(
                                      // primary: false,
                                      childAspectRatio: 1 / .4,
                                      // crossAxisSpacing: 10,
                                      // mainAxisSpacing: 10,
                                      crossAxisCount: 2,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomText(
                                                data: '${user.currentPoints}',
                                                color: ThemeConfig.lightPrimary,
                                                fontSize:
                                                    height(context) * 0.025),
                                            SizedBox(
                                              width: width(context) * 0.01,
                                            ),
                                            Flexible(
                                              child: CustomText(
                                                data: 'Shebas',
                                                fontSize:
                                                    height(context) * 0.015,
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomText(
                                              data: '${user.pendingPoints}',
                                              color: ThemeConfig.lightPrimary,
                                              fontSize: height(context) * 0.025,
                                            ),
                                            SizedBox(
                                              width: width(context) * 0.01,
                                            ),
                                            Flexible(
                                              child: CustomText(
                                                data: 'Pending',
                                                fontSize:
                                                    height(context) * 0.015,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomText(
                                              data: '${user.recycledBottles}',
                                              color: ThemeConfig.lightPrimary,
                                              fontSize: height(context) * 0.025,
                                            ),
                                            SizedBox(
                                              width: width(context) * 0.01,
                                            ),
                                            Flexible(
                                              child: CustomText(
                                                data: 'Items Recycled',
                                                fontSize:
                                                    height(context) * 0.015,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: CustomText(
                                                data:
                                                    '${user.earnedPoints - user.currentPoints}',
                                                color: ThemeConfig.lightPrimary,
                                                fontSize:
                                                    height(context) * 0.025,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width(context) * 0.01,
                                            ),
                                            CustomText(
                                              data: 'Spent',
                                              fontSize: height(context) * 0.015,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height(context) * 0.02,
                          ),
                          if (user.approver) ...[
                            Text(
                              'All Stats',
                              style: GoogleFonts.aBeeZee(fontSize: 18),
                            ),
                            SizedBox(
                              height: height(context) * 0.01,
                            ),
                            Center(
                              child: SizedBox(
                                width: width(context) * 0.98,
                                height: height(context) * 0.30,
                                child: SingleChildScrollView(
                                  child: statsSection(ref),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height(context) * 0.02,
                            ),
                          ],
                          Text(
                            'News Section',
                            style: GoogleFonts.aBeeZee(fontSize: 18),
                          ),
                          SizedBox(
                            height: height(context) * 0.01,
                          ),
                          Center(
                            child: SizedBox(
                              height: height(context) * 0.35,
                              width: width(context) * 0.98,
                              child: NewsSection(),
                            ),
                          ),
                          SizedBox(
                            height: height(context) * 0.02,
                          ),
                          Text(
                            'Top Users',
                            style: GoogleFonts.aBeeZee(fontSize: 18),
                          ),
                          SizedBox(
                            height: height(context) * 0.01,
                          ),
                          Center(
                            child: SizedBox(
                              height: height(context) * 0.15,
                              width: width(context) * 0.98,
                              child: TopUsers(),
                            ),
                          ),
                          SizedBox(
                            height: height(context) * 0.02,
                          ),
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            tileColor: Colors.teal.shade50,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SendPoints(
                                            user: user,
                                          )
                                      // user: user),
                                      ));
                            },
                            title: CustomText(
                              data: 'Send Shebas',
                              fontSize: height(context) * 0.018,
                            ),
                            trailing: Icon(Icons.send_outlined),
                          )
                        ]),
                  ),
                ),
              ));
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text("Something went wrong. Please try again."),
            ));
  }

  statsSection(WidgetRef ref) {
    final database = ref.watch(databaseProvider)!;

    final statStream = ref.watch(statStreamProvider('stats1'));
    return statStream.when(
        data: (stat) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  height(context) * 0.025,
                ),
                child: Column(children: [
                  CustomText(
                    data: '${stat.approved_items}',
                    fontSize: height(context) * 0.03,
                    color: ThemeConfig.lightPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  CustomText(
                    data: 'Items Recycled',
                    fontSize: height(context) * 0.02,
                  ),
                  SizedBox(
                    height: height(context) * 0.01,
                  ),
                  CustomText(
                    data: '${stat.total_users}',
                    fontSize: height(context) * 0.03,
                    color: Colors.lightBlueAccent,
                    fontStyle: FontStyle.italic,
                  ),
                  CustomText(
                    data: 'Users',
                    fontSize: height(context) * 0.02,
                  ),
                  SizedBox(
                    height: height(context) * 0.01,
                  ),
                  CustomText(
                    data: '${stat.points}',
                    fontSize: height(context) * 0.03,
                    color: Colors.orange.shade800,
                    fontStyle: FontStyle.italic,
                  ),
                  CustomText(
                    data: 'Shebas Earned',
                    fontSize: height(context) * 0.02,
                  ),
                ]),
              ),
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
              child: Text("Something went wrong. Please try again. $_ "),
            ));
  }
}

class TopUsers extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final users = ref.watch(usersStreamProvider);
    return ListItemsBuilder<user_model.User>(
      direction: Axis.horizontal,
      data: users,
      itemBuilder: (context, user) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: EdgeInsets.all(
            height(context) * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Avatar(
                    photoUrl: user.avatar != ""
                        ? user.avatar
                        : "https://firebasestorage.googleapis.com/v0/b/shebaplastic-e2364.appspot.com/o/avatars%2Favatar_image.png?alt=media&token=3c0cde21-7175-483a-b105-b36848550ce0",
                    radius: height(context) * 0.028,
                    borderColor: Colors.white,
                    borderWidth: 1.0,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(data: user.name),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            data: '${user.currentPoints}',
                            fontSize: height(context) * 0.02,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          CustomText(
                            data: 'Shebas',
                            fontSize: height(context) * 0.015,
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              Flexible(
                child: Container(
                  width: width(context) * 0.5,
                  child: CustomText(
                    data: user.about,
                    maxLines: 2,
                    fontSize: height(context) * 0.015,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      //  ListTile(
      //       title: Text(user.name),
      //       subtitle: Text("${user.points} Shebas"),
      //       trailing: IconButton(
      //           onPressed: () {},
      //           icon: Icon(
      //             Icons.edit,
      //             color: Theme.of(context).primaryColor,
      //           )),
      //       onTap: () {},
      //     )
    );
  }
}

class NewsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final articles = ref.watch(articlesStreamProvider);

    return ListItemsBuilder<Article>(
      direction: Axis.horizontal,
      data: articles,
      itemBuilder: (context, article) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: EdgeInsets.all(
            height(context) * 0.02,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  data: article.headline,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                SizedBox(
                  height: 10,
                ),
                Image.network(article.cover_image,
                    fit: BoxFit.cover,
                    height: height(context) * 0.2,
                    width: width(context) * 0.8,
                    color: Color.fromRGBO(255, 255, 255, 0.2),
                    colorBlendMode: BlendMode.modulate),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: width(context) * 0.8,
                  child: CustomText(
                    data: article.body,
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                CustomText(
                  data: article.creation_time.toLocal().toString(),
                  fontStyle: FontStyle.italic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
