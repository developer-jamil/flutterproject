
void main(){

  final wallets = {
    'DIAMOND' : 1000000,
    'CREDIT' : 0,
    'UNVERIFIED_CREDIT' : 0,
    'SELLER_CREDIT' : 0,
    'GAME_COIN' : 0,
  };


  final decorations = [
    Decoration(slot: 'vehicle', name: 'Car 🚗', daysLeft: 29),
    Decoration(slot: 'king', name: 'Girl with Lion', daysLeft: 354),
    Decoration(slot: 'frame', name: null, daysLeft: 0), // null = পরা নেই
    Decoration(slot: 'crown', name: null, daysLeft: 0),
  ];

  // ── এবার সাতটা কাজ, প্রতিটা এক-দুই লাইন ──

  //১. map — প্রতিটা জিনিসকে অন্য কিছুতে বদলাও। এখানে: প্রতিটা Decoration → তার slot (String):
  final slots = decorations.map((d) => d.slot).toList();
  print('১. slots: $slots'); // [vehicle, king, frame, crown]


  //২. where — শর্তে টেকে যেগুলো, রাখো। শর্ত: name null নয়। ফলটা variable এ রাখুন — ৭ নম্বরেও লাগবে:
  final worn = decorations.where((d) => d.name != null).toList();
  print('২. পরা আছে: ${worn.length}টা'); // 2টা


  //৩. firstWhere — শর্তে টেকা প্রথমটা। না পেলে ক্র্যাশ, তাই orElse এ একটা খালি Decoration:
  final king = decorations.firstWhere(
        (d) => d.slot == 'king',
    orElse: () => const Decoration(slot: 'none'),
  );
  print('৩. king: ${king.name}'); // Girl with Lion

  //৪. any — একটাও কি শর্তে টেকে? উত্তর bool। খেয়াল করুন: "৩০ দিনের কমে expire" মানে পরা আছে এবং daysLeft < 30 — নাহলে frame এর 0 দিনও ধরা পড়বে:
  final expiringSoon = worn.any((d) => d.daysLeft < 30);
  print('৪. শিগগির expire? $expiringSoon'); // true (Car এর 29 দিন)

  //৫. every — সবগুলোই কি শর্তে টেকে? Map এ সরাসরি চলে না — wallets.values (শুধু সংখ্যাগুলো) নিয়ে:
  final allPositive = wallets.values.every((v) => v > 0);
  print('৫. সব wallet এ টাকা? $allPositive'); // false (CREDIT = 0)

  //৬. fold — শুরুর মান থেকে জমা করো। 0 থেকে শুরু, প্রতিবার যোগ:
  final totalBalance = wallets.values.fold(0, (sum, v) => sum + v);
  print('৬. মোট balance: $totalBalance'); // 1000000

  //৭. reduce — দুটো দুটো করে লড়িয়ে একটা বেছে নাও। সবচেয়ে বেশি daysLeft:
  final longest = decorations.reduce((a, b) => a.daysLeft > b.daysLeft ? a : b);
  print('৭. সবচেয়ে দীর্ঘ: ${longest.name} (${longest.daysLeft} দিন)'); // Girl with Lion

  final hasDiamond = (wallets['DIAMOND'] ?? 0) > 0;
  final menu = [
    'প্রোফাইল',
    if (hasDiamond) 'Gift পাঠান' else 'Recharge করুন',
    for (final d in worn) '✦ ${d.name}',
  ];
  print(menu.join('\n'));


}

class Decoration {
  final String slot;
  final String? name;
  final int daysLeft;
  const Decoration({required this.slot, this.name, this.daysLeft = 0});
}