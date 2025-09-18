import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/data/models/batch_response_model.dart';

import '../controllers/daily_checklist_controller.dart';
class ScheduleDialog extends StatefulWidget {
  final DailyChecklistController controller;

  const ScheduleDialog({Key? key, required this.controller}) : super(key: key);

  @override
  State<ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: isDarkMode ? AppColors.darkBackgroundColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 650),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Send Invitation for Checklist/Feedback',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? AppColors.darkIconColor : AppColors.iconColor,
                      ),
                      onPressed: () {
                        widget.controller.resetSelections();
                        Get.back();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Locations dropdown
                Obx(() => _buildMultiSelectField(
                      context: context,
                      label: 'Select Locations *',
                      isDarkMode: isDarkMode,
                      textTheme: textTheme,
                      items: widget.controller.batchResponse.value?.locations ?? [],
                      selectedItems: widget.controller.selectedLocations,
                      onSelectionChanged: (locations) => widget.controller.selectedLocations.value =
                          locations.cast<Location>().toSet(),
                      hintText: widget.controller.selectedLocations.isEmpty
                          ? 'Select one or more locations'
                          : widget.controller.selectedLocations.map((l) => l.roomNumber).join(', '),
                    )),
                const SizedBox(height: 16),

                // Users dropdown
                Obx(() => _buildMultiSelectField(
                      context: context,
                      label: 'Select Users *',
                      isDarkMode: isDarkMode,
                      textTheme: textTheme,
                      items: widget.controller.batchResponse.value?.users ?? [],
                      selectedItems: widget.controller.selectedUsers,
                      onSelectionChanged: (users) => widget.controller.selectedUsers.value =
                          users.cast<User>().toSet(),
                      hintText: widget.controller.selectedUsers.isEmpty
                          ? 'Select one or more users'
                          : widget.controller.selectedUsers.map((u) => u.username).join(', '),
                    )),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () {
                          widget.controller.resetSelections();
                          Get.back();
                        },
                        color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        width: double.infinity,

                        text: 'Send Invitation Now',
                        onPressed: widget.controller.sendInvitation,
                        color: AppColors.primaryColor,
                        
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required BuildContext context,
    required String label,
    required bool isDarkMode,
    required TextTheme textTheme,
    required List<dynamic> items,
    required RxSet<dynamic> selectedItems,
    required void Function(Set<dynamic>) onSelectionChanged,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _showMultiSelectDialog(
              context,
              items,
              selectedItems,
              onSelectionChanged,
              isDarkMode,
              textTheme,
            );
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.cardBackgroundColor : AppColors.linkColor,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? AppColors.darkCardBackgroundColor
                    : AppColors.cardBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
              ),
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

void _showMultiSelectDialog(
  BuildContext context,
  List<dynamic> items,
  RxSet<dynamic> selectedItems,
  void Function(Set<dynamic>) onSelectionChanged,
  bool isDarkMode,
  TextTheme textTheme,
) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500), // limit height
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Select Items',
                style: textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No items found'))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Obx(() => ListTile(
                              leading: Icon(
                                selectedItems.contains(item)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: selectedItems.contains(item)
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                              title: Text(
                                item is Location
                                    ? item.roomNumber.split(' / ').join('\n')
                                    : item.username.split('@').join('\n@'),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkTextColor
                                      : AppColors.textColor,
                                ),
                              ),
                              onTap: () {
                                if (selectedItems.contains(item)) {
                                  selectedItems.remove(item);
                                } else {
                                  selectedItems.add(item);
                                }
                              },
                            ));
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      selectedItems.clear();
                      Get.back();
                    },
                    child: Text(
                      'Clear All',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
