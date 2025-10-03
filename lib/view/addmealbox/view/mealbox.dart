import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addmealbox/view/detailsofmealbox.dart';
import 'package:yumquick/view/addmealbox/view/updatemealbox.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/floatingbutton.dart';
import 'package:yumquick/view/widget/navbar.dart';

class MealBox {
  final String id;
  final String title;
  final String description;
  final int minQty;
  final int price;
  final int minPrepareOrderDays;
  final int maxPrepareOrderDays;
  final bool sampleAvailable;
  final List<MealItem> items;
  final String packagingDetails;
  final String boxImage;
  final String actualImage;

  MealBox({
    required this.id,
    required this.title,
    required this.description,
    required this.minQty,
    required this.price,
    required this.minPrepareOrderDays,
    required this.maxPrepareOrderDays,
    required this.sampleAvailable,
    required this.items,
    required this.packagingDetails,
    required this.boxImage,
    required this.actualImage,
  });

  factory MealBox.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<MealItem> mealItems = itemsList
        .map((item) => MealItem.fromJson(item))
        .toList();

    return MealBox(
      id: json['_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      minQty: json['minQty'] ?? 0,
      price: json['price'] ?? 0,
      minPrepareOrderDays: json['minPrepareOrderDays'] ?? 0,
      maxPrepareOrderDays: json['maxPrepareOrderDays'] ?? 0,
      sampleAvailable: json['sampleAvailable'] ?? false,
      items: mealItems,
      packagingDetails: json['packagingDetails'] ?? '',
      boxImage: json['boxImage'] ?? '',
      actualImage: json['actualImage'] ?? '',
    );
  }
}

class MealItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;

  MealItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class MealBoxScreen extends StatefulWidget {
  const MealBoxScreen({super.key});

  @override
  State<MealBoxScreen> createState() => _MealBoxScreenState();
}

class _MealBoxScreenState extends State<MealBoxScreen> {
  late Future<List<MealBox>> futureMealBoxes;

  @override
  void initState() {
    super.initState();
    futureMealBoxes = fetchMealBoxes();
  }

  Future<List<MealBox>> fetchMealBoxes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse('https://mm-food-backend.onrender.com/api/mealbox'),
      headers: {
        'Authorization': 'Bearer $token',
        // 'Content-Type': 'application/json',
      },
    );
    log("${response.statusCode}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> mealBoxesList =
          jsonResponse['data'] ?? jsonResponse['mealBoxes'] ?? [];
      List<MealBox> mealBoxes = mealBoxesList
          .map((meal) => MealBox.fromJson(meal))
          .toList();

      // Sort meal boxes by price ascending
      mealBoxes.sort((a, b) => a.price.compareTo(b.price));

      return mealBoxes;
    } else {
      throw Exception('Failed to load meal boxes');
    }
  }

  Future<void> deleteMealBox(String id) async {
    final response = await http.delete(
      Uri.parse('https://mm-food-backend.onrender.com/api/mealbox/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureMealBoxes = fetchMealBoxes();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meal box deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete meal box")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    int crossAxisCount = 1;
    if (size.width > 600) crossAxisCount = 3;
    if (size.width > 1000) crossAxisCount = 4;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AdminHomescreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AdminHomescreen()),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_sharp,
              color: AppColors.background,
            ),
          ),
          title: Text(
            'Meal Boxes',
            style: TextStyle(color: AppColors.background),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: FutureBuilder<List<MealBox>>(
          future: futureMealBoxes,
          builder: (context, snapshot) {
            // log(snapshot.data[0].prepareOrderDays);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              log('Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No meal boxes found'));
            } else {
              final mealBoxes = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.all(size.width * 0.04),
                itemCount: mealBoxes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: size.width * 0.04,
                  crossAxisSpacing: size.width * 0.04,
                  childAspectRatio: size.width / (size.width * 0.5),
                ),
                itemBuilder: (context, index) {
                  final mealBox = mealBoxes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealBoxDetailScreen(mealBox: mealBox),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: mealBox.boxImage.isNotEmpty
                                  ? Image.network(
                                      mealBox.boxImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                    )
                                  : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.fastfood,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              child: Text(
                                mealBox.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 6,
                                      color: Colors.black54,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (String value) async {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => UpdateMealBoxScreen(
                                            updateMealBox: mealBox,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Confirm Delete"),
                                          content: const Text(
                                            "Are you sure you want to delete this meal box?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text("No"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await deleteMealBox(mealBox.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.edit,
                                          color: AppColors.text,
                                        ),
                                        title: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: AppColors.text,
                                        ),
                                        title: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        bottomNavigationBar: Navbar(),
        floatingActionButton: Floating().floatingButton(context),
      ),
    );
  }
}
