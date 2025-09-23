import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_bloc.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_event.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_state.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class AddMealBoxScreen extends StatefulWidget {
  const AddMealBoxScreen({super.key});

  @override
  State createState() => _AddMealBoxScreenState();
}

class _AddMealBoxScreenState extends State<AddMealBoxScreen> {
  List<Map<String, dynamic>> availableItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  bool isLoadingItems = false;

  late TextEditingController _deliveryDateController; // ✅ state variable

  @override
  void initState() {
    super.initState();
    _deliveryDateController = TextEditingController(); // ✅ init once
    final bloc = context.read<MealBoxBloc>();
    bloc.add(ResetMealBoxEvent());

    _fetchItemsFromApi();
  }

  @override
  void dispose() {
    _deliveryDateController.dispose(); // ✅ dispose
    super.dispose();
  }

  Future<void> _fetchItemsFromApi() async {
    setState(() => isLoadingItems = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("authToken");
      final response = await http.get(
        Uri.parse("https://mm-food-backend.onrender.com/api/item"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final rawItems = body['items'] as List? ?? [];
        final items = rawItems.map<Map<String, dynamic>>((item) {
          return {
            '_id': item['_id'] ?? '',
            'name': item['name'] ?? '',
            'description': item['description'] ?? '',
            'cost': item['cost'] ?? '',
          };
        }).toList();
        setState(() {
          availableItems = items;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch items: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching items: $e')));
    } finally {
      setState(() => isLoadingItems = false);
    }
  }

  void _onItemCheckChanged(bool? checked, Map<String, dynamic> item) {
    setState(() {
      if (checked == true) {
        if (!selectedItems.any((i) => i['_id'] == item['_id'])) {
          selectedItems.add(item);
        }
      } else {
        selectedItems.removeWhere((i) => i['_id'] == item['_id']);
      }
    });
    context.read<MealBoxBloc>().add(ItemsChanged(jsonEncode(selectedItems)));
  }

  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  Widget _buildItemsMultiSelect() {
    if (isLoadingItems) {
      return const Center(child: CircularProgressIndicator());
    }

    List filteredItems = _searchTerm.isEmpty
        ? availableItems
        : availableItems.where((item) {
            final name = (item['name'] ?? '').toLowerCase();
            return name.contains(_searchTerm.toLowerCase());
          }).toList();

    if (filteredItems.isEmpty) {
      return const Text('No items available');
    }

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelStyle: TextStyle(color: AppColors.primary),
            labelText: 'Search by name',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchTerm = value;
            });
          },
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[50],
            border: Border.all(color: AppColors.primary),
          ),
          padding: const EdgeInsets.all(8),
          height: 200,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView(
              children: filteredItems.map((item) {
                final isChecked = selectedItems.any(
                  (i) => i['_id'] == item['_id'],
                );
                return CheckboxListTile(
                  title: Text(item['name'] ?? ''),
                  subtitle: Text("₹${item['cost']} " ?? ''),

                  value: isChecked,
                  onChanged: (checked) => _onItemCheckChanged(checked, item),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String>? onChanged,
    required BuildContext context,
    TextEditingController? controller,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
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
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, bool isBoxImage) {
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
                if (isBoxImage) {
                  context.read<MealBoxBloc>().add(
                    PickBoxImageEvent(ImageSource.gallery),
                  );
                } else {
                  context.read<MealBoxBloc>().add(
                    PickActualImageEvent(ImageSource.gallery),
                  );
                }
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
                if (isBoxImage) {
                  context.read<MealBoxBloc>().add(
                    PickBoxImageEvent(ImageSource.camera),
                  );
                } else {
                  context.read<MealBoxBloc>().add(
                    PickActualImageEvent(ImageSource.camera),
                  );
                }
              },
            ),
          ],
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
    const maxContentWidth = 600.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AdminHomescreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: const Text(
          'Add MealBox',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // centerTitle: true,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: BlocConsumer<MealBoxBloc, MealBoxState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('MealBox added successfully!')),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AdminHomescreen()),
              (route) => false,
            );
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
                        "Fill the mealbox details",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 18 : 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: height * 0.025),

                      // 📷 Box Image
                      GestureDetector(
                        onTap: () => _showImageSourceActionSheet(context, true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: height * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: state.boxImageFile == null
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
                                      "Tap to add box image",
                                      style: TextStyle(
                                        color: const Color.fromRGBO(
                                          255,
                                          205,
                                          89,
                                          1.0,
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
                                    state.boxImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),

                      // 📷 Actual Image
                      GestureDetector(
                        onTap: () =>
                            _showImageSourceActionSheet(context, false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: height * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: state.actualImageFile == null
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
                                      "Tap to add actual image",
                                      style: TextStyle(
                                        color: const Color.fromRGBO(
                                          255,
                                          205,
                                          89,
                                          1.0,
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
                                    state.actualImageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: height * 0.035),

                      // Title
                      _buildTextField(
                        label: "Title",
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(TitleChanged(val)),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // Description
                      _buildTextField(
                        label: "Description",
                        maxLines: 2,
                        maxLength: 120,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          DescriptionChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // Min Qty
                      _buildTextField(
                        label: "Minimum Quantity",
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(MinQtyChanged(val)),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // Price
                      _buildTextField(
                        label: "Price",
                        keyboardType: TextInputType.number,
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(PriceChanged(val)),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // ✅ Delivery Date
                      _buildTextField(
                        label: "Minimun day to Prepare",
                        controller: _deliveryDateController,
                        keyboardType: TextInputType.number,
                        // readOnly: true,
                        // suffixIcon: IconButton(
                        //   icon: const Icon(
                        //     Icons.calendar_today,
                        //     color: Color.fromRGBO(233, 83, 34, 1.0),
                        //   ),
                        //   onPressed: () => _selectDeliveryDate(context),
                        // ),
                        onChanged: (val) {
                          context.read<MealBoxBloc>().add(
                            DeliveryDateChanged(val),
                          );
                        },
                        context: context,
                      ),

                      SizedBox(height: height * 0.025),

                      // Sample Available
                      Row(
                        children: [
                          const Text(
                            "Sample Available",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            activeColor: AppColors.primary,
                            value: state.sampleAvailable,
                            onChanged: (val) {
                              if (val != null) {
                                context.read<MealBoxBloc>().add(
                                  SampleAvailableChanged(val),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Items
                      const Text(
                        'Select Items',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildItemsMultiSelect(),
                      SizedBox(height: height * 0.025),

                      // Packaging Details
                      _buildTextField(
                        label: "Packaging Details",
                        maxLines: 2,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          PackagingDetailsChanged(val),
                        ),
                        context: context,
                      ),
                      SizedBox(height: height * 0.025),

                      // Submit button
                      ElevatedButton(
                        onPressed: state.isUploading
                            ? null
                            : () {
                                context.read<MealBoxBloc>().add(
                                  UploadMealBoxEvent(),
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
                                "Add MealBox",
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
    );
  }
}
