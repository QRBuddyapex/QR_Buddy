import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/routes/routes.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/qr_buddy_logo.a2372aa9.png', height: 100),
                  const SizedBox(height: 10),
                  const Text(
                    'em@demo.com',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QR Locator'),
              subtitle: const Text('Search your location'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Task Manager'),
              onTap: () {},
            ),
            ListTile(
              selected: true,
              leading: const Icon(Icons.event_note),
              title: const Text('eTickets'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_drop_down),
              tileColor: AppColors.primaryColor.withOpacity(0.1),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New eTicket'),
              onTap: () {
                Get.toNamed(RoutesName.newtTicketView);
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Daily Checklist'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}