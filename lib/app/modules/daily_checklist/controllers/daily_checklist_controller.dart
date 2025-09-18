import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/models/batch_response_model.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';
import 'package:qr_buddy/app/data/repo/daily_checklist_repo.dart';
import 'package:qr_buddy/app/modules/daily_checklist/components/schedule_dialog.dart';

class DailyChecklistController extends GetxController {
  var selectedOption = 'Feedback Demo'.obs;
  var selectedTimeRange = 'Last 7 Days'.obs;
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var isLogExpanded = false.obs;

  /// Multi-selects
  var selectedLocations = <Location>{}.obs;
  var selectedUsers = <User>{}.obs;

  var isFiltered = false.obs;

  /// Stats
  var rounds = '0'.obs;
  var pending = '0'.obs;
  var done = '0'.obs;
  var npsScore = 0.obs;
  var promoters = '0.0'.obs;
  var passives = '0.0'.obs;
  var detractors = '0.0'.obs;

  var dailyChecklist = Rxn<DailyChecklistModel>();
  var isLoading = false.obs;
  var batchResponse = Rxn<BatchResponse>();

  final DailyChecklistRepository _repository;
  final TokenStorage _tokenStorage;

  DailyChecklistController(this._repository, this._tokenStorage);

  @override
  void onInit() {
    super.onInit();
    fetchData(useDateRange: false);
  }

