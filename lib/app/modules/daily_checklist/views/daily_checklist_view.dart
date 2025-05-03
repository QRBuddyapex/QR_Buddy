import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/core/widgets/custom_date_field.dart';
import '../controllers/daily_checklist_controller.dart';

class DailyChecklistView extends GetView<DailyChecklistController> {
  const DailyChecklistView({super.key});
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
              'Dashboard > ${controller.selectedOption.value}', 
              style: const TextStyle(color: AppColors.blackColor)
            )),
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
                    child: Obx(() => DropdownButton<String>(
                      value: controller.selectedOption.value,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      iconSize: 24,
                      elevation: 0,
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                      items: [
                        'Customer Satisfaction',
                        'Feedback Demo',
                        'IPD Feedback',
                        'OPD Patient Feedback',
                        'Physical Audit',
                        'Washroom Checklist',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.selectedOption.value = newValue;
                        }
                      },
                    )),
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
                        'Last 7 Days',
                        'Last 30 Days',
                        'This Month',
                        'Last Month',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      // Update the dropdown onChanged callback
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          // Show full screen loading indicator
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
                              );
                            },
                          );
                          
                          // Simulate loading time (remove this in production)
                          Future.delayed(const Duration(seconds: 1), () {
                            // Close the loading dialog
                            Navigator.of(context).pop();
                            // Update the selected option
                            controller.selectedOption.value = newValue;
                            // Fetch new data
                            controller.fetchData();
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
                      child: CustomDateField(
                        initialDate: controller.startDate.value,
                        onDateSelected: (date) {
                          controller.startDate.value = date;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDateField(
                        initialDate: controller.endDate.value,
                        onDateSelected: (date) {
                          controller.endDate.value = date;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      onPressed: () {},
                      text: 'Filter',
                      color: AppColors.primaryColor,
                      width: 100,
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      onPressed: () {},
                      text: 'Invite',
                      color: AppColors.escalationIconColor,
                      width: 100,
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      onPressed: () {},
                      text: 'Export',
                      color: AppColors.shadowColor,
                      width: 100,
                    ),
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
                                Icon(Icons.trending_up, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.sentiment_very_satisfied, color: Colors.green),
                                const SizedBox(height: 8),
                                Obx(() => Text(
                                  '${controller.promoters.value}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                )),
                                Text('Promoters', style: TextStyle(color: Colors.green)),
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
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                )),
                                Text('Passives', style: TextStyle(color: Colors.orange)),
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
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )),
                                Text('Detractors', style: TextStyle(color: Colors.red)),
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
                  count: '0',
                  label: 'Rounds',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.pending_actions,
                  count: '0',
                  label: 'Pending',
                  color: Colors.orange,
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  count: '0',
                  label: 'Done',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Feedback Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 60,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 60,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const months = ['Jan 25', 'Feb 25', 'Mar 25', 'Apr 25', 'May 25'];
                            if (value >= 0 && value < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: 10,
                            width: 20,
                            color: Colors.red,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 10,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: 200,
                            width: 20,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: 230,
                            width: 20,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: 240,
                            width: 20,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: 10,
                            width: 20,
                            color: Colors.red,
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 10,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                    maxY: 300,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
         
            Obx(() => ExpansionTile(
              title: Text(controller.isLogExpanded.value ? 'Hide Log' : 'Show Log'),
              onExpansionChanged: (bool expanded) {
                controller.isLogExpanded.value = expanded;
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLogItem(
                    location: 'Management Office',
                    block: 'Block A - GF',
                    times: ['08:00 AM', '10:00 AM', '12:00 PM', '02:00 PM', 
                           '04:00 PM', '05:00 PM', '08:00 PM'],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
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
    return Container(
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
            children: times.map((time) => Chip(
              label: Text(time),
              backgroundColor: Colors.pink.shade50,
              labelStyle: TextStyle(color: Colors.pink.shade700),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
