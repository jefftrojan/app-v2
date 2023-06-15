import 'package:app/src/recyclable/qrcode.dart';
import 'package:app/src/top_level_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routing/app_router.dart';
import '../../services/firestore_database.dart';
import '../../services/sizes.dart';
import '../models/recyclable.dart';

class EditRecyclablePage extends ConsumerStatefulWidget {
  const EditRecyclablePage({
    Key? key,
    this.recyclable,
  }) : super(key: key);
  final Recyclable? recyclable;

  static Future<void> show(BuildContext context,
      {Recyclable? recyclable}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editRecyclablePage,
      arguments: recyclable,
    );
  }

  @override
  _EditRecyclablePageState createState() => _EditRecyclablePageState();
}

class _EditRecyclablePageState extends ConsumerState<EditRecyclablePage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  // String? _token;
  int? _points = 0;

  @override
  void initState() {
    super.initState();
    if (widget.recyclable != null) {
      _name = widget.recyclable?.name;
      _points = widget.recyclable?.points;
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
      final database = ref.read<FirestoreDatabase?>(databaseProvider)!;
      final firebaseAuth = ref.watch(firebaseAuthProvider);

      var _recyclable;
      if (widget.recyclable == null) {
        var docRef = FirebaseFirestore.instance.collection("recyclables").doc();
        var id = docRef.id;
        final recyclable = Recyclable(
            id: id,
            creator: firebaseAuth.currentUser!.uid,
            name: _name ?? "",
            points: _points ?? 0);
        recyclable.encrypt();
        _recyclable = recyclable;
        await database.setRecyclable(id, recyclable);
      } else {
        final recyclable = Recyclable(
            id: widget.recyclable!.id,
            creator: widget.recyclable!.creator,
            name: _name ?? "",
            points: _points ?? 0);
        recyclable.encrypt();
        _recyclable = recyclable;
        await database.setRecyclable(widget.recyclable!.id, recyclable);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecyclableQRCode(
            recyclable: _recyclable,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(
            widget.recyclable == null ? 'New Recyclable' : 'Edit Recyclable'),
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
    return Center(
      child: Container(
        width: width(context) > 600 ? 600 : width(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildForm(),
              ),
            ),
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
        decoration: const InputDecoration(labelText: 'Recyclable name'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
          decoration: const InputDecoration(labelText: 'Shebas'),
          keyboardAppearance: Brightness.light,
          initialValue: _points.toString(),
          validator: (value) =>
              (value ?? '').isNotEmpty ? null : 'Shebas can\'t be empty',
          onSaved: (value) => _points = int.tryParse(value ?? '') ?? 0),
    ];
  }
}
