import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChecklistLogSection extends StatelessWidget {
  final RxMap<String, Map<String, List<dynamic>>> roundDataRx;
  final RxMap<String, dynamic> roomsRx;
  final String? defaultDate;
  final DateTime Function(String)? parseShortDate;
  final String Function(String)? formatShortDate;

  const ChecklistLogSection({
    Key? key,
    required this.roundDataRx,
    required this.roomsRx,
    this.defaultDate,
    this.parseShortDate,
    this.formatShortDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final roundData = roundDataRx;
      final rooms = roomsRx;
      if (roundData.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
           
          ),
          child: const Text(
            'No log data available',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        );
      }

      // Extract unique dates from roundData
      final allDates = <String>{};
      roundData.forEach((roomId, dateMap) {
        dateMap.keys.forEach((date) {
          allDates.add(date);
        });
      });
      final sortedDates = allDates.toList()
        ..sort((a, b) {
          try {
            final dateA =
                parseShortDate != null ? parseShortDate!(a) : DateTime.parse(a);
            final dateB =
                parseShortDate != null ? parseShortDate!(b) : DateTime.parse(b);
            return dateA.compareTo(dateB);
          } catch (e) {
            return a.compareTo(b);
          }
        });

      // Default to today if it exists, else latest date
      String todayStr = '';
      if (parseShortDate != null && formatShortDate != null) {
        final now = DateTime.now();
        for (final d in sortedDates) {
          final parsed = parseShortDate!(d);
          if (parsed.year == now.year &&
              parsed.month == now.month &&
              parsed.day == now.day) {
            todayStr = d;
            break;
          }
        }
      }
      String selectedDate = todayStr.isNotEmpty
          ? todayStr
          : (sortedDates.isNotEmpty ? sortedDates.last : '');

      return _ChecklistLogSectionContent(
        roundData: roundData,
        rooms: rooms,
        sortedDates: sortedDates,
        selectedDate: selectedDate,
        parseShortDate: parseShortDate,
        formatShortDate: formatShortDate,
      );
    });
  }
}

class _ChecklistLogSectionContent extends StatefulWidget {
  final Map<String, Map<String, List<dynamic>>> roundData;
  final Map<String, dynamic> rooms;
  final List<String> sortedDates;
  final String selectedDate;
  final DateTime Function(String)? parseShortDate;
  final String Function(String)? formatShortDate;

  const _ChecklistLogSectionContent({
    Key? key,
    required this.roundData,
    required this.rooms,
    required this.sortedDates,
    required this.selectedDate,
    this.parseShortDate,
    this.formatShortDate,
  }) : super(key: key);

  @override
  State<_ChecklistLogSectionContent> createState() =>
      _ChecklistLogSectionContentState();
}

class _ChecklistLogSectionContentState
    extends State<_ChecklistLogSectionContent> {
  late String selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Log',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.sortedDates.map((date) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedDate == date
                          ? Colors.blue.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                 
                    ),
                    child: Text(
                      widget.formatShortDate != null
                          ? widget.formatShortDate!(date)
                          : date,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            selectedDate == date ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            final logEntries = <Widget>[];
            widget.roundData.forEach((roomId, dateMap) {
              if (dateMap.containsKey(selectedDate)) {
                final room = widget.rooms[roomId];
                final rounds = dateMap[selectedDate]!;
                logEntries.add(_buildLogItem(
                  location: room?.roomNumber ?? 'Unknown',
                  block:
                      '${room?.blockName ?? 'Unknown'} - ${room?.floorName ?? 'Unknown'}',
                  times: rounds
                      .map((round) => round.timeSchedule as String)
                      .toList(),
                ));
              }
            });
            if (logEntries.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
              
                ),
                child: const Text(
                  'No log entries for this date',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              );
            }
            return Column(children: logEntries);
          },
        ),
      ],
    );
  }

  Widget _buildLogItem({
    required String location,
    required String block,
    required List<String> times,
  }) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              block,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: times
                  .map((time) => Chip(
                        label: Text(time),
                        backgroundColor: Colors.pink.shade50,
                        labelStyle: TextStyle(color: Colors.pink.shade700),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}