import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/addedproductlist/discountscreen.dart';
import 'package:yumquick/addedproductlist/upadtesubcatscreen.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_bloc.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_event.dart';
import 'package:yumquick/view/widget/app_colors.dart';

import '../view/admindashboard/model/catogrymodel.dart';

class SubCategoryScreen extends StatefulWidget {
  final List<SubCategoryModel> subCategories;
  final String categoryName;

  const SubCategoryScreen({
    required this.subCategories,
    required this.categoryName,
    super.key,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  late List<SubCategoryModel> subCategories;
  bool isActive = false;

  // Colors for classic look
  static const Color primaryDark = AppColors.text;
  static const Color background = AppColors.background;

  @override
  void initState() {
    super.initState();
    reloadSubCategories();
    subCategories = List.from(widget.subCategories);
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
      final subs = (e['subCategories'] as List? ?? [])
          .map<Map<String, dynamic>>((sub) {
            return {
              'id': (sub['_id'] ?? '').toString(),
              'name': (sub['name'] ?? '').toString(),
              'description': (sub['description'] ?? '').toString(),
              'pricePerUnit': sub['pricePerUnit'] ?? 0,
              'imageUrl': (sub['imageUrl'] ?? '').toString(),
              'available': sub['available'] ?? false,
              'quantity': sub['quantity'] ?? 0,
              'category': (sub['category'] ?? '').toString(),
              'discount': sub['discount'] ?? 0,
            };
          })
          .toList();
      return {'name': catName, 'subcategories': subs};
    }).toList();
  }

  Future<void> reloadSubCategories() async {
    try {
      final allCats = await _fetchCategoriesWithSubcategories();

      final selected = allCats.firstWhere(
        (cat) =>
            (cat['name'] as String).trim().toLowerCase() ==
            widget.categoryName.trim().toLowerCase(),
        orElse: () => {'subcategories': <Map<String, dynamic>>[]},
      );

      final subcats = List<Map<String, dynamic>>.from(
        (selected['subcategories'] as List?) ?? const <Map<String, dynamic>>[],
      );

      setState(() {
        subCategories = subcats
            .map(
              (e) => SubCategoryModel(
                id: e['id'] ?? '',
                name: e['name'] ?? '',
                description: e['description'] ?? '',
                pricePerUnit: e['pricePerUnit'] ?? 0,
                imageUrl: e['imageUrl'] ?? '',
                available: e['available'] ?? false,
                qunatity: e['quantity'] ?? 0,
                catId: e['category'] ?? '',
                discount: e['discount'] ?? 0,
              ),
            )
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching subcategories: $e")),
      );
    }
  }

  Future<void> deleteSubCategory(SubCategoryModel sc) async {
    final url =
        'https://mm-food-backend.onrender.com/api/categories/delete-subcategory/${sc.id}';
    try {
      final response = await http.delete(Uri.parse(url));
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          subCategories.removeWhere((element) => element.id == sc.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category deleted successfully")),
        );
        context.read<DashboardBloc>().add(FetchCategoriesEvent());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete category")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "${widget.categoryName.toUpperCase()} Items",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final updated = Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DiscountUpdateScreen()),
              );

              if (updated == true) {
                await reloadSubCategories();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('')),
                // );
              }
            },
            icon: Icon(Icons.discount_sharp, color: AppColors.background),
          ),
        ],
        elevation: 3,
        shadowColor: Colors.black45,
      ),
      body: subCategories.isEmpty
          ? Center(
              child: Text(
                "No subcategories found!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryDark,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: subCategories.length,
              itemBuilder: (ctx, index) {
                final sc = subCategories[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.11),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: sc.imageUrl.isNotEmpty
                              ? Image.network(
                                  sc.imageUrl,
                                  width: width * 0.18,
                                  height: width * 0.18,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 50),
                                )
                              : const Icon(
                                  Icons.fastfood,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sc.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: primaryDark,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sc.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryDark.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              sc.discount == 0
                                  ? Text(
                                      "₹${sc.pricePerUnit}",
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: primaryDark,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          "₹${sc.pricePerUnit}",
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "₹${(sc.pricePerUnit * (100 - sc.discount) / 100).toStringAsFixed(0)}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                              activeColor: primaryDark,
                              value: sc.available,
                              onChanged: (bool newValue) async {
                                try {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final token =
                                      prefs.getString('authToken') ?? '';
                                  final url = Uri.parse(
                                    'https://mm-food-backend.onrender.com/api/categories/update-subcategory-availability/${sc.id}',
                                  );
                                  final response = await http.put(
                                    url,
                                    headers: {
                                      'Authorization': 'Bearer $token',
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({'available': newValue}),
                                  );

                                  if (response.statusCode == 200) {
                                    setState(() {
                                      subCategories[index] = SubCategoryModel(
                                        discount: sc.discount,
                                        id: sc.id,
                                        name: sc.name,
                                        description: sc.description,
                                        pricePerUnit: sc.pricePerUnit,
                                        imageUrl: sc.imageUrl,
                                        available: newValue,
                                        qunatity: sc.qunatity,
                                        catId: sc.catId,
                                      );
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Availability updated'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to update availability',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error updating availability: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: primaryDark,
                              ),
                              onSelected: (String value) async {
                                if (value == 'edit') {
                                  final updated = await Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Upadtesubcatscreen(
                                              name: sc.name,
                                              id: sc.id,
                                              image: sc.imageUrl,
                                              dec: sc.description,
                                              prize: sc.pricePerUnit,
                                              quantity: sc.qunatity,
                                              categoryId: sc.catId,
                                            );
                                          },
                                        ),
                                      );
                                  if (updated == true) {
                                    await reloadSubCategories();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Subcategory refreshed'),
                                      ),
                                    );
                                  }
                                } else if (value == 'delete') {
                                  await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Category'),
                                      content: const Text(
                                        'Are you sure you want to delete this category?',
                                        style: TextStyle(color: AppColors.text),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deleteSubCategory(sc);
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: AppColors.text),
                                      Text(
                                        'Edit',
                                        style: TextStyle(color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: AppColors.text),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                              offset: const Offset(0, 30),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
