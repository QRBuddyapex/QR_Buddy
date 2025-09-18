import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/core/widgets/custom_buttom.dart';
import 'package:qr_buddy/app/data/models/location_model.dart';
import 'package:qr_buddy/app/data/repo/location_repo.dart';

class LocationDialogController extends GetxController {
  final LocationRepository locationRepo = LocationRepository();
  final TokenStorage tokenStorage = TokenStorage();

  var isLoading = false.obs;
  var blocks = <Block>[].obs;
  var floors = <Floor>[].obs;
  var rooms = <Room>[].obs;
  var selectedRooms = <String>{}.obs; // Store room IDs

  @override
  void onInit() {
    super.onInit();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      isLoading.value = true;
      final userId = await tokenStorage.getUserId() ?? '3229';
      final hcoId = await tokenStorage.getHcoId() ?? '78';
      final response = await locationRepo.fetchLocations(
        hcoId: hcoId,
        userId: userId,
      );
      blocks.assignAll(response.blocks);
      floors.assignAll(response.floors);
      rooms.assignAll(response.rooms);
    } catch (e) {
      CustomSnackbar.error('Failed to load locations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSelectedRooms() async {
    try {
      isLoading.value = true;
      final userId = await tokenStorage.getUserId() ?? '3229';
      final hcoId = await tokenStorage.getHcoId() ?? '78';
      final selectedRoomList = rooms
          .where((room) => selectedRooms.contains(room.id))
          .map((room) => SelectedRoom(
                blockId: room.blockId,
                floorId: room.floorId,
                roomId: room.id,
              ))
          .toList();

      final response = await locationRepo.saveLocations(
        userId: userId,
        hcoId: hcoId,
        rooms: selectedRoomList,
      );

      CustomSnackbar.success('Rooms updated: ${response.rooms}');
    } catch (e) {
      CustomSnackbar.error('Failed to save rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class LocationDialog extends StatelessWidget {
  const LocationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationDialogController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: isDarkMode ? AppColors.darkCardBackgroundColor : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 300,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // Group rooms by block and floor
          final groupedLocations = <String, Map<String, List<Room>>>{};
          for (var block in controller.blocks) {
            groupedLocations[block.blockName] = {};
            for (var floor in controller.floors) {
              final key = '${block.blockName}-${floor.floorName}';
              groupedLocations[block.blockName]![floor.floorName] = controller.rooms
                  .where((room) => room.blockId == block.id && room.floorId == floor.id)
                  .toList();
            }
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                          ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? AppColors.darkHintTextColor : AppColors.hintTextColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Users who need a specific set of rooms are only eligible for this option',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 10),
                ...groupedLocations.keys.map((blockName) {
                  final floors = groupedLocations[blockName]!;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: isDarkMode ? AppColors.darkCardBackgroundColor : AppColors.cardBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isDarkMode ? AppColors.darkBorderColor : AppColors.borderColor,
                      ),
                    ),
                    elevation: isDarkMode ? 2 : 4,
                    child: ExpansionTile(
                      title: Text(
                        blockName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                            ),
                      ),
                      children: floors.keys.map((floorName) {
                        final rooms = floors[floorName]!;
                        final selectedCount = rooms.where((room) => controller.selectedRooms.contains(room.id)).length;
                        return ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                floorName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                    ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$selectedCount/${rooms.length}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDarkMode ? AppColors.darkHintTextColor : AppColors.hintTextColor,
                                    ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: Text(
                                      'Check All',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isDarkMode ? AppColors.darkTextColor : AppColors.textColor,
                                          ),
                                    ),
                                    value: selectedCount == rooms.length,
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        controller.selectedRooms.addAll(rooms.map((room) => room.id));
                                      } else {
                                        controller.selectedRooms.removeAll(rooms.map((room) => room.id));
                                      }
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    activeColor: AppColors.primaryColor,
                                    checkColor: Colors.white,
                                  ),
                                  ...rooms.map((room) {
                                    final isChecked = controller.selectedRooms.contains(room.id);
                                    return CheckboxListTile(
                                      title: Text(
                                        room.roomNumber,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: isChecked
                                                  ? AppColors.dangerButtonColor
                                                  : (isDarkMode ? AppColors.darkTextColor : AppColors.textColor),
                                            ),
                                      ),
                                      value: isChecked,
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          controller.selectedRooms.add(room.id);
                                        } else {
                                          controller.selectedRooms.remove(room.id);
                                        }
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                      activeColor: AppColors.primaryColor,
                                      checkColor: Colors.white,
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 10),
                Text(
                  'Please browse through the provided list of available rooms and select the ones that best suit your needs.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkSubtitleColor : AppColors.subtitleColor,
                      ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  width: double.infinity,
                  onPressed: () async {
                    await controller.saveSelectedRooms();
                    Navigator.pop(context);
                  },
                  text: 'Update Selected Rooms',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}