void main(){

  // ১. অবস্থানভিত্তিক
  print(add(3, 4));

  // ২. নামযুক্ত ঐচ্ছিক
  greet();
  greet(name: 'Jamil');

  // ৩. required + default
  print(buildUrl(path: 'day'));
  print(buildUrl(path: 'day', page: 2));

  // ৪. ক্রম যেকোনো — নাম দিয়ে ডাকা
  print(formatPrice(amount: 250, currency: 'BDT'));
  print(formatPrice(currency: '\$', amount: 250));

  // ৫. ফাংশন একটা মান
  onTap(() => print('চাপা হয়েছে'));

  // ৬. callback এ ডেটা ফেরত
  fetchUser(onDone: (name) => print('পেলাম: $name'));


}

// ── অবস্থানভিত্তিক + তীর ফাংশন ─────────────
int add(int a, int b) => a + b;

// ── নামযুক্ত, ঐচ্ছিক (তাই nullable) ─────────
void greet({String? name}) => print('Hello ${name ?? " guest"}');

// ── required + ডিফল্ট মান ───────────────────
String buildUrl({required String path, int page = 1}) => 'https://edu.lrjamil.xyz/$path/$page';

// ── ক্রম মনে রাখতে হয় না ────────────────────
String formatPrice({required int amount, String currency = 'BDT'}) => '$currency$amount';

// ── ফাংশন প্যারামিটার হিসেবে ────────────────
void onTap(void Function() cb) => cb();


// ── callback দিয়ে ফলাফল ফেরত ───────────────
void fetchUser({required void Function(String) onDone}) {
  onDone('Jamil');

}