import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Income {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String source;

  Income({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.source,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'].toString(),
      description: json['details'] ?? '',
      source: json['source'] ?? '',
      amount: double.parse(json['amount']),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}

class Expense {
  final String id;
  final String source;
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.source,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      description: json['details'] ?? '',
      source: json['name'] ?? '',
      amount: double.parse(json['amount']),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }
}

class TabApp extends StatelessWidget {
  static const routeName = '/mapato-matumizi-tab-screen';
  final String? token;
  final String? userOccupation;
  TabApp({this.token, this.userOccupation});

// Future<void> fetchData(String? token, String? memberId, ) async {
//   if (token == null) return;

//   try {
//     final response = await http.get(
//       Uri.parse('https://vikobaapi.onrender.com/vikoba/member_detail/$memberId/'),
//       headers: {
//         'Authorization': 'Token $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       final occupation = responseData.isNotEmpty ? responseData['occupation'] : '';
//     }
//   } catch (e) {
//     print(e);
//   }
// }


  @override
  Widget build(BuildContext context) {
    print('################### $token');
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.attach_money), text: 'Mapato'),
                Tab(icon: Icon(Icons.receipt), text: 'Matumizi'),
              ],
            ),
            title: Text('Mapato na Matumizi'),
          ),
          body: TabBarView(
            children: [
              IncomeScreen(token: token, occupation: userOccupation,),
              ExpenseScreen(token: token, occupation: userOccupation,),
            ],
          ),
        ),
      ),
    );
  }
}

class IncomeScreen extends StatefulWidget {
  final String? occupation;
  final String? token;
  static const routeName = '/income-screen';

  IncomeScreen({this.token, this.occupation}){
    print('################### $occupation');
  }

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  DateTime? _selectedDate;
  bool isLoading = true;
  bool showForm = false;
  List<Income> incomeList = [];

  void addIncome() {
    setState(() {
      showForm = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      fetchIncome(widget.token!);
    } else {
      // Handle the case where widget.token is null
    }
  }

  Future<void> fetchIncome(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.122.1:8000/vikoba/income/'),
      headers: {
        'Authorization': "Token $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        incomeList = data.map((item) => Income.fromJson(item)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false; 
      });
      throw Exception('Failed to load income data');
    }
  }

  void submitForm(String token) async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://192.168.122.1:8000/vikoba/income/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, String>{
          'member_of': DateTime.now().toString(),
          'details': _descriptionController.text,
          'amount': _amountController.text,
          'date_time_added': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'source': _sourceController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        setState(() {
          incomeList.add(Income(
            id: DateTime.now().toString(),
            source: _sourceController.text,
            description: _descriptionController.text,
            amount: double.parse(_amountController.text),
            date: _selectedDate!,
          ));
          showForm = false;
          _descriptionController.clear();
          _amountController.clear();
          _dateController.clear();
          _sourceController.clear();
          _selectedDate = null;
        });
      } else {
        print((response.body));
        throw Exception('Failed to create income.');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showForm
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.withOpacity(0.3),
                ),
                width: 350,
                padding: EdgeInsets.only(left: 0),
                height: 400,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            showForm = false;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _sourceController,
                              decoration: InputDecoration(labelText: 'Chanzo'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka Chanzo';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(labelText: 'Maelezo'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka Maelezo';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(labelText: 'Gharama ya Kujiunga'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali Weka Gharama ya Kujiunga';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(labelText: 'Tarehe'),
                              onTap: () {
                                _selectDate(context);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka Tarehe';
                                }
                                return null;
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (widget.token != null) {
                                  submitForm(widget.token!);
                                } else {
                                  // Handle the case where widget.token is null
                                }
                              },
                              child: Text('Hifadhi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : incomeList.isEmpty
                          ? Center(child: Text('Hakuna mapato yaliyoongezwa'))
                          : ListView.builder(
                              itemCount: incomeList.length,
                              itemBuilder: (context, index) {
                                final income = incomeList[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(Icons.attach_money),
                                    ),
                                    title: Text(income.source),
                                    subtitle: Text('${income.description} - ${income.amount} Tsh'),
                                    trailing: Text(DateFormat.yMMMd().format(income.date)),
                                  ),
                                );
                              },
                            ),
                ),
                 if (widget.occupation == 'Leader' || widget.occupation == 'kiongozi')
              ElevatedButton(
                onPressed: addIncome,
                child: Text('ongeza'),
              )
              ],
            ),
    );
  }
}



class ExpenseScreen extends StatefulWidget {
  final String? token;
  final String? occupation;
  static const routeName = '/expense-screen';

  ExpenseScreen({this.token, this.occupation});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  DateTime? _selectedDate;
  bool isLoading = true;
  bool showForm = false;
  List<Expense> expenseList = [];

  void addExpense() {
    setState(() {
      showForm = true;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      fetchExpense(widget.token!);
    } else {
      // Handle the case where widget.token is null
    }
  }

  Future<void> fetchExpense(String token) async {
    final response = await http.get(
      Uri.parse('http://192.168.122.1:8000/vikoba/expenditure/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        // Filter out expenses that start with "Loan taken"
        expenseList = data.map((item) => Expense.fromJson(item)).where((expense) => !expense.description.startsWith('Loan taken')).toList();
        isLoading = false; 
      });
    } else {
      setState(() {
        isLoading = false; 
      });
      throw Exception('Failed to load expense data');
    }
  }

  void submitForm(String token) async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://192.168.122.1:8000/vikoba/expenditure/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(<String, String>{
          'member_of': DateTime.now().toString(),
          'details': _descriptionController.text,
          'amount': _amountController.text,
          'date_time_added': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'name': _sourceController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          expenseList.add(Expense(
            id: DateTime.now().toString(),
            source: _sourceController.text,
            description: _descriptionController.text,
            amount: double.parse(_amountController.text),
            date: _selectedDate!,
          ));
          showForm = false;
          _descriptionController.clear();
          _amountController.clear();
          _dateController.clear();
          _sourceController.clear();
          _selectedDate = null;
        });
      } else {
        print((response.body));
        throw Exception('Failed to create expense.');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMd().format(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showForm
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.withOpacity(0.3),
                ),
                width: 350,
                padding: EdgeInsets.only(left: 0),
                height: 400,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            showForm = false;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _sourceController,
                              decoration: InputDecoration(labelText: 'Chanzo'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka chanzo';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(labelText: 'Maelezo'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka Maelezo';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(labelText: 'Amount'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an amount';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _dateController,
                              decoration: InputDecoration(labelText: 'Tarehe'),
                              onTap: () {
                                _selectDate(context);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tafadhali weka Tarehe';
                                }
                                return null;
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (widget.token != null) {
                                  submitForm(widget.token!);
                                } else {
                                  // Handle the case where widget.token is null
                                }
                              },
                              child: Text('Hifadhi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
           : Column(
              children: [
                Expanded(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : expenseList.isEmpty
                          ? Center(child: Text('Hakuna Matumizi Yaliyoongezwa'))
                          : ListView.builder(
                              itemCount: expenseList.length,
                              itemBuilder: (context, index) {
                                final expense = expenseList[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(Icons.money_off),
                                    ),
                                    title: Text(expense.source),
                                    subtitle: Text('${expense.description} - ${expense.amount} Tsh'),
                                    trailing: Text(DateFormat.yMMMd().format(expense.date)),
                                  ),
                                );
                              },
                            ),
                ),
                if (widget.occupation == 'Leader' || widget.occupation == 'kiongozi')
              ElevatedButton(
                onPressed: addExpense,
                child: Text('Ongeza'),
              ) 
              ],
            ),
    );
  }
}
