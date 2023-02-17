import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:http/http.dart' as http;

import 'utils/constants.dart';

enum EventName { sendMessage, sendGift, sendLove }

final pusherMessageProvider = ChangeNotifierProvider<PusherService>((ref) {
  return PusherService();
});

class PusherService extends ChangeNotifier {
  List<Map<String, dynamic>> _messageEventList = [];

  List<Map<String, dynamic>> get messageList => _messageEventList;

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  String _apiKey = "453b959a1424bf186bf2";
  String _cluster = 'eu';

  void initPusher() async {
    try {
      await pusher.init(
        apiKey: _apiKey,
        cluster: _cluster,
        onConnectionStateChange: (String a, String b) {},
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: (_, a) {},
        onMemberAdded: (_, a) {},
        onMemberRemoved: (_, a) {},
        // authEndpoint: "<Your Authendpoint>",
        // onAuthorizer: onAuthorizer
      );

      await pusher.connect();
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  Future<void> subscribeToChannel(String channelName,
      {String? eventType, required bool istrigger}) async {
    print('inside subcribe');

    if (!istrigger) {
      await pusher.subscribe(
        channelName: channelName,
      );
    }

    print('subscribed..... ');
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
    print('subscribed success');
  }

  void onEvent(PusherEvent event) {
    log(event.data);
    print("kkkk ${event.data.runtimeType}");
    final eventData = json.decode(event.data) as Map<String, dynamic>;
    addMessage(eventData);
  }

  void addMessage(Map<String, dynamic> data) {
    _messageEventList.add(data);
    try {
      notifyListeners();
      print('notifier done');
    } catch (e) {
      print('thrown error');
    }
    print("qqqqq $_messageEventList");
  }
/*
  Future<void> trigerEvent(
      String channelName, String eventType, String userId) async {
    final newEvent = PusherEvent(
        channelName: channelName,
        eventName: 'client-$eventType',
        data: {"myName": "Bob"});
    // final _pusherChannel = await pusher.subscribe(channelName: channelName);
    print('about to send msg');

    // final _pusherChannel = await pusher.subscribe(
    //   channelName: channelName,
    // );

    pusher.trigger(newEvent);
  }

  */

  Future<void> sendEvent(
      {required String userAuthToken,
      required String channelName,
      required String userName,
      required Enum eventName,
      required String message}) async {
    const url = SEND_EVENT;
    print(url);

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userAuthToken',
    };

    final _body = {
      "channelName": channelName,
      "userName": userName,
      "message": message,
      "eventName": "${eventName.index}"
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(_body));

      // final responseData = json.decode(response.body);

      print(json.decode(response.body));
    } catch (e) {
      print("error sending event  is $e");
    }
  }

  void clearChat() {
    _messageEventList = [];
    notifyListeners();
  }
}
