import 'dart:async';
import 'dart:convert';
import 'dart:developer' show log;
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_event.dart';
import 'package:yumquick/view/addmealbox/bloc/addmealbox_state.dart';

class MealBoxBloc extends Bloc<MealBoxEvent, MealBoxState> {
  MealBoxBloc() : super(MealBoxState()) {
    on<ResetMealBoxEvent>(_onReset);
    // on<LoadCategoriesEvent>(_onLoadCategories);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<MinQtyChanged>(_onMinQtyChanged);
    on<PriceChanged>(_onPriceChanged);
    on<MinmumDayToPrepare>(_onMinmumDayToPrepareChanged);
    on<MaximumDayToPrepare>(_onMaxmumDayToPrepareChanged);
    on<SampleAvailableChanged>(_onSampleAvailableChanged);
    on<ItemsChanged>(_onItemsChanged);
    on<PackagingDetailsChanged>(_onPackagingDetailsChanged);
    // on<CategoryChanged>(_onCategoryChanged);
    on<PickBoxImageEvent>(_onPickBoxImage);
    on<PickActualImageEvent>(_onPickActualImage);
    on<UploadMealBoxEvent>(_onUploadMealBox);
    on<UpdateMealBoxEvent>(_onUpdateMealBox);
    on<PreloadBoxImageEvent>((event, emit) {
      emit(state.copyWith(boxImageUrl: event.imageUrl));
    });

    on<PreloadActualImageEvent>((event, emit) {
      emit(state.copyWith(actualImageUrl: event.imageUrl));
    });
  }

  Future<void> _onReset(
    ResetMealBoxEvent event,
    Emitter<MealBoxState> emit,
  ) async {
    emit(MealBoxState());
  }

  void _onTitleChanged(TitleChanged event, Emitter<MealBoxState> emit) {
    emit(state.copyWith(title: event.title, errorMessage: null));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<MealBoxState> emit,
  ) {
    emit(state.copyWith(description: event.description, errorMessage: null));
  }

  void _onMinQtyChanged(MinQtyChanged event, Emitter<MealBoxState> emit) {
    emit(state.copyWith(minQty: event.minQty, errorMessage: null));
  }

  void _onPriceChanged(PriceChanged event, Emitter<MealBoxState> emit) {
    emit(state.copyWith(price: event.price, errorMessage: null));
  }

  // void _onDeliveryDateChanged(
  //   DeliveryDateChanged event,
  //   Emitter<MealBoxState> emit,
  // ) {
  //   emit(
  //     state.copyWith(
  //       prepareOrderDays: event.prepareOrderDays.toString(),
  //       errorMessage: null,
  //     ),
  //   );
  // }

  void _onSampleAvailableChanged(
    SampleAvailableChanged event,
    Emitter<MealBoxState> emit,
  ) {
    emit(
      state.copyWith(
        sampleAvailable: event.sampleAvailable,
        errorMessage: null,
      ),
    );
  }

  void _onItemsChanged(ItemsChanged event, Emitter<MealBoxState> emit) {
    emit(state.copyWith(items: event.items, errorMessage: null));
  }

