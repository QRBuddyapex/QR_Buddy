import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse('tel:${ticket.phoneNumber}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch dialer. Please check permissions or try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open dialer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(ticket.orderNumber, style: Theme.of(context).textTheme.headlineSmall),
          backgroundColor: AppColors.cardBackgroundColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.hintTextColor),
            onPressed: () => Get.back(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: AppColors.cardBackgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.hintTextColor),
                      const SizedBox(width: 8),
                      Text(ticket.orderNumber, style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      const Icon(Icons.location_on, color: AppColors.hintTextColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Phone Number', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _launchPhone(ticket.phoneNumber),
                        child: Text(ticket.phoneNumber, style: TextStyle(color: AppColors.linkColor, fontSize: 16, fontFamily: GoogleFonts.poppins().fontFamily)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Priority', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Normal', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.linkColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Department', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(ticket.department, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Location', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(ticket.block, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Date/Time', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(ticket.date, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Assigned to', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(ticket.assignedTo, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Addons', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> addonEntries = [
                        {
                          'time': '10:45 AM',
                          'date': '22/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 22/04/2025 10:44 AM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '10:40 AM',
                          'date': '22/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 22/04/2025 10:39 AM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:36 PM',
                          'date': '15/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 15/04/2025 07:35 PM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:31 PM',
                          'date': '15/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 15/04/2025 07:30 PM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:21 PM',
                          'date': '15/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 22/04/2025 10:39 AM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:16 PM',
                          'date': '15/04/2025',
                          'description': 'Escalation made for - Request # - overdue. Submitted 15/04/2025 07:10 PM, due on 15/04/2025 07:15 PM. Pls resolve ASAP. Need prompt action. Thx.',
                          'icon': Icons.flag,
                          'iconColor': AppColors.escalationIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:10 PM',
                          'date': '15/04/2025',
                          'description': 'Ticket #MAX00309 is assigned to ${ticket.assignedTo}@demo.com (${ticket.assignedTo}@demo.com)',
                          'icon': Icons.person,
                          'iconColor': AppColors.assignmentIconColor,
                          'hasWhatsApp': true,
                        },
                        {
                          'time': '07:10 PM',
                          'date': '15/04/2025',
                          'description': 'Ticket #MAX00309 is accepted by ${ticket.assignedTo}@demo.com (CLIENT)',
                          'icon': Icons.person,
                          'iconColor': AppColors.assignmentIconColor,
                          'hasWhatsApp': true,
                        },
                      ];

                      final entry = addonEntries[index];

                      return Stack(
                        children: [
                          Positioned(
                            left: context.width * 0.025689,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                            leading: Icon(
                              entry['icon'],
                              color: entry['iconColor'],
                              size: 24,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  entry['time'],
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry['date'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry['description'],
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                if (entry['hasWhatsApp'])
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.whatsappIconColor,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(ticket.description, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(ticket.block, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomButton(
              width: context.width * 0.2,
              onPressed: () {},
              text: 'Accept',
            ),
            CustomButton(
              width: context.width * 0.2,
              onPressed: () {},
              text: 'Start',
            ),
            CustomButton(
              width: context.width * 0.2,
              onPressed: () {},
              text: 'Complete',
            ),
            CustomButton(
              width: context.width * 0.2,
              onPressed: () {},
              text: 'Hold',
            ),
          ],
        ),
     
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        width: context.width * 0.3,
                        onPressed: () {},
                        text: 'ReOpen',
                      ),
                      CustomButton(
                        width: context.width * 0.2,
                        onPressed: () {},
                       
                        text: 'Verify',
                      ),
                      CustomButton(
                        width: context.width * 0.2,
                        onPressed: () {},
                        color: Colors.red,
                        text: 'Cancel',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Transfer to',
                      suffixIcon: const Icon(Icons.search),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SafeArea(
                    child: SizedBox(
                      height: context.height * 0.06,
                      width: double.infinity,
                      child: Card(
                        color: AppColors.whatsappIconColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          
                          children: [
                            Text(ticket.assignedTo, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                           
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('19', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green)),
                            ),
                            
                            Text('Not Available', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red,fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}