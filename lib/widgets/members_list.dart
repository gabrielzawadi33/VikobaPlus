import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/models/member.dart';

class MembersList extends StatefulWidget {
  final String token;

  MembersList({required this.token});

  @override
  _MembersListState createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  List<Member> members = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
  try {
    final response = await http.get(
      Uri.parse('http://192.168.122.1:8000/vikoba/member-registration/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        members = responseData.map((data) => Member.fromJson(data)).toList();
        _isLoading = false;
        _hasError = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Failed to fetch members with status code: ${response.statusCode}');
    }
  } catch (error) {
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
    print('Error occurred while fetching members: $error');
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(child: Text('Failed to fetch members.'));
    }

    return members.isEmpty
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: <Widget>[
                  Text(
                    'No member added yet!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            },
          )
        : ListView.builder(
            itemBuilder: (ctx, index) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        members[index].name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Spacer(),
                      Text(
                        members[index].phoneNumber,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Spacer(),
                      Text(
                        DateFormat.yMMMd().format(members[index].join_date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: members.length,
          );
  }
}
