import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yumquick/addedproductlist/subcatscreen.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_bloc.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_event.dart';
import 'package:yumquick/view/admindashboard/bloc/dashboard_state.dart';
import 'package:yumquick/view/admindashboard/view/adminhomescreen.dart';
import 'package:yumquick/view/widget/app_colors.dart';
import 'package:yumquick/view/widget/floatingbutton.dart';
import 'package:yumquick/view/widget/navbar.dart';

class Addedproductlist extends StatefulWidget {
  const Addedproductlist({super.key});

  @override
  State<Addedproductlist> createState() => _AddedproductlistState();
}

class _AddedproductlistState extends State<Addedproductlist> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    int crossAxisCount = 2;
    if (width > 600) crossAxisCount = 3;
    if (width > 1000) crossAxisCount = 4;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AdminHomescreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        floatingActionButton: Floating().floatingButton(context),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AdminHomescreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          ),

          title: Text(
            "Your Added Products",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.background,
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            /// BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DashboardLoaded) {
                      final categories = state.allCategories;
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text(
                            'No categories found!',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(width * 0.04),
                        itemCount: categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: width * 0.04,
                          crossAxisSpacing: width * 0.04,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, idx) {
                          final cat = categories[idx];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SubCategoryScreen(
                                    subCategories: cat.subcategories,
                                    categoryName: cat.name,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Name at the top with improved style and spacing
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      cat.name.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        // decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * 0.04,
                                        color: Colors.brown[800],
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.brown.shade200
                                                .withOpacity(0.5),
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Image in the middle with rounded corners and subtle border
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child:
                                            //  cat.imageUrl.isNotEmpty
                                            //     ? Image.network(
                                            //         cat.imageUrl,
                                            //         fit: BoxFit.cover,
                                            //         width: double.infinity,
                                            //         loadingBuilder:
                                            //             (
                                            //               context,
                                            //               child,
                                            //               loadingProgress,
                                            //             ) {
                                            //               if (loadingProgress ==
                                            //                   null)
                                            //                 return child;
                                            //               return const Center(
                                            //                 child:
                                            //                     CircularProgressIndicator(
                                            //                       strokeWidth: 2,
                                            //                     ),
                                            //               );
                                            //             },
                                            //         errorBuilder: (_, __, ___) =>
                                            //             const Icon(
                                            //               Icons.broken_image,
                                            //               size: 60,
                                            //               color: Colors.grey,
                                            //             ),
                                            //       )
                                            //     :
                                            Container(
                                              color: Colors.grey.shade100,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.fastfood,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),

                                  // // Buttons below image with spacing, tooltips, and vibrant colors
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     vertical: 12,
                                  //     horizontal: 32,
                                  //   ),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceEvenly,
                                  //     children: [
                                  //       Tooltip(
                                  //         message: 'Edit Category',
                                  //         child: IconButton(
                                  //           icon: const Icon(
                                  //             Icons.edit,
                                  //             color: Colors.deepOrange,
                                  //             size: 24,
                                  //           ),
                                  //           splashRadius: 22,
                                  //           onPressed: () {
                                  //             Navigator.of(context).push(
                                  //               MaterialPageRoute(
                                  //                 builder: (context) =>
                                  //                     CategoryUpdateScreen(
                                  //                       categoryId: cat.id,
                                  //                       currentName: cat.name,
                                  //                     ),
                                  //               ),
                                  //             );
                                  //           },
                                  //         ),
                                  //       ),
                                  //       Tooltip(
                                  //         message: 'Delete Category',
                                  //         child: IconButton(
                                  //           padding: EdgeInsets.zero,
                                  //           constraints: const BoxConstraints(),
                                  //           iconSize: 22,
                                  //           splashRadius: 20,
                                  //           onPressed: () async {
                                  //             final shouldDelete = await showDialog<bool>(
                                  //               context: context,
                                  //               builder: (context) => AlertDialog(
                                  //                 title: const Text(
                                  //                   'Delete Category',
                                  //                 ),
                                  //                 content: const Text(
                                  //                   'Are you sure you want to delete this category?',
                                  //                 ),
                                  //                 actions: [
                                  //                   TextButton(
                                  //                     onPressed: () =>
                                  //                         Navigator.of(
                                  //                           context,
                                  //                         ).pop(false),
                                  //                     child: const Text('Cancel'),
                                  //                   ),
                                  //                   TextButton(
                                  //                     onPressed: () =>
                                  //                         Navigator.of(
                                  //                           context,
                                  //                         ).pop(true),
                                  //                     child: const Text(
                                  //                       'Delete',
                                  //                       style: TextStyle(
                                  //                         color: Colors.red,
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             );

                                  //             if (shouldDelete == true) {
                                  //               final url =
                                  //                   'https://mm-food-backend.onrender.com/api/categories/delete/${cat.id}';
                                  //               final res = await http.delete(
                                  //                 Uri.parse(url),
                                  //               );
                                  //               if (!mounted) return;
                                  //               if (res.statusCode == 200) {
                                  //                 ScaffoldMessenger.of(
                                  //                   context,
                                  //                 ).showSnackBar(
                                  //                   const SnackBar(
                                  //                     content: Text(
                                  //                       "Deleted successfully",
                                  //                     ),
                                  //                     duration: Duration(
                                  //                       seconds: 2,
                                  //                     ),
                                  //                     behavior: SnackBarBehavior
                                  //                         .floating,
                                  //                   ),
                                  //                 );
                                  //                 context
                                  //                     .read<DashboardBloc>()
                                  //                     .add(
                                  //                       FetchCategoriesEvent(),
                                  //                     );
                                  //               } else {
                                  //                 ScaffoldMessenger.of(
                                  //                   context,
                                  //                 ).showSnackBar(
                                  //                   const SnackBar(
                                  //                     content: Text(
                                  //                       "Failed to delete",
                                  //                     ),
                                  //                     duration: Duration(
                                  //                       seconds: 2,
                                  //                     ),
                                  //                     behavior: SnackBarBehavior
                                  //                         .floating,
                                  //                   ),
                                  //                 );
                                  //               }
                                  //             }
                                  //           },
                                  //           icon: const Icon(
                                  //             Icons.delete,
                                  //             color: Colors.redAccent,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is DashboardError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Navbar(),
      ),
    );
  }
}
