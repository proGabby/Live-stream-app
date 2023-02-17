import 'package:agora_live_streaming/pages/broadcast_page.dart';
import 'package:agora_live_streaming/stream_model.dart';
import 'package:flutter/material.dart';

class StreamCard extends StatelessWidget {
  final Streamer streamer;
  final int index;
  const StreamCard({super.key, required this.streamer, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return BroadcastPage(
            channelName: streamer.channelName,
            isBroadcaster: false,
            streamId: streamer.id,
          );
        },
      )),
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 1)),
        child: Text(
          index.toString(),
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
