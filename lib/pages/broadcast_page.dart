import 'dart:async';
import 'package:agora_live_streaming/pages/home_page.dart';
import 'package:agora_live_streaming/pages/message_card.dart';
import 'package:agora_live_streaming/provider/auth_provider.dart';
import 'package:agora_live_streaming/provider/stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';

import '../pusher_service.dart';
import '../stream_model.dart';
import '../utils/constants.dart';
import 'animatedEmoji.dart';
import 'like_animation.dart';

double buttonSize = 60;

class BroadcastPage extends ConsumerStatefulWidget {
  final String channelName;
  final bool isBroadcaster;
  final int streamId;

  const BroadcastPage(
      {super.key,
      required this.channelName,
      required this.isBroadcaster,
      required this.streamId});

  @override
  _BroadcastPageState createState() => _BroadcastPageState();
}

class _BroadcastPageState extends ConsumerState<BroadcastPage> {
  bool _emojiAppear = false;
  bool isAnimating = false;
  Streamer? _streamerData;

  TextEditingController _messageController = TextEditingController();

  int uid = 0; // uid of the local user

  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isHost =
      true; // Indicates whether the user has joined as a host or audience
  late RtcEngine agoraEngine; // Agora engine instance

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(appId: AGORA_APP_ID));

    await agoraEngine.enableVideo();

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  void leave() {
    setState(() {
      _isJoined = false;
      _remoteUid = null;
    });
    agoraEngine.leaveChannel();
  }

  @override
  void initState() {
    setupVideoSDKEngine();
    _streamerData = ref.read(streamerProvider).getStearmById(widget.streamId);
    ref.read(pusherMessageProvider).initPusher();
    super.initState();
    // Set up an instance of Agora engine
    // () async {
    //   await Future.delayed(Duration(seconds: 2));
    //   _isHost = widget.isBroadcaster;
    //   print("......... $_isHost");
    //   if (!widget.isBroadcaster) join();
    // };
  }

  // Release the resources when you leave
  @override
  void dispose() async {
    await agoraEngine.leaveChannel();
    agoraEngine.release();
    super.dispose();
  }

  void join() async {
    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (widget.isBroadcaster) {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.startPreview();
    } else {
      options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    }

    await agoraEngine.joinChannel(
      token: _streamerData!.token,
      channelId: widget.channelName,
      options: options,
      uid: uid,
    );
    print('about to subscribe');
    await ref
        .watch(pusherMessageProvider)
        .subscribeToChannel(widget.channelName, istrigger: false);
  }

  Widget buildFlowButtons(IconData icon, int index) => SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
            key: GlobalKey(debugLabel: index.toString()),
            elevation: 0,
            splashColor: Colors.black,
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              switch (index) {
                case 0:
                  setState(() {
                    _emojiAppear = true;
                  });
                  break;
                case 2:
                  print("emoji pressed");
                  setState(() {
                    isAnimating = true;
                  });
                  break;
                default:
              }
            }),
      );

  Widget buildBroadcaseterFlowButtons(IconData icon, int index) => SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: FloatingActionButton(
            key: GlobalKey(debugLabel: index.toString()),
            elevation: 0,
            splashColor: Colors.black,
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              switch (index) {
                case 2:
                  print("pressed");

                  break;
                default:
              }
            }),
      );

  Widget flowWidget(BuildContext context) {
    final iconList = <IconData>[
      Icons.chat_outlined,
      Icons.remove_red_eye_rounded,
      Icons.favorite,
      Icons.card_giftcard,
    ];
    final flowChildren = List.generate(4, (index) {
      return buildFlowButtons(iconList[index], index);
    });
    return Flow(
      delegate: FlowMenuDelegate(),
      children: flowChildren,
    );
  }

  Widget BroadCasterFlowWidget(BuildContext context) {
    final iconList = <IconData>[
      Icons.mic,
      Icons.remove_red_eye_rounded,
      Icons.switch_camera_outlined
    ];
    final flowChildren = List.generate(3, (index) {
      return buildBroadcaseterFlowButtons(iconList[index], index);
    });
    return Flow(
      delegate: FlowMenuDelegate(),
      children: flowChildren,
    );
  }

  Future<void> sendMessage(String authtoken) async {
    if (_messageController.text.isEmpty) {
      print("enter a text");
      return;
    }

    await ref.read(pusherMessageProvider).sendEvent(
        userAuthToken: authtoken,
        channelName: widget.channelName,
        userName: "kok",
        eventName: EventName.sendMessage,
        message: _messageController.text);

    _messageController.text = "";
    print('message sent');
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Streaming'),
        actions: [
          if (widget.isBroadcaster)
            TextButton(
              onPressed: () {
                _handleRadioValueChange(true);
                join();
                setState(() {
                  _isJoined = true;
                });
              },
              child: const Text(
                "Start LIVE",
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (!widget.isBroadcaster)
            TextButton(
              onPressed: () async {
                // final _token = ref.read(authProvider).token;
                // await ref
                //     .read(streamerProvider)
                //     .joinStream(_token!, widget.streamId);
                _handleRadioValueChange(false);
                join();
                setState(() {
                  _isJoined = true;
                });
              },
              child: const Text(
                "JOIN",
                style: TextStyle(color: Colors.white),
              ),
            ),
          Consumer(
            builder: (context, ref, child) {
              return Center(
                child: ElevatedButton(
                  child: Text("Leave"),
                  onPressed: () {
                    leave();
                    if (widget.isBroadcaster) {
                      final _token = ref.read(authProvider).token;
                      ref
                          .read(streamerProvider)
                          .leaveStream(_token!, widget.streamId);
                    }
                    ref.read(pusherMessageProvider).clearChat();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ));
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: deviceSize.height * 0.999,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Stack(
          children: [
            // Container for the local video
            if (_isJoined) Center(child: _videoPanel()),
            if (!widget.isBroadcaster) flowWidget(context),
            if (widget.isBroadcaster) BroadCasterFlowWidget(context),

            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linearToEaseOut,
                opacity: isAnimating ? 1.0 : 0.0,
                child: LikeAnimation(
                  child:
                      const Icon(Icons.favorite, color: Colors.blue, size: 150),
                  isAnimating: isAnimating,
                  duration: const Duration(milliseconds: 500),
                  onEnd: () {
                    setState(() {
                      isAnimating = false;
                    });
                  },
                ),
              ),
            ),

            if (!widget.isBroadcaster)
              Positioned(
                bottom: 5,
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                      constraints:
                          BoxConstraints(maxWidth: deviceSize.width * 0.9),
                      hintText: 'Enter a message',
                      // suffixIcon: const Icon(Icons.send_sharp),
                      suffix: GestureDetector(
                          onTap: () async {
                            final _token = ref.read(authProvider).token;
                            await sendMessage(_token!);
                          },
                          child: const Icon(Icons.send_sharp)),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      )),
                ),
              ),

            if (!widget.isBroadcaster && _emojiAppear)
              Positioned(
                right: 20,
                child: AnimatedEmoji(
                  iconTitle: "love_img.jpeg",
                ),
              ),

            Positioned(
              bottom: 100,
              child: Consumer(
                builder: (context, ref, child) {
                  final msgList = ref.watch(pusherMessageProvider).messageList;
                  // .reversed
                  // .toList();

                  if (msgList.length >= 10) {
                    msgList.removeRange(0, 1);
                  }

                  print("<<ppp $msgList");
                  return Container(
                    // color: Colors.grey,
                    width: 200,
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MessageCard(
                            userName: msgList[index]["user"],
                            msg: msgList[index]["message"]);
                      },
                      itemCount: msgList.length < 15 ? msgList.length : 15,
                    ),
                  );
                },
              ),
            )

            // Button Row ends
          ],
        ),
      ),
    );
  }

  Widget _videoPanel() {
    if (!_isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else if (_isHost) {
      // Show local video preview
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Show remote video
      if (_remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      } else {
        return const Text(
          'Waiting for a host to join',
          textAlign: TextAlign.center,
        );
      }
    }
  }

// Set the client role when a radio button is selected
  void _handleRadioValueChange(bool? value) async {
    setState(() {
      _isHost = (value == true);
    });
    if (_isJoined) leave();
  }
}

class FlowMenuDelegate extends FlowDelegate {
  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final xStart = size.width - buttonSize;
    final ystart = size.height - buttonSize;
    for (int i = 0; i < context.childCount; i++) {
      final margin = 20;
      final childSize = context.getChildSize(i)!.width;
      final dx = (childSize + margin) * i;
      final x = xStart;
      final y = ystart - 150 - dx;
      context.paintChild(i, transform: Matrix4.translationValues(x, y, 0));
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
