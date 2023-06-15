import 'package:app/src/product/qrcode.dart';
import 'package:app/src/top_level_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routing/app_router.dart';
import '../../services/firestore_database.dart';
import '../../services/sizes.dart';
import '../models/product.dart';

class EditProductPage extends ConsumerStatefulWidget {
  const EditProductPage({Key? key, this.product}) : super(key: key);
  final Product? product;

  static Future<void> show(BuildContext context, {Product? product}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editProductPage,
      arguments: product,
    );
  }

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends ConsumerState<EditProductPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _token;
  String? _description;
  int? _points = 0;
  double _price = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product?.name;
      _token = widget.product?.token;
      _points = widget.product?.points ?? 0;
      _price = widget.product?.price ?? 0.0;
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

      var _product;

      // print(widget.product);
      if (widget.product == null) {
        var docRef = FirebaseFirestore.instance.collection("products").doc();
        var id = docRef.id;
        final product = Product(
            id: id,
            name: _name ?? '',
            token: _token ?? '',
            points: _points ?? 0,
            seller: firebaseAuth.currentUser!.uid,
            price: _price,
            description: _description ?? "");
        product.encrypt();
        _product = product;
        await database.setProduct(_product.id, _product);
      } else {
        final product = Product(
            id: widget.product!.id,
            name: _name ?? widget.product!.name,
            token: _token ?? '',
            points: _points ?? 0,
            seller: widget.product!.seller,
            price: _price,
            description: _description ?? "");
        print(product.token);

        product.encrypt();
        print(product.token);
        _product = product;

        await database.setProduct(_product.id, _product);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductQRCode(
            product: _product,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("user id: ${widget.uid}");
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.product == null ? 'New Product' : 'Edit Product'),
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
    // print(_points);
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Product name'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Product description'),
        keyboardAppearance: Brightness.light,
        initialValue: _description,
        onSaved: (value) => _description = value,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Shebas'),
        keyboardAppearance: Brightness.light,
        initialValue: '$_points',
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Shebas can\'t be empty',
        onSaved: (value) => _points = int.tryParse(value ?? '0') ?? 0,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Price'),
        keyboardAppearance: Brightness.light,
        initialValue: '$_price',
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Price can\'t be empty',
        onSaved: (value) => _price = double.tryParse(value ?? '0.0') ?? 0.0,
      ),
    ];
  }
}
