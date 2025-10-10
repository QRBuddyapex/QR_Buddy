import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_appbar.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_date_field.dart';
import 'package:qr_buddy/app/core/widgets/custom_drawer.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';
import 'package:qr_buddy/app/modules/e_ticket/controllers/location_dialog.dart';

import '../controllers/daily_checklist_controller.dart';

class DailyChecklistView extends GetView<DailyChecklistController> {
  const DailyChecklistView({super.key});

  // Helper function to parse "3 Jun" format into a DateTime object
  DateTime _parseShortDate(String dateStr) {
    final parts = dateStr.trim().split(' ');
    if (parts.length != 2) {
      throw FormatException('Invalid date format: $dateStr');
    }

    final day = int.parse(parts[0]);
    final monthStr = parts[1];

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

    final month = monthMap[monthStr];
    if (month == null) {
      throw FormatException('Invalid month abbreviation: $monthStr');
    }

    // Use 2025 as the year (current year based on system date)
    const year = 2025;
    return DateTime(year, month, day);
  }

  // Helper function to format DateTime back to "3 Jun" for display
  String _formatShortDate(String dateStr) {
    return dateStr; // Keep the original format for display
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false,
      Color? color,
      required TextTheme textTheme,
      required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ??
              (isDarkMode
                  ? (isHeader ? AppColors.darkTextColor : AppColors.darkSubtitleColor)
                  : (isHeader ? AppColors.textColor : AppColors.subtitleColor)),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required TextTheme textTheme,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daily Checklist',
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        onQrPressed: () async {
          final result = await Get.toNamed('/qr-scan');
          if (result != null && result is String) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Scanned URL: $result',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                backgroundColor: AppColors.primaryColor.withOpacity(0.9),
              ),
            );
          }
        },
        onLocationPressed: () {
          showDialog(
            context: context,
            builder: (context) => const LocationDialog(),
          );
        },
        onProfilePressed: () {},
      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        if (controller.isRecord.value == false) {
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
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard > ${controller.selectedOption.value}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
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
                              ...categories.map((Category category) {
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
                            } else if (controller.selectedOption.value.isNotEmpty &&
                                (controller.selectedOption.value == noCategoryOption ||
                                    categories.any((cat) =>
                                        cat.categoryName == controller.selectedOption.value))) {
                              defaultValue = controller.selectedOption.value;
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
                                  controller.selectedOption.value = newValue;
                                  if (newValue == noCategoryOption) {
                                    controller.fetchData(
                                      useDateRange: true,
                                      categoryId: null,
                                    );
                                  } else {
                                    final selectedCategory = categories.firstWhere(
                                        (cat) => cat.categoryName == newValue);
                                    controller.fetchData(
                                      useDateRange: true,
                                      categoryId: selectedCategory.id,
                                    );
                                  }
                                }
                              },
                            );
                          }),
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
                          child: Obx(() => DropdownButton<String>(
                                value: controller.selectedTimeRange.value,
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
                                items: [
                                  'Today',
                                  'Last 7 Days',
                                  'Last 30 Days',
                                  'Last 60 Days',
                                  'Last 90 Days',
                                  'This Month',
                                  'Last Month',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    const noCategoryOption = 'No Category';
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return WillPopScope(
                                          onWillPop: () async => false,
                                          child: Container(
                                            color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    color: AppColors.primaryColor,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'Please wait...',
                                                    style: textTheme.bodyMedium?.copyWith(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    Future.delayed(const Duration(seconds: 1), () {
                                      Navigator.of(context).pop();
                                      controller.selectedTimeRange.value = newValue;
                                      controller.updateDateRange();
                                      final categories = controller.dailyChecklist.value?.categories ?? [];
                                      if (controller.selectedOption.value == noCategoryOption) {
                                        controller.fetchData(
                                          useDateRange: true,
                                          categoryId: null,
                                        );
                                      } else {
                                        final selectedCategory = categories.firstWhereOrNull(
                                            (cat) => cat.categoryName == controller.selectedOption.value);
                                        controller.fetchData(
                                          useDateRange: true,
                                          categoryId: selectedCategory?.id,
                                        );
                                      }
                                    });
                                  }
                                },
                              )),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            onPressed: controller.onFilterPressed,
                            text: 'Filter',
                            color: AppColors.primaryColor,
                            width: 100,
                          ),
                          Obx(() {
                            if (controller.isFiltered.value) {
                              return Row(
                                children: [
                                  const SizedBox(width: 8),
                                  CustomButton(
                                    onPressed: controller.onSchedulePressed,
                                    text: 'Schedule',
                                    color: AppColors.primaryColor,
                                    width: 100,
                                  ),
                                  const SizedBox(width: 8),
                                  CustomButton(
                                    onPressed: () {
                                      Get.snackbar('Invite', 'Invite feature not implemented');
                                    },
                                    text: 'Invite',
                                    color: AppColors.primaryColor,
                                    width: 100,
                                  ),
                                  const SizedBox(width: 8),
                                  // CustomButton(
                                  //   onPressed: () {
                                  //     Get.snackbar('Export', 'Export feature not implemented');
                                  //   },
                                  //   text: 'Export',
                                  //   color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                  //   width: 100,
                                  // ),
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() => controller.selectedOption.value == 'Customer Satisfaction'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                                        children: [
                                          Icon(Icons.trending_up, color: Colors.green),
                                          const SizedBox(height: 8),
                                          Text(
                                            'NPS',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: Colors.green,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(() => Text(
                                                '${controller.npsScore}',
                                                style: textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                                          const SizedBox(height: 8),
                                          Obx(() => Text(
                                                '${controller.promoters.value}%',
                                                style: textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              )),
                                          Text(
                                            'Promoters',
                                            style: textTheme.bodyMedium?.copyWith(color: Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.sentiment_neutral, color: Colors.orange),
                                          const SizedBox(height: 8),
                                          Obx(() => Text(
                                                '${controller.passives.value}%',
                                                style: textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              )),
                                          Text(
                                            'Passives',
                                            style: textTheme.bodyMedium?.copyWith(color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
                                          const SizedBox(height: 8),
                                          Obx(() => Text(
                                                '${controller.detractors.value}%',
                                                style: textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              )),
                                          Text(
                                            'Detractors',
                                            style: textTheme.bodyMedium?.copyWith(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox()),
                  const SizedBox(height: 24),
                  Text(
                    'Feedback Trends (Bar Chart)',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.dailyChecklist.value == null ||
                        controller.dailyChecklist.value!.chartData.bar.xaxis.categories.isEmpty) {
                      return Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'No data available',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                            ),
                          ),
                        ),
                      );
                    }

                    final barSeries = controller.dailyChecklist.value!.chartData.bar.seriesLine;
                    double maxYBar = 0;
                    for (var s in barSeries) {
                      for (var data in s.data) {
                        final value = data is String ? double.tryParse(data) ?? 0 : (data as num).toDouble();
                        maxYBar = maxYBar < value ? value : maxYBar;
                      }
                    }
                    maxYBar = (maxYBar * 1.2).ceilToDouble();
                    maxYBar = maxYBar < 100 ? 100 : maxYBar;

                    return Column(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: fl_chart.BarChart(
                              fl_chart.BarChartData(
                                gridData: fl_chart.FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: maxYBar / 5,
                                  getDrawingHorizontalLine: (value) {
                                    return fl_chart.FlLine(
                                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: fl_chart.FlTitlesData(
                                  leftTitles: fl_chart.AxisTitles(
                                    sideTitles: fl_chart.SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: maxYBar / 5,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: isDarkMode ? AppColors.darkSubtitleColor : Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: fl_chart.AxisTitles(
                                    sideTitles: fl_chart.SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final categories =
                                            controller.dailyChecklist.value!.chartData.bar.xaxis.categories;
                                        if (value >= 0 && value < categories.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              categories[value.toInt()],
                                              style: textTheme.bodySmall?.copyWith(
                                                color: isDarkMode ? AppColors.darkSubtitleColor : Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  rightTitles:
                                      fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                                  topTitles:
                                      fl_chart.AxisTitles(sideTitles: fl_chart.SideTitles(showTitles: false)),
                                ),
                                borderData: fl_chart.FlBorderData(show: false),
                                barGroups: controller.dailyChecklist.value!.chartData.bar.xaxis.categories
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final doneSeries = controller.dailyChecklist.value!.chartData.bar.seriesLine
                                      .firstWhere((series) => series.name == 'Done',
                                          orElse: () => Series(name: 'Done', data: ['0']));
                                  final otherSeries = controller.dailyChecklist.value!.chartData.bar.seriesLine
                                      .firstWhere((series) => series.name != 'Done',
                                          orElse: () => Series(name: 'Pending', data: ['0']));

                                  final doneValue = doneSeries.data.length > index
                                      ? (doneSeries.data[index] is String
                                          ? double.tryParse(doneSeries.data[index]) ?? 0
                                          : (doneSeries.data[index] as num).toDouble())
                                      : 0.0;
                                  final otherValue = otherSeries.data.length > index
                                      ? (otherSeries.data[index] is String
                                          ? double.tryParse(otherSeries.data[index]) ?? 0
                                          : (otherSeries.data[index] as num).toDouble())
                                      : 0.0;

                                  return fl_chart.BarChartGroupData(
                                    x: index,
                                    barsSpace: 4,
                                    barRods: [
                                      fl_chart.BarChartRodData(
                                        toY: doneValue,
                                        width: 12,
                                        color: Colors.green,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                      fl_chart.BarChartRodData(
                                        toY: otherValue,
                                        width: 12,
                                        color: Colors.red,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                maxY: maxYBar,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                              color: Colors.green,
                              label: 'Done',
                              textTheme: textTheme,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(width: 16),
                            _buildLegendItem(
                              color: Colors.red,
                              label: 'Pending',
                              textTheme: textTheme,
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Feedback Distribution (Pie Chart)',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.dailyChecklist.value == null ||
                        controller.dailyChecklist.value!.feedbackDistribution.labels.isEmpty ||
                        controller.dailyChecklist.value!.feedbackDistribution.series.isEmpty) {
                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'No data available',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                              'No data available for table',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                              'No feedback source data available',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final series = controller.dailyChecklist.value!.feedbackDistribution.series;
                    final labels = controller.dailyChecklist.value!.feedbackDistribution.labels;
                    final total = series.fold(0, (sum, count) => sum + count);

                    if (total == 0) {
                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'No data available',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                              'No data available for table',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                              'No feedback source data available',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final modeColors = [
                      Colors.blue, // QR
                      Colors.green, // WA
                      Colors.orange, // TAB
                      Colors.purple, // PAPER
                    ];

                    final percentages = series
                        .asMap()
                        .map((index, count) => MapEntry(
                            index, (count / total * 100).toStringAsFixed(1)))
                        .values
                        .toList();

                    final feedbackSources = controller.dailyChecklist.value!.feedbackDistribution.feedbackSource;

                    return Column(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: fl_chart.PieChart(
                              fl_chart.PieChartData(
                                sections: series.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final count = entry.value.toDouble();
                                  return fl_chart.PieChartSectionData(
                                    color: modeColors[index % modeColors.length],
                                    value: count,
                                    title: count > 0 ? '${percentages[index]}%' : '',
                                    radius: 100,
                                    titleStyle: textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? AppColors.darkTextColor : Colors.white,
                                    ),
                                  );
                                }).toList(),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: labels.asMap().entries.map((entry) {
                            final index = entry.key;
                            final label = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildLegendItem(
                                color: modeColors[index % modeColors.length],
                                label: label,
                                textTheme: textTheme,
                                isDarkMode: isDarkMode,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                width: 1,
                              ),
                              top: BorderSide(
                                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                                ),
                                children: [
                                  _buildTableCell(
                                    'Mode',
                                    isHeader: true,
                                    textTheme: textTheme,
                                    isDarkMode: isDarkMode,
                                  ),
                                  _buildTableCell(
                                    'Count',
                                    isHeader: true,
                                    textTheme: textTheme,
                                    isDarkMode: isDarkMode,
                                  ),
                                  _buildTableCell(
                                    'Percentage',
                                    isHeader: true,
                                    textTheme: textTheme,
                                    isDarkMode: isDarkMode,
                                  ),
                                ],
                              ),
                              ...labels.asMap().entries.map((entry) {
                                final index = entry.key;
                                final label = entry.value;
                                final count = series[index];
                                final percentage = percentages[index];
                                return TableRow(
                                  children: [
                                    _buildTableCell(
                                      label,
                                      color: modeColors[index % modeColors.length],
                                      textTheme: textTheme,
                                      isDarkMode: isDarkMode,
                                    ),
                                    _buildTableCell(
                                      count.toString(),
                                      textTheme: textTheme,
                                      isDarkMode: isDarkMode,
                                    ),
                                    _buildTableCell(
                                      '$percentage%',
                                      textTheme: textTheme,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Feedback Source Breakdown',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        feedbackSources.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                                  'No feedback source data available',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                                  ),
                                ),
                              )
                            : Column(
                                children: feedbackSources.asMap().entries.map((entry) {
                                  final index = labels.indexOf(entry.value.mode);
                                  final color = index != -1 ? modeColors[index % modeColors.length] : Colors.grey;
                                  final source = entry.value;
                                  final modeTotal = source.total.toDouble();

                                  final categoryEntries = source.category.entries.toList()
                                    ..sort((a, b) => b.value.compareTo(a.value));

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          '${source.mode} Breakdown',
                                          style: textTheme.bodyMedium?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDarkMode ? AppColors.darkShadowColor : AppColors.shadowColor,
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Table(
                                          border: TableBorder(
                                            horizontalInside: BorderSide(
                                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                              width: 1,
                                            ),
                                            top: BorderSide(
                                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                              width: 1,
                                            ),
                                            bottom: BorderSide(
                                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          columnWidths: const {
                                            0: FlexColumnWidth(2),
                                            1: FlexColumnWidth(1),
                                            2: FlexColumnWidth(1),
                                          },
                                          children: [
                                            TableRow(
                                              decoration: BoxDecoration(
                                                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                                              ),
                                              children: [
                                                _buildTableCell(
                                                  'Category',
                                                  isHeader: true,
                                                  textTheme: textTheme,
                                                  isDarkMode: isDarkMode,
                                                ),
                                                _buildTableCell(
                                                  'Count',
                                                  isHeader: true,
                                                  textTheme: textTheme,
                                                  isDarkMode: isDarkMode,
                                                ),
                                                _buildTableCell(
                                                  'Percentage',
                                                  isHeader: true,
                                                  textTheme: textTheme,
                                                  isDarkMode: isDarkMode,
                                                ),
                                              ],
                                            ),
                                            ...categoryEntries.map((categoryEntry) {
                                              final categoryName = categoryEntry.key.isEmpty
                                                  ? 'Uncategorized'
                                                  : categoryEntry.key;
                                              final count = categoryEntry.value;
                                              final percentage =
                                                  (count / modeTotal * 100).toStringAsFixed(1);
                                              return TableRow(
                                                children: [
                                                  _buildTableCell(
                                                    categoryName,
                                                    textTheme: textTheme,
                                                    isDarkMode: isDarkMode,
                                                  ),
                                                  _buildTableCell(
                                                    count.toString(),
                                                    textTheme: textTheme,
                                                    isDarkMode: isDarkMode,
                                                  ),
                                                  _buildTableCell(
                                                    '$percentage%',
                                                    textTheme: textTheme,
                                                    isDarkMode: isDarkMode,
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'Log',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.dailyChecklist.value == null ||
                        controller.dailyChecklist.value!.roundData.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
                          color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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

                    final todayDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    );
                    String mostRecentDate = sortedDates.first;
                    Duration minDifference = todayDate.difference(_parseShortDate(sortedDates.first)).abs();

                    for (final date in sortedDates) {
                      final parsedDate = _parseShortDate(date);
                      final difference = todayDate.difference(parsedDate).abs();
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
                                              : (isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white),
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
                                location: room?.roomNumber ?? 'Unknown',
                                block: '${room?.blockName ?? 'Unknown'} - ${room?.floorName ?? 'Unknown'}',
                                times: rounds.map((round) => round.timeSchedule).toList(),
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
                                color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please wait...',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
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
            runSpacing: 4,
            children: times
                .map((time) => Chip(
                      label: Text(
                        time,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.pink.shade700,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}