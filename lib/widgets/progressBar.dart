import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;

  ProgressBarWidget({required this.totalIncome, required this.totalExpenses}) {
    print('Total Income: $totalIncome, Total Expenses: $totalExpenses');
  }

  double getProfitPercentage() {
    double profit = totalIncome - totalExpenses;
    if (totalIncome == 0) return 0;
    return (profit / totalIncome) * 100;
  }

  Color getProgressColor(double value) {
    if (value >= 80) {
      return Colors.green;
    } else if (value >= 60) {
      return Colors.lightGreen;
    } else if (value >= 40) {
      return Colors.yellow;
    } else if (value >= 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    double profitPercentage = getProfitPercentage();
    double progressValue = profitPercentage / 100;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Faida',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  value: progressValue > 1.0 ? 1.0 : (progressValue < 0 ? 0 : progressValue),
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(getProgressColor(profitPercentage)),
                ),
              ),
            ),
            Text(
              '${profitPercentage.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
