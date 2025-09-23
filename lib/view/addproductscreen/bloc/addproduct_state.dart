import 'dart:io';

import 'package:yumquick/view/addproductscreen/model/productmodel.dart';

class ProductState {
  final ProductModel product;
  final File? imageFile;
  final bool isUploading;
  final String? errorMessage;
  final bool isSuccess;

  const ProductState({
    required this.product,
    this.imageFile,
    this.isUploading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ProductState copyWith({
    ProductModel? product,
    File? imageFile,
    bool? isUploading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ProductState(
      product: product ?? this.product,
      imageFile: imageFile ?? this.imageFile,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
