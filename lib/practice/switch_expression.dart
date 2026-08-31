void main() {
  print(show('loading'));
  print(show('done'));
  print(show('abc'));

  print(Show('loading'));
  print(Show('done'));
  print(Show('abc'));

}


//=== Method if else ===
String show(String value) {
  if (value == 'loading') {
    return 'Loading Please wait';
  } else if (value == 'done') {
    return 'Date fetched';
  } else {
    return 'Problems Found';
  }
}


//=== method if else with switch short ===
String Show(String status) => switch (status) {
  'loading' => 'লোড হচ্ছে...',
  'done' => 'হয়ে গেছে',
  _ => 'সমস্যা', // _ মানে "বাকি সব"
};