  void _onPackagingDetailsChanged(
    PackagingDetailsChanged event,
    Emitter<MealBoxState> emit,
  ) {
    emit(
      state.copyWith(
        packagingDetails: event.packagingDetails,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onPickBoxImage(
    PickBoxImageEvent event,
    Emitter<MealBoxState> emit,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: event.source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        emit(
          state.copyWith(
            boxImageFile: File(pickedFile.path),
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick box image'));
    }
  }

  Future<void> _onPickActualImage(
    PickActualImageEvent event,
    Emitter<MealBoxState> emit,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: event.source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        emit(
          state.copyWith(
            actualImageFile: File(pickedFile.path),
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick actual image'));
    }
  }

  Future<void> _onUploadMealBox(
    UploadMealBoxEvent event,
    Emitter<MealBoxState> emit,
  ) async {
    emit(
      state.copyWith(isUploading: true, errorMessage: null, isSuccess: false),
    );
    log(state.title);
    log(state.description);
    log(state.minQty);
    log(state.price);
    log(state.minPrepareOrderDays.toString());
    log(state.maxPrepareOrderDays.toString());
    log(state.sampleAvailable.toString());
    log(state.packagingDetails);
    // log(state.boxImageUrl!);
    // log(state.actualImageUrl!);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception('No auth token found');

      Uri uri = Uri.parse('https://mm-food-backend.onrender.com/api/mealbox');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = state.title;
      request.fields['description'] = state.description;
      request.fields['minQty'] = state.minQty;
      request.fields['price'] = state.price;
      request.fields['minPrepareOrderDays'] = state.minPrepareOrderDays
          .toString();
      request.fields['maxPrepareOrderDays'] = state.maxPrepareOrderDays
          .toString();
      request.fields['sampleAvailable'] = state.sampleAvailable.toString();
      request.fields['packagingDetails'] = state.packagingDetails;
      request.fields['category'] = state.selectedCategoryId ?? '';
      // Pass items string directly as JSON string
      request.fields['items'] = state.items.isNotEmpty
          ? state.items
          : jsonEncode([]);

      if (state.boxImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'boxImage',
            state.boxImageFile!.path,
          ),
        );
      }

      if (state.actualImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'actualImage',
            state.actualImageFile!.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(state.copyWith(isUploading: false, isSuccess: true));
      } else {
        final respStr = await response.stream.bytesToString();
        log(respStr);
        emit(
          state.copyWith(
            isUploading: false,
            errorMessage:
                'Failed to upload mealbox. Status: ${response.statusCode}, $respStr',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isUploading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateMealBox(
    UpdateMealBoxEvent event,
    Emitter<MealBoxState> emit,
  ) async {
    log("Updating mealbox with ID: ${event.mealBoxId}");
    emit(
      state.copyWith(isUploading: true, errorMessage: null, isSuccess: false),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) throw Exception('No auth token found');

      final uri = Uri.parse(
        'https://mm-food-backend.onrender.com/api/mealbox/${event.mealBoxId}',
      );
      final request = http.MultipartRequest('PUT', uri);

      // Set headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['title'] = state.title;
      request.fields['description'] = state.description;
      request.fields['minQty'] = state.minQty;
      request.fields['price'] = state.price;
      request.fields['minPrepareOrderDays'] = state.minPrepareOrderDays
          .toString();
      request.fields['maxPrepareOrderDays'] = state.maxPrepareOrderDays
          .toString();
      request.fields['sampleAvailable'] = state.sampleAvailable.toString();
      request.fields['packagingDetails'] = state.packagingDetails;
      request.fields['category'] = state.selectedCategoryId ?? '';

      // Add items as JSON string or empty array if none
      request.fields['items'] = state.items.isNotEmpty
          ? state.items
          : jsonEncode([]);

      // Attach box image file if available
      if (state.boxImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'boxImage',
            state.boxImageFile!.path,
          ),
        );
      }

      // Attach actual image file if available
      if (state.actualImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'actualImage',
            state.actualImageFile!.path,
          ),
        );
      }

      // Debug prints
      print('Sending PUT request to: $uri');
      print('Fields: ${request.fields}');
      print('Files attached: ${request.files.length}');

      final response = await request.send();

      final respStr = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $respStr');

      if (response.statusCode == 200) {
        emit(state.copyWith(isUploading: false, isSuccess: true));
      } else {
        emit(
          state.copyWith(
            isUploading: false,
            errorMessage:
                'Failed to update mealbox. Status: ${response.statusCode}, $respStr',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isUploading: false,
          errorMessage: 'Update error: ${e.toString()}',
        ),
      );
    }
  }

  void _onMinmumDayToPrepareChanged(
    MinmumDayToPrepare event,
    Emitter<MealBoxState> emit,
  ) {
    emit(
      state.copyWith(
        minPrepareOrderDays: event.minPrepareOrderDays.toString(),
        errorMessage: null,
      ),
    );
  }

  void _onMaxmumDayToPrepareChanged(
    MaximumDayToPrepare event,
    Emitter<MealBoxState> emit,
  ) {
    emit(
      state.copyWith(
        maxPrepareOrderDays: event.maxPrepareOrderDays.toString(),
        errorMessage: null,
      ),
    );
  }
}
