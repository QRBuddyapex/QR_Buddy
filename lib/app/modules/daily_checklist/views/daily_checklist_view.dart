import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_date_field.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Checklist'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() => Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard > ${controller.selectedOption.value}',
                      style: const TextStyle(color: AppColors.blackColor),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowColor.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Obx(() {
                              // Check if categories are available
                              final categories = controller.dailyChecklist.value?.categories ?? [];
                              const noCategoryOption = 'No Category';

                              // List of dropdown items including "No Category"
                              final dropdownItems = [
                                DropdownMenuItem<String>(
                                  value: noCategoryOption,
                                  child: Text(noCategoryOption),
                                ),
                                ...categories.map((Category category) {
                                  return DropdownMenuItem<String>(
                                    value: category.categoryName,
                                    child: Text(category.categoryName),
                                  );
                                }).toList(),
                              ];

                              // Determine the default value
                              String defaultValue;
                              if (categories.isEmpty) {
                                defaultValue = noCategoryOption;
                              } else if (controller.selectedOption.value.isNotEmpty &&
                                  (controller.selectedOption.value == noCategoryOption ||
                                      categories.any((cat) =>
                                          cat.categoryName == controller.selectedOption.value))) {
                                defaultValue = controller.selectedOption.value;
                              } else {
                                defaultValue = noCategoryOption; // Default to "No Category"
                              }

                              return DropdownButton<String>(
                                value: defaultValue,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                iconSize: 24,
                                elevation: 0,
                                style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 16,
                                ),
                                hint: const Text('Loading categories...'),
                                items: dropdownItems,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.selectedOption.value = newValue;
                                    if (newValue == noCategoryOption) {
                                      // Call API without category_id
                                      controller.fetchData(
                                        useDateRange: true,
                                        categoryId: null,
                                      );
                                    } else {
                                      // Find the category ID for the selected option
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
                            color: AppColors.backgroundColor,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Obx(() => DropdownButton<String>(
                                  value: controller.selectedTimeRange.value,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  iconSize: 24,
                                  elevation: 0,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
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
                                      child: Text(value),
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
                                              color: Colors.white,
                                              child: const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Please wait...',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.of(context).pop();
                                        controller.selectedTimeRange.value =
                                            newValue;
                                        controller
                                            .updateDateRange(); // Update dates based on selection
                                        // Determine category_id based on selected option
                                        final categories = controller
                                                .dailyChecklist.value?.categories ??
                                            [];
                                        if (controller.selectedOption.value ==
                                            noCategoryOption) {
                                          controller.fetchData(
                                            useDateRange: true,
                                            categoryId: null,
                                          );
                                        } else {
                                          final selectedCategory = categories
                                              .firstWhereOrNull((cat) =>
                                                  cat.categoryName ==
                                                  controller.selectedOption.value);
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
                                  const Text(
                                    'Start Date',
                                    style: TextStyle(fontSize: 16),
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
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'End Date',
                                    style: TextStyle(fontSize: 16),
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
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
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
                            const SizedBox(width: 8),
                            CustomButton(
                              onPressed: () {
                                Get.snackbar(
                                    'Invite', 'Invite feature not implemented');
                              },
                              text: 'Invite',
                              color: AppColors.escalationIconColor,
                              width: 100,
                            ),
                            const SizedBox(width: 8),
                            CustomButton(
                              onPressed: () {
                                Get.snackbar(
                                    'Export', 'Export feature not implemented');
                              },
                              text: 'Export',
                              color: AppColors.shadowColor,
                              width: 100,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Obx(() => controller.selectedOption.value ==
                            'Customer Satisfaction'
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
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey
                                                  .withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(Icons.trending_up,
                                                color: Colors.green),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'NPS',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Obx(() => Text(
                                                  '${controller.npsScore}',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                                Icons.sentiment_very_satisfied,
                                                color: Colors.green),
                                            const SizedBox(height: 8),
                                            Obx(() => Text(
                                                  '${controller.promoters.value}%',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                )),
                                            const Text('Promoters',
                                                style: TextStyle(
                                                    color: Colors.green)),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(Icons.sentiment_neutral,
                                                color: Colors.orange),
                                            const SizedBox(height: 8),
                                            Obx(() => Text(
                                                  '${controller.passives.value}%',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                )),
                                            const Text('Passives',
                                                style: TextStyle(
                                                    color: Colors.orange)),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                                Icons
                                                    .sentiment_very_dissatisfied,
                                                color: Colors.red),
                                            const SizedBox(height: 8),
                                            Obx(() => Text(
                                                  '${controller.detractors.value}%',
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red,
                                                  ),
                                                )),
                                            const Text('Detractors',
                                                style:
                                                    TextStyle(color: Colors.red)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          icon: Icons.check_circle_outline,
                          count: controller.rounds.value,
                          label: 'Rounds',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.pending_actions,
                          count: controller.pending.value,
                          label: 'Pending',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.check_circle,
                          count: controller.done.value,
                          label: 'Done',
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Feedback Trends (Bar Chart)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.dailyChecklist.value == null ||
                          controller.dailyChecklist.value!.chartData.bar.xaxis
                              .categories.isEmpty) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(child: Text('No data available')),
                        );
                      }

                      // Calculate maxY dynamically based on data
                      final barSeries = controller
                          .dailyChecklist.value!.chartData.bar.seriesLine;
                      double maxYBar = 0;
                      for (var s in barSeries) {
                        for (var data in s.data) {
                          final value = data is String
                              ? double.tryParse(data) ?? 0
                              : (data as num).toDouble();
                          maxYBar = maxYBar < value ? value : maxYBar;
                        }
                      }
                      maxYBar = (maxYBar * 1.2).ceilToDouble(); // Add 20% padding
                      maxYBar = maxYBar < 100 ? 100 : maxYBar; // Ensure minimum height

                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
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
                                        color: Colors.grey.shade200,
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
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
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
                                          final categories = controller
                                              .dailyChecklist
                                              .value!
                                              .chartData
                                              .bar
                                              .xaxis
                                              .categories;
                                          if (value >= 0 &&
                                              value < categories.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(
                                                categories[value.toInt()],
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    rightTitles: fl_chart.AxisTitles(
                                        sideTitles:
                                            fl_chart.SideTitles(showTitles: false)),
                                    topTitles: fl_chart.AxisTitles(
                                        sideTitles:
                                            fl_chart.SideTitles(showTitles: false)),
                                  ),
                                  borderData: fl_chart.FlBorderData(show: false),
                                  barGroups: controller.dailyChecklist.value!
                                      .chartData.bar.xaxis.categories
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final doneSeries = controller
                                        .dailyChecklist
                                        .value!
                                        .chartData
                                        .bar
                                        .seriesLine
                                        .firstWhere(
                                            (series) => series.name == 'Done',
                                            orElse: () => Series(
                                                name: 'Done', data: ['0']));
                                    final otherSeries = controller
                                        .dailyChecklist
                                        .value!
                                        .chartData
                                        .bar
                                        .seriesLine
                                        .firstWhere(
                                            (series) => series.name != 'Done',
                                            orElse: () => Series(
                                                name: 'Pending', data: ['0']));

                                    final doneValue = doneSeries.data.length >
                                            index
                                        ? (doneSeries.data[index] is String
                                            ? double.tryParse(
                                                    doneSeries.data[index]) ??
                                                0
                                            : (doneSeries.data[index] as num)
                                                .toDouble())
                                        : 0.0;
                                    final otherValue = otherSeries.data.length >
                                            index
                                        ? (otherSeries.data[index] is String
                                            ? double.tryParse(
                                                    otherSeries.data[index]) ??
                                                0
                                            : (otherSeries.data[index] as num)
                                                .toDouble())
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
                                  color: Colors.green, label: 'Done'),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                  color: Colors.red, label: 'Pending'),
                            ],
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                    const Text(
                      'Feedback Distribution (Pie Chart)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Center(child: Text('No data available')),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'No data available for table',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'No feedback source data available',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        );
                      }

                      // Calculate total feedback count
                      final series = controller.dailyChecklist.value!.feedbackDistribution.series;
                      final labels = controller.dailyChecklist.value!.feedbackDistribution.labels;
                      final total = series.fold(0, (sum, count) => sum + count);

                      // Avoid division by zero
                      if (total == 0) {
                        return Column(
                          children: [
                            Container(
                              height: 300,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Center(child: Text('No data available')),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'No data available for table',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'No feedback source data available',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        );
                      }

                      // Define colors for each mode
                      final modeColors = [
                        Colors.blue,   // QR
                        Colors.green,  // WA
                        Colors.orange, // TAB
                        Colors.purple, // PAPER
                      ];

                      // Calculate percentages for each mode
                      final percentages = series
                          .asMap()
                          .map((index, count) => MapEntry(
                              index,
                              (count / total * 100).toStringAsFixed(1)))
                          .values
                          .toList();

                      // Get feedback source data
                      final feedbackSources = controller.dailyChecklist.value!.feedbackDistribution.feedbackSource;

                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
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
                                      color: modeColors[index],
                                      value: count,
                                      title: count > 0 ? '${percentages[index]}%' : '',
                                      radius: 100,
                                      titleStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
                                  color: modeColors[index],
                                  label: label,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Table(
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                top: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
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
                                    color: Colors.grey.shade50,
                                  ),
                                  children: [
                                    _buildTableCell('Mode', isHeader: true),
                                    _buildTableCell('Count', isHeader: true),
                                    _buildTableCell('Percentage', isHeader: true),
                                  ],
                                ),
                                ...labels.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final label = entry.value;
                                  final count = series[index];
                                  final percentage = percentages[index];
                                  return TableRow(
                                    children: [
                                      _buildTableCell(label, color: modeColors[index]),
                                      _buildTableCell(count.toString()),
                                      _buildTableCell('$percentage%'),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Feedback Source Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          feedbackSources.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'No feedback source data available',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                )
                              : Column(
                                  children: feedbackSources.asMap().entries.map((entry) {
                                    final index = labels.indexOf(entry.value.mode);
                                    final color = index != -1 ? modeColors[index] : Colors.grey;
                                    final source = entry.value;
                                    final modeTotal = source.total.toDouble();

                                    // Convert category map to list of entries and sort by count (descending)
                                    final categoryEntries = source.category.entries.toList()
                                      ..sort((a, b) => b.value.compareTo(a.value));

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            '${source.mode} Breakdown',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Table(
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                              top: BorderSide(
                                                color: Colors.grey.shade200,
                                                width: 1,
                                              ),
                                              bottom: BorderSide(
                                                color: Colors.grey.shade200,
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
                                                  color: Colors.grey.shade50,
                                                ),
                                                children: [
                                                  _buildTableCell('Category', isHeader: true),
                                                  _buildTableCell('Count', isHeader: true),
                                                  _buildTableCell('Percentage', isHeader: true),
                                                ],
                                              ),
                                              ...categoryEntries.map((categoryEntry) {
                                                final categoryName = categoryEntry.key.isEmpty
                                                    ? 'Uncategorized'
                                                    : categoryEntry.key;
                                                final count = categoryEntry.value;
                                                final percentage = (count / modeTotal * 100).toStringAsFixed(1);
                                                return TableRow(
                                                  children: [
                                                    _buildTableCell(categoryName),
                                                    _buildTableCell(count.toString()),
                                                    _buildTableCell('$percentage%'),
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
                    const Text(
                      'Log',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'No log data available',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        );
                      }

                      // Extract unique dates from roundData
                      final roundData = controller.dailyChecklist.value!.roundData;
                      final rooms = controller.dailyChecklist.value!.rooms;
                      final allDates = <String>{};

                      roundData.forEach((roomId, dateMap) {
                        dateMap.keys.forEach((date) {
                          allDates.add(date);
                        });
                      });

                      // Sort dates chronologically
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'No log data available',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        );
                      }

                      // Find the most recent date (closest to today, June 10, 2025)
                      final today = DateTime(2025, 6, 10);
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

                      // Use a reactive variable to track the selected date, default to most recent
                      final selectedDate = mostRecentDate.obs;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Horizontal date scroller
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: selectedDate.value == date
                                                ? Colors.blue.shade50
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            _formatShortDate(date),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: selectedDate.value == date
                                                  ? Colors.blue
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ));
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Log entries for the selected date
                          Obx(() {
                            final logEntries = <Widget>[];
                            roundData.forEach((roomId, dateMap) {
                              if (dateMap.containsKey(selectedDate.value)) {
                                final room = rooms[roomId];
                                final rounds = dateMap[selectedDate.value]!;
                                logEntries.add(_buildLogItem(
                                  location: room?.roomNumber ?? 'Unknown',
                                  block:
                                      '${room?.blockName ?? 'Unknown'} - ${room?.floorName ?? 'Unknown'}',
                                  times: rounds
                                      .map((round) => round.timeSchedule)
                                      .toList(),
                                ));
                              }
                            });

                            if (logEntries.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'No log entries for this date',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
                  color: Colors.white.withOpacity(0.8),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Please wait...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem({
    required String location,
    required String block,
    required List<String> times,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              block,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: times
                  .map((time) => Chip(
                        label: Text(time),
                        backgroundColor: Colors.pink.shade50,
                        labelStyle: TextStyle(color: Colors.pink.shade700),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.black : Colors.grey.shade800),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}