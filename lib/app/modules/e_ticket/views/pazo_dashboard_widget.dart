import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ticket_controller.dart';

class PazoDashboardWidget extends StatefulWidget {
  const PazoDashboardWidget({super.key});

  @override
  State<PazoDashboardWidget> createState() => _PazoDashboardWidgetState();
}

class _PazoDashboardWidgetState extends State<PazoDashboardWidget> with SingleTickerProviderStateMixin {
   final TicketController controller = Get.put(TicketController());
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orangeAccent;
    return Colors.red;
  }

  Color _getLineColor(int value) {
    if (value >= 50) return Colors.red;
    if (value >= 20) return Colors.orangeAccent;
    if (value >= 10) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final TicketController controller = Get.find<TicketController>();
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.28;
    final double circleSize = size.width * 0.3;

    return Container(
      color: const Color(0xFF2D2346),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B2E5B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.01),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Obx(() => SizedBox(
                                    width: circleSize,
                                    height: circleSize,
                                    child: CircularProgressIndicator(
                                      value: (controller.todayStatus.value / 100) * _progressAnimation.value,
                                      strokeWidth: 6,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getStatusColor(controller.todayStatus.value),
                                      ),
                                      backgroundColor: Colors.white24,
                                    ),
                                  ));
                                },
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Today's",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                  Text(
                                    "Status",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.035,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Obx(() => Text(
                                    "${controller.todayStatus.value}%",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: size.width * 0.045,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Obx(() => _infoCard(
                                "Flags",
                                controller.flags.value.toString(),
                                Icons.flag,
                                cardWidth,
                                size,
                                _getLineColor(controller.flags.value),
                              )),
                              SizedBox(width: size.width * 0.02),
                              Obx(() => _infoCard(
                                "Comments",
                                controller.comments.value.toString(),
                                Icons.comment,
                                cardWidth,
                                size,
                                _getLineColor(controller.comments.value),
                              )),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            children: [
                              Obx(() => _infoCard(
                                "Missed",
                                controller.missed.value.toString(),
                                Icons.close,
                                cardWidth,
                                size,
                                _getLineColor(controller.missed.value),
                              )),
                              SizedBox(width: size.width * 0.02),
                              Obx(() => _infoCard(
                                "Review Pending",
                                controller.reviewPending.value.toString(),
                                Icons.thumb_up,
                                cardWidth,
                                size,
                                _getLineColor(controller.reviewPending.value),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B2E5B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Obx(() => _bottomTabItem(
                    controller.schedules.value.toString(),
                    "Schedules",
                    true,
                    size,
                  )),
                  _verticalDivider(size),
                  Obx(() => _bottomTabItem(
                    controller.openIssues.value.toString(),
                    "Open Issues",
                    false,
                    size,
                  )),
                  _verticalDivider(size),
                  Obx(() => _bottomTabItem(
                    controller.tasks.value.toString(),
                    "Task",
                    false,
                    size,
                  )),
                  _verticalDivider(size),
                  Obx(() => _bottomTabItem(
                    controller.documents.value.toString(),
                    "Documents",
                    false,
                    size,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String count, IconData icon, double cardWidth, Size size, Color lineColor) {
    return Container(
      width: cardWidth,
      padding: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3C67),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3,
                width: size.width * 0.05,
                color: lineColor,
                margin: EdgeInsets.only(bottom: size.height * 0.01),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.03,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                count,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Positioned(
            bottom: size.height * 0.005,
            right: size.width * 0.01,
            child: Icon(
              icon,
              color: Colors.white60,
              size: size.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomTabItem(String count, String title, bool isActive, Size size) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.015),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.03,
              ),
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Container(
                margin: EdgeInsets.only(top: size.height * 0.007),
                height: 3,
                width: size.width * 0.075,
                color: Colors.orangeAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider(Size size) {
    return Container(
      height: size.height * 0.05,
      width: 1,
      color: Colors.white24,
    );
  }
}