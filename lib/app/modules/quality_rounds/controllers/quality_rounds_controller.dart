import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/data/models/management_form_model.dart';
import 'package:qr_buddy/app/data/repo/quality_rounds_repo.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class QualityRoundsController extends GetxController {
  final QualityRoundsRepository _repo = QualityRoundsRepository();
  final Rx<ManagementFormModel?> formModel = Rx<ManagementFormModel?>(null);
  final RxMap<String, dynamic> formData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxString roomUuid = ''.obs;
  final RxString categoryUuid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get room_uuid and category_uuid from route arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      if (arguments.containsKey('room_uuid')) {
        roomUuid.value = arguments['room_uuid'];
      }
      if (arguments.containsKey('category_uuid')) {
        categoryUuid.value = arguments['category_uuid'];
      }
    }
    fetchFormData();
  }

  Future<void> fetchFormData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId = await TokenStorage().getUserId() ?? '2053';
      final hcoId = await TokenStorage().getHcoId() ?? '46';
      final form = await _repo.fetchParameters(
        categoryUuid: categoryUuid.value.isNotEmpty
            ? categoryUuid.value
            : 'e1643e28404611ef99170200d429951a', 
        userId: userId,
        hcoId: hcoId,
      );
      formModel.value = form;

      formData.value = {
        for (var param in form.parameters)
          param.parameterName!: param.valueString!.isNotEmpty
              ? param.valueString
              : (param.valueInt != null ? param.valueInt.toString() : param.valueDefault ?? ''),
      };
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to fetch form data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateFormData(String key, dynamic value) {
    formData[key] = value;
  }

  Future<void> onSubmit(double averageRating) async {
    if (formModel.value == null || roomUuid.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Form data or room UUID is missing',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final userId = await TokenStorage().getUserId() ?? '2053';
      final hcoId = await TokenStorage().getHcoId() ?? '46';
      await _repo.saveFormData(
        categoryUuid: categoryUuid.value.isNotEmpty
            ? categoryUuid.value
            : 'e1643e28404611ef99170200d429951a', // Fallback to default
        userId: userId,
        hcoId: hcoId,
        roomUuid: roomUuid.value,
        parameters: formData,
        formParameters: formModel.value!.parameters,
        averageRating: averageRating.toString(),
      );
      Get.snackbar(
        'Success',
        'Form submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.offAndToNamed(RoutesName.ticketDashboardView);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit form: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}