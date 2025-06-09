import 'package:get/get.dart';
import 'package:qr_buddy/app/core/config/token_storage.dart';
import 'package:qr_buddy/app/core/utils/snackbar.dart';
import 'package:qr_buddy/app/data/models/daily_checklist_model.dart';
import 'package:qr_buddy/app/data/repo/daily_checklist_repo.dart';

class DailyChecklistController extends GetxController {
  var selectedOption = 'Feedback Demo'.obs; // Will now hold category_name
  var selectedTimeRange = 'Last 7 Days'.obs;
  var startDate = Rxn<DateTime>(); // Initially null (empty)
  var endDate = Rxn<DateTime>(); // Initially null (empty)
  var isLogExpanded = false.obs;

  // Observable variables for stats
  var rounds = '0'.obs;
  var pending = '0'.obs;
  var done = '0'.obs;
  var npsScore = 0.obs;
  var promoters = '0.0'.obs;
  var passives = '0.0'.obs;
  var detractors = '0.0'.obs;

  // Observable for API data
  var dailyChecklist = Rxn<DailyChecklistModel>();
  var isLoading = false.obs;

  final DailyChecklistRepository _repository;
  final TokenStorage _tokenStorage;

  DailyChecklistController(this._repository, this._tokenStorage);

  @override
  void onInit() {
    super.onInit();
    fetchData(useDateRange: false); // Initial fetch with empty dates
  }

  // Format date for API (e.g., "2025-06-09")
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Format date for display (e.g., "2025-06-09")
  String formatDateForDisplay(DateTime? date) {
    if (date == null) return 'Not selected';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Calculate date range based on selected time range
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
        endDate.value = DateTime(lastMonth.year, lastMonth.month + 1, 0); // Last day of previous month
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
      if (useDateRange && startDate.value != null && endDate.value != null) {
        dateFrom = _formatDateForApi(startDate.value!);
        dateTo = _formatDateForApi(endDate.value!);
      }

      final response = await _repository.fetchDailyChecklist(
        hcoId: hcoId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        userId: userId,
        phoneUuid: phoneUuid,
        hcoKey: '0',
        categoryId: categoryId, // Pass the category_id
      );

      dailyChecklist.value = response;

      // Update stats based on API response
      rounds.value = response.stats.total.value.toString();
      pending.value = response.stats.pending.value.toString();
      done.value = response.stats.done.value.toString();
      npsScore.value = response.nps.score;
      promoters.value = response.nps.stats
          .firstWhere((stat) => stat.title == 'Promoters')
          .value;
      passives.value = response.nps.stats
          .firstWhere((stat) => stat.title == 'Passives')
          .value;
      detractors.value = response.nps.stats
          .firstWhere((stat) => stat.title == 'Detractors')
          .value;

      // Set default selected option if not set
      if (dailyChecklist.value!.categories.isNotEmpty &&
          selectedOption.value.isEmpty) {
        selectedOption.value = dailyChecklist.value!.categories.first.categoryName;
      }

      CustomSnackbar.success('Data fetched successfully');
    } catch (e) {
      CustomSnackbar.error('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Handle filter button press
  void onFilterPressed() {
    if (startDate.value == null || endDate.value == null) {
      CustomSnackbar.error('Please select both start and end dates');
      return;
    }
    // Find the category ID for the selected option
    final selectedCategory = dailyChecklist.value?.categories
        .firstWhereOrNull((cat) => cat.categoryName == selectedOption.value);
    fetchData(
      useDateRange: true,
      categoryId: selectedCategory?.id,
    );
  }
}