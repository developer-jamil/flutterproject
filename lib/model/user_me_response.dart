import 'json_helper.dart';

/// GET /users/me এর response — Probasi Live backend

class UserMeResponse {
  final bool success;
  final Account account;
  final Profile profile;
  final Map<String, int> wallets; // key বাড়তে পারে, তাই ক্লাস নয় — Map
  final Stats stats;

  UserMeResponse({
    this.success = false,
    required this.account,
    required this.profile,
    this.wallets = const {},
    required this.stats,
  });

  factory UserMeResponse.fromJson(Map<String, dynamic> j) => UserMeResponse(
    success: toBool(j['success']),
    account: Account.fromJson(j['account'] as Map<String, dynamic>? ?? {}),
    profile: Profile.fromJson(j['profile'] as Map<String, dynamic>? ?? {}),
    wallets: (j['wallets'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, toInt(v)),
    ),
    stats: Stats.fromJson(j['stats'] as Map<String, dynamic>? ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'success': success,
    'account': account.toJson(),
    'profile': profile.toJson(),
    'wallets': wallets.map((k, v) => MapEntry(k, v.toString())),
    'stats': stats.toJson(),
  };

  // getter — wallets Map থেকে সহজে diamond বের করা
  int get diamonds => wallets['DIAMOND'] ?? 0;
}

class Account {
  final String id; // "9713" — string হয়ে আসে, অঙ্ক হয় না, তাই String ই
  final String shortId;
  final String email;
  final bool emailVerified;
  final String? phone; // আপনার JSON এ null ছিল → nullable
  final String status;
  final DateTime? createdAt;

  Account({
    this.id = '',
    this.shortId = '',
    this.email = '',
    this.emailVerified = false,
    this.phone,
    this.status = '',
    this.createdAt,
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    id: toStr(j['id']),
    shortId: toStr(j['shortId']),
    email: toStr(j['email']),
    emailVerified: toBool(j['emailVerified']),
    phone: j['phone'] as String?,
    status: toStr(j['status']),
    createdAt: DateTime.tryParse(toStr(j['createdAt'])),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shortId': shortId,
    'email': email,
    'emailVerified': emailVerified,
    'phone': phone,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
  };

  bool get isActive => status == 'ACTIVE';
}

class Profile {
  final String name;
  final String bio;
  final String? avatarUrl; // null মানে "ছবি নেই" — আলাদা দেখাতে হয় → nullable
  final String? country;
  final int spenderLevel;
  final int earnerLevel;

  Profile({
    this.name = '',
    this.bio = '',
    this.avatarUrl,
    this.country,
    this.spenderLevel = 0,
    this.earnerLevel = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    name: toStr(j['name']),
    bio: toStr(j['bio']),
    avatarUrl: j['avatarUrl'] as String?,
    country: j['country'] as String?,
    spenderLevel: toInt(j['spenderLevel']),
    earnerLevel: toInt(j['earnerLevel']),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'bio': bio,
    'avatarUrl': avatarUrl,
    'country': country,
    'spenderLevel': spenderLevel,
    'earnerLevel': earnerLevel,
  };

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}

class Stats {
  final int lifetimeRecharge; // JSON এ "3013000" — string! তাই toInt
  final int lifetimeSpent;
  final int lifetimeEarned;

  Stats({
    this.lifetimeRecharge = 0,
    this.lifetimeSpent = 0,
    this.lifetimeEarned = 0,
  });

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
    lifetimeRecharge: toInt(j['lifetimeRecharge']),
    lifetimeSpent: toInt(j['lifetimeSpent']),
    lifetimeEarned: toInt(j['lifetimeEarned']),
  );

  Map<String, dynamic> toJson() => {
    'lifetimeRecharge': lifetimeRecharge.toString(),
    'lifetimeSpent': lifetimeSpent.toString(),
    'lifetimeEarned': lifetimeEarned.toString(),
  };
}
