import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_dropdown.dart';
import 'package:qr_buddy/app/core/widgets/custom_textfield.dart';
import 'package:qr_buddy/app/modules/new_ticket/components/custom_choice_chip.dart';
import 'package:qr_buddy/app/modules/new_ticket/controllers/new_ticket_controller.dart';

class NewETicketScreen extends StatelessWidget {
  const NewETicketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewETicketController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackgroundColor,
        elevation: 0,
        title: const Text('New eTicket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomDropdownField(
                    label: 'Room',
                    value: controller.room.value,
                    items: controller.roomOptions,
                    onChanged: controller.updateRoom,
                    validator: controller.validateField,
                  ),
                  CustomDropdownField(
                    label: 'Services',
                    value: controller.services.value,
                    items: controller.serviceOptions,
                    onChanged: controller.updateServices,
                    validator: controller.validateField,
                  ),
                  CustomTextField(
                    label: "Complainant's Name",
                    hintText: "[Optional]",
                    onChanged: controller.updateComplainantName,
                    initialValue: controller.complainantName.value,
                  ),
                  CustomTextField(
                    label: "Complainant's Phone Number",
                    hintText: "[Optional]",
                    onChanged: controller.updateComplainantPhone,
                    initialValue: controller.complainantPhone.value,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomChoiceChip(
                          label: 'Request',
                          selected: controller.ticketType.value == 'Request',
                          onSelected: () => controller.updateTicketType('Request'),
                        ),
                        CustomChoiceChip(
                          label: 'Complaint',
                          selected: controller.ticketType.value == 'Complaint',
                          onSelected: () => controller.updateTicketType('Complaint'),
                        ),
                        CustomChoiceChip(
                          label: 'Incident',
                          selected: controller.ticketType.value == 'Incident',
                          onSelected: () => controller.updateTicketType('Incident'),
                        ),
                      ],
                    ),
                  ),
                  CustomDropdownField(
                    label: 'Priority',
                    value: controller.priority.value,
                    items: controller.priorityOptions,
                    onChanged: controller.updatePriority,
                    validator: controller.validateField,
                  ),
                  CustomTextField(
                    label: 'Remarks',
                    hintText: "[Optional]",
                    onChanged: controller.updateRemarks,
                    initialValue: controller.remarks.value,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: controller.pickImages,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_a_photo, size: 40, color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (controller.selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.selectedImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(controller.selectedImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => controller.removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                       
                        text: 'Back',
                        onPressed: () => Get.back(),
                      ),
                      CustomButton(
                        
                        text: 'Submit',
                        onPressed: controller.submit,
                      ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}