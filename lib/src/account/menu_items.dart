import 'package:flutter/material.dart';

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({required this.text, required this.icon});
}

class MenuItems {
  static const List<MenuItem> firstItems = [edit, share, copy, delete];

  static const edit = MenuItem(text: "Edit Profile", icon: Icons.edit);
  static const share = MenuItem(text: "Share Profile", icon: Icons.share_sharp);
  static const copy = MenuItem(text: "Copy My ID", icon: Icons.content_copy);
  static const delete =
      MenuItem(text: "Delete Account", icon: Icons.delete_outline_rounded);
}
