// // app/modules/daily_checklist/views/invite_dialog.dart (new file)
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qr_buddy/app/core/theme/app_theme.dart';
// import 'package:qr_buddy/app/data/models/batch_response_model.dart';


// class InviteDialog extends StatefulWidget {
//   final BatchResponse batchForm;

//   const InviteDialog({super.key, required this.batchForm});

//   @override
//   State<InviteDialog> createState() => _InviteDialogState();
// }

// class _InviteDialogState extends State<InviteDialog> {
//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final textTheme = Theme.of(context).textTheme;

//     return AlertDialog(
//       backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Back Trends'),
//           ),
//           const Text('Send invitation for Checklist/feedback'),
//           const SizedBox(width: 0), // Placeholder for alignment
//         ],
//       ),
//       content: StatefulBuilder(
//         builder: (context, setState) {
//           List<String> selectedLocationIds = [];
//           List<String> selectedUserIds = [];

//           return SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('Select Location'),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor),
//                   ),
//                   child: ListView.builder(
//                     itemCount: widget.batchForm.locations.length,
//                     itemBuilder: (context, index) {
//                       final location = widget.batchForm.locations[index];
//                       return CheckboxListTile(
//                         title: Text(
//                           location.roomNumber,
//                           style: textTheme.bodySmall?.copyWith(
//                             color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
//                           ),
//                         ),
//                         value: selectedLocationIds.contains(location.id),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             if (value == true) {
//                               selectedLocationIds.add(location.id);
//                             } else {
//                               selectedLocationIds.remove(location.id);
//                             }
//                           });
//                         },
//                         controlAffinity: ListTileControlAffinity.leading,
//                         dense: true,
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text('Select User'),
//                 const SizedBox(height: 8),
//                 Container(
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor),
//                   ),
//                   child: ListView.builder(
//                     itemCount: widget.batchForm.users.length,
//                     itemBuilder: (context, index) {
//                       final user = widget.batchForm.users[index];
//                       return CheckboxListTile(
//                         title: Text(
//                           user.username,
//                           style: textTheme.bodySmall?.copyWith(
//                             color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
//                           ),
//                         ),
//                         value: selectedUserIds.contains(user.id),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             if (value == true) {
//                               selectedUserIds.add(user.id);
//                             } else {
//                               selectedUserIds.remove(user.id);
//                             }
//                           });
//                         },
//                         controlAffinity: ListTileControlAffinity.leading,
//                         dense: true,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: Text(
//             'Cancel',
//             style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryColor),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             // TODO: Implement actual send invitation API call
//             // if (/* selectedLocationIds.isNotEmpty && selectedUserIds.isNotEmpty */) {
//             //   CustomSnackbar.success('Invitation sent successfully');
//             //   Get.back();
//             // } else {
//             //   CustomSnackbar.error('Please select at least one location and one user');
//             // }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryColor,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           child: const Text(
//             'Send invitation now',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ],
//     );
//   }
// }