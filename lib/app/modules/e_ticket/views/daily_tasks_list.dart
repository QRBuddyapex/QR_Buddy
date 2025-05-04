import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class TaskListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Size size;
  final TextTheme textTheme;

  const TaskListWidget({
    Key? key,
    required this.tasks,
    required this.size,
    required this.textTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks.map((group) {
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
                        onPressed: () {},
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
            ...group['tasks'].asMap().entries.map((entry) {
              int index = entry.key + 1;
              var task = entry.value;
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
                                    "Task $index",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.04,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Text(
                                  task['taskName'],
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Assigned: ",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.hintTextColor,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Wrap(
                                  spacing: size.width * 0.015,
                                  runSpacing: size.height * 0.005,
                                  children: task['assigned'].map<Widget>((assignee) {
                                    return CircleAvatar(
                                      radius: size.width * 0.035,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        assignee,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size.width * 0.025,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.015),
                        Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              color: task['priority'] == 'High' ? Colors.red : Colors.blue,
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "Priority: ",
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.hintTextColor,
                                fontSize: size.width * 0.035,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.height * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color: task['priority'] == 'High' ? Colors.red[50] : Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task['priority'],
                                style: textTheme.bodySmall?.copyWith(
                                  color: task['priority'] == 'High' ? Colors.red : Colors.blue,
                                  fontSize: size.width * 0.035,
                                ),
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
                                "Due Date: ${task['dueDate']}",
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
                              Icons.note,
                              color: AppColors.primaryColor,
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Expanded(
                              child: Text(
                                "Notes: ${task['notes']}",
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
                              Icons.update,
                              color: AppColors.primaryColor,
                              size: size.width * 0.05,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Expanded(
                              child: Text(
                                "Last Updated: ${task['lastUpdated']}",
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
                    "Add Task",
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
  }
}