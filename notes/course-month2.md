# মাস ২ — পেশাদার Flutter (সপ্তাহ ৫–৮ · ২১ সেপ্টেম্বর – ১৮ অক্টোবর)

> **রোডম্যাপ সংশোধনী (মাস ৩–৫ এ যোগ হবে):**
> - সপ্তাহ ১৩: আধা দিন — platform channel (Dart ↔ Kotlin), Agora AAR/jniLibs বোঝার ভিত্তি
> - সপ্তাহ ১৪: ৩ দিনের realtime মডিউল — WebSocket/socket.io client, StreamBuilder দিয়ে live event, Agora Flutter SDK hello-world (join/leave, mute)
> - সপ্তাহ ১৫: ১ দিন — Play Billing নীতি + in_app_purchase (diamond/coin = digital goods, SSLCommerz ওখানে বৈধ নয়); animation দিনে CustomPaint/Canvas এক বেলা
> - সপ্তাহ ১৭: ১ ঘণ্টা — force update কৌশল (version check, আপডেট dialog)

---

## সপ্তাহ ৫ — নেটওয়ার্ক স্তর: Dio থেকে Repository

**সপ্তাহের লক্ষ্য:** আপনার Probasi Live backend এর সাথে অ্যাপের কথা বলার পুরো স্তরটা পেশাদারভাবে দাঁড় করানো।

### দিন ১ — Dio দিয়ে প্রথম আসল কল

**১. http বনাম Dio, আর প্রথম GET** · ⏱ ৬০ মিনিট · নেটওয়ার্ক

📋 Dio বসান (`dart pub add dio`), নিজের backend এর একটা খোলা endpoint এ GET মারুন।

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://your-api.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
));

final res = await dio.get('/sliders');
print(res.statusCode);
print(res.data); // Dio নিজেই jsonDecode করে দেয়
```

⚠️ timeout না দিলে দুর্বল নেটে অ্যাপ অনন্তকাল ঝুলে থাকে — বাংলাদেশের নেটে এটা বিলাসিতা নয়, বাধ্যতামূলক।

✓ যাচাই: status 200 আর আসল ডেটা console এ দেখেছেন? timeout ২ সেকেন্ডে নামিয়ে দুর্বল নেট simulate করে TimeoutException দেখেছেন?

**২. DioException ধরা** · ⏱ ৪৫ মিনিট · নেটওয়ার্ক

📋 ভুল URL, বন্ধ সার্ভার, 404 — তিনভাবে কল ব্যর্থ করিয়ে `on DioException catch (e)` এ `e.type` আর `e.response?.statusCode` লগ করুন। মাস ১ এর sealed `Result` মনে করুন — এই exception গুলোই পরে `Err` হবে।

✓ যাচাই: connectionTimeout, badResponse, connectionError — তিনটা আলাদা type নিজে বানিয়ে দেখেছেন?

### দিন ২ — Interceptor

**১. LogInterceptor ও নিজের interceptor** · ⏱ ৭৫ মিনিট · নেটওয়ার্ক

📋 প্রতিটা request/response লগ হবে, আর প্রতিটা request এ নিজে থেকেই header বসবে।

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options); // ⚠️ next() ভুললে request আটকে থাকবে
  },
  onError: (e, handler) {
    if (e.response?.statusCode == 401) {
      // এখানেই পরে refresh token বসবে (মাস ৩)
    }
    handler.next(e);
  },
));
```

⚠️ production build এ LogInterceptor বন্ধ রাখবেন — token লগে ছাপা মানেই ফাঁস (মাস ১ এর secrets পাঠ মনে করুন)।

✓ যাচাই: interceptor দিয়ে বসানো header সার্ভার লগে/httpbin.org/headers এ দেখেছেন?

### দিন ৩ — freezed দিয়ে model

**১. build_runner ও freezed setup** · ⏱ ৪৫ মিনিট · টুলিং

📋 `freezed_annotation`, `json_annotation` (deps) আর `build_runner`, `freezed`, `json_serializable` (dev_deps) বসান। চালান: `dart run build_runner watch -d`

**২. হাতের model কে freezed এ রূপান্তর** · ⏱ ৯০ মিনিট · মডেল

