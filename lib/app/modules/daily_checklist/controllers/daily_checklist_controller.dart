import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyChecklistController extends GetxController {
  var selectedOption = 'Feedback Demo'.obs;
  var selectedTimeRange = 'Last 7 Days'.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;
  var isLogExpanded = false.obs;

  // Observable variables for stats
  var rounds = '0'.obs;
  var pending = '0'.obs;
  var done = '0'.obs;
  var npsScore = 0.obs;
  var promoters = '0.0'.obs;
  var passives = '0.0'.obs;
  var detractors = '0.0'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() {
    // Simulate API call based on selected option
    // In real implementation, replace with actual API calls
    switch (selectedOption.value) {
      case 'Feedback Demo':
        updateFeedbackDemoData();
        break;
      case 'Customer Satisfaction':
        updateCustomerSatisfactionData();
        break;
      // Add other cases for different options
    }
  }

  void updateFeedbackDemoData() {
    // Simulate data update
    rounds.value = '5';
    pending.value = '2';
    done.value = '3';
    promoters.value = '60.0';
    passives.value = '30.0';
    detractors.value = '10.0';
    npsScore.value = 50;
  }

  void updateCustomerSatisfactionData() {
    // Different data for customer satisfaction
    rounds.value = '8';
    pending.value = '3';
    done.value = '5';
    promoters.value = '70.0';
    passives.value = '20.0';
    detractors.value = '10.0';
    npsScore.value = 60;
  }
}
