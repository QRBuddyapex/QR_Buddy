import 'package:get/get.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart'; // Import the binding
import 'package:qr_buddy/app/modules/auth/views/login_view.dart';
import 'package:qr_buddy/app/modules/e_ticket/bindings/ticket_dashboard_binding.dart';
import 'package:qr_buddy/app/modules/e_ticket/views/ticket_dashboard_screen.dart';
import 'package:qr_buddy/app/routes/routes.dart';

class AppRoutes {
  static List<GetPage> appRoutes() => [
        GetPage(
          name: RoutesName.loginScreen,
          page: () =>  LoginView(),
          binding: AuthBinding(), // Attach the binding here
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
         GetPage(
          name: RoutesName.ticketDashboardView,
          page: () =>  TicketDashboardScreen(),
          binding: TicketDashboardBinding(), // Attach the binding here
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ];
}