📋 মাস ১ এ হাতে লেখা `Profile`/`Stats` কে freezed এ নতুন করে লিখুন — এবার বুঝবেন generator ঠিক কী কী লিখে দিচ্ছে (fromJson, copyWith, ==, toString — সব যা আপনি হাতে লিখেছিলেন)।

```dart
@freezed
sealed class Profile with _$Profile {
  const factory Profile({
    @Default('') String name,
    @Default('') String bio,
    String? avatarUrl,
    @Default(0) int spenderLevel,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
```

⚠️ `@Default` টাই হাতের `?? ''` এর জায়গা নিল — এটা বাদ দিলে সেই পুরনো null-ক্র্যাশ ফিরে আসবে। AI generated freezed model এও এটাই সবচেয়ে বেশি বাদ পড়ে।

✓ যাচাই: `Profile.fromJson({})` ক্র্যাশ ছাড়া চলে? `.copyWith(name: 'x')` কাজ করে? generated ফাইলটা খুলে একবার চোখ বুলিয়েছেন?

### দিন ৪ — Retrofit

**১. Retrofit দিয়ে টাইপ-নিরাপদ API ক্লাস** · ⏱ ৯০ মিনিট · নেটওয়ার্ক

📋 `retrofit` + `retrofit_generator` বসিয়ে আপনার ৩টা endpoint এর interface লিখুন:

```dart
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio) = _UserApi;

  @GET('/users/me')
  Future<UserMeResponse> getMe();

  @GET('/users/{id}')
  Future<UserMeResponse> getUser(@Path() String id);

  @GET('/users/search')
  Future<List<UserLite>> search(@Query('q') String q);
}
```

✓ যাচাই: হাতে dio.get লেখা আর Retrofit — কোন কোন ভুল Retrofit এ কম্পাইল টাইমেই ধরা পড়ে, দুটো উদাহরণ বলতে পারেন?

### দিন ৫ — sealed Result থেকে fpdart

**১. Result দিয়ে Repository র ভাষা** · ⏱ ৬০ মিনিট · আর্কিটেকচার

📋 মাস ১ এর sealed `Result<T>` (Ok/Err/Loading) নেটওয়ার্ক স্তরে বসান — DioException কে Err এ রূপান্তরের একটা helper লিখুন (কোন type → কোন বাংলা বার্তা)।

**২. fpdart এর Either — পড়া ও তুলনা** · ⏱ ৪৫ মিনিট · আর্কিটেকচার

📋 `Either<Failure, T>` কী, নিজের Result এর সাথে পার্থক্য কোথায় — পড়ুন, একটা ফাংশন Either দিয়ে লিখে দেখুন। সিদ্ধান্ত নিন: নিজের প্রজেক্টে কোনটা ব্যবহার করবেন (দুটোই বৈধ — নিজের Result সহজ, fpdart এ chaining শক্তিশালী)।

✓ যাচাই: `fold` কী করে বলতে পারেন? কেন exception ছোড়ার চেয়ে Either/Result ফেরত ভালো — এক লাইনে?

### দিন ৬ — Repository ও সপ্তাহের প্রজেক্ট

**১. Repository এর সীমানা** · ⏱ ৯০ মিনিট · আর্কিটেকচার

📋 নিয়ম: UI কখনো Dio/Retrofit চেনে না — চেনে শুধু Repository। লিখুন `UserRepository`: ভেতরে `UserApi`, বাইরে `Future<Result<UserMeResponse>> getMe()`। সব try/catch এখানেই শেষ — Repository র বাইরে exception বেরোয় না।

**২. মিনি-প্রজেক্ট: আসল প্রোফাইল ডেটা** · ⏱ ৬০ মিনিট · প্রজেক্ট

📋 মাস ১ এর Day3Screen এ hardcoded JSON এর বদলে `UserRepository.getMe()` — FutureBuilder দিয়ে loading/সফল/ব্যর্থ তিন অবস্থা দেখান (switch expression দিয়ে — মাস ১ এর exhaustiveness এখানেই ফল দিল)।

