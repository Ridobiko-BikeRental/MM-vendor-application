import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_bloc.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_event.dart';
import 'package:yumquick/view/addproductscreen/bloc/addproduct_state.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ResetProductEvent());
    _loadCategories();
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
                color: Color.fromRGBO(233, 83, 34, 1.0),
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
              leading: const Icon(
                Icons.camera_alt,
                color: Color.fromRGBO(233, 83, 34, 1.0),
              ),
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

  Widget _buildTextField({
    int? maxlenght,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    required BuildContext context,
  }) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return TextFormField(
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxlenght,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromRGBO(233, 83, 34, 1.0)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = size.width;
    final height = size.height;
    final isSmall = width < 360;
    final maxContentWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: const Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
            setState(() {
              _selectedCategoryId = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product added successfully!')),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                        "Fill the product details",
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
                          child: state.imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        color: const Color.fromRGBO(
                                          255,
                                          205,
                                          89,
                                          1,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmall ? 14 : 16,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    state.imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.035),
                      _buildTextField(
                        label: "Product Name",
                        onChanged: (val) =>
                            context.read<ProductBloc>().add(NameChanged(val)),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Short Description",
                        maxLines: 2,
                        maxlenght: 80,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          DescriptionChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // ... inside build or widget tree where Quantity and Price input fields are:
                      _buildTextField(
                        label: "Quantity",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          QuantityChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      _buildTextField(
                        label: "Price Per Unit",
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            context.read<ProductBloc>().add(PriceChanged(val)),
                        context: context,
                      ),

                      SizedBox(height: height * 0.025),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(
                            color: Color.fromRGBO(233, 83, 34, 1.0),
                          ),
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
                                if (_selectedCategoryId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select a category'),
                                    ),
                                  );
                                  return;
                                }
                                context.read<ProductBloc>().add(
                                  UploadProductEvent(
                                    categoryId: _selectedCategoryId!,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: Size(width * 0.5, height * 0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: const Color.fromRGBO(
                            233,
                            83,
                            34,
                            1.0,
                          ),
                          elevation: 8,
                        ),
                        child: state.isUploading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              )
                            : const Text(
                                "Add Product",
                                style: TextStyle(
                                  color: Colors.white,
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
      // bottomNavigationBar: const Navbar(),
    );
  }
}
