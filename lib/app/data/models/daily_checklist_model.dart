class DailyChecklistModel {
  List<Category> categories;
  dynamic category;
  Map<String, Room> rooms;
  List<String> dates;
  Map<String, Map<String, List<RoundData>>> roundData;
  Nps nps;
  ChartData chartData;
  Stats stats;
  List<Reply> replies;
  CSat cSat;
  Ces ces;
  FeedbackDistribution feedbackDistribution;
  int status;
  String message;

  DailyChecklistModel({
    required this.categories,
    this.category,
    required this.rooms,
    required this.dates,
    required this.roundData,
    required this.nps,
    required this.chartData,
    required this.stats,
    required this.replies,
    required this.cSat,
    required this.ces,
    required this.feedbackDistribution,
    required this.status,
    required this.message,
  });

  factory DailyChecklistModel.fromJson(Map<String, dynamic> json) {
    Map<String, Room> parseRooms(dynamic roomsJson) {
      if (roomsJson is List) {
        return {};
      } else if (roomsJson is Map<String, dynamic>) {
        return roomsJson.map(
          (key, value) => MapEntry(key, Room.fromJson(value)),
        );
      }
      return {};
    }

    Map<String, Map<String, List<RoundData>>> parseRoundData(dynamic roundDataJson) {
      if (roundDataJson is List) {
        return {};
      } else if (roundDataJson is Map<String, dynamic>) {
        return roundDataJson.map(
          (key, value) => MapEntry(
            key,
            (value as Map<String, dynamic>).map(
              (k, v) => MapEntry(
                k,
                (v as List).map((item) => RoundData.fromJson(item)).toList(),
              ),
            ),
          ),
        );
      }
      return {};
    }

    return DailyChecklistModel(
      categories: (json['categories'] as List)
          .map((item) => Category.fromJson(item))
          .toList(),
      category: json['category'],
      rooms: parseRooms(json['rooms']),
      dates: List<String>.from(json['dates'] ?? []),
      roundData: parseRoundData(json['round_data']),
      nps: Nps.fromJson(json['nps']),
      chartData: ChartData.fromJson(json['chartData']),
      stats: Stats.fromJson(json['stats']),
      replies: (json['replies'] as List)
          .map((item) => Reply.fromJson(item))
          .toList(),
      cSat: CSat.fromJson(json['c_sat']),
      ces: Ces.fromJson(json['ces']),
      feedbackDistribution:
          FeedbackDistribution.fromJson(json['feedback_distribution']),
      status: (json['status'] is double
          ? (json['status'] as double).toInt()
          : json['status'] as int? ?? 0),
      message: json['message']?.toString() ?? '',
    );
  }
}

class Category {
  String id;
  String uuid;
  String type;
  String categoryName;
  String iconUrl;
  String frequencies;
  String statusLogin;
  String statusNoScheduling;
  String statusNps;
  String status;

