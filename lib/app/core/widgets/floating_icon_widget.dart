// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qr_buddy/app/modules/e_ticket/controllers/shift_controller.dart';

// class CircularFloatingMenu extends StatefulWidget {
//   final double mainSize; // Main button size
//   final double itemSize; // Floating buttons size
//   final double radius; // Distance from main button
//   const CircularFloatingMenu({
//     Key? key,
//     this.mainSize = 60,
//     this.itemSize = 50,
//     this.radius = 100,
//   }) : super(key: key);

//   @override
//   State<CircularFloatingMenu> createState() => _CircularFloatingMenuState();
// }

// class _CircularFloatingMenuState extends State<CircularFloatingMenu>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   bool isOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//   }

//   void toggleMenu() {
//     if (isOpen) {
//       _controller.reverse();
//     } else {
//       _controller.forward();
//     }
//     setState(() => isOpen = !isOpen);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Define buttons: icon, color, and action
//     final buttons = [
//       {
//         'icon': Icons.pause,
//         'color': Colors.orange,
//         'action': () => Get.find<ShiftController>().updateShiftStatus('BREAK')
//       },
//       {
//         'icon': Icons.play_arrow,
//         'color': Colors.green,
//         'action': () => Get.find<ShiftController>().updateShiftStatus('START')
//       },
//       {
//         'icon': Icons.close,
//         'color': Colors.red,
//         'action': () => Get.find<ShiftController>().updateShiftStatus('END')
//       },
//     ];

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Floating buttons
//         ...List.generate(buttons.length, (index) {
//           final angle = -pi / 2 + (index * pi / (buttons.length - 1));
//           return AnimatedBuilder(
//             animation: _controller,
//             builder: (_, __) {
//               final offset = Offset.fromDirection(angle, widget.radius * _controller.value);
//               return Transform.translate(
//                 offset: offset,
//                 child: Opacity(
//                   opacity: _controller.value,
//                   child: FloatingActionButton(
//                     heroTag: 'button_$index',
//                     onPressed: () {
//                       buttons[index]['action']!;
//                       toggleMenu();
//                     },
//                     backgroundColor: buttons[index]['color'] as Color,
//                     mini: true,
//                     child: Icon(buttons[index]['icon'] as IconData),
//                   ),
//                 ),
//               );
//             },
//           );
//         }),
//         // Main button
//         FloatingActionButton(
//           heroTag: 'main_button',
//           onPressed: toggleMenu,
//           child: AnimatedBuilder(
//             animation: _controller,
//             builder: (_, __) {
//               return Transform.rotate(
//                 angle: _controller.value * pi / 4,
//                 child: Icon(isOpen ? Icons.close : Icons.menu),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
