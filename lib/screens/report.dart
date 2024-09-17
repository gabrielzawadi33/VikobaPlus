import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/piechart.dart';
import '../widgets/progressBar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyReportPage(title: 'Taarifa fupi ya fedha'),
    );
  }
}

class MyReportPage extends StatefulWidget {
  final String title;
  final String? memberId;
  final String? token;
  final String? userOccupation;

  MyReportPage({Key? key, required this.title, this.token, this.memberId, this.userOccupation}) : super(key: key);
  static const routeName = '/myreoportpage';

  @override
  _MyReportPageState createState() => _MyReportPageState();
}

class _MyReportPageState extends State<MyReportPage> {
  int _counter = 0;
  String dropdownValue = '';
  bool _isLoadingIncome = true;
  bool _isLoadingExpenses = true;
  Map<String, double> _incomeData = {};
  Map<String, double> _expensesData = {};
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double get _profit => _totalIncome - _totalExpenses;
  double get _startAmount => 0.0;
  double get _endAmount => _profit + _startAmount;
  double get _profitPercentage => _totalIncome != 0 ? (_profit / _totalIncome) * 100 : 0;

  final Map<String, int> monthMap = {
    'Januari': 1,
    'Februari': 2,
    'Machi': 3,
    'Aprili': 4,
    'Mei': 5,
    'Juni': 6,
    'Julai': 7,
    'Agosti': 8,
    'Septemba': 9,
    'Octoba': 10,
    'Nocemba': 11,
    'Disemba': 12,
  };

  @override
  void initState() {
    super.initState();
    setDefaultDropdownValue();
    fetchExpensesData();
    fetchIncomeData();
  }

  void setDefaultDropdownValue() {
    int currentMonth = DateTime.now().month;
    dropdownValue = monthMap.entries.firstWhere((entry) => entry.value == currentMonth).key;
  }

Future<void> fetchIncomeData() async {
  final int selectedMonth = monthMap[dropdownValue] ?? 1; // Default to January if no value selected
  final url = 'http://192.168.122.1:8000/vikoba/income-sum/$selectedMonth';

  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Token ${widget.token}',
  });

  if (response.statusCode == 200) {
    print('####################### ${response.body}');

    final dynamic responseData = json.decode(response.body);

    // Check if the responseData is a list or a single object
    if (responseData is List) {
      // Case: List of incomes
      List<dynamic> incomeJson = responseData;
      Map<String, double> incomeMap = {};
      double totalIncome = 0.0;

      for (var income in incomeJson) {
        incomeMap[income['source']] = income['amount'].toDouble();
        totalIncome += income['amount'].toDouble();
      }

      setState(() {
        _incomeData = incomeMap;
        _isLoadingIncome = false;
        _totalIncome = totalIncome;
      });
    } else if (responseData is Map) {
      // Case: Single income object
      Map<String, dynamic>? incomeData = responseData.cast<String, dynamic>();
      Map<String, double> incomeMap = {
        incomeData['source']: incomeData['amount'].toDouble(),
      };
      double totalIncome = incomeData['amount'].toDouble();

      setState(() {
        _incomeData = incomeMap;
        _isLoadingIncome = false;
        _totalIncome = totalIncome;
      });
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    throw Exception('Failed to load income data');
  }
}


Future<void> fetchExpensesData() async {
  final int selectedMonth = monthMap[dropdownValue] ?? 1; // Default to January if no value selected
  final url = 'http://192.168.122.1:8000/vikoba/expenditure-sum/$selectedMonth';

  final response = await http.get(Uri.parse(url), headers: {
    'Authorization': 'Token ${widget.token}',
  });

  if (response.statusCode == 200) {
    print('####################### ${response.body}');
    final dynamic responseData = json.decode(response.body);

    // Check if the responseData is a list or a single object
    if (responseData is List) {
      // Case: List of expenses
      List<dynamic> expensesJson = responseData;
      Map<String, double> expenseMap = {};
      double totalExpenses = 0.0;

      for (var expense in expensesJson) {
        // Exclude expenses starting with "Loan taken"
        if (!expense['source'].toString().startsWith('Loan taken')) {
          expenseMap[expense['source']] = expense['amount'].toDouble();
          totalExpenses += expense['amount'].toDouble();
        }
      }

      setState(() {
        _expensesData = expenseMap;
        _isLoadingExpenses = false;
        _totalExpenses = totalExpenses;
      });
    } else if (responseData is Map) {
      // Case: Single expense object
      Map<String, dynamic>? expenseData = responseData.cast<String, dynamic>();
      Map<String, double> expenseMap = {};

      // Exclude expenses starting with "Loan taken"
      if (!expenseData['source'].toString().startsWith('Loan taken')) {
        expenseMap[expenseData['source']] = expenseData['amount'].toDouble();
        double totalExpenses = expenseData['amount'].toDouble();

        setState(() {
          _expensesData = expenseMap;
          _isLoadingExpenses = false;
          _totalExpenses = totalExpenses;
        });
      }
    } else {
      throw Exception('Unexpected response format');
    }
  } else {
    throw Exception('Failed to load expenses data');
  }
}


  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TAARIFA YA MWEZI'),
                  Text('$dropdownValue'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Expanded(
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: DropdownButton<String>(
                  hint: Text('Mwezi'),
                  value: dropdownValue,
                  items: monthMap.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue ?? 'default value';
                    });
                    fetchIncomeData();
                    fetchExpensesData();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: <Widget>[
              //     Center(child: Text('Kianzio')),
              //     Center(
              //       child: Text(
              //         '$_startAmount Tzsh/=',
              //         style: TextStyle(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 5),
              Column(
                children: [
                  Container(
                    color: Colors.blueAccent[200],
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text('Mapato')),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$_totalIncome',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                height: 200,
                child: _isLoadingIncome
                    ? CircularProgressIndicator()
                    : _incomeData.isEmpty
                        ? Center(child: Text('No income data available'))
                        : MyPieChart(
                            dataMap: _incomeData,
                            colorList: [
                              Colors.blue,
                              Colors.green,
                              Colors.red,
                              Colors.yellow,
                              Colors.purple,
                            ],
                            centerText: 'Mapato',
                          ),
              ),
              SizedBox(height: 5),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blueAccent[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(child: Text('Matumizi')),
                          ),
                          Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Center(
                              child: Text(
                                '$_totalExpenses',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                height: 200,
                child: _isLoadingExpenses
                    ? CircularProgressIndicator()
                    : _expensesData.isEmpty
                        ? Center(child: Text("No expenses data available"))
                        : MyPieChart(
                            dataMap: _expensesData,
                            colorList: [
                              Colors.blue,
                              Colors.green,
                              Colors.red,
                              Colors.yellow,
                              Colors.purple,
                            ],
                            centerText: 'Matumizi',
                          ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blueAccent[100]!,
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(width: 100, child: ProgressBarWidget(
                            totalIncome: _totalIncome,
                            totalExpenses: _totalExpenses,
                          ),
                          ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '$_profit Tzsh/=',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Salio Kuu $_endAmount/=',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
