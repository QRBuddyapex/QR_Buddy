import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/services/api_service.dart';
import 'package:qr_buddy/app/data/models/new_e_ticket_response.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class NewETicketController extends GetxController {
  var room = ''.obs;
  var services = ''.obs;
  var complainantName = ''.obs;
  var complainantPhone = ''.obs;
  var priority = 'Normal'.obs;
  var ticketType = Rx<String?>(null);
  var remarks = ''.obs;
  var selectedImages = <XFile>[].obs;
  var isLoading = false.obs;

  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage();

  var roomOptions = <String>[].obs;
  var serviceOptions = <String>[].obs;
  final List<String> priorityOptions = ['Low', 'Normal', 'High', 'Critical'];
  NewETicketResponseModel? formResponse;

  @override
  void onInit() {
    super.onInit();
    fetchFormData();
  }
Future<void> fetchFormData() async {
  try {
    isLoading.value = true;

    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();

    if (userId == null || hcoId == null) {
      Get.snackbar('Error', 'Authentication data missing',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final payload = {
      'user_id': userId,
      'hco_id': hcoId,
    };

    final response = await _apiService.post(
      '/mobile.html?action=fetch_form&user_id=$userId&hco_id=$hcoId',
      data: payload,
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // rooms
      final roomsList = (data['rooms'] as List)
          .map((r) => r['room_number'].toString())
          .toList();

      // services
      final servicesList = (data['services'] as List)
          .map((s) => s['service_name'].toString())
          .toList();

      roomOptions.value = roomsList;
      serviceOptions.value = servicesList;
    } else {
      Get.snackbar('Error', 'Failed to fetch data',
          snackPosition: SnackPosition.BOTTOM);
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to fetch data: $e',
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}

  void updateRoom(String? value) => room.value = value ?? '';
  void updateServices(String? value) => services.value = value ?? '';
  void updateComplainantName(String value) => complainantName.value = value;
  void updateComplainantPhone(String value) => complainantPhone.value = value;
  void updatePriority(String? value) => priority.value = value ?? 'Normal';
  void updateRemarks(String value) => remarks.value = value;
  void updateTicketType(String? value) => ticketType.value = value;

  Future<void> pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }
Future<void> submit() async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  // Additional validation for room and services
  if (room.value.isEmpty || services.value.isEmpty) {
    Get.snackbar('Error', 'Please select a valid room and service',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  try {
    isLoading.value = true;

    final userId = await _tokenStorage.getUserId();
    final hcoId = await _tokenStorage.getHcoId();

    if (userId == null || hcoId == null || formResponse == null) {
      Get.snackbar('Error', 'Authentication data or form data missing',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Find room_uuid and service_id
    final selectedRoom = formResponse!.rooms.firstWhereOrNull(
      (r) => r.roomNumber == room.value, // Use room.value
    );
    final selectedService = formResponse!.services.firstWhereOrNull(
      (service) => service.serviceName == services.value, // Use services.value
    );

    if (selectedRoom == null || selectedService == null) {
      Get.snackbar('Error', 'Please select a valid room and service',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Normalize priority to match API (e.g., "Low" -> "LOW")
    final normalizedPriority = priority.value.toUpperCase().substring(0, 3); // Convert to "LOW", "NOR", "HIG", "CRI"

    // Construct parameters as an object to match the provided payload
    final parameters = {
      'priority': normalizedPriority,
      'map_long': 'undefined',
      'map_lat': 'undefined',
      'map_distance': 'undefined',
    };

    // Construct form data
    final formData = dio.FormData.fromMap({
      'file_count': "0",
      'user_id': userId,
      'room_uuid': selectedRoom.uuid,
      'stock_uuid': 'undefined',
      'stock_down': 'undefined',
      'service_id': selectedService.id,
      'parameter_category_id': '0',
      'parameters': parameters, 
      'source': 'WEB',
      'request_type': ticketType.value ?? 'SER',
      'addons[phone_number]': complainantPhone.value.isEmpty ? 'test' : complainantPhone.value,
      'addons[full_name]': complainantName.value.isEmpty ? 'test' : complainantName.value,
      'addons[notes]': remarks.value.isEmpty ? 'test' : remarks.value,
    });

    // Add image files
    for (var i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      formData.files.add(MapEntry(
        'file$i',
        await dio.MultipartFile.fromFile(file.path, filename: file.name),
      ));
    }

    // Make API call
    final response = await _apiService.post(
      '/ticket/ticket.html?action=save&user_id=$userId&hco_id=$hcoId',
      data: formData,
    );

    if (response.statusCode == 200 && response.data['status'] == 1) {
      Get.snackbar('Success', 'Ticket saved successfully',
          snackPosition: SnackPosition.BOTTOM);
      // Reset form
      room.value = '';
      services.value = '';
      complainantName.value = '';
      complainantPhone.value = '';
      priority.value = 'Normal';
      ticketType.value = null;
      remarks.value = '';
      selectedImages.clear();

      Get.toNamed(RoutesName.ticketDashboardView);
    } else {
      Get.snackbar('Error', 'Failed to save ticket: ${response.data['message']}',
          snackPosition: SnackPosition.BOTTOM);
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to save ticket: $e',
        snackPosition: SnackPosition.BOTTOM);
  } finally {
    isLoading.value = false;
  }
}
  String? validateField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  Future<void> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        selectedImages.add(photo);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}