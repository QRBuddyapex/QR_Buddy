import 'package:get/get.dart';
import 'package:qr_buddy/app/data/models/ticket.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart';
import 'package:qr_buddy/app/modules/auth/views/login_view.dart';
import 'package:qr_buddy/app/modules/e_ticket/bindings/ticket_dashboard_binding.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_dashboard_screen.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_details_screen.dart';
import 'package:qr_buddy/app/modules/new_ticket/bindings/new_ticket_bindings.dart';
import 'package:qr_buddy/app/modules/new_ticket/views/new_ticket_screen.dart';
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
          name: RoutesName.ticketDetailsView,
          page: () {
            // Retrieve the ticket argument passed during navigation
            final Ticket ticket = Get.arguments as Ticket;
            return TicketDetailScreen(ticket: ticket);
          },
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ];
}