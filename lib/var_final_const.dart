main() {

  Basic_Part1();
  Identical_Part2();
  FinalTrap_Part3();

  // part4ConstCrash();   // চালু করলে ক্র্যাশ — শেষে দেখুন

  //১. আগে const লেখার চেষ্টা করুন
  //২. না হলে final
  //৩. সত্যিই বদলাতে হলে তবেই var
}




// ── ১. তিনটের পার্থক্য ────────────────────────
void Basic_Part1() {
  var x = 5; // টাইপ অনুমান করে, বদলানো যায়
  final y = 5; // একবার বসবে, রানটাইমে ঠিক হয়
  const z = 5; // কম্পাইল করার সময়েই জানা
  print(x);
  print(y);
  print(z);

  x = 10;           // ✓ var বদলায়
  // y = 10;        // ✗ final একবারই
  // z = 10;        // ✗ const একবারই
  print('$x $y $z');

  final now = DateTime.now();    // ✓ রানটাইমে ঠিক হয়
  // const bad = DateTime.now(); // ✗ কম্পাইল সময়ে জানা নেই
  print(now);


}

// ── ২. আসল ব্যাপার: canonicalization ──────────
void Identical_Part2() {

  const a = [1, 2, 3];
  const b = [1, 2, 3];
  identical(a, b); //true
  print(identical(a, b));

  final c = [1, 2, 3];
  final d = [1, 2, 3];
  identical(d, d); //false
  print(identical(a, b));

  print('final:  ${identical(c, d)}');   // false — দুটো আলাদা
  print('সমান কি? ${c == d}');           // false! (list এ == identity)

}


// ── ৩. final এর ফাঁদ ──────────────────────────
void FinalTrap_Part3(){

  final list = [1, 2, 3];
  list.add(4);          // ✓ ভেতরটা বদলে গেল
  print(list);          // [1, 2, 3, 4]
  // list = [5];        // ✗ রেফারেন্স বদলানো যাবে না

}

// ── ৪. const সত্যিই অপরিবর্তনীয় ───────────────
void part4ConstCrash() {
  const list = [1, 2, 3];
  list.add(4);          // 💥 Unsupported operation: Cannot add to an unmodifiable list
}