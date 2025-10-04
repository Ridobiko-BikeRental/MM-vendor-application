import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addmealbox/view/mealbox.dart' show MealBox;
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/navbar.dart';

import '../bloc/addmealbox_bloc.dart';
import '../bloc/addmealbox_event.dart';
import '../bloc/addmealbox_state.dart';

class UpdateMealBoxScreen extends StatefulWidget {
  final MealBox updateMealBox;

  const UpdateMealBoxScreen({Key? key, required this.updateMealBox})
    : super(key: key);

  @override
  State createState() => _UpdateMealBoxScreenState();
}

class _UpdateMealBoxScreenState extends State<UpdateMealBoxScreen> {
  List<Map<String, dynamic>> availableItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  bool isLoadingItems = false;

  final TextEditingController _mindeliveryDateController =
      TextEditingController();
  final TextEditingController _maxdeliveryDateController =
      TextEditingController();

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<MealBoxBloc>();

    bloc.add(ResetMealBoxEvent());

    final mb = widget.updateMealBox;

    bloc.add(TitleChanged(mb.title));
    bloc.add(DescriptionChanged(mb.description));
    bloc.add(MinQtyChanged(mb.minQty.toString()));
    bloc.add(PriceChanged(mb.price.toString()));

    // Format and set delivery date to controller

    bloc.add(MinmumDayToPrepare(mb.minPrepareOrderDays.toString()));
    bloc.add(MaximumDayToPrepare(mb.maxPrepareOrderDays.toString()));

    bloc.add(SampleAvailableChanged(mb.sampleAvailable));
    bloc.add(PackagingDetailsChanged(mb.packagingDetails));

    // Fill initial selected items from widget data and notify Bloc state
    selectedItems = mb.items
        .map(
          (item) => {
            'id': item.id,
            'name': item.name,
            'description': item.description,
          },
        )
        .toList();
    bloc.add(ItemsChanged(jsonEncode(selectedItems)));

    // Preload existing images into bloc state
    if (mb.boxImage.isNotEmpty) {
      bloc.add(PreloadBoxImageEvent(mb.boxImage));
    }
    if (mb.actualImage.isNotEmpty) {
      bloc.add(PreloadActualImageEvent(mb.actualImage));
    }

