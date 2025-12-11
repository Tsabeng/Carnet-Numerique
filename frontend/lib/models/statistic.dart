class StatisticData {
  final String label;
  final double value;
  final Color color;
  final String? unit;

  const StatisticData({
    required this.label,
    required this.value,
    required this.color,
    this.unit,
  });
}

class Statistic {
  final String title;
  final String description;
  final List<StatisticData> data;
  final String type; // line, bar, pie, donut
  final DateTime periodStart;
  final DateTime periodEnd;

  const Statistic({
    required this.title,
    required this.description,
    required this.data,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
  });
}