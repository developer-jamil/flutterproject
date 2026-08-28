import 'dart:convert';

import 'package:flutterproject/model/user_me_response.dart';

void main() {
  // ── কেস ১: আসল Postman response ──
  // এখানে r''' এর ভেতরে আপনার Postman থেকে কপি করা পুরো JSON টা বসান

  const raw = r'''
  {
    "success": true,
    "monitor": null,
    "account": {
        "id": "9713",
        "shortId": "9",
        "email": "computerbasiclarn@gmail.com",
        "emailVerified": true,
        "phone": null,
        "provider": "GOOGLE",
        "role": "USER",
        "canGiftInRoom": true,
        "sellerVerified": false,
        "status": "ACTIVE",
        "statusReason": null,
        "bonusClaimed": false,
        "loginCount": 11,
        "lastLoginAt": "2026-08-28T02:36:13.387Z",
        "lastActiveAt": "2026-08-28T02:36:40.978Z",
        "createdAt": "2026-08-17T04:04:31.472Z"
    },
    "profile": {
        "name": "Basic Learn",
        "bio": "",
        "avatarUrl": "https://lh3.googleusercontent.com/a/ACg8ocIynBQ_O4YEfMIL4oPWpBOvzlTanhv5wdsgtdH5rKm0irt4GoU=s96-c",
        "coverUrl": null,
        "gender": "MALE",
        "dateOfBirth": null,
        "country": "Bangladesh",
        "countryCode": "BD",
        "address": null,
        "language": null,
        "spenderLevel": 11,
        "earnerLevel": 0
    },
    "wallets": {
        "DIAMOND": "9006366",
        "CREDIT": "0",
        "UNVERIFIED_CREDIT": "0",
        "SELLER_CREDIT": "0",
        "GAME_COIN": "0"
    },
    "level": {
        "ladder": "USER",
        "tier": 11,
        "name": "Lv 11",
        "iconUrl": null,
        "color": "#E0A146",
        "total": "3013000"
    },
    "counts": {
        "friends": 0,
        "following": 4,
        "followers": 4
    },
    "decorations": {
        "frame": null,
        "vehicle": {
            "id": 28,
            "name": "Car 🚗",
            "imageUrl": "https://phm-backend.bondhulive.com/uploads/1787003768466-fc6b5618747dcfdb.jpg",
            "animationUrl": "https://phm-backend.bondhulive.com/uploads/gift-1787003754649-bbb5b8d1cf0361ae.mp4",
            "expiresAt": "2026-09-26T16:03:12.778Z"
        },
        "chatBubble": null,
        "entryBar": null,
        "sticker": null,
        "roomBackground": null,
        "roomLock": null,
        "theme": null,
        "king": {
            "id": 19,
            "name": "Girl with Lion",
            "imageUrl": "https://phmbackend.phmlive.com/uploads/1786986914754-46d83e73b40a963f.png",
            "animationUrl": "https://phmbackend.phmlive.com/uploads/gift-1786986877336-8c5495d5d8f47297.mp4",
            "expiresAt": "2027-08-17T17:47:28.370Z"
        },
        "crown": null,
        "vvip": null,
        "vip": null
    },
    "stats": {
        "lifetimeRecharge": "0",
        "lifetimeSpent": "3013000",
        "lifetimeEarned": "3174466"
    }
}
  ''';


  final me = UserMeResponse.fromJson(jsonDecode(raw));
  print('name: ${me.profile.name}');
  print('bio: ${me.profile.initial}');
  print('Diamond: ${me.diamonds}');
  print('Email Verified: ${me.account.emailVerified}');
  print('Active? ${me.account.isActive}');
  print('Total Cost: ${me.stats.lifetimeSpent}');


  // ── কেস ২: সার্ভার অর্ধেক পাঠাল ──
  final half = UserMeResponse.fromJson({'success': true, 'account': {'id': '5'}});
  print('\nঅর্ধেক: ${half.account.id}, নাম="${half.profile.name}"'); // ক্র্যাশ নয়!


  // ── কেস ৩: একদম খালি ──
  final empty = UserMeResponse.fromJson({});
  print('খালি: diamonds=${empty.diamonds}');

  // ── round trip ──
  final back = UserMeResponse.fromJson(me.toJson());
  print('\nফেরত এসে নাম: ${back.profile.name}');

}
