void main() {
  final streams = [
    Stream_(id: 1, title: 'Friday Night', viewers: 1240, tags: ['music'], isLive: true),
    Stream_(id: 2, title: 'Morning Talk', viewers: 85, tags: ['chat', 'news'], isLive: false),
    Stream_(id: 3, title: 'Gaming Marathon', viewers: 3200, tags: ['game', 'chat'], isLive: true),
    Stream_(id: 4, title: 'Quiet Room', viewers: 12, tags: [], isLive: false),
  ];

  // ১. map — রূপান্তর
  final titles = streams.map((s) => s.title).toList();
  print('শিরোনাম: $titles');

  // ২. where — ছাঁকা
  final live = streams.where((s) => s.isLive).toList();
  print('চলছে: ${live.length}টা');

  // ৩. firstWhere — প্রথমটা (না পেলে ক্র্যাশ! তাই orElse)
  final top = streams.firstWhere(
        (s) => s.viewers > 1000,
    orElse: () => streams.first,
  );
  print('প্রথম বড়: ${top.title}');

  // ৪. any — একটাও আছে?
  print('কেউ কি লাইভ? ${streams.any((s) => s.isLive)}');

  // ৫. every — সবগুলোই?
  print('সবার ট্যাগ আছে? ${streams.every((s) => s.tags.isNotEmpty)}');

  // ৬. fold — শুরুর মান দিয়ে জড়ো করা (খালি হলেও নিরাপদ)
  final total = streams.fold<int>(0, (sum, s) => sum + s.viewers);
  print('মোট দর্শক: $total');

  // ৭. reduce — শুরুর মান নেই (খালি list এ ক্র্যাশ)
  final busiest = streams.reduce((a, b) => a.viewers > b.viewers ? a : b);
  print('সবচেয়ে ব্যস্ত: ${busiest.title}');

  // ── চেইন করা — বাস্তবে এভাবেই লিখবেন ──
  final liveTitles = streams
      .where((s) => s.isLive)
      .map((s) => '${s.title} (${s.viewers})')
      .toList();
  print('লাইভ তালিকা: $liveTitles');

  // ── Set — ডুপ্লিকেট নিজেই বাদ ──
  final allTags = streams.expand((s) => s.tags).toSet();
  print('সব ট্যাগ: $allTags');   // chat দুবার আছে, একবারই এলো

  // ── Map — id দিয়ে খোঁজার জন্য ──
  final byId = {for (final s in streams) s.id: s};
  print('id 3 = ${byId[3]?.title}');
  print('id 9 = ${byId[9]?.title ?? 'নেই'}');

  // ── groupBy হাতে বানানো ──
  final grouped = <bool, List<Stream_>>{};
  for (final s in streams) {
    grouped.putIfAbsent(s.isLive, () => []).add(s);
  }
  print('লাইভ: ${grouped[true]?.length}, বন্ধ: ${grouped[false]?.length}');

  // ── spread ──
  final pinned = [Stream_(id: 0, title: 'ঘোষণা', viewers: 0, tags: [], isLive: false)];
  List<Stream_>? maybeNull;
  final feed = [...pinned, ...streams, ...?maybeNull];
  print('ফিড: ${feed.length}টা');

  // ── collection if / for ──
  final isLoggedIn = true;
  final menu = [
    'হোম',
    if (isLoggedIn) 'প্রোফাইল',
    if (isLoggedIn) 'সেটিংস' else 'লগইন',
    for (final s in live) '▶ ${s.title}',
  ];
  print(menu.join('\n'));
}

class Stream_ {
  final int id;
  final String title;
  final int viewers;
  final List<String> tags;
  final bool isLive;

  const Stream_({
    required this.id,
    required this.title,
    required this.viewers,
    required this.tags,
    required this.isLive,
  });
}