  String _formatDateForApi(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _getCurrentDate() {
    final now = DateTime.now();
    return _formatDateForApi(now);
  }

  String formatDateForDisplay(DateTime? date) {
    if (date == null) return 'Not selected';
    return _formatDateForApi(date);
  }

  void updateDateRange() {
    final now = DateTime.now();
    switch (selectedTimeRange.value) {
      case 'Today':
        startDate.value = now;
        endDate.value = now;
        break;
      case 'Last 7 Days':
        startDate.value = now.subtract(const Duration(days: 7));
        endDate.value = now;
        break;
      case 'Last 30 Days':
        startDate.value = now.subtract(const Duration(days: 30));
        endDate.value = now;
        break;
      case 'Last 60 Days':
        startDate.value = now.subtract(const Duration(days: 60));
        endDate.value = now;
        break;
      case 'Last 90 Days':
        startDate.value = now.subtract(const Duration(days: 90));
        endDate.value = now;
        break;
      case 'This Month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate.value = lastMonth;
        endDate.value = DateTime(lastMonth.year, lastMonth.month + 1, 0);
        break;
    }
  }

  Future<void> fetchData({bool useDateRange = true, String? categoryId}) async {
    try {
      isLoading.value = true;
      final hcoId = await _tokenStorage.getHcoId();
      final userId = await _tokenStorage.getUserId();
      const phoneUuid = '5678b6baf95911ef8b460200d429951a';

      if (hcoId == null || userId == null) {
        CustomSnackbar.error('HCO ID or User ID not found');
        return;
      }

      String? dateFrom;
      String? dateTo;
      if (useDateRange) {
        dateFrom = startDate.value != null
            ? _formatDateForApi(startDate.value!)
            : _getCurrentDate();
        dateTo = endDate.value != null
            ? _formatDateForApi(endDate.value!)
            : _getCurrentDate();
      }

      final response = await _repository.fetchDailyChecklist(
        hcoId: hcoId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        userId: userId,
        phoneUuid: phoneUuid,
        hcoKey: '0',
        categoryId: categoryId,
      );

      dailyChecklist.value = response;

      rounds.value = response.stats.total.value.toString();
      pending.value = response.stats.pending.value.toString();
      done.value = response.stats.done.value.toString();
      npsScore.value = response.nps.score;
      promoters.value =
          response.nps.stats.firstWhere((s) => s.title == 'Promoters').value;
      passives.value =
          response.nps.stats.firstWhere((s) => s.title == 'Passives').value;
      detractors.value =
          response.nps.stats.firstWhere((s) => s.title == 'Detractors').value;

      if (dailyChecklist.value!.categories.isNotEmpty &&
          selectedOption.value.isEmpty) {
        selectedOption.value =
            dailyChecklist.value!.categories.first.categoryName;
      }

      CustomSnackbar.success('Data fetched successfully');
    } catch (e) {
      CustomSnackbar.error('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBatchForm() async {
    try {
      final hcoId = await _tokenStorage.getHcoId();
      final userId = await _tokenStorage.getUserId();
      const phoneUuid = '';

      if (hcoId == null || userId == null) {
        CustomSnackbar.error('HCO ID or User ID not found');
        return;
      }

      final response = await _repository.fetchBatchForm(
        hcoId: hcoId,
        userId: userId,
        phoneUuid: phoneUuid,
        hcoKey: '0',
      );

      batchResponse.value = response;
      print('Batch Response Locations: ${response.locations.map((l) => l.roomNumber).toList()}');
      print('Batch Response Users: ${response.users.map((u) => u.username).toList()}');
    } catch (e) {
      CustomSnackbar.error('Error fetching batch form: $e');
      batchResponse.value = null;
    }
  }

  void onSchedulePressed() {
    fetchBatchForm().then((_) {
      if (batchResponse.value != null) {
        Get.dialog(
          ScheduleDialog(controller: this),
          barrierDismissible: true,
        );
      }
    });
  }

  void onFilterPressed() {
    final selectedCategory = dailyChecklist.value?.categories
        .firstWhereOrNull((c) => c.categoryName == selectedOption.value);

    fetchData(
      useDateRange: true,
      categoryId: selectedCategory?.id,
    ).then((_) => isFiltered.value = true);
  }

  Future<void> sendInvitation() async {
    print('sendInvitation called');
    print('Selected Locations: ${selectedLocations.map((l) => l.roomNumber).toList()}');
    print('Selected Users: ${selectedUsers.map((u) => u.username).toList()}');
    print('Selected Category: ${selectedOption.value}');

    if (selectedLocations.isEmpty || selectedUsers.isEmpty || selectedOption.value.isEmpty) {
      CustomSnackbar.error('Please select at least one location, one user, and one category');
      return;
    }

    try {
      final hcoId = await _tokenStorage.getHcoId();
      final userId = await _tokenStorage.getUserId();
      const phoneUuid = '';
      const hcoKey = '0';

      if (hcoId == null || userId == null) {
        CustomSnackbar.error('HCO ID or User ID not found');
        return;
      }

      // Find the Category object for selectedOption
      final selectedCategory = dailyChecklist.value?.categories
          .firstWhereOrNull((c) => c.categoryName == selectedOption.value);
      if (selectedCategory == null) {
        CustomSnackbar.error('Selected category not found');
        return;
      }
      final categoryId = selectedCategory.id.toString();

      // Prepare room_ids and user_ids
      final roomIds = selectedLocations.map((location) => location.id).toList();
      final userIds = selectedUsers.map((user) => user.id).toList();

      print('Sending API request with:');
      print('Room IDs: $roomIds');
      print('User IDs: $userIds');
      print('Category ID: $categoryId');

      // Call the API
      await _repository.createBatchChecklist(
        hcoId: hcoId,
        userId: userId,
        phoneUuid: phoneUuid,
        hcoKey: hcoKey,
        roomIds: roomIds,
        userIds: userIds,
        categoryId: categoryId,
      );

      // Show success message for each combination
      for (var location in selectedLocations) {
        for (var user in selectedUsers) {
          CustomSnackbar.success(
            'Invitation sent to ${user.username} for ${location.roomNumber}',
          );
        }
      }

      Get.back();
      resetSelections();
    } catch (e) {
      CustomSnackbar.error('Error sending invitation: $e');
    }
  }

  void resetSelections() {
    selectedLocations.clear();
    selectedUsers.clear();
    print('Selections reset');
  }

  void toggleLocation(Location location) {
    if (selectedLocations.contains(location)) {
      selectedLocations.remove(location);
    } else {
      selectedLocations.add(location);
    }
    print('Toggled Location: ${location.roomNumber}, Selected: ${selectedLocations.map((l) => l.roomNumber).toList()}');
  }

  void toggleUser(User user) {
    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }
    print('Toggled User: ${user.username}, Selected: ${selectedUsers.map((u) => u.username).toList()}');
  }
}