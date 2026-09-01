# মাস ৪ — সত্যিকারের প্রজেক্ট (সপ্তাহ ১৩–১৬ · ১৬ নভেম্বর – ১৩ ডিসেম্বর)

> **এই মাসের চরিত্র:** আর বিচ্ছিন্ন অনুশীলন নয় — চার মাসের সব শেখা মিলিয়ে **একটা সম্পূর্ণ অ্যাপ** শূন্য থেকে ছাড়ার-যোগ্য পর্যন্ত। আপনার নিজের ঘরানার একটা mini live/community অ্যাপ বানান (যেমন: একটা room-list + profile + wallet + realtime chat — Probasi এর ছোট সংস্করণ)।
>
> **এখানেই বসছে আগে যোগ করা জিনিসগুলো:** platform channel (সপ্তাহ ১৩), realtime/Agora ৩ দিন (সপ্তাহ ১৪), Play Billing + CustomPaint (সপ্তাহ ১৫)।
>
> **নিয়ম:** প্রথম দিন থেকেই contract, test, CI — শেষে জোড়াতালি নয়।

---

## সপ্তাহ ১৩ — ভিত্তি দাঁড় করানো

**সপ্তাহের লক্ষ্য:** কোড লেখার আগে কাঠামো — contract, auth, architecture, CI — যেন বাকি তিন সপ্তাহ শুধু ফিচার বসানো।

### দিন ১ — Contract আগে

**১. OpenAPI contract লেখা** · ⏱ ১২০ মিনিট · নকশা

📋 মাস ৩ এর OpenAPI দিয়ে অ্যাপের সব endpoint কাগজে ঠিক করুন **কোড লেখার আগে**: auth (login/refresh/me), rooms (list/detail/join), wallet (balance/recharge), chat (history/send)। এই spec-ই frontend আর backend এর একমাত্র সত্য।

✓ যাচাই: প্রতিটা endpoint এর method, path, request, response, error — সব লেখা?

**২. প্রজেক্ট কাঠামো + git init** · ⏱ ৬০ মিনিট · সেটআপ

📋 মাস ২ এর feature-first কাঠামো, মাস ১ এর git+CI। প্রথম commit-ই যেন `.gitignore` ঠিক (key, .env বাদ)।

### দিন ২ — Architecture ও CI

**১. তিন স্তর + DI দাঁড় করানো** · ⏱ ৯০ মিনিট · আর্কিটেকচার

📋 core (dio, theme, router, di), features (খালি ফোল্ডার প্রতি ফিচারে data/application/presentation)। get_it/Riverpod সেটআপ, Dio + interceptor (auth header + refresh — মাস ২)।

**২. CI প্রথম দিনেই** · ⏱ ৬০ মিনিট · CI

📋 মাস ১ এর ci.yml + মাস ২ এর `flutter test`। একটা smoke test দিয়ে সবুজ টিক নিশ্চিত করুন — এখন থেকে প্রতিটা PR এ CI পাহারা।

### দিন ৩ — Auth পুরো প্রবাহ

**১. Login → token → auto-login → logout** · ⏱ ১২০ মিনিট · Auth

📋 মাস ৩ এর জ্ঞান বাস্তবে: login → access+refresh, secure_storage এ refresh (মাস ৩ সপ্তাহ ১২), app খুললে auto-login, 401 এ interceptor refresh, logout এ সব মুছে token অচল। GoRouter redirect দিয়ে auth guard (logged out হলে জোর করে login এ)।

✓ যাচাই: token মেয়াদ শেষ হলেও ইউজার টের পায় না (নিঃশব্দ refresh)? logout এর পর back চেপে ভেতরে ঢোকা যায় না?

### দিন ৪ — Platform channel (যোগ করা টপিক)

**১. Dart ↔ Kotlin কথা বলা** · ⏱ ১২০ মিনিট · Native

📋 MethodChannel দিয়ে Flutter থেকে native Android কল — একটা সহজ দিয়ে শুরু (ব্যাটারি %, বা device model):

```dart
static const _ch = MethodChannel('app/native');
final model = await _ch.invokeMethod<String>('getDeviceModel');
```

Kotlin দিকে `MainActivity` তে handler। ⚠️ কেন লাগবে আপনার: Agora এর মতো SDK, native lib (jniLibs/AAR), বা platform-নির্দিষ্ট কাজ — এই সেতু ছাড়া করা যায় না। আপনার live audio কাজে (মেমরিতে আছে) এই স্তরেই হাত দিতে হয়েছিল।