  Category({
    required this.id,
    required this.uuid,
    required this.type,
    required this.categoryName,
    required this.iconUrl,
    required this.frequencies,
    required this.statusLogin,
    required this.statusNoScheduling,
    required this.statusNps,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString() ?? '',
      frequencies: json['frequencies']?.toString() ?? '',
      statusLogin: json['status_login']?.toString() ?? '',
      statusNoScheduling: json['status_no_scheduling']?.toString() ?? '',
      statusNps: json['status_nps']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}

class Room {
  String blockName;
  String floorName;
  String roomNumber;

  Room({
    required this.blockName,
    required this.floorName,
    required this.roomNumber,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      blockName: json['block_name']?.toString() ?? '',
      floorName: json['floor_name']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? '',
    );
  }
}

class RoundData {
  String id;
  String uuid;
  String parameterCategoryId;
  String roundStatus;
  String dateEnd;
  String roomId;
  String stockId;
  String npsScore;
  String npsType;
  String npsStatus;
  String projectId;
  String roundTitle;
  String remarks;
  String dateStart;
  String rating;
  String cesScore;
  String csatScore;
  String source;
  String dateSchedule;
  String dtSchedule;
  String timeSchedule;
  String blockName;
  String floorName;
  String roomNumber;
  String? itemName;
  String? assetNumber;
  String month;

  RoundData({
    required this.id,
    required this.uuid,
    required this.parameterCategoryId,
    required this.roundStatus,
    required this.dateEnd,
    required this.roomId,
    required this.stockId,
    required this.npsScore,
    required this.npsType,
    required this.npsStatus,
    required this.projectId,
    required this.roundTitle,
    required this.remarks,
    required this.dateStart,
    required this.rating,
    required this.cesScore,
    required this.csatScore,
    required this.source,
    required this.dateSchedule,
    required this.dtSchedule,
    required this.timeSchedule,
    required this.blockName,
    required this.floorName,
    required this.roomNumber,
    this.itemName,
    this.assetNumber,
    required this.month,
  });

  factory RoundData.fromJson(Map<String, dynamic> json) {
    return RoundData(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      parameterCategoryId: json['parameter_category_id']?.toString() ?? '',
      roundStatus: json['round_status']?.toString() ?? '',
      dateEnd: json['date_end']?.toString() ?? '',
      roomId: json['room_id']?.toString() ?? '',
      stockId: json['stock_id']?.toString() ?? '',
      npsScore: json['nps_score']?.toString() ?? '',
      npsType: json['nps_type']?.toString() ?? '',
      npsStatus: json['nps_status']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      roundTitle: json['round_title']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      dateStart: json['date_start']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      cesScore: json['ces_score']?.toString() ?? '',
      csatScore: json['csat_score']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      dateSchedule: json['date_schedule']?.toString() ?? '',
      dtSchedule: json['dt_schedule']?.toString() ?? '',
      timeSchedule: json['time_schedule']?.toString() ?? '',
      blockName: json['block_name']?.toString() ?? '',
      floorName: json['floor_name']?.toString() ?? '',
      roomNumber: json['room_number']?.toString() ?? '',
      itemName: json['item_name']?.toString(),
      assetNumber: json['asset_number']?.toString(),
      month: json['month']?.toString() ?? '',
    );
  }
}

class Nps {
  int npsResponses;
  int npsPromoters;
  int npsPassives;
  int npsDetractors;
  int score;
  List<Stat> stats;

  Nps({
    required this.npsResponses,
    required this.npsPromoters,
    required this.npsPassives,
    required this.npsDetractors,
    required this.score,
    required this.stats,
  });

  factory Nps.fromJson(Map<String, dynamic> json) {
    return Nps(
      npsResponses: (json['npsResponses'] is double
          ? (json['npsResponses'] as double).toInt()
          : json['npsResponses'] as int? ?? 0),
      npsPromoters: (json['npsPromoters'] is double
          ? (json['npsPromoters'] as double).toInt()
          : json['npsPromoters'] as int? ?? 0),
      npsPassives: (json['npsPassives'] is double
          ? (json['npsPassives'] as double).toInt()
          : json['npsPassives'] as int? ?? 0),
      npsDetractors: (json['npsDetractors'] is double
          ? (json['npsDetractors'] as double).toInt()
          : json['npsDetractors'] as int? ?? 0),
      score: (json['score'] is double
          ? (json['score'] as double).toInt()
          : json['score'] as int? ?? 0),
      stats: (json['stats'] as List<dynamic>?)
              ?.map((item) => Stat.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Stat {
  String title;
  String value;
  String color;
  String icon;

  Stat({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      title: json['title']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }
}

class ChartData {
  LineChart line;
  BarChart bar;

  ChartData({
    required this.line,
    required this.bar,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      line: LineChart.fromJson(json['line']),
      bar: BarChart.fromJson(json['bar']),
    );
  }
}

class LineChart {
  XAxis xaxis;
  List<Series> series;

  LineChart({
    required this.xaxis,
    required this.series,
  });

  factory LineChart.fromJson(Map<String, dynamic> json) {
    return LineChart(
      xaxis: XAxis.fromJson(json['xaxis']),
      series: (json['series'] as List<dynamic>?)
              ?.map((item) => Series.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class BarChart {
  XAxis xaxis;
  List<Series> seriesLine;

  BarChart({
    required this.xaxis,
    required this.seriesLine,
  });

  factory BarChart.fromJson(Map<String, dynamic> json) {
    return BarChart(
      xaxis: XAxis.fromJson(json['xaxis']),
      seriesLine: (json['seriesLine'] as List<dynamic>?)
              ?.map((item) => Series.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class XAxis {
  List<String> categories;
  Title title;

  XAxis({
    required this.categories,
    required this.title,
  });

  factory XAxis.fromJson(Map<String, dynamic> json) {
    return XAxis(
      categories: List<String>.from(json['categories'] ?? []),
      title: Title.fromJson(json['title']),
    );
  }
}

class Title {
  String text;

  Title({
    required this.text,
  });

  factory Title.fromJson(Map<String, dynamic> json) {
    return Title(
      text: json['text']?.toString() ?? '',
    );
  }
}

class Series {
  String name;
  List<dynamic> data;

  Series({
    required this.name,
    required this.data,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      name: json['name']?.toString() ?? '',
      data: json['data'] ?? [],
    );
  }
}

class Stats {
  StatItem total;
  StatItem pending;
  StatItem done;

  Stats({
    required this.total,
    required this.pending,
    required this.done,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      total: StatItem.fromJson(json['total']),
      pending: StatItem.fromJson(json['pending']),
      done: StatItem.fromJson(json['done']),
    );
  }
}

class StatItem {
  String title;
  int value;
  String color;
  int cols;
  String icon;

  StatItem({
    required this.title,
    required this.value,
    required this.color,
    required this.cols,
    required this.icon,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      title: json['title']?.toString() ?? '',
      value: (json['value'] is double
          ? (json['value'] as double).toInt()
          : json['value'] as int? ?? 0),
      color: json['color']?.toString() ?? '',
      cols: (json['cols'] is double
          ? (json['cols'] as double).toInt()
          : json['cols'] as int? ?? 0),
      icon: json['icon']?.toString() ?? '',
    );
  }
}

class Reply {
  String question;
  int max;
  List<Answer> answers;

  Reply({
    required this.question,
    required this.max,
    required this.answers,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      question: json['question']?.toString() ?? '',
      max: (json['max'] is double
          ? (json['max'] as double).toInt()
          : json['max'] as int? ?? 0),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((item) => Answer.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Answer {
  String title;
  String icon;
  String color;
  int value;

  Answer({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      value: (json['value'] is double
          ? (json['value'] as double).toInt()
          : json['value'] as int? ?? 0),
    );
  }
}

class CSat {
  List<FeedbackStat> feedbackStats;
  int score;

  CSat({
    required this.feedbackStats,
    required this.score,
  });

  factory CSat.fromJson(Map<String, dynamic> json) {
    return CSat(
      feedbackStats: (json['feedbackStats'] as List<dynamic>?)
              ?.map((item) => FeedbackStat.fromJson(item))
              .toList() ??
          [],
      score: (json['score'] is double
          ? (json['score'] as double).toInt()
          : json['score'] as int? ?? 0),
    );
  }
}

class FeedbackStat {
  String title;
  int value;
  String color;
  String icon;

  FeedbackStat({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  factory FeedbackStat.fromJson(Map<String, dynamic> json) {
    return FeedbackStat(
      title: json['title']?.toString() ?? '',
      value: (json['value'] is double
          ? (json['value'] as double).toInt()
          : json['value'] as int? ?? 0),
      color: json['color']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }
}

class Ces {
  int cesScore;
  List<CesStat> cesStats;

  Ces({
    required this.cesScore,
    required this.cesStats,
  });

  factory Ces.fromJson(Map<String, dynamic> json) {
    return Ces(
      cesScore: (json['ces_score'] is double
          ? (json['ces_score'] as double).toInt()
          : json['ces_score'] as int? ?? 0),
      cesStats: (json['ces_stats'] as List<dynamic>?)
              ?.map((item) => CesStat.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CesStat {
  String title;
  int value;
  String color;
  String icon;

  CesStat({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  factory CesStat.fromJson(Map<String, dynamic> json) {
    return CesStat(
      title: json['title']?.toString() ?? '',
      value: (json['value'] is double
          ? (json['value'] as double).toInt()
          : json['value'] as int? ?? 0),
      color: json['color']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }
}

class FeedbackDistribution {
  List<String> labels;
  List<int> series;
  List<FeedbackSource> feedbackSource;

  FeedbackDistribution({
    required this.labels,
    required this.series,
    required this.feedbackSource,
  });

  factory FeedbackDistribution.fromJson(Map<String, dynamic> json) {
    return FeedbackDistribution(
      labels: List<String>.from(json['labels'] ?? []),
      series: (json['series'] as List<dynamic>?)
              ?.map((item) => (item is double ? item.toInt() : item as int? ?? 0))
              .toList() ??
          [],
      feedbackSource: (json['feedback_source'] as List<dynamic>?)
              ?.map((item) => FeedbackSource.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FeedbackSource {
  String mode;
  Map<String, int> category;
  int total;

  FeedbackSource({
    required this.mode,
    required this.category,
    required this.total,
  });

  factory FeedbackSource.fromJson(Map<String, dynamic> json) {
    return FeedbackSource(
      mode: json['mode']?.toString() ?? '',
      category: (json['category'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
                key, value is double ? (value as double).toInt() : value as int? ?? 0),
          ) ??
          {},
      total: (json['total'] is double
          ? (json['total'] as double).toInt()
          : json['total'] as int? ?? 0),
    );
  }
}