✓ যাচাই: নেট বন্ধ করে অ্যাপ খুললে সুন্দর error বার্তা দেখায়, ক্র্যাশ নয়? 🔗 GitHub এ সপ্তাহের সব কাজ এক PR এ।

---

## সপ্তাহ ৬ — টেস্টিং (পুরো সপ্তাহ)

**সপ্তাহের লক্ষ্য:** "চালিয়ে দেখলাম, চলছে" থেকে "test বলছে চলছে" — আর AI এর লেখা কোড যাচাই করার ক্ষমতা।

### দিন ১ — unit test

**১. প্রথম unit test: নিজের মডেল** · ⏱ ৯০ মিনিট · টেস্টিং

📋 মাস ১ এর তিন কেস (পূর্ণ/অর্ধেক/খালি JSON) এবার print নয় — test:

```dart
test('খালি JSON এ ক্র্যাশ নয়, default বসে', () {
  final p = Profile.fromJson({});
  expect(p.name, '');
  expect(p.spenderLevel, 0);
});

test('string সংখ্যা int হয়', () {
  final s = Stats.fromJson({'lifetimeSpent': '3013000'});
  expect(s.lifetimeSpent, 3013000);
});
```

চালান: `flutter test`

✓ যাচাই: ইচ্ছা করে model ভেঙে (একটা `@Default` মুছে) test লাল হতে দেখেছেন? — লাল না দেখলে বুঝবেন না test টা আসলে পাহারা দিচ্ছে।

**২. group, setUp, matcher** · ⏱ ৪৫ মিনিট · টেস্টিং

📋 `group()` দিয়ে সাজানো, `setUp()` এ সাধারণ প্রস্তুতি, matcher: `throwsA`, `isA<T>()`, `contains`।

### দিন ২ — mocktail

**১. নকল সার্ভার দিয়ে Repository টেস্ট** · ⏱ ৯০ মিনিট · টেস্টিং

📋 আসল সার্ভার ছাড়া টেস্ট — `mocktail` দিয়ে UserApi নকল:

```dart
class MockUserApi extends Mock implements UserApi {}

test('404 এ Err ফেরে, exception নয়', () async {
  final api = MockUserApi();
  when(() => api.getMe()).thenThrow(fake404());
  final repo = UserRepository(api);

  final r = await repo.getMe();
  expect(r, isA<Err>());
});
```

⚠️ কেন নকল: টেস্ট সার্ভারের মর্জির উপর নির্ভর করলে CI তে random লাল হবে, আর আপনি টেস্ট বিশ্বাস করা ছেড়ে দেবেন।

✓ যাচাই: `when`/`verify` এর পার্থক্য বলতে পারেন? সার্ভার বন্ধ রেখেও পুরো টেস্ট সবুজ?

### দিন ৩ — widget test

**১. প্রথম widget test** · ⏱ ৯০ মিনিট · টেস্টিং

📋 প্রোফাইল কার্ডের টেস্ট: pumpWidget → find → expect:

```dart
testWidgets('নাম আর ব্যালেন্স দেখায়', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: ProfileCard(user: testUser),
  ));
  expect(find.text('Basic Learn'), findsOneWidget);
  expect(find.byIcon(Icons.verified), findsOneWidget);
});
```

⚠️ `pump()` বনাম `pumpAndSettle()` — animation থাকলে দ্বিতীয়টা; কিন্তু অনন্ত animation (loading spinner) এ pumpAndSettle কখনো শেষ হয় না — সেখানে `pump(Duration(...))`।

✓ যাচাই: টেস্টে একটা বাটন tap করিয়ে (tester.tap) ফলাফল যাচাই করেছেন?

### দিন ৪ — golden ও integration

**১. golden test — চেহারার স্ক্রিনশট পাহারা** · ⏱ ৬০ মিনিট · টেস্টিং

📋 `expectLater(find.byType(ProfileCard), matchesGoldenFile('profile_card.png'))` — প্রথমবার `flutter test --update-goldens`, তারপর কেউ UI ভাঙলে টেস্ট লাল।

⚠️ golden ফাইল প্ল্যাটফর্মভেদে সামান্য আলাদা রেন্ডার হয় — CI আর নিজের পিসিতে একই OS না হলে ঝামেলা; আপাতত লোকালেই রাখুন।

