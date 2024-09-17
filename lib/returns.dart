import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class LoanInfo {
  final String id;
  final String name;
  final String phoneNumber;
  final String guarantor;
  final DateTime dateOfTaking;
  final double amount;
  final double interestRate;
  final int repaymentPeriod;
  final double totalDebt;
  final String debtorId;
  double paid;
  double unpaid;
  double penalty;
  final DateTime returnDate;

  LoanInfo({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.guarantor,
    required this.dateOfTaking,
    required this.amount,
    required this.interestRate,
    required this.repaymentPeriod,
    required this.totalDebt,
    required this.returnDate,
    required this.debtorId,
    required this.paid,
    required this.unpaid,
    required this.penalty,
  });

  factory LoanInfo.fromJson(Map<String, dynamic> json) {
    final DateTime dateTaken = DateTime.parse(json['date_taken'] ?? DateTime.now().toString());
    final DateTime returnDate = DateTime(
      dateTaken.year, 
      dateTaken.month + (int.tryParse(json['repayment_period']?.toString() ?? '0') ?? 0), 
      dateTaken.day
    );
    final DateTime now = DateTime.now();

    double unpaid = max(0, (json['total_debt'] ?? 0).toDouble() - (json['total_paid'] ?? 0).toDouble());
    final int monthsPassed = now.year * 12 + now.month - returnDate.year * 12 - returnDate.month;
    double penalty = 0.0;
    if (monthsPassed > 0 && unpaid > 0) {
      for (int i = 0; i < monthsPassed; i++) {
        penalty += unpaid;
        unpaid *= 2;
      }
    }
    return LoanInfo(
      id: json['loan_id'] ?? '',
      name: json['borrower_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      guarantor: json['guarantor'] ?? '',
      dateOfTaking: dateTaken,
      amount: (json['loan_taken'] ?? 0).toDouble(),
      interestRate: double.tryParse(json['interest_rate']?.toString() ?? '0') ?? 0.0,
      repaymentPeriod: int.tryParse(json['repayment_period']?.toString() ?? '0') ?? 0,
      totalDebt: (json['total_debt'] ?? 0).toDouble(),
      returnDate: returnDate,
      debtorId: json['member_id'] ?? '',
      paid: (json['total_paid'] ?? 0).toDouble(),
      unpaid: unpaid,
      penalty: penalty,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marejesho',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoanTrackerScreen(
        token: 'your_token_here',
        memberId: 'your_member_id_here',
        userOccupation: 'your_user_occupation_here',
      ),
    );
  }
}

class LoanTrackerScreen extends StatefulWidget {
  static const routeName = '/loan-tracker-screen';

  final String? token;
  final String? memberId;
  final String? userOccupation;

  LoanTrackerScreen({
    this.token,
    this.memberId,
    this.userOccupation,
  });

  @override
  _LoanTrackerScreenState createState() => _LoanTrackerScreenState();
}

class _LoanTrackerScreenState extends State<LoanTrackerScreen> {
  List<LoanInfo> _loanList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLoans();
  }

  Future<void> fetchLoans() async {
    final url = 'http://192.168.122.1:8000/vikoba/loan/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData); // Add this line to print the JSON response

      final List<dynamic> loanData = responseData;
      setState(() {
        _loanList = loanData.map((data) => LoanInfo.fromJson(data)).toList();
        _isLoading = false;
      });
    } else {
      print('Failed to load loans: ${response.statusCode}');
      throw Exception('Failed to load loans');
    }
  }

  Future<void> _recordPaidAmount(LoanInfo loanInfo, double amountPaid) async {
    final url = 'http://192.168.122.1:8000/vikoba/loans/paid/${loanInfo.debtorId}/${loanInfo.id}/';
    print('Request URL: $url');  // Debug: print the URL being sent

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount_paid': amountPaid,
        'sender': loanInfo.name // Ensure loanInfo.name is not empty or null
      }),
    );

    if (response.statusCode == 201) {
      // Successful response handling
      fetchLoans(); // Assuming fetchLoans() is a method to update loan data after recording payment
      print('Response body: ${response.body}');
    } else {
      // Error handling
      print('Failed to record paid amount');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to record paid amount');
    }
  }

  void _showRecordPaymentDialog(LoanInfo loan) {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(' Rekodi Malipo'),
              content: TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Kiasi kilicholipwa'),
                keyboardType: TextInputType.number,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final amountPaid = double.tryParse(_amountController.text);
                    if (amountPaid == null || amountPaid <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tafadhali ingiza kiasi sahihi')),
                      );
                    } else if (amountPaid > loan.unpaid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kiasi ni kikubwa sana')),
                      );
                      _amountController.clear();
                    } else {
                      _recordPaidAmount(loan, amountPaid);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<LoanInfo> _filteredLoans() {
    final searchQuery = _searchController.text.toLowerCase();
    return _loanList.where((loan) {
      final name = loan.name.toLowerCase();
      return name.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marejesho ya Mkopo')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: _filteredLoans().isEmpty
                      ? Center(child: Text('No loans found'))
                      : ListView.builder(
                          itemCount: _filteredLoans().length,
                          itemBuilder: (context, index) {
                            final loan = _filteredLoans()[index];
                            return GestureDetector(
                              onTap: widget.userOccupation == 'Leader' ? () {
                                if (loan.unpaid == 0) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Hali ya Mkopo'),
                                      content: Text('Mkopo huu umeshalipwa. Hakuna malipo yanayohitajika.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  _showRecordPaymentDialog(loan);
                                }
                              } : null,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text('Jina la mdaiwa: ${loan.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                                          if (loan.unpaid == 0)
                                            Icon(Icons.check_circle, color: Colors.green),
                                        ],
                                      ),
                                      Text('Namba ya Simu: ${loan.phoneNumber}'),
                                      Text('Mdhamini: ${loan.guarantor}'),
                                      Text('Mkopo uliochukuliwa: ${loan.amount}'),
                                      Text('Riba: ${(loan.interestRate * 100).toString()}%'),
                                      Text('Repayment Period: Miezi ${loan.repaymentPeriod}'),
                                      Text('Jumla ya Mkopo: ${loan.totalDebt}'),
                                      Text('Kiasi kilicholipwa: ${loan.paid}'),
                                      Text('Haijalipwa: ${loan.unpaid}'),
                                      Text('Penalti: ${loan.penalty}'),
                                      Text('Tarehe ya kuchukua Mkopo: ${DateFormat('yyyy-MM-dd').format(loan.dateOfTaking)}'),
                                      Text('Tarehe ya marejesho: ${DateFormat('yyyy-MM-dd').format(loan.returnDate)}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
