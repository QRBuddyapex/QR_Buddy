
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_date_field.dart';
import 'package:qr_buddy/app/modules/e_ticket/components/ticket_card.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/ticket_controller.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class InfoCardContentWidget extends StatelessWidget {
  const InfoCardContentWidget({Key? key}) : super(key: key);

  Widget _buildGroupHeader({
    required BuildContext context,
    required String groupName,
    required VoidCallback onRefresh,
    required Size size,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
        horizontal: size.width * 0.04,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            groupName,
            style: textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodDeliveryCard({
    required BuildContext context,
    required Map<String, dynamic> delivery,
    required int index,
    required Size size,
    required TextTheme textTheme,
  }) {
    final roomUuid = delivery['room_uuid']?.toString().trim();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.004,
        vertical: size.height * 0.01,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderColor
                : AppColors.shadowColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    SizedBox(width: size.width * 0.02),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Room: ${delivery['room_number']}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextColor
                                  : AppColors.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.03,
                            ),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            "Category: ${delivery['category_name']}",
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkSubtitleColor
                                  : AppColors.hintTextColor,
                              fontSize: size.width * 0.035,
                            ),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final scannedUuid = await Get.toNamed(
                    RoutesName.qrScanForFoodDelivery,
                    arguments: {'room_uuid': roomUuid},
                  );

                  if (scannedUuid != null && scannedUuid == roomUuid) {
                    Get.toNamed(
                      RoutesName.qualityRoundsScreen,
                      arguments: {
                        'room_uuid': roomUuid,
                        'category_uuid': delivery['category_uuid'],
                      },
                    );
                  } else if (scannedUuid != null) {
                    Get.snackbar(
                      'Error',
                      'Scanned QR code does not match the room UUID',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                  }
                },
                child: Icon(
                  Icons.qr_code,
                  color: Colors.white,
                  size: size.width * 0.06,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistCard({
    required BuildContext context,
    required Map<String, dynamic> checklist,
    required int index,
    required Size size,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderColor
                : AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.015),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Checklist $index",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        checklist['checklist_name'],
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.dangerButtonColor,
                      size: size.width * 0.06,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      "Location: ${checklist['location']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSubtitleColor
                            : AppColors.hintTextColor,
                        fontSize: size.width * 0.035,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: size.width * 0.05,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      "Date & Time: ${checklist['date_and_time']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSubtitleColor
                            : AppColors.hintTextColor,
                        fontSize: size.width * 0.035,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required String label,
    required Size size,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.add,
            color: Colors.green,
            size: size.width * 0.06,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.green,
              fontSize: size.width * 0.04,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogItem({
    required String location,
    required String block,
    required List<String> times,
    required TextTheme textTheme,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
            ),
          ),
          Text(
            block,
            style: textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? AppColors.darkSubtitleColor : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: times
                .map((time) => Chip(
                      label: Text(
                        time,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.pink.shade700,
                        ),
                      ),
                      backgroundColor: Colors.pink.shade50,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  DateTime _parseShortDate(String dateStr) {
    final parts = dateStr.trim().split(' ');
    if (parts.length != 2) {
      return DateTime.now();
    }

    final day = int.tryParse(parts[0]) ?? 1;
    const monthMap = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final month = monthMap[parts[1]] ?? 1;
    return DateTime(2025, month, day);
  }

  String _formatShortDate(String dateStr) {
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<TicketController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.selectedInfoCard.value == '') {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredTickets.length,
          itemBuilder: (context, index) {
            final ticket = controller.filteredTickets[index];
            return TicketCard(
              index: index,
              orderNumber: ticket.orderNumber,
              description: ticket.description,
              block: ticket.block,
              status: ticket.status,
              date: ticket.date,
              department: ticket.department,
              phoneNumber: ticket.phoneNumber,
              assignedTo: ticket.assignedTo,
              serviceLabel: ticket.serviceLabel,
              isQuickRequest: ticket.isQuickRequest ?? false,
              onTap: () => controller.navigateToDetail(ticket),
            );
          },
        );
      } else if (controller.selectedInfoCard.value == 'Food Delivery') {
        if (controller.tasksCount == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no_order.png',
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: controller.tasks.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupHeader(
                  context: context,
                  groupName: group['group'],
                  onRefresh: () => controller.fetchFoodDeliveries(),
                  size: size,
                  textTheme: textTheme,
                ),
                ...group['tasks'].asMap().entries.map((entry) {
                  return _buildFoodDeliveryCard(
                    context: context,
                    delivery: entry.value,
                    index: entry.key + 1,
                    size: size,
                    textTheme: textTheme,
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      } else if (controller.selectedInfoCard.value == 'Checklists') {
          if (controller.logEntriesCount == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no_order.png',
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checklists Section
            ...controller.checklists.map((group) {
              final checklistWidgets = group['checklists'].asMap().entries.map<Widget>((entry) {
                return _buildChecklistCard(
                  context: context,
                  checklist: entry.value,
                  index: entry.key + 1,
                  size: size,
                  textTheme: textTheme,
                );
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGroupHeader(
                    context: context,
                    groupName: group['group'],
                    onRefresh: () => controller.fetchChecklistLog(),
                    size: size,
                    textTheme: textTheme,
                  ),
                  if (checklistWidgets.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.01,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'No checklists available for the selected date range',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                          ),
                        ),
                      ),
                    )
                  else
                    ...checklistWidgets,
                  _buildAddButton(
                    context: context,
                    label: 'Add Checklist',
                    size: size,
                  ),
                ],
              );
            }).toList(),
            // Filters Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
                horizontal: size.width * 0.04,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                      border: Border.all(
                        color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Obx(() {
                        final categories = controller.dailyChecklist.value?.categories ?? [];
                        const noCategoryOption = 'No Category';

                        final dropdownItems = [
                          DropdownMenuItem<String>(
                            value: noCategoryOption,
                            child: Text(
                              noCategoryOption,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              ),
                            ),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.categoryName,
                              child: Text(
                                category.categoryName,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ];

                        String defaultValue;
                        if (categories.isEmpty) {
                          defaultValue = noCategoryOption;
                        } else if (controller.selectedCategory.value.isNotEmpty &&
                            (controller.selectedCategory.value == noCategoryOption ||
                                categories.any((cat) => cat.categoryName == controller.selectedCategory.value))) {
                          defaultValue = controller.selectedCategory.value;
                        } else {
                          defaultValue = noCategoryOption;
                        }

                        return DropdownButton<String>(
                          value: defaultValue,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: isDarkMode ? AppColors.darkIconColor : AppColors.iconColor,
                          ),
                          iconSize: 24,
                          elevation: 0,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                          ),
                          hint: Text(
                            'Loading categories...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                            ),
                          ),
                          items: dropdownItems,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              controller.selectedCategory.value = newValue;
                              controller.fetchChecklistLog();
                            }
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomDateField(
                              initialDate: controller.startDate.value,
                              onDateSelected: (date) {
                                controller.startDate.value = date;
                              },
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Text(
                                  'Selected: ${controller.formatDateForDisplay(controller.startDate.value)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                    fontSize: 14,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomDateField(
                              initialDate: controller.endDate.value,
                              onDateSelected: (date) {
                                controller.endDate.value = date;
                              },
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Text(
                                  'Selected: ${controller.formatDateForDisplay(controller.endDate.value)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                    fontSize: 14,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.fetchChecklistLog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Filter',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Log Section
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.01,
                horizontal: size.width * 0.04,
              ),
              child: Text(
                'Log',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.dailyChecklist.value == null ||
                  controller.dailyChecklist.value!.roundData.isEmpty ||
                  controller.dailyChecklist.value!.rooms.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'No log data available',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                    ),
                  ),
                );
              }

              final roundData = controller.dailyChecklist.value!.roundData;
              final rooms = controller.dailyChecklist.value!.rooms;
              final allDates = <String>{};

              roundData.forEach((roomId, dateMap) {
                dateMap.keys.forEach((date) {
                  allDates.add(date);
                });
              });

              final sortedDates = allDates.toList()
                ..sort((a, b) {
                  try {
                    final dateA = _parseShortDate(a);
                    final dateB = _parseShortDate(b);
                    return dateA.compareTo(dateB);
                  } catch (e) {
                    return a.compareTo(b);
                  }
                });

              if (sortedDates.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                        spreadRadius: 1,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'No log data available',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                    ),
                  ),
                );
              }

              final today = DateTime.now();
              String mostRecentDate = sortedDates.first;
              Duration minDifference = today.difference(_parseShortDate(sortedDates.first)).abs();

              for (final date in sortedDates) {
                final parsedDate = _parseShortDate(date);
                final difference = today.difference(parsedDate).abs();
                if (difference < minDifference) {
                  minDifference = difference;
                  mostRecentDate = date;
                }
              }

              final selectedDate = mostRecentDate.obs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sortedDates.map((date) {
                          return Obx(() => GestureDetector(
                                onTap: () {
                                  selectedDate.value = date;
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedDate.value == date
                                        ? Colors.blue.shade50
                                        : (isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _formatShortDate(date),
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: selectedDate.value == date
                                          ? Colors.blue
                                          : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor),
                                    ),
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    final logEntries = <Widget>[];
                    roundData.forEach((roomId, dateMap) {
                      if (dateMap.containsKey(selectedDate.value)) {
                        final room = rooms[roomId];
                        final rounds = dateMap[selectedDate.value]!;
                        logEntries.add(_buildLogItem(
                          location: room?.roomNumber?.toString() ?? 'Unknown',
                          block: '${room?.blockName?.toString() ?? 'Unknown'} - ${room?.floorName?.toString() ?? 'Unknown'}',
                          times: rounds.map((round) => round.timeSchedule?.toString() ?? '').toList(),
                          textTheme: textTheme,
                          isDarkMode: isDarkMode,
                        ));
                      }
                    });

                    if (logEntries.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          'No log entries for this date',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: logEntries,
                    );
                  }),
                ],
              );
            }),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }
}
