import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'widgets/adaptive_flat_button.dart';

class Member {
  final String id;
  final String memberName;
  final String phoneNumber;
  final String occupation;
  final DateTime joinDate;
  final String? sponsor; 
  final String? memberOf;
  Member({
    required this.id,
    required this.memberName,
    required this.phoneNumber,
    required this.occupation,
    required this.joinDate,
    this.sponsor,
    this.memberOf,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['member_id'] ?? '',
      memberName: json['member_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      occupation: json['occupation'] ?? '',
      joinDate: DateTime.parse(json['join_date']),
      sponsor: json['sponsor'],
      memberOf: json['member_of'] ?? '',
    );
  }
}

  

// NewMember Widget
class NewMember extends StatefulWidget {
  final Function(String, double, String, DateTime, String, String) addTx;
  final String? token; 
  final VoidCallback onMemberAdded; 
  final  String? _commonMemberOf ;
  String? occupation;
  
  

  NewMember(this.addTx, this.token, this._commonMemberOf, this.onMemberAdded);

  @override
  _NewMemberState createState() => _NewMemberState();
}

class _NewMemberState extends State<NewMember> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _jobController = TextEditingController();
  final _refereeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _submitData() async {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredName = _nameController.text;
    final enteredAmount = double.parse(_amountController.text);
    final enteredPhoneNumber = _phoneNumberController.text;
    final enteredJob = _jobController.text;
    final enteredReferee = _refereeController.text;

    if (enteredName.isEmpty || enteredPhoneNumber.isEmpty || enteredJob.isEmpty || enteredReferee.isEmpty) {
      _showErrorDialog('Please fill all the fields!');
      return;
    }

    if (widget.token == null) {
      _showErrorDialog('Please Login!');
      return;
    }

    final response = await http.post(
      Uri.parse('http://192.168.122.1:8000/vikoba/member-registration/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${widget.token}',
      },
      body: jsonEncode(<String, String>{
        'member_name': enteredName,
        'amount': enteredAmount.toString(),
        'phone_number': enteredPhoneNumber,
        'occupation': enteredJob,
        'sponsor': enteredReferee,
        'join_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'member_of': widget._commonMemberOf.toString(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      widget.onMemberAdded();
      Navigator.of(context).pop();
    } else {
      _showErrorDialog('Failed to create member.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: kIsWeb ? 10 : MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Jina'),
                    controller: _nameController,
                    onSubmitted: (_) => _submitData(),
                  ),
                ),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Pesa ya kujiunga'),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _submitData(),
                  ),
                ),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    onSubmitted: (_) => _submitData(),
                  ),
                ),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Kazi au shughuli'),
                    controller: _jobController,
                    onSubmitted: (_) => _submitData(),
                  ),
                ),
                Flexible(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Mdhamini'),
                    controller: _refereeController,
                    onSubmitted: (_) => _submitData(),
                  ),
                ),
                Container(
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedDate == DateTime.now()
                              ? 'No Date Chosen!'
                              : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                        ),
                      ),
                      AdaptiveFlatButton('Choose Date', _presentDatePicker)
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text('Add Member'),
                  onPressed: _submitData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// MyMembersPage Widget
class MyMembersPage extends StatefulWidget {
  static const String routeName = '/my-members-list';
  final String? token;
  final String? memberId;
  final String? userOccupation;

  MyMembersPage({required this.token, this.memberId, this.userOccupation}){
    print('^^^^^^^^^^^^^^^^^^^ $userOccupation');
  }

  @override
  _MyMembersPageState createState() => _MyMembersPageState();
}

