import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/winner.dart';

class WinnersMarquee extends StatefulWidget {
  @override
  _WinnersMarqueeState createState() => _WinnersMarqueeState();
}

class _WinnersMarqueeState extends State<WinnersMarquee>
    with SingleTickerProviderStateMixin {
  List<Winner> winners = [];
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    );
    fetchWinners();
  }

  Future<void> fetchWinners() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.brilldaddy.com/api/voucher/getWinners'));
      if (response.statusCode == 200) {
        final List<dynamic> winnersData = jsonDecode(response.body);
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final validWinners = winnersData.where((winner) {
          final endTime =
              DateTime.parse(winner['endTime']).millisecondsSinceEpoch;
          return endTime > currentTime;
        }).toList();
        setState(() {
          winners =
              validWinners.map((winner) => Winner.fromJson(winner)).toList();
          _startScrolling();
        });
      } else {
        print('Failed to fetch winners: ${response.body}');
      }
    } catch (error) {
      print('Failed to fetch winners: $error');
    }
  }

  void _startScrolling() {
    if (winners.isNotEmpty) {
      Future.delayed(Duration(seconds: 1), () {
        _autoScroll();
      });
    }
  }

  void _autoScroll() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 10),
        curve: Curves.linear,
      ).then((_) {
        _scrollController.jumpTo(0);
        _autoScroll();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (winners.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.blue[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Colors.white),
                SizedBox(width: 8.0),
                Text(
                  'Our Winners List',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            height: 50.0,
            color: Colors.blue[50],
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: winners.length * 2, // Duplicate list for seamless loop
              itemBuilder: (context, index) {
                final winner = winners[index % winners.length];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue[100]!,
                          blurRadius: 4.0,
                          spreadRadius: 2.0),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        winner.username,
                        style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        winner.state,
                        style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        winner.productName,
                        style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '₹${winner.prize}',
                        style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
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
