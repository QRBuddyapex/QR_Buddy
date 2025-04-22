import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewETicketController extends GetxController {
  var room = ''.obs;
  var services = ''.obs;
  var complainantName = ''.obs;
  var complainantPhone = ''.obs;
  var priority = 'Normal'.obs;
  var remarks = ''.obs;
  var ticketType = Rx<String?>(null);

  final formKey = GlobalKey<FormState>();

  // Dummy dropdown values
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

  void submit() {
    if (formKey.currentState!.validate()) {
      // Handle submission logic
      print({
        'room': room.value,
        'services': services.value,
        'complainantName': complainantName.value,
        'complainantPhone': complainantPhone.value,
        'ticketType': ticketType.value,
        'priority': priority.value,
        'remarks': remarks.value,
      });
    }
  }

  String? validateField(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }
}