import 'package:get/get.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
import 'package:qr_buddy/app/modules/auth/views/login_view.dart';
import 'package:qr_buddy/app/modules/daily_checklist/bindings/daily_checklist_binding.dart';
import 'package:qr_buddy/app/modules/daily_checklist/views/daily_checklist_view.dart';
import 'package:qr_buddy/app/modules/e_ticket/bindings/ticket_dashboard_binding.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/accept_ticket_screen.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/qr_scan_for_food_delivery.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/qr_scan_screen.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_dashboard_screen.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_details_screen.dart';
import 'package:qr_buddy/app/modules/new_ticket/bindings/new_ticket_bindings.dart';
import 'package:qr_buddy/app/modules/new_ticket/views/new_ticket_screen.dart';
import 'package:qr_buddy/app/modules/quality_rounds/bindings/quality_rounds_binding.dart';
import 'package:qr_buddy/app/modules/quality_rounds/views/quality_rounds_view.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class AppRoutes {
  static List<GetPage> appRoutes() => [
        GetPage(
          name: RoutesName.loginScreen,
          page: () => LoginView(),
          binding: AuthBinding(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: RoutesName.ticketDashboardView,
          page: () => const TicketDashboardScreen(),
          binding: TicketDashboardBinding(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: RoutesName.newtTicketView,
          page: () => const NewETicketScreen(),
          binding: NewTicketBinding(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: RoutesName.dailyChecklistView,
          page: () => const DailyChecklistView(),
          binding: DailyChecklistBinding(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: RoutesName.qualityRoundsScreen,
          page: () => const QualityRoundsView(),
          binding: QualityRoundsBinding(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: RoutesName.acceptTicketScreen,
          page: () => AcceptTicketScreen(
            ticket: Get.arguments as Ticket,
          ),
        ),
        GetPage(
          name: RoutesName.ticketDetailsView,
          page: () {
            // Retrieve the ticket argument passed during navigation
            final Ticket ticket = Get.arguments as Ticket;
            return TicketDetailScreen(ticket: ticket);
          },
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/qr-scan',
          page: () => const QrScanScreen(),
          transition: Transition.downToUp,
          transitionDuration: const Duration(milliseconds: 250),
        ),
          GetPage(
          name: RoutesName.qrScanForFoodDelivery,
          page: () => const QrScanForFoodDelivery(),
          transition: Transition.downToUp,
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ];
}
