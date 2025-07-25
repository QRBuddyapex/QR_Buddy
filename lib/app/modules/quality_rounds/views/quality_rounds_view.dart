// quality_rounds_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_textfield.dart';
import 'package:qr_buddy/app/data/models/management_form_model.dart';
import 'package:qr_buddy/app/modules/quality_rounds/components/emoji_fields.dart';

import '../controllers/quality_rounds_controller.dart';

class QualityRoundsView extends GetView<QualityRoundsController> {
  const QualityRoundsView({super.key});

  Widget _buildFormField(Parameter param, QualityRoundsController controller) {
    switch (param.dataEntryType) {
      case 'NUM':
        return _buildNumberField(param, controller);
      case 'SLT':
        return _buildSingleLineTextField(param, controller);
      case 'MLT':
        return _buildMultipleLineTextField(param, controller);
      case 'SEL':
        return _buildSelectField(param, controller);
      case 'CHK':
        return _buildCheckboxField(param, controller);
      case 'MCHK':
        return _buildMultipleCheckboxField(param, controller);
      case 'RAD':
        return _buildRadioField(param, controller);
      case 'STR':
        return _buildStarField(param, controller);
      case 'YN':
        return _buildYesNoField(param, controller);
      case 'EMJ':
        return _buildEmojiField(param, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNumberField(Parameter param, QualityRoundsController controller) {
    return CustomTextField(
      label: param.parameterName ?? param.parameterName,
      hintText: 'Enter ${param.parameterName}',
      onChanged: (value) => controller.updateFormData(param.parameterName!, value),
      initialValue: controller.formData[param.parameterName!] as String?,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSingleLineTextField(Parameter param, QualityRoundsController controller) {
    return CustomTextField(
      label: param.parameterName ?? param.parameterName,
      hintText: 'Enter ${param.parameterName}',
      onChanged: (value) => controller.updateFormData(param.parameterName!, value),
      initialValue: controller.formData[param.parameterName!] as String?,
    );
  }

  Widget _buildMultipleLineTextField(Parameter param, QualityRoundsController controller) {
    return CustomTextField(
      label: param.parameterName ?? param.parameterName,
      hintText: 'Enter ${param.parameterName}',
      onChanged: (value) => controller.updateFormData(param.parameterName!, value),
      initialValue: controller.formData[param.parameterName!] as String?,
      maxLines: 3,
    );
  }

  Widget _buildSelectField(Parameter param, QualityRoundsController controller) {
    final choices = param.choices.isNotEmpty
        ? param.choices.map((e) => e.toString()).toList()
        : ['Option 1', 'Option 2', 'Option 3'];
    final currentValue = controller.formData[param.parameterName!] as String? ?? choices.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            param.parameterName ?? param.parameterName ?? '',
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
          DropdownButtonFormField<String>(
            value: choices.contains(currentValue) ? currentValue : null,
            hint: const Text('Select an option'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
            ),
            items: choices.map<DropdownMenuItem<String>>((choice) => DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                )).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.updateFormData(param.parameterName!, value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxField(Parameter param, QualityRoundsController controller) {
    final currentValue = controller.formData[param.parameterName!] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: currentValue,
            onChanged: (value) {
              if (value != null) {
                controller.updateFormData(param.parameterName!, value);
              }
            },
            activeColor: AppColors.primaryColor,
          ),
          Text(
            param.parameterName ?? param.parameterName ?? '',
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleCheckboxField(Parameter param, QualityRoundsController controller) {
    final choices = param.choices.isNotEmpty ? param.choices : ['Option 1', 'Option 2', 'Option 3'];
    final currentValues = (controller.formData[param.parameterName!] as List<dynamic>?)?.cast<String>() ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: choices.map((choice) {
          final isSelected = currentValues.contains(choice);
          return Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  if (value != null) {
                    final updatedValues = List<String>.from(currentValues);
                    if (value) {
                      updatedValues.add(choice);
                    } else {
                      updatedValues.remove(choice);
                    }
                    controller.updateFormData(param.parameterName!, updatedValues);
                  }
                },
                activeColor: AppColors.primaryColor,
              ),
              Text(choice, style: Theme.of(Get.context!).textTheme.bodyMedium),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadioField(Parameter param, QualityRoundsController controller) {
    final choices = param.choices.isNotEmpty ? param.choices : ['Option 1', 'Option 2', 'Option 3'];
    final currentValue = controller.formData[param.parameterName!] as String? ?? choices.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: choices.map((choice) {
          return Row(
            children: [
              Radio<String>(
                value: choice,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) {
                    controller.updateFormData(param.parameterName!, value);
                  }
                },
                activeColor: AppColors.primaryColor,
              ),
              Text(choice, style: Theme.of(Get.context!).textTheme.bodyMedium),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStarField(Parameter param, QualityRoundsController controller) {
    final currentValue = int.tryParse(controller.formData[param.parameterName!] as String? ?? '0') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            param.parameterName ?? param.parameterName ?? '',
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) => GestureDetector(
              onTap: () {
                controller.updateFormData(param.parameterName!, (index + 1).toString());
              },
              child: Icon(
                index < currentValue ? Icons.star : Icons.star_border,
                color: AppColors.primaryColor,
                size: 50,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoField(Parameter param, QualityRoundsController controller) {
    final currentValue = controller.formData[param.parameterName!] as String? ?? 'false';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            param.parameterName ?? param.parameterName ?? '',
            style: Theme.of(Get.context!).textTheme.bodyMedium,
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Yes'),
                  value: true,
                  groupValue: currentValue == 'true',
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateFormData(param.parameterName!, value.toString());
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('No'),
                  value: false,
                  groupValue: currentValue == 'false',
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateFormData(param.parameterName!, value.toString());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiField(Parameter param, QualityRoundsController controller) {
    final currentValue = controller.formData[param.parameterName!] as String?;
    return EmojiSelectorField(
      label: param.parameterName ?? param.parameterName ?? '',
      initialValue: currentValue,
      onChanged: (value) {
        controller.updateFormData(param.parameterName!, value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Rounds'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        if (controller.formModel.value == null) {
          return const Center(child: Text('No form data available'));
        }

    
        double totalRating = 0.0;
        int ratingCount = 0;
        for (var param in controller.formModel.value!.parameters) {
          if (param.dataEntryType == 'EMJ' || param.dataEntryType == 'STR') {
            final value = int.tryParse(controller.formData[param.parameterName!] as String? ?? '0') ?? 0;
            if (value > 0 && value <= 5) {
              totalRating += value;
              ratingCount++;
            }
          }
        }
        final averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.formModel.value!.category?.categoryName ?? 'Form',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                ...controller.formModel.value!.parameters
                    .map((param) => _buildFormField(param, controller))
                    .toList(),
                const SizedBox(height: 16),
                // Display average rating
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 80,
                    width: 300,
                    child: Text(
                      textAlign: TextAlign.center,
                      'Average Rating: ${averageRating.toStringAsFixed(1)}/5',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: controller.isSubmitting.value ? 'Submitting...' : 'Submit',
                  onPressed: () async {
                    await controller.onSubmit(averageRating as int);
                  },
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}