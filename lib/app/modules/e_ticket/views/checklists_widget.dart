import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

import '../controllers/ticket_controller.dart';

class ChecklistsWidget extends StatelessWidget {
  const ChecklistsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TicketController controller = Get.find<TicketController>();
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      return Column(
        children: controller.checklists.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.01,
                  horizontal: size.width * 0.04,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group['group'],
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.05,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: AppColors.hintTextColor,
                            size: size.width * 0.06,
                          ),
                          onPressed: () {
                            controller.fetchChecklists();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.hintTextColor,
                            size: size.width * 0.06,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ...group['checklists'].asMap().entries.map((entry) {
                int index = entry.key + 1;
                var checklist = entry.value;
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
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    color: Colors.white,
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
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.03,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
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
                                    color: AppColors.hintTextColor,
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
                                    color: AppColors.hintTextColor,
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
              }).toList(),
              Padding(
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
                      "Add Checklist",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      );
    });
  }
}