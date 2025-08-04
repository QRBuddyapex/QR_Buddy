
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/data/models/management_form_model.dart';
import 'package:qr_buddy/app/data/repo/quality_rounds_repo.dart';

class QualityRoundsController extends GetxController {
  final QualityRoundsRepository _repo = QualityRoundsRepository();
  final Rx<ManagementFormModel?> formModel = Rx<ManagementFormModel?>(null);
  final RxMap<String, dynamic> formData = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFormData();
  }

  Future<void> fetchFormData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final userId = await TokenStorage().getUserId() ?? '2053';
      final hcoId = await TokenStorage().getHcoId() ?? '46';
      final form = await _repo.fetchParameters(
        categoryUuid: 'e1643e28404611ef99170200d429951a',
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
    } finally {
      isLoading.value = false;
    }
  }

  void updateFormData(String key, dynamic value) {
    formData[key] = value;
  }

  Future<void> onSubmit(double averageRating) async {
    
    if (formModel.value == null) return;

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final userId = await TokenStorage().getUserId() ?? '2053';
      final hcoId = await TokenStorage().getHcoId() ?? '46';
      await _repo.saveFormData(
        categoryUuid: 'e1643e28404611ef99170200d429951a',
        userId: userId,
        hcoId: hcoId,
        parameters: formData,
        formParameters: formModel.value!.parameters,
        averageRating: averageRating.toString(),
      
      );
      Get.snackbar(
        'Success',
        'Form submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit form: $e',
        snackPosition: SnackPosition.BOTTOM,
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