**২. integration test এক নজরে** · ⏱ ৪৫ মিনিট · টেস্টিং

📋 `integration_test` package — আসল ডিভাইসে পুরো অ্যাপ চালিয়ে টেস্ট। আজ শুধু একটা চালিয়ে দেখুন; গভীরে মাস ৪ এ।

### দিন ৫ — Riverpod provider টেস্ট ও CI

**১. ProviderContainer দিয়ে টেস্ট** · ⏱ ৬০ মিনিট · টেস্টিং

📋 `ProviderContainer(overrides: [userRepoProvider.overrideWithValue(mockRepo)])` — UI ছাড়াই state logic টেস্ট।

**২. CI তে টেস্ট** · ⏱ ৪৫ মিনিট · CI

📋 মাস ১ এর ci.yml এ `flutter test --coverage` তো ছিলই — এবার ইচ্ছা করে একটা টেস্ট ভেঙে push করুন, PR এ লাল ✗ দেখুন, ঠিক করে সবুজ করুন। এই লাল-সবুজ চক্রটা একবার চোখে দেখাই CI বোঝার আসল উপায়।

✓ যাচাই: PR এ status check ফেল করলে merge বোতামের চেহারা কেমন হয়, দেখেছেন?

### দিন ৬ — AI কোড যাচাই + GetX/Bloc পড়া

**১. AI এর লেখা কোড যাচাইয়ের পদ্ধতি** · ⏱ ৯০ মিনিট · পদ্ধতি

📋 AI কে দিয়ে একটা model + repository লেখান, তারপর checklist ধরে ধরুন: null default আছে? exception কোথায় ধরা হচ্ছে? টাইপ ফাঁদ (string সংখ্যা)? তারপর **টেস্ট লিখে প্রমাণ করুন** — খালি JSON, 404, timeout। যা ফেল করে, সেটাই AI এর বাদ দেওয়া জায়গা।

✓ যাচাই: AI এর কোডে অন্তত ১টা আসল ভুল টেস্ট দিয়ে ধরেছেন?

**২. GetX ও Bloc পড়তে পারা** · ⏱ ৯০ মিনিট · পাঠ

📋 লিখবেন না — পড়বেন। GetX: `Obx`, `.obs`, `Get.to` চিনুন; Bloc: Event → Bloc → State চক্র, `BlocBuilder` চিনুন। বাংলাদেশের ক্লায়েন্ট কোডে দুটোই আসবে — চিনতে পারলেই চলবে।

✓ যাচাই: GetX এর একটা স্ক্রিন দেখে বলতে পারেন কোন লাইনে state বদলায়? 🔗 সপ্তাহের সব টেস্ট এক PR এ, CI সবুজ।

---

## সপ্তাহ ৭ — Firebase

**সপ্তাহের লক্ষ্য:** Auth, ডেটা, ফাইল, নোটিফিকেশন — চারটাই, আর সবচেয়ে জরুরি: Security Rules।

### দিন ১ — প্রজেক্ট setup ও Google Sign-In

**১. Firebase প্রজেক্ট + flutterfire configure** · ⏱ ৬০ মিনিট · Firebase

📋 Firebase console এ প্রজেক্ট → `flutterfire configure` → Android app যোগ। ⚠️ `google-services.json` এ API key থাকে — এটা আসলে গোপন নয় (client key), কিন্তু SHA-1 fingerprint যোগ না করলে Google Sign-In চলবে না: `./gradlew signingReport` দিয়ে debug SHA-1 নিয়ে console এ বসান।

**২. Google Sign-In** · ⏱ ৯০ মিনিট · Auth

📋 `firebase_auth` + `google_sign_in` — login বোতাম → Google account বাছাই → `userCredential.user` পাওয়া পর্যন্ত।

✓ যাচাই: login এর পর অ্যাপ বন্ধ করে খুললে user টিকে আছে (`authStateChanges`)?

### দিন ২ — OTP ও Apple

**১. Phone OTP** · ⏱ ৯০ মিনিট · Auth

