import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/productmodel.dart';
import 'addproduct_event.dart';
import 'addproduct_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ImagePicker _picker = ImagePicker();

  ProductBloc()
    : super(
        ProductState(
          product: ProductModel(
            name: "",
            shortDescription: "",
            pricePerUnit: "",
            priceType: "",
            minDeliveryDays: '',
            deliveryPriceEnabled: false,
            deliveryPrice: '',
            maxDeliveryDays: '',
            category: "null",
            minQty: "",
            imageUrl: '',
          ),
        ),
      ) {
    on<PickImageEvent>(_onPickImage);
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<QuantityChanged>(_onminQtyChanged);
    on<PriceChanged>(_onPriceChanged);
    on<PriceTypeChanged>(_onPriceTypeChanged);
    on<MaxDeliveryDaysChanged>(_onMaxDeliveryDaysChanged);
    on<MinDeliveryDaysChanged>(_onMinDeliveryDaysChanged);
    on<DeliveryPriceChanged>(_onDeliveryPriceChanged);
    on<DeliveryPriceEnabledChanged>(_onDeliberyPriceEnabledChanged);
    on<UploadProductEvent>(_onUploadProduct);
    on<ResetProductEvent>((event, emit) {
      emit(
        ProductState(
          product: ProductModel(
            name: "",
            shortDescription: "",
            pricePerUnit: "",
            priceType: "",
            deliveryPrice: "",
            deliveryPriceEnabled: false,
            minDeliveryDays: '',
            maxDeliveryDays: '',
            category: "null",
            minQty: "",
            imageUrl: '',
          ),
          imageFile: null,
          isUploading: false,
          errorMessage: null,
          isSuccess: false,
        ),
      );
    });
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<ProductState> emit,
  ) async {
    final picked = await _picker.pickImage(source: event.source);
    if (picked != null) {
      emit(
        state.copyWith(
          imageFile: File(picked.path),
          errorMessage: null,
          isSuccess: false,
        ),
      );
    }
  }

  Future<void> _onNameChanged(
    NameChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(
        product: state.product.copyWith(name: event.name),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(
        product: state.product.copyWith(shortDescription: event.description),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onminQtyChanged(
    QuantityChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(
        product: state.product.copyWith(minQty: event.quantity),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onPriceChanged(
    PriceChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(
      state.copyWith(
        product: state.product.copyWith(pricePerUnit: event.price),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onUploadProduct(
    UploadProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final product = state.product;

    if (product.name.isEmpty ||
        product.minQty.isEmpty ||
        product.shortDescription.isEmpty ||
        product.priceType.isEmpty ||
        product.maxDeliveryDays == 0 ||
        product.minDeliveryDays == 0 ||
        product.pricePerUnit.isEmpty) {
      emit(state.copyWith(errorMessage: "Please fill all fields"));
      return;
    }

    if (state.imageFile == null) {
      emit(state.copyWith(errorMessage: "Please select an image"));
      return;
    }

    if (event.categoryId.isEmpty) {
      emit(state.copyWith(errorMessage: "Please select a category"));
      return;
    }

    emit(
      state.copyWith(isUploading: true, errorMessage: null, isSuccess: false),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken') ?? '';

      var uri = Uri.parse('https://munchmartfoods.com/vendor/subcategory.php');
      var request = http.MultipartRequest('POST', uri);

      // Add Authorization header if token exists
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Note: MultipartRequest sets multipart/form-data content-type automatically
      log("Uploading product: ${product.maxDeliveryDays}");
      log("Uploading product: ${product.minDeliveryDays}");
      log("Uploading product: ${product.priceType}");
      // Convert all values from dynamic to String explicitly
      final Map<String, String> fields = <String, String>{
        'name': product.name,
        'description': product.shortDescription,
        'pricePerUnit': product.pricePerUnit,
        'category_id': event.categoryId,
        'quantity': product.minQty,
        'deliveryPriceEnabled': product.deliveryPriceEnabled.toString(),
        'deliveryPrice': product.deliveryPrice,
        "priceType": product.priceType,
        "minDeliveryDays": product.minDeliveryDays.toString(),
        "maxDeliveryDays": product.maxDeliveryDays.toString(),
      };

      // Add fields
      request.fields.addAll(fields);

      // Add image file as multipart file with field name 'image'
      request.files.add(
        await http.MultipartFile.fromPath('image', state.imageFile!.path),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      log("Response Status: ${respStr}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(respStr);
        emit(
          state.copyWith(
            isUploading: false,
            isSuccess: true,
            imageFile: null,
            product: ProductModel(
              name: '',
              shortDescription: '',
              pricePerUnit: '',
              deliveryPrice: '',
              deliveryPriceEnabled: false,
              category: '',
              minQty: '',
              imageUrl: '',
              priceType: "",
              minDeliveryDays: '',
              maxDeliveryDays: '',
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isUploading: false,
            errorMessage: "Failed: ${response.statusCode}",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isUploading: false,
          errorMessage: "Error: ${e.toString()}",
        ),
      );
    }
  }

  FutureOr<void> _onPriceTypeChanged(
    PriceTypeChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        product: state.product.copyWith(
          priceType: event.type,
        ), // correct field updated
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onMaxDeliveryDaysChanged(
    MaxDeliveryDaysChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        product: state.product.copyWith(
          maxDeliveryDays: event.maxDeliveryDays,
        ), // correct field
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onMinDeliveryDaysChanged(
    MinDeliveryDaysChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        product: state.product.copyWith(
          minDeliveryDays: event.minDeliveryDays,
        ), // correct field
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onDeliveryPriceChanged(
    DeliveryPriceChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        product: state.product.copyWith(
          deliveryPrice: event.deliveryPrice,
        ), // correct field
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onDeliberyPriceEnabledChanged(
    DeliveryPriceEnabledChanged event,
    Emitter<ProductState> emit,
  ) {
    emit(
      state.copyWith(
        product: state.product.copyWith(
          deliveryPriceEnabled: event.deliveryPriceEnabled,
        ), // correct field
        errorMessage: null,
      ),
    );
  }
}
