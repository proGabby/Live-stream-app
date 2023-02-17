import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

const AGORA_APP_ID = "9f2ac24faa694684b1d65a2a908b451f";
const AGORA_APP_CERTIFICATE = "617a95591e3946beb96e2ba2c7bac9f9";

// const userId = 'mainboss2two';

// const appKey = '41903234#1070497';
// const chatappToken =
//     "007eJxTYGC/ufuRytsbhVMljlbzvMr93X373nLrufk3O/+wPWz69eWGAoNFcophYqqZhZlZmpmJobGFhXGKcZqpgVmaRWqyaaqJxQ2nV8kNgYwMdz7eZmRkYGVgZGBiAPEZGADiSSOK";
// const chatUserToken =
//     '007eJxTYMiMzfe7f6xyXZZTzILfDF1q8xtEVNJm6h7uTtCTDoyOyFVgsEhOMUxMNbMwM0szMzE0trAwTjFOMzUwS7NITTZNNbGY5fMquSGQkYH3SRITIwMrAyMQgvgqDJamiWbmSeYGuolJiWa6hoapKbpJhgYmuolpRmapBmmmScnJxgCinyXA';

// const token =
//     '007eJxTYCh/oVibo7RtS9u7vWd5N95esihW5vNPS7lJDqEbmPd8ypimwGCRnGKYmGpmYWaWZmZiaGxhYZxinGZqYJZmkZpsmmpisULzVXJDICND77d8RkYGCATxWRhSUnPzGRgA1JMhYg==';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

const BASE_API = "https://meetmate.net/public/api/";
const LOG_IN_USER = "${BASE_API}user/login";
const GET_ONGOING_STREAM = "${BASE_API}user/get/all/ongoing/livestream";
const START_LIVE_STREAM = "${BASE_API}user/start/livestream";
const JOIN_LIVE_STREAM = "${BASE_API}user/join/livestream";
const END_LIVE_STREAM = "${BASE_API}user/end/livestream";
const SEND_EVENT = "${BASE_API}user/send/livestream/event";
