import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MessageCard extends StatelessWidget {
  final String userName;
  final String msg;
  const MessageCard({super.key, required this.userName, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: const TextStyle(color: Colors.blue, fontSize: 20),
          ),
          Text(msg),
        ],
      ),
    );
  }
}