    _fetchItems();
  }

  Future _fetchItems() async {
    setState(() => isLoadingItems = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final response = await http.get(
        Uri.parse("https://munchmartfoods.com/vendor/item.php"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final rawItems = body['items'] as List? ?? [];
        final items = rawItems.map<Map<String, dynamic>>((item) {
          // Normalize values to String to ensure consistent comparisons
          final idVal = item['id'] ?? item['_id'] ?? '';
          return {
            'id': idVal.toString(),
            'name': (item['name'] ?? '').toString(),
            'description': (item['description'] ?? '').toString(),
          };
        }).toList();

        setState(() => availableItems = items);
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
    final bloc = context.read<MealBoxBloc>();
    if (checked ?? false) {
      // Add item if not already selected
      if (!selectedItems.any(
        (e) => e['id'].toString() == item['id'].toString(),
      )) {
        selectedItems.add({
          'id': item['id'].toString(),
          'name': item['name'].toString(),
          'description': item['description'].toString(),
        });
      }
    } else {
      // Remove item if found
      selectedItems.removeWhere(
        (e) => e['id'].toString() == item['id'].toString(),
      );
    }
    bloc.add(ItemsChanged(jsonEncode(selectedItems)));
  }

  Widget _buildItemsMultiSelect() {
    if (isLoadingItems) return const Center(child: CircularProgressIndicator());

    if (availableItems.isEmpty) return const Text("No items available");

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: const Color(0xFFCDCDCD)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          children: availableItems.map((item) {
            bool checked = selectedItems.any(
              (e) => e['id'].toString() == item['id'].toString(),
            );
            return CheckboxListTile(
              title: Text(item['name'].toString()),
              subtitle: Text(item['description'].toString()),
              value: checked,
              onChanged: (value) => _onItemCheckChanged(value, item),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    required BuildContext context,
    String? initialValue,
    TextEditingController? controller,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final isSmall = MediaQuery.of(context).size.width < 360;
    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black87),
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFE95322)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 12 : 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE95322), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFCD59)),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  void _showImagePickerSheet(bool isBoxImage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFE95322),
              ),
              title: const Text('Select from Gallery'),
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
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE95322)),
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
  void dispose() {
    _mindeliveryDateController.dispose();
    _maxdeliveryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final isSmall = width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Update MealBox",
          style: TextStyle(color: Colors.white),
        ),
        // centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.background,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<MealBoxBloc, MealBoxState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.isSuccess != current.isSuccess,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("MealBox updated successfully")),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const AdminHomescreen()),
              (route) => false,
            );
          }
        },
        buildWhen: (previous, current) =>
            previous.items != current.items ||
            previous.isUploading != current.isUploading ||
            previous.boxImageFile != current.boxImageFile ||
            previous.boxImageUrl != current.boxImageUrl ||
            previous.actualImageFile != current.actualImageFile ||
            previous.actualImageUrl != current.actualImageUrl ||
            previous.title != current.title ||
            previous.description != current.description ||
            previous.minQty != current.minQty ||
            previous.price != current.price ||
            previous.minPrepareOrderDays.toString() !=
                current.minPrepareOrderDays.toString() ||
            previous.maxPrepareOrderDays.toString() !=
                current.maxPrepareOrderDays.toString() ||
            previous.sampleAvailable != current.sampleAvailable ||
            previous.packagingDetails != current.packagingDetails,
        builder: (context, state) {
          // Sync selectedItems with Bloc state items string
          try {
            final selectedFromState = jsonDecode(state.items);
            if (selectedFromState is List) {
              selectedItems = List<Map<String, dynamic>>.from(
                selectedFromState,
              );
            } else {
              selectedItems = [];
            }
          } catch (_) {
            selectedItems = [];
          }

          // Update delivery date controller if differs from current
          if (_mindeliveryDateController.text != state.minPrepareOrderDays) {
            _mindeliveryDateController.text = "${state.minPrepareOrderDays}";
          }
          if (_maxdeliveryDateController.text != state.maxPrepareOrderDays) {
            _maxdeliveryDateController.text = "${state.maxPrepareOrderDays}";
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05,
                  vertical: height * 0.02,
                ),
                child: Container(
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
                  padding: EdgeInsets.all(width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Update MealBox details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFE95322),
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 18 : 20,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Box Image selector
                      GestureDetector(
                        onTap: () => _showImagePickerSheet(true),
                        child: Container(
                          height: height * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFFFCD59),
                              width: 2,
                            ),
                          ),
                          child: state.boxImageFile != null
                              ? Image.file(
                                  state.boxImageFile!,
                                  fit: BoxFit.cover,
                                )
                              : (state.boxImageUrl != null &&
                                    state.boxImageUrl!.isNotEmpty)
                              ? Image.network(
                                  state.boxImageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    "Tap to add box image",
                                    style: TextStyle(
                                      color: const Color(0xFFE95322),
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmall ? 14 : 16,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Actual Image selector
                      GestureDetector(
                        onTap: () => _showImagePickerSheet(false),
                        child: Container(
                          height: height * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFFFCD59),
                              width: 2,
                            ),
                          ),
                          child: state.actualImageFile != null
                              ? Image.file(
                                  state.actualImageFile!,
                                  fit: BoxFit.cover,
                                )
                              : (state.actualImageUrl != null &&
                                    state.actualImageUrl!.isNotEmpty)
                              ? Image.network(
                                  state.actualImageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    "Tap to add actual image",
                                    style: TextStyle(
                                      color: const Color(0xFFE95322),
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmall ? 14 : 16,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form fields
                      _buildTextField(
                        label: "Title",
                        initialValue: state.title,
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(TitleChanged(val)),
                        context: context,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Description",
                        maxLines: 2,
                        initialValue: state.description,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          DescriptionChanged(val),
                        ),
                        context: context,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Minimum Quantity",
                        keyboardType: TextInputType.number,
                        initialValue: state.minQty,
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(MinQtyChanged(val)),
                        context: context,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Price",
                        keyboardType: TextInputType.number,
                        initialValue: state.price,
                        onChanged: (val) =>
                            context.read<MealBoxBloc>().add(PriceChanged(val)),
                        context: context,
                      ),
                      const SizedBox(height: 15),

                      // Delivery Date with calendar icon and picker
                      _buildTextField(
                        label: "Minmum day to prepare",
                        keyboardType: TextInputType.number,
                        initialValue: state.minPrepareOrderDays,

                        // readOnly: true,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          MinmumDayToPrepare(val),
                        ),
                        context: context,
                      ),

                      // suffixIcon: IconButton(
                      //   icon: const Icon(
                      //     Icons.calendar_today,
                      //     color: Color(0xFFE95322),
                      //   ),
                      //   onPressed: () => _selectDeliveryDate(context),
                      // ),
                      // onTap: () => _selectDeliveryDate(context),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Maximum day to prepare",
                        keyboardType: TextInputType.number,
                        initialValue: state.maxPrepareOrderDays,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          MaximumDayToPrepare(val),
                        ),
                        context: context,
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          const Text(
                            "Sample Available",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE95322),
                            ),
                          ),
                          Checkbox(
                            value: state.sampleAvailable,
                            activeColor: const Color(0xFFE95322),
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
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "Packaging Details",
                        maxLines: 2,
                        initialValue: state.packagingDetails,
                        onChanged: (val) => context.read<MealBoxBloc>().add(
                          PackagingDetailsChanged(val),
                        ),
                        context: context,
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        "Select Items",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE95322),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _buildItemsMultiSelect(),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: () {
                          context.read<MealBoxBloc>().add(
                            UpdateMealBoxEvent(widget.updateMealBox.id),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE95322),
                          minimumSize: Size(width * 0.5, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: state.isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Update MealBox",
                                style: TextStyle(
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
