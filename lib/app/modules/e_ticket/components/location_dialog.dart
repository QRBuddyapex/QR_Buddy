import 'package:flutter/material.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

import 'custom_button.dart';

class LocationDialog extends StatefulWidget {
  const LocationDialog({Key? key}) : super(key: key);

  @override
  _LocationDialogState createState() => _LocationDialogState();
}

class _LocationDialogState extends State<LocationDialog> {
  Map<String, List<String>> subLocations = {
    'Edison-GF': ['Check All', 'Apple', 'Chai Point', 'Management Office', 'Bira', 'Reception Area', 'Store', 'Pvt 102', 'Server Room', 'Burger Singh'],
    '-GF': [],
    '-FF': ['Pvt 102'],
    '-2nd': ['Pvt 102'],
  };

  Map<String, Set<String>> selectedSubLocations = {
    'Edison-GF': {},
    '-GF': {},
    '-FF': {},
    '-2nd': {},
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const Text(
                'Users who need a specific set of rooms are only eligible for this option',
                style: TextStyle(color: AppColors.primaryColor, fontSize: 12),
              ),
              const SizedBox(height: 10),

              // Location Cards
              ...subLocations.keys.map((location) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: AppColors.cardBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Text(location, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 5),
                        Text(
                          '${selectedSubLocations[location]!.length}/${subLocations[location]!.length}',
                          style: const TextStyle(color: AppColors.hintTextColor),
                        ),
                      ],
                    ),
                    children: subLocations[location]!.isNotEmpty
                        ? [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: subLocations[location]!.map((subLoc) {
                                  final isCheckAll = subLoc == 'Check All';
                                  final isChecked = selectedSubLocations[location]!.contains(subLoc);

                                  return CheckboxListTile(
                                    title: Text(
                                      subLoc,
                                      style: TextStyle(
                                        color: isChecked ? Colors.red : AppColors.textColor, // Red for checked, default for unchecked
                                      ),
                                    ),
                                    value: isCheckAll
                                        ? selectedSubLocations[location]!.length ==
                                            subLocations[location]!.where((e) => e != 'Check All').length
                                        : isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (isCheckAll) {
                                          if (value == true) {
                                            selectedSubLocations[location]!.addAll(
                                              subLocations[location]!.where((e) => e != 'Check All'),
                                            );
                                          } else {
                                            selectedSubLocations[location]!.clear();
                                          }
                                        } else {
                                          if (value == true) {
                                            selectedSubLocations[location]!.add(subLoc);
                                          } else {
                                            selectedSubLocations[location]!.remove(subLoc);
                                          }
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ),
                          ]
                        : [],
                  ),
                );
              }).toList(),

              const SizedBox(height: 10),

              const Text(
                'Please browse through the provided list of available rooms and select the ones that best suit your needs.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),

              CustomButton(
                onPressed: () {
                  // Handle selected rooms update
                  print("Selected Rooms: $selectedSubLocations");
                  Navigator.pop(context);
                },
                label: 'Update Selected Rooms',
                backgroundColor: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}