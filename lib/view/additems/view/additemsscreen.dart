import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yumquick/view/additems/bloc/add_items_bloc.dart';
import 'package:yumquick/view/additems/model/itemsmodel.dart';
import 'package:yumquick/view/additems/view/addeditemscreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class AddItemsScreen extends StatefulWidget {
  final Item? editItem;

  const AddItemsScreen({super.key, this.editItem});

  @override
  State<AddItemsScreen> createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  File? _pickedImage;
  String? editingItemId;
  String? imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      editingItemId = widget.editItem!.id;
      _nameCtrl.text = widget.editItem!.name;
      _descCtrl.text = widget.editItem!.description;
      _costCtrl.text = widget.editItem!.cost;
      imageUrl = widget.editItem!.imageUrl;
    }
    context.read<AddItemsBloc>().add(LoadItemsRequested());
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color.fromRGBO(233, 83, 34, 1.0),
              ),
              title: const Text('Upload from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color.fromRGBO(233, 83, 34, 1.0),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      labelText: label,
      labelStyle: const TextStyle(color: Color.fromRGBO(233, 83, 34, 1.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 12 : 14,
      ),
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final cost = _costCtrl.text.trim();

    if (name.isEmpty ||
        desc.isEmpty ||
        cost.isEmpty ||
        (_pickedImage == null && editingItemId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields including image are required'),
        ),
      );
      return;
    }

    String imagePath = _pickedImage?.path ?? '';

    if (editingItemId == null) {
      context.read<AddItemsBloc>().add(
        AddItemRequested(
          name: name,
          description: desc,
          image: imagePath,
          cost: cost.toString(),
        ),
      );
    } else {
      context.read<AddItemsBloc>().add(
        EditItemRequested(
          id: editingItemId!,
          name: name,
          description: desc,
          image: imagePath,
          cost: cost.toString(),
        ),
      );
    }

    setState(() {
      editingItemId = null;
      _pickedImage = null;
    });

    _nameCtrl.clear();
    _descCtrl.clear();
    _costCtrl.clear();
  }

  void _startEdit(Item item) {
    setState(() {
      editingItemId = item.id;
      _nameCtrl.text = item.name;
      _descCtrl.text = item.description;
      _costCtrl.text = item.cost;
      _pickedImage = null; // The user can pick a new image if desired
      imageUrl = item.imageUrl;
    });
  }

  void _delete(String id) {
    context.read<AddItemsBloc>().add(DeleteItemRequested(id));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = size.width;
    final height = size.height;
    const maxContentWidth = 600.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: const Text(
          'Add Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddedItemScreen()),
              );
            },
            icon: Icon(Icons.list),
          ),
        ],
        // centerTitle: true,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.all(width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    editingItemId == null ? "Add a new item" : "Edit item",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: width < 360 ? 18 : 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _nameCtrl,
                    decoration: _buildInputDecoration('Name', context),
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _descCtrl,
                    decoration: _buildInputDecoration('Description', context),
                    maxLines: 1,
                    maxLength: 70,

                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: height * 0.02),
                  TextField(
                    controller: _costCtrl,
                    decoration: _buildInputDecoration('Cost of item', context),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: height * 0.03),
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: height * 0.28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[100],
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _pickedImage == null
                          ? (editingItemId != null && imageUrl != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          imageUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: width * 0.18,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tap to add image",
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width < 360 ? 14 : 16,
                                        ),
                                      ),
                                    ],
                                  ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  BlocListener<AddItemsBloc, AddItemsState>(
                    listener: (context, state) {
                      if (state is AddItemsOperationFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                      }
                    },
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        backgroundColor: AppColors.primary,
                        elevation: 8,
                        minimumSize: Size(width * 0.5, height * 0.06),
                      ),
                      child: Text(
                        editingItemId == null ? 'Add Item' : 'Edit Item',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  // Optionally, list previously-added items or button to navigate elsewhere
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }
}
