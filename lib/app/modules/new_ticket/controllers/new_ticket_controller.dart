import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NewETicketController extends GetxController {
  var room = ''.obs;
  var services = ''.obs;
  var complainantName = ''.obs;
  var complainantPhone = ''.obs;
  var priority = 'Normal'.obs;
  var remarks = ''.obs;
  var ticketType = Rx<String?>(null);
  var selectedImages = <XFile>[].obs;

  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final List<String> roomOptions = ['Room 101', 'Room 102', 'Room 103', 'Room 104'];
  final List<String> serviceOptions = ['Cleaning', 'Maintenance', 'Plumbing', 'Electrical'];
  final List<String> priorityOptions = ['Low', 'Normal', 'High', 'Urgent'];

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

  void submit() {
    if (formKey.currentState!.validate()) {
      print({
        'room': room.value,
        'services': services.value,
        'complainantName': complainantName.value,
        'complainantPhone': complainantPhone.value,
        'ticketType': ticketType.value,
        'priority': priority.value,
        'remarks': remarks.value,
        'imageCount': selectedImages.length,
      });
    }
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }
}