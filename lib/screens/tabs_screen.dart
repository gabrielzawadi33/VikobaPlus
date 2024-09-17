import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication.dart';
import '../widgets/main_drawer.dart';
import './categories_screen.dart';
import 'report.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tab-screen';

  final String? token;
  final String? memberId;
  final String? userOccupation;
  
  
  TabsScreen({Key? key, this.token, this.memberId, this.userOccupation}) : super(key: key);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  String _memberName = '';

  late final List<Map<String, Object>> _pages;

  

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': CategoriesScreen(token: widget.token,memberId:  widget.memberId,),
    
        'title': 'Vikoba',
      },
      {
        'page': MyReportPage(title: 'Taarifa fupi ya fedha'),
        'title': 'taarifa ya fedha',
      },
    ];
    fetchData(widget.token, widget.memberId);
  }


  // Method to check internet connectivity
  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  Future<void> fetchData(String? token, String? memberId) async {
  if (token == null) return;

  bool isConnected = await checkConnectivity();
    if (!isConnected) {
      _showNoConnectionDialog();
      return;
    }

  try {
    print('#############################################$token');
    final response = await http.get(
      Uri.parse('http://192.168.122.1:8000/vikoba/member_detail/$memberId/'),
      headers: {
        // "Content-Type": "application/json",
        "Authorization": "Token $token",
      },
    );

    if (response.statusCode == 200) { 
      print('########################### ${response.body}');
      final responseData = json.decode(response.body); // Adjust the value as needed
      final memberName = responseData.isNotEmpty ? responseData['member_name'] : '';
      

      print('************************ $memberName  ');
      final nameInitials = memberName.split(' ').map((name) => name[0].toUpperCase()).join();
      print('************ $nameInitials');
      final userOccupation = responseData.isNotEmpty ? responseData['occupation']: '';

      final groupName = responseData.isNotEmpty ? responseData['member_of'] : '';

      
      

      setState(() {
        // Update the state with the group name
        _pages[0]['title'] = groupName;
        _pages[0]['page'] = CategoriesScreen(token: widget.token, memberId: widget.memberId, userOccupation: userOccupation);
        
        _memberName = nameInitials;
      });

      print(responseData);
    } else {
      print(token);
      print('############################# Failed to fetch data with status code: ${response.body}');
      print('############################# Failed to fetch data with status code: ${response.statusCode}');
    
    }
  } catch (error) {
    
    print('Error occurred while fetching data: $error');
  }
}


    void _showNoConnectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('No Internet Connection'),
        content: Text('Please check your internet connection and try again.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }


  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent[100],
        title: Text(_pages[_selectedPageIndex]['title'] as String),
        actions: <Widget>[
          FloatingActionButton(
        backgroundColor: Colors.blueAccent[100],
        mini: false,
        onPressed: () {
          
            Navigator.of(context).pushNamed(AuthScreen.routeName);
          
        },
        child: _memberName.isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _memberName,
                  style: TextStyle(color: Colors.blueAccent),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person_2),
                  Text('Ingia'),
                ],
              ),
          ),
        ],
      ),
      drawer: MainDrawer(widget.token, widget.memberId),
      body: _pages[_selectedPageIndex]['page'] as Widget, // Adjust the value as needed
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Colors.blueAccent[100],
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.category),
            label: 'Vidokezo',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.bar_chart),
            label: 'Ripoti',
          ),
        ],
      ),
    );
  }
}