class _MyMembersPageState extends State<MyMembersPage> {
  final List<Member> _userMembers = [];
  String _commonMemberOf = '';

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _fetchCommonMemberOf();
    await _fetchMembers();
    setState(() {});
  }

  Future<void> _fetchMembers() async {
    if (widget.token != null) {
      final members = await MemberService.fetchMembers(widget.token!);
      setState(() {
        _userMembers.clear();
        _userMembers.addAll(members);
      });
    }
  }


  Future<void> _fetchCommonMemberOf() async {
    if (widget.token != null) {
      final commonMemberOf = await MemberService.getCommonMemberOf(widget.token!);
      setState(() {
        _commonMemberOf = commonMemberOf;
      });
    }
  }

  void _addNewMember(String txName, double txAmount, String txPhoneNumber, DateTime chosenDate, String txOccupation, String txSponsor) {
    final newTx = Member(
      id: DateTime.now().toString(),
      memberName: txName,
      phoneNumber: txPhoneNumber,
      joinDate: chosenDate,
      occupation: txOccupation,
      sponsor: txSponsor,
    );

    setState(() {
      _userMembers.add(newTx);
    });
  }

  void _startAddNewMember(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewMember(_addNewMember, widget.token, _commonMemberOf, _fetchMembers);
      },
    );
  }

  List<DataRow> _buildRows() {
    return _userMembers.map((member) {
      return DataRow(cells: [
        DataCell(Text(member.memberName)),
        DataCell(Text(member.phoneNumber)),
        DataCell(Text(member.occupation)),
        DataCell(Text(DateFormat.yMMMd().format(member.joinDate))),
        DataCell(Text(member.sponsor ?? 'N/A')),
        if (widget.userOccupation == 'Leader') ...[
          DataCell(
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                if (widget.token != null) {
                  MemberService.deleteMember(widget.token!, member.id).then((_) {
                    // If the delete operation was successful, navigate to MyMembersPage
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyMembersPage(token: widget.token, memberId: widget.memberId,)),
                    );
                  }).catchError((error) {
                    // Handle error
                    print('Failed to delete member: $error');
                  });
                }
              },
            ),
          ),
          DataCell(
            IconButton( 
              icon: Icon(Icons.edit),
              onPressed: () {
                // if (widget.token != null) {
                //   Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(builder: (context) => EditMemberPage(token: widget.token, memberId: member.id, userOccupation: widget.userOccupation)),
                //   );
                // }
              },
            ),
          ),
        ],
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wanachama'),
        actions: <Widget>[
          if (widget.userOccupation == 'Leader') 
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _startAddNewMember(context),
            ),
        ],
      ),
      body: _userMembers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Occupation')),
                  DataColumn(label: Text('Join Date')),
                  DataColumn(label: Text('Sponsor')),
                  if (widget.userOccupation == 'Leader') ...[
                    DataColumn(label: Text('Delete')),
                    DataColumn(label: Text('Edit')),
                  ],
                ],
                rows: _buildRows(),
              ),
            ),
    );
  }
}

class MemberService {
  static Future<List<Member>> fetchMembers(String token) async {
    try {
      print('############################# $token');
      final response = await http.get(
        Uri.parse('http://192.168.122.1:8000/vikoba/member-registration/'),
        headers: {
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode ==201) {
        final List<dynamic> responseData = json.decode(response.body);
        print(responseData);
        return responseData.map((data) => Member.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch members with status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred while fetching members: $error');
    }
  }

  static Future<void> deleteMember(String token, String memberId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.122.1:8000/vikoba/members/$memberId/'),
        headers: {
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print(response.body);
        throw Exception('Failed to delete member with status code: ${response.statusCode}');
      }
      else{
        print('###############${token}');
        await fetchMembers(token);

      }
    
      
    }
    catch (error) {
      
      throw Exception('Error occurred while deleting member: $error');
    }
  }


  static Future<String> getCommonMemberOf(String token) async {
    final members = await fetchMembers(token);
    if (members.isEmpty) {
      return '';
    }

    // Assuming memberOf is common among all members
    return members[0].memberOf ?? '';
  }
  static Future<Member> fetchCurrentUserDetails(String token, String memberId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.250.203:8000/member_detail/$memberId/'),
        headers: {
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Member.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch user details with status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error occurred while fetching user details: $error');
    }
  }
}




// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   final String token = "7d2f20f6b0c85504fbdb6f9e561301a0e666112e"; // Replace with your actual token

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Member Management',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyMembersPage(token: token), // Pass the token here
//     );
//   }
// }