📋 `verifyPhoneNumber` চক্র — codeSent → SMS কোড → credential। ⚠️ বাংলাদেশের নম্বরে টেস্ট করতে Firebase console এ test phone number যোগ করুন — আসল SMS এ দিনে সীমা আছে।

**২. Apple Sign-In — বাস্তবতা** · ⏱ ৩০ মিনিট · Auth

📋 শুধু পড়ুন: App Store নীতি — social login থাকলে Apple login ও লাগবে; Windows এ টেস্ট করা যাবে না, Codemagic/ধার-করা Mac লাগবে। নোটে লিখে রাখুন, বাস্তবায়ন মাস ৪ এ।

### দিন ৩ — Firestore

**১. CRUD ও realtime snapshot** · ⏱ ১২০ মিনিট · ডেটা

📋 `users` collection এ document লেখা-পড়া, তারপর আসল জাদু:

```dart
FirebaseFirestore.instance
    .collection('rooms').doc(roomId).collection('messages')
    .orderBy('at', descending: true).limit(50)
    .snapshots() // ← Stream! নতুন message এলে নিজেই আসবে
```

StreamBuilder দিয়ে live chat list — আপনার live অ্যাপের চ্যাটের ছোট সংস্করণ।

✓ যাচাই: console থেকে হাতে document বদলালে অ্যাপে সাথে সাথে বদল দেখা যায়?

### দিন ৪ — Security Rules (সপ্তাহের সবচেয়ে জরুরি দিন)

**১. খোলা ডাটাবেস নিজে হ্যাক করুন** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 test mode এর rules (`allow read, write: if true`) রেখে **অন্য account দিয়ে** অন্যের document মুছে দেখান — নিজের চোখে দেখুন খোলা ডাটাবেস মানে কী।

**২. Rules লেখা** · ⏱ ৯০ মিনিট · নিরাপত্তা

```
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId; // নিজেরটাই শুধু
}
```

Rules playground এ দুই পরিচয়ে টেস্ট করুন। ⚠️ মনে রাখুন: client এ if দিয়ে লুকানো = নিরাপত্তা নয়; rules ই একমাত্র দেয়াল। (মাস ৩ এর BOLA এর পূর্বাভাস এটাই।)

✓ যাচাই: অন্যের document এ write এখন permission-denied?

### দিন ৫ — Storage ও FCM

**১. ছবি আপলোড** · ⏱ ৬০ মিনিট · Storage

📋 image_picker → compress → `putFile` → downloadURL → Firestore এ সেভ। Storage rules ও লিখুন (নিজের ফোল্ডারেই শুধু write)।

**২. FCM তিন অবস্থায়** · ⏱ ৯০ মিনিট · নোটিফিকেশন

📋 foreground (onMessage — নিজে দেখাতে হয়), background, terminated (getInitialMessage) — তিনটাই টেস্ট। console থেকে test message পাঠান। ⚠️ iOS এ APNs .p8 key লাগে — নোটে লিখুন, করবেন মাস ৪ এ।

✓ যাচাই: অ্যাপ পুরো বন্ধ রেখে notification পেয়েছেন, আর tap করলে ঠিক স্ক্রিনে গেছে?

### দিন ৬ — সপ্তাহের প্রজেক্ট

📋 ⏱ ১৮০ মিনিট — সব জোড়া দিন: Google login → প্রোফাইল Firestore এ → ছবি আপলোড → অন্য ডিভাইস/emulator থেকে বদল live দেখা → FCM। Rules কড়া। 🔗 GitHub PR + স্ক্রিনশট।

---

## সপ্তাহ ৮ — Architecture ও UI গভীরে

**সপ্তাহের লক্ষ্য:** কোড কোথায় রাখব প্রশ্নের স্থায়ী উত্তর, আর Figma থেকে হুবহু UI।

### দিন ১ — তিন স্তর

**১. তিন স্তরের architecture** · ⏱ ৯০ মিনিট · আর্কিটেকচার

📋 স্তর: **presentation** (widget + provider) → **domain/application** (logic) → **data** (repository + api + model)। নিয়ম দুটো: নির্ভরতা শুধু নিচের দিকে; UI কখনো data স্তরের জিনিস import করে না। নিজের এখনকার কোড এই তিন ভাগে ভাগ করে খাতায় আঁকুন।