✓ যাচাই: Flutter থেকে ডাকা native মান স্ক্রিনে দেখাতে পেরেছেন? platform check (`Platform.isAndroid`) দিয়েছেন যেন iOS এ ক্র্যাশ না করে?

### দিন ৫–৬ — Rooms তালিকা (প্রথম আসল ফিচার)

📋 এক ফিচার শুরু-থেকে-শেষ, সব স্তর মেনে: model (freezed) → repository (Result) → provider (AsyncNotifier) → UI (তালিকা, pull-to-refresh, loading/error/empty তিন অবস্থা)। প্রতিটায় authorization মাথায় (মাস ৩): তালিকায় শুধু যা দেখার অনুমতি আছে।

✓ জমা: auth + rooms তালিকা চলছে, CI সবুজ, PR। এটাই বাকি সপ্তাহের ভিত।

---

## সপ্তাহ ১৪ — ফিচার + Realtime (যোগ করা মডিউল)

**সপ্তাহের লক্ষ্য:** সাধারণ ফিচার (তালিকা/খোঁজা/বিস্তারিত/আপলোড) শেষ করা, আর আপনার পেশার প্রাণ — realtime — অ্যাপে আনা।

### দিন ১ — খোঁজা, ছাঁকা, বিস্তারিত

**১. search + filter + detail** · ⏱ ১২০ মিনিট · ফিচার

📋 room/user খোঁজা (debounce দিয়ে — প্রতি অক্ষরে API নয়), ছাঁকা (live/category), বিস্তারিত পাতা। ⚠️ debounce না দিলে দ্রুত টাইপে ১০টা request — সার্ভার আর rate-limit দুটোই কাঁদবে।

### দিন ২ — ছবি আপলোড ও offline

**১. ছবি আপলোড** · ⏱ ৭৫ মিনিট · ফিচার

📋 pick → compress → progress দেখিয়ে upload → URL সেভ (মাস ২ Storage বা নিজের API)।

**২. Offline sync ও দ্বন্দ্ব** · ⏱ ৭৫ মিনিট · ফিচার

📋 Drift (মাস ১) দিয়ে local cache, নেট ফিরলে sync। ⚠️ দ্বন্দ্ব: local আর server দুটোই বদলালে কে জেতে (last-write-wins নাকি merge) — সিদ্ধান্ত নিন, নীরবে হারিয়ে ফেলবেন না।

### দিন ৩ — Realtime ভিত্তি (যোগ করা)

**১. WebSocket / socket.io client** · ⏱ ১২০ মিনিট · Realtime

📋 realtime এর মূল ধারণা: connection খোলা থাকে, দুই দিকেই message যায়। `web_socket_channel` বা `socket_io_client` দিয়ে connect → listen → send। StreamBuilder দিয়ে আসা event স্ক্রিনে।

⚠️ তিনটা বাস্তব সমস্যা যা সব টিউটোরিয়াল বাদ দেয়:
- **reconnect:** নেট গেলে নিজে থেকে আবার connect (backoff সহ)
- **lifecycle:** অ্যাপ background এ গেলে connection কী হবে
- **auth:** socket connect এও token লাগে

✓ যাচাই: নেট বন্ধ-চালু করলে connection নিজে ফিরে আসে? দুটো ডিভাইস থেকে একজনের পাঠানো message অন্যজন সাথে সাথে পায়?

### দিন ৪ — Realtime চ্যাট (যোগ করা)

**১. live chat বসানো** · ⏱ ১৫০ মিনিট · Realtime

📋 room এ ঢুকলে socket join → message list (নতুন নিচে/উপরে), send → optimistic UI (নিজের message সাথে সাথে দেখাও, server confirm পরে), seat/presence event (কে ঢুকল/বেরোলো)।

⚠️ আপনার multi-live কাজের শিক্ষা (মেমরিতে): seat/entry broadcast client-RTM এ, server relay নয় — এই স্থাপত্য সিদ্ধান্তটা এখানে সচেতনভাবে নিন।

✓ যাচাই: message এর ক্রম ঠিক থাকে? দ্রুত ১০টা পাঠালে গুলিয়ে যায় না?

### দিন ৫ — Agora hello-world (যোগ করা)

