import 'dart:io';

import 'package:equatable/equatable.dart';

class MealBoxState extends Equatable {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final String title;
  final String description;
  final String minQty;
  final String price;
  final String prepareOrderDays;
  final bool sampleAvailable;
  final String items; // JSON string of selected items
  final String packagingDetails;
  final File? boxImageFile;
  final File? actualImageFile;
  final String? boxImageUrl; // ✅ Added
  final String? actualImageUrl; // ✅ Added
  final bool isUploading;
  final bool isSuccess;
  final String? errorMessage;

  const MealBoxState({
    this.categories = const [],
    this.selectedCategoryId,
    this.title = '',
    this.description = '',
    this.minQty = '',
    this.price = '',
    this.prepareOrderDays = '',
    this.sampleAvailable = false,
    this.items = '',
    this.packagingDetails = '',
    this.boxImageFile,
    this.actualImageFile,
    this.boxImageUrl,
    this.actualImageUrl,
    this.isUploading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  MealBoxState copyWith({
    List<Map<String, dynamic>>? categories,
    String? selectedCategoryId,
    String? title,
    String? description,
    String? minQty,
    String? price,
    String? prepareOrderDays,
    bool? sampleAvailable,
    String? items,
    String? packagingDetails,
    File? boxImageFile,
    File? actualImageFile,
    String? boxImageUrl,
    String? actualImageUrl,
    bool? isUploading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return MealBoxState(
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      minQty: minQty ?? this.minQty,
      price: price ?? this.price,
      prepareOrderDays: prepareOrderDays ?? this.prepareOrderDays,
      sampleAvailable: sampleAvailable ?? this.sampleAvailable,
      items: items ?? this.items,
      packagingDetails: packagingDetails ?? this.packagingDetails,
      boxImageFile: boxImageFile ?? this.boxImageFile,
      actualImageFile: actualImageFile ?? this.actualImageFile,
      boxImageUrl: boxImageUrl ?? this.boxImageUrl,
      actualImageUrl: actualImageUrl ?? this.actualImageUrl,
      isUploading: isUploading ?? this.isUploading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    selectedCategoryId,
    title,
    description,
    minQty,
    price,
    prepareOrderDays,
    sampleAvailable,
    items,
    packagingDetails,
    boxImageFile,
    actualImageFile,
    boxImageUrl, // ✅ Included in equality
    actualImageUrl, // ✅ Included in equality
    isUploading,
    isSuccess,
    errorMessage,
  ];
}
