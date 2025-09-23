import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class DiscountUpdateScreen extends StatefulWidget {
  @override
  State<DiscountUpdateScreen> createState() => _DiscountUpdateScreenState();
}

class _DiscountUpdateScreenState extends State<DiscountUpdateScreen> {
  String? _selectedCategoryName;
  String? _selectedSubcategoryId;

  List<Map<String, dynamic>> _categoriesWithSubs = [];
  List<Map<String, String>> _subcategories = [];

  final _discountController = TextEditingController();
  DateTime? _discountStart;
  DateTime? _discountEnd;

  bool _isLoading = false;
  bool _isFetchingCats = false;

  @override
  void initState() {
    super.initState();
    _loadCategoriesWithSubcategories();
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoriesWithSubcategories() async {
    setState(() => _isFetchingCats = true);
    try {
      final catsWithSubs = await _fetchCategoriesWithSubcategories();
      setState(() {
        _categoriesWithSubs = catsWithSubs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    } finally {
      if (mounted) setState(() => _isFetchingCats = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategoriesWithSubcategories() async {
    const String url =
        "https://mm-food-backend.onrender.com/api/categories/my-categories-with-subcategories";

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("authToken");
    if (token == null) throw Exception("No token found in SharedPreferences");

    final response = await http.get(
      Uri.parse(url),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed: ${response.statusCode}, Body: ${response.body}");
    }

    final decoded = json.decode(response.body);
    final List<dynamic> rawCats = (decoded['categories'] as List?) ?? [];

    return rawCats.map<Map<String, dynamic>>((e) {
      final String catName = (e['name'] ?? '').toString();
      final subs = (e['subCategories'] as List? ?? []).map<Map<String, String>>(
        (sub) {
          return {
            'id': (sub['_id'] ?? '').toString(),
            'name': (sub['name'] ?? '').toString(),
          };
        },
      ).toList();
      return {'name': catName, 'subcategories': subs};
    }).toList();
  }

  void _filterSubcategoriesByCategoryName(String categoryName) {
    final selected = _categoriesWithSubs.firstWhere(
      (cat) =>
          (cat['name'] as String).trim().toLowerCase() ==
          categoryName.trim().toLowerCase(),
      orElse: () => {'subcategories': <Map<String, String>>[]},
    );

    final subcats = List<Map<String, String>>.from(
      (selected['subcategories'] as List?) ?? const <Map<String, String>>[],
    );

    setState(() {
      _subcategories = subcats;
      _selectedSubcategoryId = null;
    });
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _discountStart = picked;
        } else {
          _discountEnd = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedSubcategoryId == null ||
        _discountController.text.trim().isEmpty ||
        _discountStart == null ||
        _discountEnd == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_discountEnd!.isBefore(_discountStart!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final discount = int.tryParse(_discountController.text.trim());
    if (discount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid discount number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url =
        'https://mm-food-backend.onrender.com/api/categories/update-subcategory/$_selectedSubcategoryId';

    final body = json.encode({
      'discount': discount,
      'discountStart': _discountStart!.toIso8601String(),
      'discountEnd': _discountEnd!.toIso8601String(),
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("authToken");
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Discount updated')));
        _discountController.clear();
        _discountEnd = null;
        _discountStart = null;
        _loadCategoriesWithSubcategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update discount: ${response.statusCode} ${response.body}',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;
    final maxContentWidth = 600.0;

    final categoryNames = _categoriesWithSubs
        .map((cat) => (cat['name'] as String?) ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Update Discount',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // centerTitle: true,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.background,
      body: _isFetchingCats
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 0.06),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Update subcategory discount",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmall ? 18 : 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryName,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          items: categoryNames
                              .map(
                                (name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedCategoryName = value);
                            if (value != null) {
                              _filterSubcategoriesByCategoryName(value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedSubcategoryId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Subcategory',
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          items: _subcategories
                              .map(
                                (sub) => DropdownMenuItem<String>(
                                  value: sub['id'],
                                  child: Text(sub['name'] ?? ''),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedSubcategoryId = value),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _discountController,
                          decoration: InputDecoration(
                            labelText: 'Discount (%)',
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _pickDate(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  _discountStart == null
                                      ? "Start Date"
                                      : _discountStart!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _pickDate(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.background,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  _discountEnd == null
                                      ? "End Date"
                                      : _discountEnd!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Submit',
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
            ),
    );
  }
}
