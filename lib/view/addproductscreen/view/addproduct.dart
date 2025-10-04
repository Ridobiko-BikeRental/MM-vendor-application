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
import 'package:yumquick/view/admindashboard/model/catogrymodel.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<CategoryModelforaddproduct> _categories = [];
  String? _selectedCategoryId;
  String? selectedPriceType;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ResetProductEvent());
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _fetchCategories();

      // Deduplicate fetched categories by id (in case server returns duplicates)
      final seenIds = <String>{};
      final deduped = <CategoryModelforaddproduct>[];
      for (var c in data) {
        final idStr = c.id.toString();
        if (!seenIds.contains(idStr)) {
          seenIds.add(idStr);
          deduped.add(c);
        }
      }

      if (mounted) {
        setState(() {
          _categories = deduped;
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

  Future<List<CategoryModelforaddproduct>> _fetchCategories() async {
    final url = Uri.parse('https://munchmartfoods.com/vendor/subcategory.php');
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';
      log(token);
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );
      log("jhagdsj${response.statusCode.toString()}");
      log("response${response.body.toString()}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final categoriesJson = data['categories'] as List<dynamic>? ?? [];
        List<CategoryModelforaddproduct> categories = categoriesJson
            .map(
              (e) => CategoryModelforaddproduct.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
        log('Fetched categories count: ${categories.length}');
        for (var cat in categories) {
          log('Category: id=${cat.id}, name=${cat.name}');
        }
        return categories;
      }
      // } else {
      //   throw Exception(
      //     "Failed to load categories: ${response.statusCode}, Body: ${response.body}",
      //   );
      // }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
    return [];
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

    // Ensure selected category is valid
    // Ensure selected category is valid, reset to null if invalid
    // Inside build(), after categories are loaded and set
    // Ensure selected category is valid without calling setState during build
    final bool isSelectedCategoryValid =
        _selectedCategoryId != null &&
        _categories.any((c) => c.id.toString() == _selectedCategoryId);

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
                        label: "Min Quantity",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          QuantityChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Minmum Order date",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          MinDeliveryDaysChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Maximum Order date",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          MaxDeliveryDaysChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // Define a variable to keep track of selection
                      DropdownButtonFormField<String>(
                        value: selectedPriceType,
                        decoration: InputDecoration(
                          labelText: "Price Type",
                          labelStyle: TextStyle(color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "unit", child: Text("Unit")),
                          DropdownMenuItem(value: "gram", child: Text("Gram")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            selectedPriceType = val;
                          });
                          context.read<ProductBloc>().add(
                            PriceTypeChanged(val ?? ""),
                          );
                        },
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
                      Row(
                        children: [
                          const Text(
                            "Delivery Price Available",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            activeColor: AppColors.primary,
                            value: state.product.deliveryPriceEnabled,
                            onChanged: (val) {
                              if (val != null) {
                                context.read<ProductBloc>().add(
                                  DeliveryPriceEnabledChanged(val),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Delivery Price",
                        keyboardType: TextInputType.number,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          DeliveryPriceChanged(val),
                        ),
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
                            value: isSelectedCategoryValid
                                ? _selectedCategoryId
                                : null,
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
                                value: category.id.toString(),
                                child: Text(category.name),
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
