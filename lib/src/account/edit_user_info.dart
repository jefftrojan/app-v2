import 'package:app/services/firestore_database.dart';
import 'package:app/services/sizes.dart';
import 'package:app/src/models/user.dart';
import 'package:app/src/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routing/app_router.dart';

class EditUserPage extends ConsumerStatefulWidget {
  const EditUserPage({Key? key, this.user}) : super(key: key);
  final User? user;

  static Future<void> show(BuildContext context, {User? user}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editUserPage,
      arguments: user,
    );
  }

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends ConsumerState<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _username;
  String? _address;
  String? _phoneNumber;
  String? _about;
  bool? _public;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _name = widget.user?.name;
      _username = widget.user?.username ?? "";
      _address = widget.user?.address ?? "";
      _phoneNumber = widget.user?.phoneNumber ?? "";
      _about = widget.user?.about ?? "";
      _public = widget.user?.public;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      // try {
      final database = ref.read<FirestoreDatabase?>(databaseProvider)!;

      // print(widget.user!.toMap());
      final id = widget.user?.id ?? documentIdFromCurrentDate();
      final user = User(
        id: id,
        name: _name ?? '',
        email: widget.user!.email,
        seller: widget.user!.seller,
        avatar: widget.user!.avatar,
        currentPoints: widget.user!.currentPoints,
        earnedPoints: widget.user!.earnedPoints,
        pendingPoints: widget.user!.pendingPoints,
        approver: widget.user!.approver,
        recycledBottles: widget.user!.recycledBottles,
        username: _username ?? '',
        address: _address ?? '',
        about: _about ?? '',
        phoneNumber: _phoneNumber ?? '',
        public: _public ?? false,
      );
      await database.setCurrentUser(user);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.user == null ? 'New User' : 'Edit User'),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Names'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Username/Handle'),
        keyboardAppearance: Brightness.light,
        initialValue: _username,
        validator: (value) {
          (value ?? '').isNotEmpty ? null : 'Name can\'t be empty';
          (value ?? '').contains(' ') ? 'Can not contain black spaces' : null;
          return null;
        },
        onSaved: (value) => _username = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'About'),
        keyboardAppearance: Brightness.light,
        initialValue: _about,
        onSaved: (value) => _about = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Phone Number'),
        keyboardAppearance: Brightness.light,
        initialValue: _phoneNumber,
        onSaved: (value) => _phoneNumber = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Address'),
        keyboardAppearance: Brightness.light,
        initialValue: _address,
        onSaved: (value) => _address = value,
      ),
      SizedBox(
        height: height(context) * 0.01,
      ),
      Text('Public'),
      SizedBox(
        height: height(context) * 0.01,
      ),
      FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
                errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
                hintText: 'Should your profile be public?',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
            isEmpty: _public == false,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                // value: _public! ? 'True' : 'False',
                isDense: true,
                onChanged: (newValue) {
                  _public = newValue == 'True' ? true : false;
                  print('${_public}');
                },
                items: ['True', 'False'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          );
        },
      )
    ];
  }
}
