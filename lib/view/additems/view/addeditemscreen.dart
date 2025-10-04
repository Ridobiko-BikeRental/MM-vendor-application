import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yumquick/view/additems/bloc/add_items_bloc.dart';
import 'package:yumquick/view/additems/model/itemsmodel.dart';
import 'package:yumquick/view/additems/view/additemsscreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';

class AddedItemScreen extends StatefulWidget {
  const AddedItemScreen({super.key});

  @override
  State<AddedItemScreen> createState() => _AddedItemScreenState();
}

class _AddedItemScreenState extends State<AddedItemScreen> {
  // Edit: Open AddItemsScreen in edit mode with the selected item
  Future<void> _startEdit(Item item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddItemsScreen(editItem: item)),
    );
    // Refresh items after returning from edit
    context.read<AddItemsBloc>().add(LoadItemsRequested());
  }

  void _delete(String id) {
    context.read<AddItemsBloc>().add(DeleteItemRequested(id));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Added Items",
          style: TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.background),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Existing Items",
              style: TextStyle(
                color: const Color.fromRGBO(233, 83, 34, 1.0),
                fontWeight: FontWeight.bold,
                fontSize: width < 360 ? 18 : 20,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<AddItemsBloc, AddItemsState>(
                builder: (context, state) {
                  if (state is AddItemsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AddItemsLoadSuccess) {
                    if (state.items.isEmpty) {
                      return const Center(child: Text('No items found.'));
                    }
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: item.imageUrl.isNotEmpty
                                      ? Image.network(
                                          item.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[700],
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name.trim(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description.trim(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "₹${item.cost.toString()}",
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.black87,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onSelected: (String value) async {
                                    if (value == "edit") {
                                      await _startEdit(item);
                                    } else if (value == "delete") {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Item'),
                                          content: const Text(
                                            'Are you sure you want to delete this item?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: AppColors.text,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
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
                                      if (confirm == true) {
                                        _delete(item.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: "edit",
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.edit,
                                          color: AppColors.text,
                                        ),
                                        title: Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: "delete",
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: AppColors.text,
                                        ),
                                        title: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is AddItemsOperationFailure) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