**১. Agora Flutter SDK প্রথম কল** · ⏱ ১৫০ মিনিট · Realtime

📋 `agora_rtc_engine` — engine init → token নিয়ে channel join → নিজের audio publish → remote user এর audio শোনা → mute/unmute/leave। ⚠️ token সার্ভার থেকে আসবে (কখনো app key hardcode নয়); permission (mic) চাওয়া; leave/dispose ঠিকমতো নাহলে audio leak।

📋 রেফারেন্স হিসেবে minimal setup রাখুন — over-customize করলেই সমস্যা (আপনার BondhuLive-reference শিক্ষা, মেমরিতে)।

✓ যাচাই: দুই ডিভাইসে একই channel এ join করে একে অন্যের কথা শুনতে পান? mute কাজ করে?

### দিন ৬ — সপ্তাহের সমন্বয়

📋 rooms → detail → realtime chat + Agora audio এক প্রবাহে। authorization প্রতিটায় (মাস ৩)। 🔗 PR, CI সবুজ।

---

## সপ্তাহ ১৫ — পেমেন্ট, নোটিফিকেশন, animation

**সপ্তাহের লক্ষ্য:** আয়ের পথ (recharge), engagement (FCM/deep link), আর যা অ্যাপকে পেশাদার দেখায় (animation) — সব বাস্তবে।

### দিন ১ — Play Billing নীতি (যোগ করা, জরুরি)

**১. digital goods বনাম physical** · ⏱ ৯০ মিনিট · পেমেন্ট নীতি

📋 ⚠️ **এই একটা পাঠ না জানলে অ্যাপ suspend হতে পারে:** Google/Apple নিয়মে **digital goods** (diamond, coin, VIP, unlock) অবশ্যই Play Billing/StoreKit দিয়ে বেচতে হয় — SSLCommerz/bKash নয়। bKash শুধু **physical/real-world** সেবায় বৈধ (জমির কাগজ, ডেলিভারি)। আপনার diamond = digital = Play Billing বাধ্যতামূলক।

📋 তালিকা করুন: আপনার তিন অ্যাপে কোন কোন বিক্রি digital, কোনটা physical — কোনটায় কোন পথ।

**২. in_app_purchase বসানো** · ⏱ ৯০ মিনিট · পেমেন্ট

📋 `in_app_purchase` — product list → কিনা → **সার্ভারে receipt যাচাই** (মাস ৩: শুধু যাচাইয়ের পর diamond) → deliver। ⚠️ client এর "কেনা হয়েছে" বিশ্বাস নয়, সার্ভার receipt verify।

### দিন ২ — বাকি পেমেন্ট + webhook

**১. SSLCommerz/bKash (physical পথ) + webhook** · ⏱ ১২০ মিনিট · পেমেন্ট

📋 মাস ৩ সপ্তাহ ১২ এর webhook+signature+idempotency এখন বাস্তবে। physical সেবার recharge প্রবাহ সম্পূর্ণ।

✓ যাচাই: নকল "success" (অ্যাপ থেকে) দিয়ে diamond পাওয়া যায় না — শুধু verified path এ?

### দিন ৩ — FCM ও deep link

**১. push + deep link** · ⏱ ১২০ মিনিট · Engagement

📋 FCM তিন অবস্থা (মাস ২)। notification tap → নির্দিষ্ট room/profile এ যাওয়া (GoRouter deep link)। App Links (Android) vs Universal Links (iOS) — পার্থক্য নোট।

### দিন ৪ — Animation ভিত্তি

**১. implicit বনাম explicit** · ⏱ ৯০ মিনিট · UI

📋 implicit (AnimatedContainer, AnimatedSwitcher, AnimatedOpacity — সহজ, বেশিরভাগ কাজ) বনাম explicit (AnimationController — নিয়ন্ত্রণ বেশি, gift animation/টাইমিং)। Hero দিয়ে screen-transition (তালিকার ছবি → detail এ বড়)।

**২. Lottie** · ⏱ ৪৫ মিনিট · UI

📋 gift/celebration animation — Lottie JSON চালানো। ⚠️ ভারী Lottie অনেকগুলো একসাথে = jank; দরকারে বন্ধ/cache।

### দিন ৫ — CustomPaint / Canvas (যোগ করা)

**১. নিজে আঁকা** · ⏱ ১২০ মিনিট · UI