**২. feature-first ফোল্ডার** · ⏱ ৬০ মিনিট · আর্কিটেকচার

```
lib/
├── features/
│   ├── auth/        (data / application / presentation)
│   ├── profile/
│   └── gifts/
├── core/            (dio, theme, router, helpers)
└── main.dart
```

📋 layer-first (models/, screens/, services/) এর বদলে feature-first কেন — এক ফিচারের সব এক জায়গায়, ফিচার মুছলে এক ফোল্ডার মুছলেই শেষ। নিজের প্র্যাকটিস প্রজেক্ট এই কাঠামোয় সাজান।

### দিন ২ — DI

**১. get_it ও injectable** · ⏱ ৯০ মিনিট · আর্কিটেকচার

📋 "new কোথায় হবে" প্রশ্নের উত্তর এক জায়গায়: `getIt.registerLazySingleton<UserRepository>(...)`। Riverpod নিজেই DI পারে — কখন কোনটা, তুলনা লিখুন।

**২. কখন architecture অতিরিক্ত** · ⏱ ৪৫ মিনিট · বিচারবুদ্ধি

📋 নোট লিখুন: ৩ স্ক্রিনের অ্যাপে injectable + তিন স্তর + fpdart = সময় নষ্ট। কোন আকারে কোনটা লাগে — নিজের নিয়ম বানান। (জমা: নোট)

### দিন ৩ — Figma Dev Mode

**১. Figma থেকে ডিজাইন তোলা** · ⏱ ১২০ মিনিট · UI

📋 Figma community থেকে একটা free app design খুলুন → Dev Mode → রঙ (hex), ফন্ট size/weight, spacing, radius পড়া → অ্যাসেট (আইকন/ছবি) export → Flutter এ এক স্ক্রিন **হুবহু** তুলুন — চোখের আন্দাজে নয়, মাপ ধরে ধরে।

✓ যাচাই: আপনার স্ক্রিন আর Figma পাশাপাশি রেখে ৯০% মিল?

### দিন ৪ — নিজের design system

**১. theme ও token এক জায়গায়** · ⏱ ৯০ মিনিট · UI

📋 `core/theme/` এ: AppColors, AppTextStyles, AppSpacing (৪/৮/১২/১৬/২৪), ThemeData (Material 3, ColorScheme.fromSeed, dark) — আর নিয়ম: **widget এ আর কোনো হাতে-লেখা Color(0xFF...) বা fontSize থাকবে না।** পুরনো স্ক্রিনগুলো রূপান্তর করুন।

### দিন ৫ — responsive টুলবক্স

**১. পাঁচটা যন্ত্র** · ⏱ ১২০ মিনিট · UI

📋 প্রতিটার একটা করে বাস্তব ব্যবহার: `LayoutBuilder` (জায়গা মেপে সিদ্ধান্ত), `AspectRatio` (ভিডিও/ব্যানার 16:9), `FractionallySizedBox` (অর্ধেক চওড়া বোতাম), `MediaQuery.sizeOf` (⚠️ .of নয় — sizeOf এ rebuild কম), `Flexible/Expanded` এর পার্থক্য। ছোট ফোন (৩২০ চওড়া) আর ট্যাব — দুটোতেই আপনার প্রোফাইল স্ক্রিন না-ভেঙে চলে কিনা দেখুন।

### দিন ৬–৭ — সপ্তাহ-প্রজেক্ট: News অ্যাপ

📋 ⏱ দুই দিন · মাসের চূড়ান্ত জমা — নিজের API দিয়ে News অ্যাপ:

- feature-first কাঠামো, তিন স্তর, নিজের design system
- Dio + Retrofit + freezed + Repository + Result
- তালিকা (pagination), বিস্তারিত পাতা, খোঁজা
- অন্তত ৮টা টেস্ট (model, repository-mock, widget), CI সবুজ
- README তে স্ক্রিনশট

✓ মাস শেষের যাচাই: "যেকোনো API দিলে অ্যাপ বানাতে পারি" — বুকে হাত দিয়ে হ্যাঁ বলতে পারলে মাস ৩ এ যান। 🔗 আলাদা repo, public।
