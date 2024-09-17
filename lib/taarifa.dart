import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class Message {
  final String sender;
  final String content;
  final DateTime timestamp;

  Message(this.sender, this.content, this.timestamp);
}

class TaarifaApp extends StatefulWidget {
  @override
  _TaarifaAppState createState() => _TaarifaAppState();
  static const routeName = '/taarifa';
  final String? token;
  final String? memberId;
  final String? userOccupation;

  TaarifaApp({this.token, this.memberId, this.userOccupation}) {
    print('Token: $token, Member ID: $memberId, User Occupation: $userOccupation');
  }
}
class _TaarifaAppState extends State<TaarifaApp> {
  List<Message> messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch existing messages when the widget initializes
    if (widget.token != null) {
      fetchMessages(widget.token!, widget.memberId!);
    }
  }

  void fetchMessages(String token, String memberId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.122.1:8000/vikoba/messages/'), // Replace with your API endpoint
        headers: {
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Message> fetchedMessages = data.map((item) => Message(
          item['sender'],
          item['message'],
          DateTime.parse(item['date_sent']),
        )).toList();

        setState(() {
          messages = fetchedMessages;
        });

        _scrollToBottom(); // Scroll to bottom after loading messages
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    try {
      final message = Message("Me", _textController.text, DateTime.now());
      final response = await http.post(
        Uri.parse('http://192.168.122.1:8000/vikoba/messages/${widget.memberId}/'), // Replace with your API endpoint
        headers: {
          'Authorization': 'Token ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sender': message.sender,
          'message': message.content,
          'timestamp': message.timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          messages.add(message);
          _textController.text = "";
        });
        _scrollToBottom(); // Scroll to bottom after sending message
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kTextTabBarHeight),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: 45 * pi / 180,
                      child: Icon(Icons.push_pin),
                    ),
                    Text(
                      "Taarifa",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 16, 17, 17),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.blue.withOpacity(0.4),
                        ),
                        height: 100,
                        margin: EdgeInsets.only(
                          bottom: 5,
                          right: 15,
                          left: 10,
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              child: Text(
                                message.sender.split(' ').map((l) => l[0].toUpperCase()).join(),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 81, 96, 104),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.message),
                                        SizedBox(width: 5),
                                        Text(
                                          DateFormat('d MMMM yyyy HH:mm')
                                              .format(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.blueGrey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.blueGrey.withOpacity(0.3),
                                        ),
                                        child: Text(
                                          message.content,
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (widget.userOccupation == 'Leader') 
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.blue.withOpacity(0.4),
                            border: Border.all(
                              color: Color.fromARGB(255, 81, 96, 104),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _textController,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
              ],
            ),
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height * 0.3,
              child: FloatingActionButton(
                child: Icon(Icons.arrow_downward),
                onPressed: _scrollToBottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
