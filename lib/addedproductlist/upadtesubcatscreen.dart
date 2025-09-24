import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_bloc.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_event.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_state.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/navbar.dart';

class Upadtesubcatscreen extends StatefulWidget {
  final String id;
  final String? name;
  final String? image;
  final String? dec;
  final int? prize;
  final int? quantity;
  final String? categoryId;

  const Upadtesubcatscreen({
    super.key,
    required this.id,
    this.name,
    this.image,
    this.dec,
    this.prize,
    this.quantity,
    this.categoryId,
  });

  @override
  State<Upadtesubcatscreen> createState() => _UpadtesubcatscreenState();
}

class _UpadtesubcatscreenState extends State<Upadtesubcatscreen> {
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;

  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ResetProductEvent());
    _loadCategories();

    _nameController = TextEditingController(text: widget.name ?? '');
    _descriptionController = TextEditingController(text: widget.dec ?? '');
    _priceController = TextEditingController(
      text: widget.prize?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.quantity?.toString() ?? '',
    );

    _selectedCategoryId = widget.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _fetchCategories();
      if (mounted) {
        setState(() {
          _categories = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load categories: $e")),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    const String url =
        "https://mm-food-backend.onrender.com/api/categories/all";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("authToken");

    if (token == null) {
      throw Exception("No token found in SharedPreferences");
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      log("${response.statusCode}");
      final responseData = json.decode(response.body);
      final List<dynamic> data =
          responseData['categories'] ?? responseData ?? [];
      log("${data.length}");
      return data
          .map<Map<String, dynamic>>(
            (e) => {'id': e['_id'] ?? '', 'name': e['name'] ?? ''},
          )
          .toList();
    } else {
      throw Exception(
        "Failed to load categories: ${response.statusCode}, Body: ${response.body}",
      );
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
                color: Color(0xFFE95322),
              ),
              title: const Text('Upload from Gallery'),
              onTap: () {
                Navigator.pop(context);
                context.read<ProductBloc>().add(
                  PickImageEvent(ImageSource.gallery),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE95322)),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                context.read<ProductBloc>().add(
                  PickImageEvent(ImageSource.camera),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSubCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    final String url =
        'https://mm-food-backend.onrender.com/api/categories/update-subcategory/${widget.id}';

    final Map<String, dynamic> body = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "pricePerUnit": int.tryParse(_priceController.text.trim()) ?? 0,
      "imageUrl": _pickedImageFile == null ? (widget.image ?? '') : '',
      "category": _selectedCategoryId!,
      "quantity": int.tryParse(_quantityController.text.trim()) ?? 0,
    };

    // TODO: Add image upload logic here if needed and set imageUrl properly before sending.

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subcategory updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update subcategory')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating subcategory: $e')));
    }
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    required TextEditingController controller,
  }) {
    final bool isSmall = MediaQuery.of(context).size.width < 360;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFE95322)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 12 : 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final bool isSmall = width < 360;
    const double maxContentWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Update Subcategory',
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        // centerTitle: true,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isSuccess) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subcategory updated successfully!'),
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state.imageFile != null) {
            setState(() {
              _pickedImageFile = state.imageFile;
            });
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        "Update the subcategory details",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 18 : 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.025),
                      GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: height * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: _pickedImageFile == null
                              ? (widget.image != null &&
                                        widget.image!.isNotEmpty)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          widget.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                              ),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: width * 0.15,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Tap to add image",
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmall ? 14 : 16,
                                            ),
                                          ),
                                        ],
                                      )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _pickedImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.035),
                      _buildTextField(
                        label: 'Name',
                        controller: _nameController,
                        onChanged: (val) {
                          context.read<ProductBloc>().add(NameChanged(val));
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: 2,
                        onChanged: (val) {
                          context.read<ProductBloc>().add(
                            DescriptionChanged(val),
                          );
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: 'Quantity',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          context.read<ProductBloc>().add(QuantityChanged(val));
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: 'Price',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          context.read<ProductBloc>().add(PriceChanged(val));
                        },
                      ),
                      SizedBox(height: height * 0.025),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Color(0xFFE95322)),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategoryId,
                            hint: const Text('Select Category'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategoryId = newValue;
                              });
                            },
                            items: _categories.map<DropdownMenuItem<String>>((
                              category,
                            ) {
                              return DropdownMenuItem<String>(
                                value: category['id'],
                                child: Text(category['name']),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.045),
                      ElevatedButton(
                        onPressed: state.isUploading
                            ? null
                            : () {
                                if (_selectedCategoryId == null ||
                                    _selectedCategoryId!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a category',
                                        style: TextStyle(color: AppColors.text),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                updateSubCategory();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: Size(width * 0.5, height * 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: AppColors.primary,
                          elevation: 8,
                        ),
                        child: state.isUploading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                "Update Subcategory",
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}
