import 'package:agora_live_streaming/pages/broadcast.dart';
import 'package:agora_live_streaming/pages/stream_card.dart';
import 'package:agora_live_streaming/provider/auth_provider.dart';
import 'package:agora_live_streaming/provider/stream_provider.dart';
import 'package:agora_live_streaming/pusher_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:uuid/uuid.dart';

import '../utils/constants.dart';
import 'broadcast_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  TextEditingController _maxParticipant = TextEditingController();
  TextEditingController _leastCashGift = TextEditingController();
  late Future futureHolder;

  @override
  void initState() {
    futureHolder = fetchFuture();

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _maxParticipant.dispose();
    _leastCashGift.dispose();
    super.dispose();
  }

  Future<void> fetchFuture() async {
    final _token = ref.read(authProvider).token;
    if (_token != null) {
      try {
        await ref.read(streamerProvider).fetchAndSetStream(_token);
      } catch (e) {
        showMessage(context, "error occurred while fetching data");
      }
    }
  }

  void submitToGoLive() async {
    if (_leastCashGift.text.isEmpty || _maxParticipant.text.isEmpty) {
      print('error here');
      return;
    }

    if (double.tryParse(_leastCashGift.text) == null ||
        int.tryParse(_maxParticipant.text) == null) {
      print('error2 here');
      return;
    }

    final _authToken = ref.read(authProvider).token;
    print("token is $_authToken");

    try {
      final meetingData = await ref.read(streamerProvider).addLiveStream(
            leastGift: double.parse(_leastCashGift.text),
            maxParticipant: int.parse(_maxParticipant.text),
            userAuthToken: _authToken!,
          );

      final channelName = meetingData['channelName'];
      final streamId = meetingData["streamId"];

      if (channelName != null && streamId != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return BroadcastPage(
                channelName: channelName,
                isBroadcaster: true,
                streamId: streamId);
          },
        ));
      } else {
        print("channel name not available");
      }
    } catch (e) {
      print("error n $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("live streaming"),
        actions: [
          TextButton(
              onPressed: () {
                final id = Uuid().v4();
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => BroadcastPage(
                //           channelName: "demo",
                //           isBroadcaster: true,
                //           streamId: id,
                //         ),
                //       ));

                // ref.read(streamerProvider).addLiveStream(
                //     id: id,
                //     isHost: true,
                //     isAudience: false,
                //     channelName: "demo",
                //     token: token);
                showDialog(
                    context: context,
                    builder: ((context) {
                      return Dialog(
                          child: Container(
                        padding: const EdgeInsets.all(15),
                        height: 300,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _leastCashGift,
                              decoration: InputDecoration(
                                helperText: 'Enter least cash gift',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: _maxParticipant,
                              decoration: InputDecoration(
                                helperText: 'Enter Maximum participant',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              color: Colors.blue,
                              child: ElevatedButton(
                                  onPressed: submitToGoLive,
                                  child: Text('Submit')),
                            )
                          ],
                        ),
                      ));
                    }));
              },
              child: const Text(
                "Go Live",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: FutureBuilder(
        future: futureHolder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text("Error occur");
          }

          final streamerList = ref.watch(streamerProvider).streamer;
          print(".... $streamerList");
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) =>
                StreamCard(streamer: streamerList[index], index: index),
            itemCount: streamerList.length,
          );
        },
      ),
      // bottomNavigationBar: TextButton(
      //     onPressed: () {
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => BroadcastPage(
      //               channelName: "demo",
      //               isBroadcaster: false,
      //               streamId: id,
      //             ),
      //           ));
      //     },
      //     child: const Text('Join')),
    );
  }
}
