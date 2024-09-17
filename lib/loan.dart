import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';


class LoanPage extends StatefulWidget {
  final String? token;
  final String? memberId;
  final String title;
  final String? userOccupation;
  String? memberName;
  String? phoneNumber;
  String? groupName;
  String? sponsor;

  LoanPage({Key? key, required this.title, this.token, this.memberId, this.userOccupation}) : super(key: key);
  static const routeName = '/loan-page';

  @override
  _LoanPageState createState() => _LoanPageState();
  
}

class _LoanPageState extends State<LoanPage> with TickerProviderStateMixin {
  late Timer _timer;
  List<String> inputData = ['input 1', 'Input 2', 'input 3'];
  PageController _controller = PageController(
    initialPage: 0,
  );
  late AnimationController _animationController;
  late Animation<double> _animation;
  late String loanAmount;
  TextEditingController _loanAmountController = TextEditingController();
  TextEditingController _loanPeriodController = TextEditingController();
  double _totalAmount = 0.0;
  final double _interestRate = 0.10;


  @override
  void initState() {
    super.initState();
    fetchData(widget.token, widget.memberId);
   

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_controller.page!.toInt() < inputData.length - 1) {
        _controller.animateToPage(
          _controller.page!.toInt() + 1,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      } else {
        _controller.animateToPage(
          0,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });

    _loanAmountController.addListener(_calculateTotal);
    _loanPeriodController.addListener(_calculateTotal);

  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _timer.cancel();
    _loanAmountController.dispose();
    _loanPeriodController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String? token, String? memberId) async {
    if (token == null) return;

    try {
      print('Fetching data with token: $token');
      final response = await http.get(
        Uri.parse('http://192.168.122.1:8000/vikoba/member_detail/$memberId/'),
        headers: {
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final responseData = json.decode(response.body);
        final memberName = responseData.isNotEmpty ? responseData['member_name'] : '';
        final phoneNumber = responseData.isNotEmpty ? responseData['phone_number'] : '';
        final groupName = responseData.isNotEmpty ? responseData['member_of'] : '';
        final sponsor = responseData.isNotEmpty ? responseData['sponsor'] : '';

        setState(() {
          widget.memberName = memberName;
          widget.phoneNumber = phoneNumber;
          widget.groupName = groupName;
          widget.sponsor = sponsor;
        });

        print('Member Name: $memberName');
        print('Group Name: $groupName');
      } else {
        print('########################################################Failed to fetch data: ${response.body}');
        print('Failed to fetch data: ${response.body}');
        print('Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while fetching data: $error');
    }
  }

  Future<void> submitLoanRequest() async {
    final String borrowerName = widget.memberName ?? '';
    final String? guarantor = widget.sponsor;
    final int repaymentPeriod = int.tryParse(_loanPeriodController.text) ?? 0;
    final String? groupName = widget.groupName;
    final String phoneNumber = widget.phoneNumber ?? '';
    final double loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
    final double totalDebt = _totalAmount;

    final Map<String, dynamic> requestBody = {
      'borrower_name': borrowerName,
      'guarantor': guarantor,
      'loan_taken': loanAmount.toInt(),
      'total_debt': totalDebt,
      'interest_rate': _interestRate,
      'repayment_period': repaymentPeriod,
      'member_of': groupName,
      'phone_number': phoneNumber,
      'date_taken': DateTime.now().toIso8601String().split('T').first, // assuming the date_taken is the current date
    };
    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.1:8000/vikoba/loan/${widget.memberId}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${widget.token}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        _resetForm();
        Fluttertoast.showToast(
          msg: 'umemaliza maombi ya mkopo ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        print('#####################${response.body}');
        Fluttertoast.showToast(
          msg: 'Ombi la mkopo halikufanikiwa ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Tatizo limejitokeza , Tafadhali jaribu tena baadae,',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _resetForm() {
    _loanAmountController.clear();
    _loanPeriodController.clear();
    setState(() {
      _totalAmount = 0.0;
    });
  }

    void _calculateTotal() {
    double loanAmount = double.tryParse(_loanAmountController.text) ?? 0.0;
    int loanPeriod = int.tryParse(_loanPeriodController.text) ?? 0;
    setState(() {
      _totalAmount = loanAmount + (loanAmount * _interestRate * loanPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.of(context).pop({'token': widget.token, 'memberId': widget.memberId});
      return false;
    },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: Center(
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 200,
                      child: PageView(
                        controller: _controller,
                        children: [
                          Stack(
                            children:[
                               Container(
                              decoration: BoxDecoration(
                                image:DecorationImage(
                                  image: AssetImage('assets/images/loan_giving.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:  BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              bottom:   0,
                              child: Text(
                              'My first text',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors
                                    .secondarySystemBackground,
                              ),
                            ),
                            ),
                            ],
                          ),
                          Stack(
                            children:[
                               Container(
                              decoration: BoxDecoration(
                                image:DecorationImage(
                                  image: AssetImage('assets/images/loan1.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:  BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              bottom:   0,
                              child: Text(
                              'My second text',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors
                                    .secondarySystemBackground,
                              ),
                            ),
                            ),
                            ],
                          ),
                          Stack(
                            children:[
                               Container(
                              decoration: BoxDecoration(
                                image:DecorationImage(
                                  image: AssetImage('assets/images/loan3.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:  BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              bottom:   0,
                              child: Text(
                              'My third text',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors
                                    .secondarySystemBackground,
                              ),
                            ),
                            ),
                            ],
                          ),
                          Stack(
                            children:[ 
                              Container(
                              decoration: BoxDecoration(
                                image:DecorationImage(
                                  image: AssetImage('assets/images/loan2.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:  BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              bottom:   0,
                              child: Text(
                              'My fourth text',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors
                                    .secondarySystemBackground,
                              ),
                            ),
                            ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                      gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.white,
                                    ],
                                  ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Enter your details',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 5, 5, 6)),
                            ),
                            Text('${widget.memberName}', textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: const Color.fromARGB(255, 15, 15, 15),
                              ),
                            ),
                            _buildTextField(
                              controller: _loanAmountController,
                              labelText: 'kiasi cha mkopo',
                            ),
                            _buildTextField(
                              controller: _loanPeriodController,
                              labelText: 'Muda (miezi)',
                            ),
                            Text('${widget.phoneNumber}', textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w200,
                                color: const Color.fromARGB(255, 15, 15, 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    // height: 350,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)
                          ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [ 
                              _buildSummaryCard('JUMLA YA MKOPO', _totalAmount.toStringAsFixed(2)),
                              // _buildSummaryCard('Total', _totalAmount.toStringAsFixed(2)),
                              _buildSummaryCard('Riba', '10%'),
                            ],
                              
                          ),
                          
                        ),
                         ScaleTransition(
                           scale: Tween(begin: 1.0, end: 0.9).animate(_animation),
                         child:Container(
                           decoration: BoxDecoration(
                             color: Color.fromARGB(255, 141, 216, 151),
                             border: Border.all(
                               color: Colors.black,
                             ),
                             borderRadius: BorderRadius.circular(40),
                           ),
                           child: IconButton(
                               icon: Icon(Icons.check),
                               iconSize: 50 ,
                             onPressed: submitLoanRequest,
                             ),
                          ),
                          
                         ),
                         Text('Kamilisha maombi yako',
                         style: TextStyle(
                           fontSize: 12,
                           fontStyle: FontStyle.italic,
                           fontWeight: FontWeight.bold,
                           color: const Color.fromARGB(255, 9, 9, 10),
                         ),
                         ),
                     ],
                    )  
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

 Widget _buildPage(String imagePath, String text) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              )
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.secondarySystemBackground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText}) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(5),
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blueAccent[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 15, 15, 15),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w200,
                color: const Color.fromARGB(255, 15, 15, 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
