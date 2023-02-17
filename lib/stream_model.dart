class Streamer {
  final int id;
  final String channelName;
  final String token;
  final int views;
  final int? meetingId;

  Streamer(
      {required this.id,
      required this.meetingId,
      required this.views,
      required this.channelName,
      required this.token});

  factory Streamer.fromData(
    Map<String, dynamic> data,
  ) =>
      Streamer(
          id: data["id"],
          meetingId: data["meeting_id"],
          views: data["views"],
          channelName: data["channel_name"],
          token: data["token"]);
}
