import 'package:flutter/material.dart';
import 'package:yumquick/view/addmealbox/view/mealbox.dart' show MealBox;
import 'package:yumquick/view/widget/app_colors.dart';

class MealBoxDetailScreen extends StatelessWidget {
  final MealBox mealBox;

  const MealBoxDetailScreen({super.key, required this.mealBox});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1000;

    int gridCount = 2;
    if (isDesktop) {
      gridCount = 4;
    } else if (isTablet) {
      gridCount = 3;
    }

    Widget buildMealItemsHorizontal() {
      if (mealBox.items.isEmpty) return const SizedBox.shrink();

      final itemWidth = isTablet ? size.width * 0.28 : size.width * 0.38;

      return SizedBox(
        height: isTablet ? 200 : 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: mealBox.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final item = mealBox.items[index];
            final imageUrl = (item.imageUrl ?? "").toString();

            return Container(
              width: itemWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                // boxShadow: const [
                //   BoxShadow(
                //     color: Color.fromARGB(19, 0, 0, 0),
                //     blurRadius: 5,
                //     offset: Offset(0, 3),
                //   ),
                // ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: itemWidth,
                            height: isTablet ? 110 : 95,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: isTablet ? 110 : 95,
                              width: itemWidth,
                              color: Colors.orange.shade100,
                              child: const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            height: isTablet ? 110 : 95,
                            width: itemWidth,
                            color: Colors.orange.shade100,
                            child: const Icon(
                              Icons.fastfood,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? 'Unnamed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 16 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description ?? '',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          mealBox.title.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.background),
        ),
        elevation: 2,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                mealBox.actualImage.isNotEmpty
                    ? mealBox.actualImage
                    : mealBox.boxImage,
                width: double.infinity,
                height: isTablet ? size.height * 0.35 : size.height * 0.28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isTablet ? size.height * 0.35 : size.height * 0.28,
                  color: Colors.orange.shade100,
                  child: const Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              mealBox.title,
              style: TextStyle(
                fontSize: isTablet ? 26 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              mealBox.description,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader("Included Items", isTablet),
            buildMealItemsHorizontal(),
            const SizedBox(height: 24),

            // Key info grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: isTablet ? 2.2 : 1.9,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final infoItems = [
                  {
                    "label": "Price",
                    "value": "₹${mealBox.price}",
                    "icon": Icons.currency_rupee,
                  },
                  {
                    "label": "Min Qty",
                    "value": "${mealBox.minQty}",
                    "icon": Icons.format_list_numbered,
                  },
                  {
                    "label": "Sample",
                    "value": mealBox.sampleAvailable
                        ? "Available"
                        : "Not Available",
                    "icon": Icons.inventory_2_outlined,
                  },
                  {
                    "label": "Req Day To prepare",
                    "value": mealBox.minPrepareOrderDays.toString(),
                    "icon": Icons.calendar_today,
                  },
                ];

                final item = infoItems[index];
                return _infoBox(
                  item["label"]! as String,
                  item["value"]! as String,
                  item["icon"]! as IconData,
                  isTablet,
                  context,
                );
              },
            ),
            // const SizedBox(height: 28),
            const SizedBox(height: 28),
            _sectionHeader("Packaging Details", isTablet),
            Text(
              mealBox.packagingDetails.isNotEmpty
                  ? mealBox.packagingDetails
                  : "No packaging details provided.",
              style: TextStyle(
                fontSize: isTablet ? 15 : 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(
    String label,
    String value,
    IconData icon,
    bool isTablet,
    BuildContext context,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      // padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.brown[800], size: isTablet ? 32 : 26),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isTablet) {
    return Row(
      children: [
        Container(
          width: 6,
          height: isTablet ? 28 : 22,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}
