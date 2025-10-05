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
    final hPadding = size.width * 0.04;
    final vPadding = size.height * 0.01;
    final fontSize = size.width * 0.05;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: vPadding,
        horizontal: hPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            groupName,
            style: textTheme.headlineSmall?.copyWith(
              color: isDarkMode
                  ? AppColors.darkTextColor
                  : AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
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
    final hPaddingSmall = size.width * 0.004;
    final vPadding = size.height * 0.01;
    final cardPadding = size.width * 0.04;
    final iconSize = size.width * 0.06;
    final fontSizeLarge = size.width * 0.03;
    final fontSizeSmall = size.width * 0.035;
    final vSpacing = size.height * 0.005;
    final roomUuid = delivery['room_uuid']?.toString().trim();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPaddingSmall,
        vertical: vPadding,
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.darkBorderColor
                : AppColors.shadowColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
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
                              color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeLarge,
                            ),
                            maxLines: null,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(height: vSpacing),
                          Text(
                            "Category: ${delivery['category_name']}",
                            style: textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkSubtitleColor
                                  : AppColors.hintTextColor,
                              fontSize: fontSizeSmall,
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
                        'round_uuid': delivery['uuid'] != null ? delivery['uuid'].toString() : '',
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
                  size: iconSize,
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
    final hPadding = size.width * 0.04;
    final vPadding = size.height * 0.01;
    final cardPadding = size.width * 0.04;
    final iconSize = size.width * 0.05;
    final fontSizeLarge = size.width * 0.04;
    final fontSizeSmall = size.width * 0.035;
    final vSpacing = size.height * 0.015;
    final hSpacing = size.width * 0.02;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.darkBorderColor
                : AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        color: isDarkMode
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
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
                            fontSize: fontSizeLarge,
                          ),
                        ),
                      ),
                      SizedBox(width: hSpacing),
                      Text(
                        checklist['checklist_name'],
                        style: textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeSmall,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.dangerButtonColor,
                      size: iconSize,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: vSpacing),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: iconSize,
                  ),
                  SizedBox(width: hSpacing),
                  Expanded(
                    child: Text(
                      "Location: ${checklist['location']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkSubtitleColor
                            : AppColors.hintTextColor,
                        fontSize: fontSizeSmall,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: vSpacing),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: iconSize,
                  ),
                  SizedBox(width: hSpacing),
                  Expanded(
                    child: Text(
                      "Date & Time: ${checklist['date_and_time']}",
                      style: textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? AppColors.darkSubtitleColor
                            : AppColors.hintTextColor,
                        fontSize: fontSizeSmall,
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
    final hPadding = size.width * 0.04;
    final vPadding = size.height * 0.01;
    final iconSize = size.width * 0.06;
    final fontSize = size.width * 0.04;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: vPadding,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.add,
            color: Colors.green,
            size: iconSize,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.green,
              fontSize: fontSize,
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
    required Size size,
  }) {
    final vMargin = size.height * 0.01;
    final padding = size.width * 0.04;
    final vSpacing = size.height * 0.01;
    final hSpacing = size.width * 0.02;
    final chipSpacing = size.width * 0.02;
    return Container(
      margin: EdgeInsets.symmetric(vertical: vMargin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      
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
          SizedBox(height: vSpacing),
          Wrap(
            spacing: chipSpacing,
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
    final width = size.width;
    final height = size.height;
    final hPadding = width * 0.04;
    final vPadding = height * 0.01;
    final vSpacingSmall = height * 0.005;
    final vSpacingMedium = height * 0.015;
    final vSpacingLarge = height * 0.02;
    final imageSize = width * 0.7;
    final fontSizeLarge = width * 0.045;
    final fontSizeSmall = width * 0.035;
    final hSpacing = width * 0.02;
    final filterHSpacing = width * 0.04;
    final filterVSpacing = height * 0.01;
    final dropdownIconSize = width * 0.06;
    final dateFontSize = width * 0.035;
    final chipMarginH = width * 0.01;
    final chipPaddingH = width * 0.04;
    final chipPaddingV = height * 0.01;
    final dateRowHeight = height * 0.06;
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
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: vSpacingMedium),
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
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: vSpacingMedium),
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
                        horizontal: hPadding,
                        vertical: vPadding,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                       
                        ),
                        child: Text(
                          'No checklists available for the selected date range',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizeSmall,
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
                vertical: vPadding,
                horizontal: filterHSpacing,
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
                  SizedBox(height: vSpacingMedium),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                      border: Border.all(
                        color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(25),
                   
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
                          iconSize: dropdownIconSize,
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
                  SizedBox(height: vSpacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: fontSizeLarge,
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              ),
                            ),
                            SizedBox(height: vSpacingSmall),
                            CustomDateField(
                              initialDate: controller.startDate.value,
                              onDateSelected: (date) {
                                controller.startDate.value = date;
                              },
                            ),
                            SizedBox(height: vSpacingSmall),
                            Obx(() => Text(
                                  'Selected: ${controller.formatDateForDisplay(controller.startDate.value)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                    fontSize: dateFontSize,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(width: hSpacing),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: fontSizeLarge,
                                color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                              ),
                            ),
                            SizedBox(height: vSpacingSmall),
                            CustomDateField(
                              initialDate: controller.endDate.value,
                              onDateSelected: (date) {
                                controller.endDate.value = date;
                              },
                            ),
                            SizedBox(height: vSpacingSmall),
                            Obx(() => Text(
                                  'Selected: ${controller.formatDateForDisplay(controller.endDate.value)}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                    fontSize: dateFontSize,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: vSpacingMedium),
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
                        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
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
                vertical: vPadding,
                horizontal: filterHSpacing,
              ),
              child: Text(
                'Log',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                ),
              ),
            ),
            SizedBox(height: vSpacingMedium),
            Obx(() {
              if (controller.dailyChecklist.value == null ||
                  controller.dailyChecklist.value!.roundData.isEmpty ||
                  controller.dailyChecklist.value!.rooms.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  
                  ),
                  child: Text(
                    'No log data available',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: fontSizeSmall,
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                 
                  ),
                  child: Text(
                    'No log data available',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: fontSizeSmall,
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
                    height: dateRowHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sortedDates.map((date) {
                          return Obx(() => GestureDetector(
                                onTap: () {
                                  selectedDate.value = date;
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: chipMarginH),
                                  padding: EdgeInsets.symmetric(horizontal: chipPaddingH, vertical: chipPaddingV),
                                  decoration: BoxDecoration(
                                    color: selectedDate.value == date
                                        ? Colors.blue.shade50
                                        : (isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor),
                                    borderRadius: BorderRadius.circular(8),
                                 
                                  ),
                                  child: Text(
                                    _formatShortDate(date),
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: fontSizeSmall,
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
                  SizedBox(height: vSpacingMedium),
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
                          size: size,
                        ));
                      }
                    });

                    if (logEntries.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                       
                        ),
                        child: Text(
                          'No log entries for this date',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizeSmall,
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