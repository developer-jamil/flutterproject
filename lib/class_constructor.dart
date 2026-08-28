void main(){

  // সার্ভার থেকে আসা আসল response (দুটো আলাদা কেস)
  final fullJson = {
    'id': 101,
    'title': 'Friday Night Live',
    'viewer_count': 1240,
    'coin_price': '49.50',        // ⚠️ সার্ভার string পাঠাচ্ছে!
    'is_live': 1,                 // ⚠️ bool নয়, int
    'started_at': '2026-08-26T20:30:00Z',
    'host': {'id': 7, 'name': 'Jamil', 'avatar': null},
    'tags': ['music', 'chat'],
  };

  // একই endpoint, কিন্তু ফিল্ড অর্ধেক নেই — এটাই ক্র্যাশের আসল কারণ
  final brokenJson = {'id': 102};

  final a = LiveStream.fromJson(fullJson);
  final b = LiveStream.fromJson(brokenJson);

  print(a);
  print(b);                       // ক্র্যাশ করেনি, খেয়াল করুন
  print('দর্শক: ${a.viewerLabel}');
  print('হোস্ট: ${a.host.name}');
  print('চলছে? ${a.isLive}');
  print(a.toJson());

  final empty = LiveStream.empty();
  print('খালি: ${empty.title}');

}

// ─────────────────────────────────────────────
class LiveStream {
  final int id;
  final String title;
  final int viewerCount;
  final double coinPrice;
  final bool isLive;
  final DateTime? startedAt;      // নাও থাকতে পারে → nullable
  final Host host;                // nested object
  final List<String> tags;

  // this. শর্টকাট — Java এর মতো assignment লিখতে হচ্ছে না
  const LiveStream({
    required this.id,
    required this.title,
    this.viewerCount = 0,
    this.coinPrice = 0,
    this.isLive = false,
    this.startedAt,
    required this.host,
    this.tags = const [],         // ⚠️ const list — ডিফল্ট হতে হলে const লাগে
  });

  // নামযুক্ত কনস্ট্রাক্টর — লোডিং/খালি অবস্থার জন্য
  LiveStream.empty()
      : id = 0,
        title = '',
        viewerCount = 0,
        coinPrice = 0,
        isLive = false,
        startedAt = null,
        host = Host.empty(),
        tags = const [];

  // factory — parsing এর আসল জায়গা
  factory LiveStream.fromJson(Map<String, dynamic> j) {
    return LiveStream(
      id: _toInt(j['id']),
      title: j['title'] as String? ?? 'শিরোনাম নেই',
      viewerCount: _toInt(j['viewer_count']),
      coinPrice: _toDouble(j['coin_price']),
      isLive: _toBool(j['is_live']),
      startedAt: DateTime.tryParse(j['started_at'] as String? ?? ''),
      host: Host.fromJson(j['host'] as Map<String, dynamic>? ?? {}),
      tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'viewer_count': viewerCount,
    'coin_price': coinPrice,
    'is_live': isLive ? 1 : 0,              // সার্ভার যেভাবে চায়
    'started_at': startedAt?.toIso8601String(),
    'host': host.toJson(),
    'tags': tags,
  };

  // getter — বন্ধনী ছাড়া ফিল্ডের মতো ব্যবহার হয়
  String get viewerLabel =>
      viewerCount >= 1000 ? '${(viewerCount / 1000).toStringAsFixed(1)}K' : '$viewerCount';

  bool get hasStarted => startedAt != null;

  Duration? get runningFor =>
      startedAt == null ? null : DateTime.now().difference(startedAt!);

  // UI তে ডেটা বদলাতে লাগবেই — immutable রেখে কপি
  LiveStream copyWith({int? viewerCount, bool? isLive}) => LiveStream(
    id: id,
    title: title,
    viewerCount: viewerCount ?? this.viewerCount,
    coinPrice: coinPrice,
    isLive: isLive ?? this.isLive,
    startedAt: startedAt,
    host: host,
    tags: tags,
  );

  @override
  String toString() => 'LiveStream($id, $title, ${host.name}, live=$isLive)';
}

// ─────────────────────────────────────────────
class Host {
  final int id;
  final String name;
  final String? avatar;

  const Host({required this.id, required this.name, this.avatar});

  Host.empty() : id = 0, name = 'অজানা', avatar = null;

  factory Host.fromJson(Map<String, dynamic> j) => Host(
    id: _toInt(j['id']),
    name: j['name'] as String? ?? 'অজানা',
    avatar: j['avatar'] as String?,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'avatar': avatar};

  // getter দিয়ে UI এর সিদ্ধান্ত মডেলেই রাখা
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}

// ─── সার্ভার যা-ই পাঠাক, নিরাপদে রূপান্তর ────
int _toInt(dynamic v) =>
    v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

bool _toBool(dynamic v) =>
    v is bool ? v : (v == 1 || v == '1' || v == 'true');