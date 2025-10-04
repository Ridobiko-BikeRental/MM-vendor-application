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
import 'package:yumquick/view/admindashboard/model/catogrymodel.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/navbar.dart';

class Upadtesubcatscreen extends StatefulWidget {
  final int id;
  final String? name;
  final String? image;
  final String? dec;
  final String? prize;
  final int? quantity;
  final int? categoryId;
  final int? minimumorderDate;
  final int? maximumorderDate;
  final double? deliveryPrize;
  final bool deliverybool;
  final String? prizeType;

  const Upadtesubcatscreen({
    super.key,
    required this.id,
    this.name,
    this.image,
    this.dec,
    this.prize,
    this.quantity,
    this.categoryId,
    this.minimumorderDate,
    this.maximumorderDate,
    this.deliveryPrize,
    required this.deliverybool,
    this.prizeType,
  });

  @override
  State<Upadtesubcatscreen> createState() => _UpadtesubcatscreenState();
}

class _UpadtesubcatscreenState extends State<Upadtesubcatscreen> {
  List<CategoryModelforaddproduct> _categories = [];
  String? _selectedCategoryId;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _minDeliveryDaysController;
  late TextEditingController _maxDeliveryDaysController;
  late TextEditingController _deliveryPriceController;

  File? _pickedImageFile;
  String? selectedPriceType;
  bool deliveryPriceEnabled = false;

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
    _minDeliveryDaysController = TextEditingController(
      text: widget.minimumorderDate?.toString() ?? '',
    );
    _maxDeliveryDaysController = TextEditingController(
      text: widget.maximumorderDate?.toString() ?? '',
    );
    _deliveryPriceController = TextEditingController(
      text: widget.deliveryPrize?.toString() ?? '',
    );

    // Coerce incoming values to strings to avoid runtime type errors
    _selectedCategoryId = widget.categoryId?.toString();
    selectedPriceType = widget.prizeType?.toString();
    deliveryPriceEnabled = widget.deliverybool;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minDeliveryDaysController.dispose();
    _maxDeliveryDaysController.dispose();
    _deliveryPriceController.dispose();
    super.dispose();
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
        'https://munchmartfoods.com/vendor/subcategory.php?id=${widget.id}';

    final Map<String, dynamic> body = {
      "name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "pricePerUnit": int.tryParse(_priceController.text.trim()) ?? 0,
      "image_url": _pickedImageFile == null ? (widget.image ?? '') : '',
      "categoryId": _selectedCategoryId!.toString(),

      "quantity": int.tryParse(_quantityController.text.trim()) ?? 0,
      "minDeliveryDays":
          int.tryParse(_minDeliveryDaysController.text.trim()) ?? 0,
      "maxDeliveryDays":
          int.tryParse(_maxDeliveryDaysController.text.trim()) ?? 0,
      "deliveryPrice": int.tryParse(_deliveryPriceController.text.trim()) ?? 0,
      "deliveryPriceEnabled": deliveryPriceEnabled,
      "priceType": selectedPriceType ?? "",
    };

    // TODO: Add image upload logic here if needed and set image_url properly before sending.

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          // "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );
      log(response.body);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subcategory updated successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        log(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update subcategory: ${response.statusCode} - ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating subcategory: $e')));
    }
  }

  Widget _buildTextField({
    int? maxlenght,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    required BuildContext context,
    TextEditingController? controller,
  }) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return TextFormField(
      controller: controller,
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
                        label: "Product Name",
                        controller: _nameController,
                        onChanged: (val) =>
                            context.read<ProductBloc>().add(NameChanged(val)),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Short Description",
                        maxLines: 2,
                        maxlenght: 80,
                        controller: _descriptionController,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          DescriptionChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Min Quantity",
                        keyboardType: TextInputType.number,
                        controller: _quantityController,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          QuantityChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Minimum Order date",
                        keyboardType: TextInputType.number,
                        controller: _minDeliveryDaysController,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          MinDeliveryDaysChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      _buildTextField(
                        label: "Maximum Order date",
                        keyboardType: TextInputType.number,
                        controller: _maxDeliveryDaysController,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          MaxDeliveryDaysChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),
                      DropdownButtonFormField<String>(
                        // Only provide a non-null value if it matches one of the items
                        value:
                            (selectedPriceType != null &&
                                (['unit', 'gram'].contains(selectedPriceType)))
                            ? selectedPriceType
                            : null,
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
                        controller: _priceController,
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
                            value: deliveryPriceEnabled,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  deliveryPriceEnabled = val;
                                });
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
                        controller: _deliveryPriceController,
                        onChanged: (val) => context.read<ProductBloc>().add(
                          DeliveryPriceChanged(val),
                        ),
                        context: context,
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
                          child: Builder(
                            builder: (context) {
                              // Build unique dropdown items and ensure selected value exists
                              final seen = <String>{};
                              final items = <DropdownMenuItem<String>>[];
                              for (var category in _categories) {
                                final val = category.id.toString();
                                if (!seen.contains(val)) {
                                  seen.add(val);
                                  items.add(
                                    DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(category.name),
                                    ),
                                  );
                                }
                              }

                              final selectedValue =
                                  (_selectedCategoryId != null &&
                                      items.any(
                                        (i) => i.value == _selectedCategoryId,
                                      ))
                                  ? _selectedCategoryId
                                  : null;

                              return DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue,
                                hint: const Text('Select Category'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategoryId = newValue;
                                  });
                                },
                                items: items,
                              );
                            },
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