📋 CustomPainter দিয়ে যা widget এ হয় না: audio waveform (live অ্যাপে কথা বলার সময়), custom progress ring (level/gift-combo), sticker/gift path। ⚠️ `shouldRepaint` ঠিক না দিলে প্রতি frame এ অকারণ redraw = battery/jank।

✓ যাচাই: একটা সরল waveform বা circular level-indicator নিজে এঁকেছেন?

### দিন ৬ — পারফরম্যান্স

**১. DevTools দিয়ে মাপা** · ⏱ ১২০ মিনিট · পারফরম্যান্স

📋 অনুমান নয়, মাপা: Performance overlay (jank frame), rebuild count (মাস ২ এর select মনে করুন), memory (image/animation leak), network timeline। আপনার chat/room list scroll কি ৬০fps? না হলে কোথায় আটকায় — খুঁজে ঠিক করুন।

✓ জমা: পেমেন্ট + FCM + animation চলছে, একটা পরিমাপযোগ্য পারফরম্যান্স উন্নতি PR এ লেখা।

---

## সপ্তাহ ১৬ — কঠিন করা ও ছাড়ার প্রস্তুতি

**সপ্তাহের লক্ষ্য:** নিরাপত্তা যাচাই, টেস্ট কভারেজ, release build, দুই স্টোরের testing track।

### দিন ১ — নিজের API তে OWASP

**১. নিজের নতুন অ্যাপে অডিট** · ⏱ ১২০ মিনিট · নিরাপত্তা

📋 মাস ৩ এর OWASP checklist এবার **নিজের বানানো** এই অ্যাপে চালান: BOLA (অন্যের room/wallet), mass assignment, rate limit (login/recharge), secret ফাঁস। পাওয়া গর্ত ঠিক করুন — শেখার অ্যাপেও যেন অভ্যাসটা পাকা।

### দিন ২ — টেস্ট কভারেজ পূর্ণ

**১. ফাঁক ভরাট** · ⏱ ১৫০ মিনিট · টেস্টিং

📋 coverage রিপোর্ট (মাস ২) দেখে untested critical path — auth refresh, payment verify, BOLA guard — এ টেস্ট যোগ। ⚠️ ১০০% লক্ষ্য নয়; লক্ষ্য critical path কভার। টাকা/নিরাপত্তা ছোঁয়া কোড অবশ্যই।

### দিন ৩ — Android release build

**১. keystore, flavor, ProGuard** · ⏱ ১৫০ মিনিট · রিলিজ

📋 release keystore বানানো ও **নিরাপদে রাখা** (⚠️ হারালে অ্যাপ আর update করা যায় না; repo তে কখনো নয় — মাস ১ secrets), signing config, dev/prod flavor (আলাদা API URL/icon), ProGuard/R8 (minify + obfuscate), API 36 target। `flutter build appbundle`।

✓ যাচাই: release AAB বানিয়েছেন? obfuscate করা build এ crash হলে symbol ফাইল রেখেছেন (নাহলে Crashlytics পড়া যাবে না)?

### দিন ৪ — iOS বাস্তবতা

**১. App Privacy ও অ্যাকাউন্ট মোছা** · ⏱ ১২০ মিনিট · রিলিজ

📋 (Windows এ — Codemagic/ধার Mac) App Store এর App Privacy প্রশ্নমালা: কোন ডেটা সংগ্রহ, কেন। ⚠️ **অ্যাকাউন্ট মোছার সুযোগ বাধ্যতামূলক** — না থাকলে Apple সরাসরি reject। .p8 (APNs), App Attest — মাস ৩ এর নোট এখন বাস্তবায়ন।

### দিন ৫–৬ — দুই স্টোরে testing track

📋 Play: internal testing track এ AAB, tester যোগ, test লিংক। App Store: TestFlight এ build (Codemagic দিয়ে)। ⚠️ প্রথম App Store submit এ যা reject করায়: crash, ভাঙা ফিচার, privacy ভুল, অ্যাকাউন্ট-মোছা নেই, incomplete metadata — checklist ধরে যাচাই।

✓ মাস শেষের যাচাই: "একটা সম্পূর্ণ অ্যাপ — Flutter সামনে, শক্ত-করা backend পেছনে — দুই স্টোরের testing track এ আছে।" 🔗 জমা: release build + দুই track এ live + README (স্ক্রিনশট, architecture, কী শিখলাম)।
