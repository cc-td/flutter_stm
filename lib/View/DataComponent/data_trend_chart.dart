import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../Model/data.dart';

class DataTrendChart extends StatelessWidget {
  static const double chartLeft = 30;
  final TimeSeriesLine? line;
  final Color lineColor;
  final DateTime visibleStart;
  final DateTime visibleEnd;
  final ValueChanged<Duration> onWindowPan;

  const DataTrendChart({
    super.key,
    required this.line,
    required this.lineColor,
    required this.visibleStart,
    required this.visibleEnd,
    required this.onWindowPan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(18, 11, 11, 11),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: line == null
            ? Center(
                child: Text(
                  '暂无数据',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth = constraints.maxWidth - chartLeft;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      if (chartWidth <= 0) return;

                      final int windowMs = visibleEnd
                          .difference(visibleStart)
                          .inMilliseconds;
                      final int deltaMs =
                          (-details.delta.dx / chartWidth * windowMs).round();
                      onWindowPan(Duration(milliseconds: deltaMs));
                    },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: DataTrendChartPainter(
                        line: line!,
                        lineColor: lineColor,
                        visibleStart: visibleStart,
                        visibleEnd: visibleEnd,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 具体画图
class DataTrendChartPainter extends CustomPainter {
  final TimeSeriesLine line;
  final Color lineColor;
  final DateTime visibleStart;
  final DateTime visibleEnd;
  DataTrendChartPainter({
    required this.line,
    required this.lineColor,
    required this.visibleStart,
    required this.visibleEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = line.points;
    if (points.length < 2) return;

    double minValue = points.first.value;
    double maxValue = points.first.value;
    for (final p in points) {
      if (p.value < minValue) minValue = p.value;
      if (p.value > maxValue) maxValue = p.value;
    }
    double valueRange = maxValue - minValue;
    if (valueRange == 0) valueRange = 1;

    double chartLeft = 30;
    double bottomLabelHeight = 20;
    final double chartWidth = size.width - chartLeft;
    final double chartHeight = size.height - bottomLabelHeight;

    // 参考线
    final gradPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // y轴说明
    final axisValues = [maxValue, (maxValue + minValue) / 2, minValue];
    for (final v in axisValues) {
      final double vProgress = (v - minValue) / valueRange;
      final double y = (1 - vProgress) * chartHeight;

      canvas.drawLine(Offset(chartLeft, y), Offset(size.width, y), gradPaint);

      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(3),
          style: TextStyle(color: Color.fromARGB(255, 15, 12, 6), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(chartLeft - tp.width - 4, y - tp.height / 2));
    }
    // 数据曲线
    final int startMs = visibleStart.millisecondsSinceEpoch;
    final int endMs = visibleEnd.millisecondsSinceEpoch;
    final int windowMs = endMs - startMs;
    if (windowMs <= 0) return;

    final path = Path();
    bool hasStarted = false;
    for (final p in points) {
      final int tMs = p.timestamp.millisecondsSinceEpoch;
      if (tMs < startMs || tMs > endMs) continue;

      final double xProgress = (tMs - startMs) / windowMs;
      final double x = chartLeft + xProgress * chartWidth;

      final double vProgress = (p.value - minValue) / valueRange;
      final double y = (1 - vProgress) * chartHeight;

      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);

    // x轴
    void drawTimeLabel(DateTime time, double x, TextAlign align) {
      final tp = TextPainter(
        text: TextSpan(text: _formatTime(time), style: TextStyle(
          color: Color.fromARGB(255, 74, 79, 89),fontSize: 10,),),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2
      );
      tp.layout();

      double paintX;
      if (align == TextAlign.left) {
        paintX = x;
      } else if (align == TextAlign.right) {
        paintX = x - tp.width;
      } else {
        paintX = x - tp.width / 2;
      }

      tp.paint(canvas, Offset(paintX, chartHeight + 4));
    }

    final DateTime midTime = DateTime.fromMillisecondsSinceEpoch(
      (startMs + endMs) ~/ 2,
    );

    drawTimeLabel(visibleStart, chartLeft, TextAlign.left);
    drawTimeLabel(midTime, chartLeft + chartWidth / 2, TextAlign.center);
    drawTimeLabel(visibleEnd, chartLeft + chartWidth, TextAlign.right);
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm\n[$month-$day]';
  }

  @override
  bool shouldRepaint(covariant DataTrendChartPainter oldDelegate) {
    return oldDelegate.line != line ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.visibleStart != visibleStart ||
        oldDelegate.visibleEnd != visibleEnd;
  }
}
