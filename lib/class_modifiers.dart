void main() {
  final repo = LiveRepository();

  handle(repo.fetch(id: 1));    // সফল
  handle(repo.fetch(id: -1));   // ভুল
  handle(repo.fetch(id: 99));   // পাওয়া যায়নি

  repo.log('কাজ শেষ');
  print('মোট কল: ${repo.callCount}');
}

// ─── sealed এর আসল দাম এখানে ─────────────────
void handle(Result<String> r) {
  // switch এ একটা কেস বাদ দিলে কম্পাইলার ধরবে
  final msg = switch (r) {
    Ok(:final data) => '✓ পেলাম: $data',
    Err(:final message, :final code) => '✗ ভুল [$code]: $message',
    Loading() => '⏳ অপেক্ষা...',
  };
  print(msg);
}

// ─────────────────────────────────────────────
// sealed = abstract + final + উপশ্রেণি একই ফাইলে
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);
}

final class Err<T> extends Result<T> {
  final String message;
  final int code;
  const Err(this.message, {this.code = 0});
}

final class Loading<T> extends Result<T> {
  const Loading();
}

// ─── mixin — Java তে নেই ─────────────────────
mixin Loggable {
  void log(String m) => print('[LOG] $m');
}

// mixin এ অবস্থাও রাখা যায় — এটাই default method এর চেয়ে বেশি
mixin Countable {
  int _count = 0;
  int get callCount => _count;
  void countUp() => _count++;
}

// ─── base = extends হবে, implements নয় ───────
base class Repository with Loggable, Countable {
  // ভেতরের এই কোডটা যেন কেউ নকল করে
  // এড়িয়ে যেতে না পারে
  Result<T> guard<T>(T Function() body) {
    countUp();
    try {
      return Ok(body());
    } catch (e) {
      return Err(e.toString(), code: 500);
    }
  }
}

// base ক্লাসের সন্তানকেও base/final/sealed হতে হয়
final class LiveRepository extends Repository {
  Result<String> fetch({required int id}) {
    if (id < 0) return const Err('id ভুল', code: 400);
    if (id > 50) return const Err('পাওয়া যায়নি', code: 404);
    return guard(() => 'Stream #$id');
  }
}

// ─── বাকি modifier গুলো ──────────────────────

// abstract — অবজেক্ট বানানো যাবে না, শুধু চুক্তি
abstract class Cache {
  String? read(String key);
  void write(String key, String value);
}

// interface — implements হবে, extends নয়
interface class Analytics {
  void track(String event) => print('track: $event');
}

// implements করলে ভেতরের কোড পাওয়া যায় না, নিজে লিখতে হয়
class FirebaseAnalytics implements Analytics {
  @override
  void track(String event) => print('firebase: $event');
}

// final — কেউ extends ও করতে পারবে না, implements ও না
final class AppConfig {
  static const baseUrl = 'https://edu.lrjamil.xyz';
  const AppConfig();
}