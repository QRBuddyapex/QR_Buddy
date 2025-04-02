import 'package:get/get.dart';
import 'package:qr_buddy/app/modules/auth/bindings/auth_binding.dart'; // Import the binding
import 'package:qr_buddy/app/modules/auth/views/login_view.dart';
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
      ];
}