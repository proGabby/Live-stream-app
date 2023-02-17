import 'dart:convert';

import 'package:agora_live_streaming/stream_model.dart';
import 'package:agora_live_streaming/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final streamerProvider = ChangeNotifierProvider<StreamerProvider>((ref) {
  return StreamerProvider();
});

class StreamerProvider extends ChangeNotifier {
  List<Streamer> _streamers = [];

  List<Streamer> get streamer => _streamers;

  Future<Map<String, dynamic>> addLiveStream(
      {required double leastGift,
      required int maxParticipant,
      required String userAuthToken}) async {
    String? channelName;
    int? streamId;

    const url = START_LIVE_STREAM;
    print(url);

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userAuthToken',
    };
    final _body = {"least_gift": leastGift, "participantMax": maxParticipant};

    try {
      final response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(_body));
      final responseData = json.decode(response.body);

      print(responseData);
      if (responseData['status']) {
        final newStream = Streamer.fromData(responseData['data']);
        _streamers.add(newStream);
        channelName = responseData['data']['channel_name'];
        streamId = responseData['data']['id'];
      }
      notifyListeners();
      return {"channelName": channelName, "streamId": streamId};
    } catch (e) {
      print("error going live is $e");
      rethrow;
    }
  }

  // void closeStream(int id) {

  // }

  Future<void> fetchAndSetStream(String userAuthToken) async {
    const url = GET_ONGOING_STREAM;

    final header = {
      'Authorization': 'Bearer $userAuthToken',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: header,
      );
      final responseData = json.decode(response.body);
      final List<Streamer> _streamerList = [];
      if (responseData['status']) {
        final _streamList = responseData['data'] as List;
        _streamList.forEach((element) {
          final newStream = Streamer.fromData(element);
          _streamerList.add(newStream);
        });
      }
      _streamers = _streamerList;
      notifyListeners();
    } catch (e) {
      print("error fetching is $e");
    }
  }

  Streamer? getStearmById(int streamId) {
    Streamer? _stream;
    try {
      _stream = _streamers.firstWhere((element) => element.id == streamId);
    } catch (e) {
      _stream = null;
    }

    return _stream;
  }

  Future<void> joinStream(String userAuthToken, int streamId) async {
    print("....$streamId");
    const url = JOIN_LIVE_STREAM;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userAuthToken',
    };

    final _body = {
      "liveId": streamId,
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(_body));

      final responseData = json.decode(response.body);

      print(responseData.toString());
      // final List<Streamer> _streamerList = [];
      // if (responseData['status']) {
      //   final _streamList = responseData['data'] as List;
      //   _streamList.forEach((element) {
      //     final newStream = Streamer.fromData(element);
      //     _streamerList.add(newStream);
      //   });
      // }
      // _streamers = _streamerList;
      // notifyListeners();
    } catch (e) {
      print("error join stream is $e");
    }
  }

  Future<void> leaveStream(String userAuthToken, int streamId) async {
    print("....$streamId");
    const url = END_LIVE_STREAM;

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userAuthToken',
    };

    final _body = {
      "liveId": streamId,
    };

    try {
      final response = await http.post(Uri.parse(url),
          headers: header, body: json.encode(_body));

      final responseData = json.decode(response.body);

      print(responseData.toString());

      _streamers.removeWhere((item) => item.id == streamId);
      notifyListeners();
      // final List<Streamer> _streamerList = [];
      // if (responseData['status']) {
      //   final _streamList = responseData['data'] as List;
      //   _streamList.forEach((element) {
      //     final newStream = Streamer.fromData(element);
      //     _streamerList.add(newStream);
      //   });
      // }
      // _streamers = _streamerList;
      // notifyListeners();
    } catch (e) {
      print("error join stream is $e");
    }
  }
}
