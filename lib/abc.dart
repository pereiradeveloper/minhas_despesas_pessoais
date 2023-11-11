import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'transaction_dao.dart';

class PieChartWidget extends StatefulWidget {
  final List<Transaction> transactions;
  const PieChartWidget({super.key, required this.transactions});

  @override
  State<StatefulWidget> createState() => PieChartWidgetState();
}

class PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = 0;

  final mapping = {
    'Renda': Colors.red,
    'Alimentação': Colors.blue,
    'Transporte': Colors.purple,
    'Saúde': Colors.deepPurple,
    'Educação': Colors.green,
    'Lazer': Colors.yellow,
    'Vestuário': Colors.grey,
    'Telefones/Internet': Colors.deepOrange,
    'Outros': Colors.amber,
    'Bancos': Colors.black
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: PieChart(
            PieChartData(
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: showingSections(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: mapping.entries
                .map(
                  (entry) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(entry.key),
                      const SizedBox(width: 8),
                      Container(
                        color: entry.value,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    final isTouched = 1 == touchedIndex;
    final fontSize = isTouched ? 20.0 : 16.0;
    final radius = isTouched ? 110.0 : 100.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    final transactions = widget.transactions;

    final totalValue = transactions.fold(0.0, (sum, element) => sum + element.value);
    final grouped = transactions.groupFoldBy<String, double>((element) => element.category, (sum, element) => (sum ?? 0) + element.value);

    final items = grouped.entries.map((entry) {
      final value = (entry.value / totalValue * 100).roundToDouble();
      return PieItem(
        value: value,
        category: entry.key,
        color: mapping[entry.key]!,
      );
    }).toList();

    return items
        .map(
          (item) => PieChartSectionData(
            color: item.color,
            value: item.value,
            title: '${item.value}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              shadows: shadows,
            ),
            badgePositionPercentageOffset: .98,
          ),
        )
        .toList();
  }
}

double mapValueToRange(double value, double minInput, double maxInput, double minOutput, double maxOutput) {
  // Garante que o valor de entrada esteja dentro do intervalo mínimo e máximo de entrada
  value = value.clamp(minInput, maxInput);

  // Calcula a interpolação do valor para o novo intervalo
  double result = ((value - minInput) / (maxInput - minInput)) * (maxOutput - minOutput) + minOutput;

  return result;
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.svgAsset, {
    required this.size,
    required this.borderColor,
  });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: const Center(
        child: Icon(Icons.access_alarms),
      ),
    );
  }
}

class PieItem {
  final double value;
  final String category;
  final Color color;

  PieItem({
    required this.value,
    required this.category,
    required this.color,
  });
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
