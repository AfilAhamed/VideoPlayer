// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class BarChartSample2 extends StatefulWidget {
//   const BarChartSample2({super.key});
//   final Color leftBarColor = Colors.white;
//   final Color rightBarColor = Colors.orange;
//   final Color avgColor = Colors.red;
//   @override
//   State<StatefulWidget> createState() => BarChartSample2State();
// }

// class BarChartSample2State extends State<BarChartSample2> {
//   final double width = 7;

//   late List<BarChartGroupData> rawBarGroups;
//   late List<BarChartGroupData> showingBarGroups;

//   int touchedGroupIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     final barGroup1 = makeGroupData(1, 5, 12);
//     final barGroup2 = makeGroupData(1, 16, 12);
//     final barGroup3 = makeGroupData(2, 18, 5);
//     final barGroup4 = makeGroupData(3, 20, 16);
//     final barGroup5 = makeGroupData(4, 17, 6);
//     final barGroup6 = makeGroupData(5, 19, 1.5);
//     final barGroup7 = makeGroupData(6, 10, 1.5);

//     final items = [
//       barGroup1,
//       barGroup2,
//       barGroup3,
//       barGroup4,
//       barGroup5,
//       barGroup6,
//       barGroup7,
//     ];

//     rawBarGroups = items;

//     showingBarGroups = rawBarGroups;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Chart'),
//         backgroundColor: Colors.black,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: Padding(
//           padding: const EdgeInsets.only(top: 10),
//           child: Column(
//             children: [
//               Container(
//                 width: MediaQuery.of(context).size.width * 1,
//                 height: MediaQuery.of(context).size.height * 0.1,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Colors.black),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Screen On',
//                       style: TextStyle(color: Colors.orange, fontSize: 25),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       'Time',
//                       style: TextStyle(color: Colors.white, fontSize: 25),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     color: Colors.black),
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: <Widget>[
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: <Widget>[
//                             makeTransactionsIcon(),
//                             const SizedBox(
//                               width: 45,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 38,
//                         ),
//                         Expanded(
//                           child: BarChart(
//                             BarChartData(
//                               maxY: 20,
//                               barTouchData: BarTouchData(
//                                 touchTooltipData: BarTouchTooltipData(
//                                   tooltipBgColor: Colors.grey,
//                                   getTooltipItem: (a, b, c, d) => null,
//                                 ),
//                                 touchCallback: (FlTouchEvent event, response) {
//                                   if (response == null ||
//                                       response.spot == null) {
//                                     setState(() {
//                                       touchedGroupIndex = -1;
//                                       showingBarGroups = List.of(rawBarGroups);
//                                     });
//                                     return;
//                                   }

//                                   touchedGroupIndex =
//                                       response.spot!.touchedBarGroupIndex;

//                                   setState(() {
//                                     if (!event.isInterestedForInteractions) {
//                                       touchedGroupIndex = -1;
//                                       showingBarGroups = List.of(rawBarGroups);
//                                       return;
//                                     }
//                                     showingBarGroups = List.of(rawBarGroups);
//                                     if (touchedGroupIndex != -1) {
//                                       var sum = 0.0;
//                                       for (final rod
//                                           in showingBarGroups[touchedGroupIndex]
//                                               .barRods) {
//                                         sum += rod.toY;
//                                       }
//                                       final avg = sum /
//                                           showingBarGroups[touchedGroupIndex]
//                                               .barRods
//                                               .length;

//                                       showingBarGroups[touchedGroupIndex] =
//                                           showingBarGroups[touchedGroupIndex]
//                                               .copyWith(
//                                         barRods:
//                                             showingBarGroups[touchedGroupIndex]
//                                                 .barRods
//                                                 .map((rod) {
//                                           return rod.copyWith(
//                                               toY: avg, color: widget.avgColor);
//                                         }).toList(),
//                                       );
//                                     }
//                                   });
//                                 },
//                               ),
//                               titlesData: FlTitlesData(
//                                 show: true,
//                                 rightTitles: const AxisTitles(
//                                   sideTitles: SideTitles(showTitles: false),
//                                 ),
//                                 topTitles: const AxisTitles(
//                                   sideTitles: SideTitles(showTitles: false),
//                                 ),
//                                 bottomTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     getTitlesWidget: bottomTitles,
//                                     reservedSize: 42,
//                                   ),
//                                 ),
//                                 leftTitles: AxisTitles(
//                                   sideTitles: SideTitles(
//                                     showTitles: true,
//                                     reservedSize: 28,
//                                     interval: 1,
//                                     getTitlesWidget: leftTitles,
//                                   ),
//                                 ),
//                               ),
//                               borderData: FlBorderData(
//                                 show: false,
//                               ),
//                               barGroups: showingBarGroups,
//                               gridData: const FlGridData(show: false),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 12,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget leftTitles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: Color(0xff7589a2),
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text;
//     if (value == 0) {
//       text = '1K';
//     } else if (value == 10) {
//       text = '5K';
//     } else if (value == 19) {
//       text = '10K';
//     } else {
//       return Container();
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 0,
//       child: Text(text, style: style),
//     );
//   }

//   Widget bottomTitles(double value, TitleMeta meta) {
//     final titles = <String>['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];

//     final Widget text = Text(
//       titles[value.toInt()],
//       style: const TextStyle(
//         color: Color(0xff7589a2),
//         fontWeight: FontWeight.bold,
//         fontSize: 14,
//       ),
//     );

//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 16, //margin top
//       child: text,
//     );
//   }

//   BarChartGroupData makeGroupData(int x, double y1, double y2) {
//     return BarChartGroupData(
//       barsSpace: 4,
//       x: x,
//       barRods: [
//         BarChartRodData(
//           toY: y1,
//           color: widget.leftBarColor,
//           width: width,
//         ),
//         BarChartRodData(
//           toY: y2,
//           color: widget.rightBarColor,
//           width: width,
//         ),
//       ],
//     );
//   }

//   Widget makeTransactionsIcon() {
//     const width = 4.5;
//     const space = 3.5;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: <Widget>[
//         Container(
//           width: width,
//           height: 10,
//           color: Colors.white.withOpacity(0.4),
//         ),
//         const SizedBox(
//           width: space,
//         ),
//         Container(
//           width: width,
//           height: 28,
//           color: Colors.white.withOpacity(0.8),
//         ),
//         const SizedBox(
//           width: space,
//         ),
//         Container(
//           width: width,
//           height: 42,
//           color: Colors.white.withOpacity(1),
//         ),
//         const SizedBox(
//           width: space,
//         ),
//         Container(
//           width: width,
//           height: 28,
//           color: Colors.white.withOpacity(0.8),
//         ),
//         const SizedBox(
//           width: space,
//         ),
//         Container(
//           width: width,
//           height: 10,
//           color: Colors.white.withOpacity(0.4),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:videoplayer_miniproject/model/chart_model/chart_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  String selectedPeriod = 'Day'; // Default selection

  @override
  Widget build(BuildContext context) {
    final statisticsBox = Hive.box<VideoStatistics>('statistics');
    final data = statisticsBox.values.toList();

    final filteredData = data.where((statistics) {
      final today = DateTime.now();
      final statisticsDate = DateTime.parse(statistics.period);

      if (selectedPeriod == 'Day') {
        return statisticsDate.isAfter(today.subtract(const Duration(days: 1)));
      } else if (selectedPeriod == 'Week') {
        return statisticsDate.isAfter(today.subtract(const Duration(days: 7)));
      } else if (selectedPeriod == 'Month') {
        return statisticsDate.isAfter(today.subtract(const Duration(days: 30)));
      }

      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Video Statistics'),
        actions: [
          DropdownButton<String>(
            iconEnabledColor: Colors.orange,
            dropdownColor: Colors.black,
            iconSize: 27,
            style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 17,
                fontWeight: FontWeight.bold),
            value: selectedPeriod,
            onChanged: (newValue) {
              setState(() {
                selectedPeriod = newValue!;
              });
            },
            items: ['Day', 'Week', 'Month'].map((period) {
              return DropdownMenuItem<String>(
                value: period,
                child: Text(
                  period,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Center(
        child: StatisticsChart(filteredData),
      ),
    );
  }
}

class StatisticsChart extends StatelessWidget {
  final List<VideoStatistics> filteredData;

  const StatisticsChart(this.filteredData, {super.key});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      [
        charts.Series<VideoStatistics, String>(
          id: 'Added',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (VideoStatistics statistics, _) => statistics.period,
          measureFn: (VideoStatistics statistics, _) => statistics.addedCount,
          data: filteredData,
        ),
        charts.Series<VideoStatistics, String>(
          id: 'Deleted',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (VideoStatistics statistics, _) => statistics.period,
          measureFn: (VideoStatistics statistics, _) => statistics.deletedCount,
          data: filteredData,
        ),
      ],
      animate: true,
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [
        charts.SeriesLegend(
          position: charts.BehaviorPosition.top, // Legend at the top
          desiredMaxRows: 2, // Limit to 2 rows for better alignment
        ),
      ],
    );
  }
}
