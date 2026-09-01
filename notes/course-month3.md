# মাস ৩ — Backend ও নিরাপত্তা (সপ্তাহ ৯–১২ · ১৯ অক্টোবর – ১৫ নভেম্বর)

> **এই মাসের বিশেষত্ব:** এটা "টিউটোরিয়াল" মাস নয় — এটা আপনার **নিজের চালু তিনটা backend** (BondhuLive, PHM Live, Probasi Live) হাতে নিয়ে কাটাছেঁড়ার মাস। প্রতিটা ধারণা শেখার পর সাথে সাথে নিজের কোডে খুঁজবেন: "আমার এখানে এটা আছে? ঠিক আছে, না ফাঁক?"
>
> ⚠️ **সোনার নিয়ম:** নিজের production সার্ভারে কখনো হ্যাক-পরীক্ষা চালাবেন না। আগে একটা staging copy দাঁড় করান (আলাদা DB, আলাদা env)। আসল ইউজারের ডেটার উপর BOLA টেস্ট করা মানে নিজের ইউজারকেই বিপদে ফেলা।
>
> **stack মনে রাখুন:** আপনার backend = NestJS + Prisma। উদাহরণগুলো সেই অনুযায়ী।

---

## সপ্তাহ ৯ — API নকশা: চুক্তি আগে, কোড পরে

**সপ্তাহের লক্ষ্য:** এলোমেলো endpoint নয় — একটা সুসংগত, অনুমান-করা-যায় এমন API কেমন হয়, আর সেটা কোড লেখার আগেই কাগজে ঠিক করা।

### দিন ১ — Resource মডেলিং

**১. endpoint নয়, resource ভাবুন** · ⏱ ৭৫ মিনিট · API নকশা

📋 আপনার Probasi backend এর route গুলো (`users.controller.ts` ইত্যাদি) খুলে তালিকা করুন। তারপর প্রতিটাকে REST নিয়মে যাচাই:

```
❌ POST /getUserProfile        ✅ GET  /users/{id}
❌ POST /updateUserBalance     ✅ PATCH /users/{id}/wallet
❌ GET  /deleteRoom?id=5       ✅ DELETE /rooms/{id}
```

নিয়ম: URL এ **noun** (জিনিস), কাজটা বোঝায় **HTTP method**। কাজ URL এ লিখবেন না।

✓ যাচাই: নিজের ৫টা route এর মধ্যে কয়টা এই নিয়ম ভাঙে? তালিকা করুন।

**২. Status code এর আসল অর্থ** · ⏱ ৪৫ মিনিট · API নকশা

📋 নিজের কোডে খুঁজুন — সব সফল response এ কি 200 পাঠাচ্ছেন? তাহলে ভুল।

- `200` পেলাম/বদলালাম · `201` নতুন বানালাম · `204` করলাম, ফেরত দেওয়ার কিছু নেই
- `400` তোমার পাঠানো ভুল · `401` তুমি কে জানি না (login করো) · `403` জানি, কিন্তু অনুমতি নেই · `404` নেই · `409` দ্বন্দ্ব (ডুপ্লিকেট) · `422` গঠন ঠিক, মান ভুল
- `429` বেশি হচ্ছে, থামো · `500` আমার দোষ

⚠️ ৪০১ আর ৪০৩ গুলিয়ে ফেলা সবচেয়ে সাধারণ ভুল — "কে তুমি" বনাম "তোমার অনুমতি নেই"।

✓ যাচাই: নিজের একটা error path খুঁজুন যেখানে ভুল code যাচ্ছে।

### দিন ২ — Idempotency ও pagination

**১. Idempotency — একই request দুবার** · ⏱ ৯০ মিনিট · API নকশা

📋 সবচেয়ে গুরুত্বপূর্ণ ধারণা আপনার অ্যাপের জন্য। ভাবুন: ইউজার gift পাঠাল, নেট আটকে গেল, অ্যাপ retry করল — diamond কি দুবার কাটবে?

- GET/PUT/DELETE স্বভাবতই idempotent, POST নয়
- সমাধান: client একটা `Idempotency-Key` (uuid) পাঠাবে, সার্ভার সেই key দেখে দ্বিতীয়বার একই ফল ফেরাবে, নতুন কাজ করবে না
- আপনার wallet/gift/payment এ এটা না থাকলে ডাবল-চার্জ অনিবার্য

✓ যাচাই: আপনার gift-send বা recharge endpoint কি idempotent? না হলে — এটাই এ সপ্তাহের সবচেয়ে দামি আবিষ্কার।

**২. Pagination** · ⏱ ৬০ মিনিট · API নকশা

📋 offset (`?page=2&limit=20`) বনাম cursor (`?after=<id>&limit=20`)। আপনার leaderboard/gift-history/message list — বড় তালিকা যেগুলো, সেগুলোয় offset হলে গভীর পাতায় ধীর ও ডুপ্লিকেট আসে; realtime-ইশ তালিকায় cursor ভালো।

✓ যাচাই: নিজের সবচেয়ে বড় তালিকার endpoint এ কোনটা ব্যবহার করছেন?

### দিন ৩ — Versioning ও error শেপ

**১. API versioning** · ⏱ ৬০ মিনিট · API নকশা

📋 পুরনো অ্যাপ (Play Store এ আটকে থাকা ইউজার) না ভেঙে API বদলানো: `/v1/`, `/v2/`। কী কী পরিবর্তন "breaking" (ফিল্ড মোছা, টাইপ বদল) আর কী নয় (নতুন ফিল্ড যোগ) — তালিকা করুন। এটা সরাসরি আপনার force-update সমস্যার সাথে যুক্ত।

**২. সুসংগত error response** · ⏱ ৪৫ মিনিট · API নকশা

📋 সব error এক আকারে: `{ "error": { "code": "INSUFFICIENT_BALANCE", "message": "...", "details": {...} } }`। NestJS এ একটা global exception filter দিয়ে এটা এক জায়গায়। অ্যাপের Dio interceptor এ এই `code` ধরেই সিদ্ধান্ত (মাস ২ এর interceptor মনে করুন)।

### দিন ৪ — OpenAPI: চুক্তি আগে

**১. OpenAPI spec পড়া ও লেখা** · ⏱ ১২০ মিনিট · API নকশা

📋 NestJS এ `@nestjs/swagger` আছে — decorator থেকে OpenAPI নিজেই বনে। একটা module (যেমন users) এ DTO তে `@ApiProperty` বসিয়ে `/api` তে Swagger UI খুলুন। এটাই আপনার আর frontend/AI এর মধ্যে **চুক্তি** — এটা দেখেই অ্যাপের model লেখা যায়।

**২. AI কে spec ধরিয়ে দেওয়া** · ⏱ ৪৫ মিনিট · পদ্ধতি

📋 OpenAPI JSON টা AI কে দিয়ে বলুন "এই endpoint এর Dart freezed model + Retrofit interface লেখো" — তারপর মাস ২ এর যাচাই checklist চালান। spec থাকলে AI ভুল model লেখার সুযোগ কমে।

✓ যাচাই: Swagger UI থেকে একটা endpoint "Try it out" করে সত্যি response পেয়েছেন?

### দিন ৫–৬ — সপ্তাহের কাজ

📋 আপনার একটা আসল backend module বেছে নিন (যেমন Probasi এর `store` বা `gifts`)। কাগজে/Markdown এ পুরো নতুন করে ডিজাইন করুন যেন প্রথম থেকে বানাচ্ছেন: resource তালিকা, method, status code, idempotency দরকার কোথায়, error shape, OpenAPI। তারপর আসল কোডের সাথে মিলিয়ে **পার্থক্যের তালিকা** — "আদর্শ" বনাম "যা আছে"।

✓ জমা: ওই module এর ডিজাইন নথি + পার্থক্য তালিকা (Markdown, repo তে)।

---

## সপ্তাহ ১০ — Authentication বনাম Authorization

**সপ্তাহের লক্ষ্য:** "তুমি কে" (authn) আর "তুমি কী করতে পারো" (authz) — দুটোকে আলাদা করে, দুটোই ঠিকভাবে করা।

### দিন ১ — মূল পার্থক্য ও JWT গঠন

**১. authn বনাম authz** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 এক লাইন: authn = দরজায় পরিচয়পত্র দেখানো; authz = কোন কোন ঘরে ঢুকতে পারবে। ⚠️ সবচেয়ে বড় ভুল: authn করেই ভাবা authz হয়ে গেছে। login করা ইউজার = বিশ্বস্ত নয়; সে অন্যের ডেটা চাইতেই পারে (BOLA, সপ্তাহ ১১)।

**২. JWT ভেতর থেকে** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 jwt.io তে নিজের অ্যাপের একটা token পেস্ট করুন — header/payload/signature তিন অংশ দেখুন।

⚠️ চোখ খোলার তিনটা কথা:
- payload **এনক্রিপ্ট করা নয়, শুধু base64** — যে কেউ পড়তে পারে। তাই token এ password/গোপন কিছু রাখবেন না।
- নিরাপত্তা signature এ — সার্ভারের secret ছাড়া কেউ বৈধ token বানাতে পারে না।
- `alg: none` আক্রমণ — কিছু লাইব্রেরি "no signature" মানে। নিজের verify তে algorithm হার্ডকোড করে দিন।

✓ যাচাই: নিজের token এর payload এ কী কী আছে? সেখানে থাকা উচিত নয় এমন কিছু আছে?

### দিন ২ — Refresh ঘোরানো ও বাতিল

**১. access + refresh জোড়া** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 access token আয়ু ছোট (১৫ মিন), refresh লম্বা (৩০ দিন)। কেন: access চুরি হলেও অল্প সময়ে অচল। মাস ২ এর interceptor এ এবার আসল refresh বসান: 401 → refresh দিয়ে নতুন access → আসল request replay। ⚠️ একসাথে ৫টা request 401 খেলে refresh ৫ বার নয় — একবার, বাকিরা অপেক্ষা করবে (refresh lock)।

**২. refresh rotation ও বাতিল** · ⏱ ৭৫ মিনিট · নিরাপত্তা

📋 প্রতিবার refresh ব্যবহারে নতুন refresh দিন, পুরনোটা DB তে অচল করুন। একই refresh দুবার এলে = চুরি হয়েছে → ওই ইউজারের সব session বাতিল। logout/ban এ token কীভাবে সাথে সাথে অচল করবেন (DB blocklist বা short TTL) — আপনার ban ব্যবস্থার সাথে মেলান।

✓ যাচাই: ইউজার ban করলে তার চালু session কত দ্রুত অচল হয়? (আপনার fraud-recovery কাজের সাথে সরাসরি যুক্ত।)

### দিন ৩ — Session বনাম token, OAuth/OIDC

**১. তুলনা** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 session (সার্ভার মনে রাখে, বাতিল সহজ) বনাম JWT (stateless, স্কেল সহজ, বাতিল কঠিন)। আপনার live অ্যাপে কোনটা কেন — নোট।

**২. OAuth2 ও OIDC প্রবাহ** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 Google login এর সময় আসলে কী ঘটে — authorization code flow ধাপে ধাপে। ⚠️ mobile এ implicit flow নয়, PKCE সহ code flow। OIDC এর id_token আর OAuth এর access_token এর পার্থক্য।

### দিন ৪ — Role ও permission

**১. RBAC মডেল** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 আপনার আসল role গুলো (USER, HOST, AGENCY, ADMIN, DIAMOND_SELLER...) নিয়ে permission matrix বানান: কোন role কোন কাজ পারে। NestJS এ Guard + `@Roles()` decorator দিয়ে বসানো। ⚠️ role check শুধু client এ (অ্যাপে বোতাম লুকানো) = নিরাপত্তা নয় — সার্ভার Guard-ই আসল।

**২. resource-স্তরের অনুমতি** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 role যথেষ্ট নয়: HOST নিজের room edit করতে পারে, অন্যের নয়। মানে "HOST কিনা" + "এটা কি তারই room কিনা" — দুটোই। এটাই সপ্তাহ ১১ এর BOLA আটকানোর মূল।

✓ যাচাই: নিজের কোডে একটা edit/delete endpoint খুঁজুন — role চেক আছে, কিন্তু "এটা কি তার জিনিস" চেক আছে কি?

### দিন ৫–৬ — সপ্তাহের কাজ

📋 নিজের একটা backend এর auth প্রবাহ পুরো কাগজে আঁকুন: login → token issue → request এ verify → refresh → logout/ban। প্রতিটা ধাপে "এখানে কী ভুল হতে পারে" লিখুন। তারপর staging এ refresh rotation বা refresh-lock — যেটা নেই — যোগ করে টেস্ট।

✓ জমা: auth-flow ডায়াগ্রাম + অন্তত একটা বাস্তব উন্নতি।

---

## সপ্তাহ ১১ — OWASP API Top 10 হাতে-কলমে

**সপ্তাহের লক্ষ্য:** আক্রমণগুলো **নিজে বানিয়ে নিজে চালিয়ে** দেখা — তারপর নিজের তিনটা backend এর লিখিত অডিট।

> ⚠️ সব পরীক্ষা staging এ। টুল: Postman/Insomnia + দুটো টেস্ট account।

### দিন ১ — BOLA (#1, সবচেয়ে সাধারণ ও সবচেয়ে বিপজ্জনক)

**১. নিজে BOLA বানিয়ে নিজে ভাঙা** · ⏱ ১২০ মিনিট · নিরাপত্তা

📋 BOLA = Broken Object Level Authorization। account A এর token নিয়ে `GET /users/{B এর id}` বা `GET /wallets/{অন্যের id}` মারুন। যদি অন্যের ডেটা ফেরত আসে — BOLA আছে।

- আপনার অ্যাপে সবচেয়ে বিপজ্জনক জায়গা: wallet, withdraw, gift-history, personal profile
- ঠিক করা: প্রতিটা object-access এ `resource.userId === request.user.id` (বা proper role) — সপ্তাহ ১০ দিন ৪ এর resource-স্তর

✓ যাচাই: A এর token দিয়ে B এর wallet পড়া যায় কিনা — তিনটা backend এই টেস্ট করুন। ফল লিখুন।

### দিন ২ — Mass assignment ও broken authn

**১. Mass assignment** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 `PATCH /users/me` এ body তে `{"role": "ADMIN"}` বা `{"coinBalance": 999999}` পাঠান। সার্ভার যদি অন্ধভাবে সব ফিল্ড নেয় — বিপদ। ⚠️ Prisma এ `data: req.body` সরাসরি দেওয়া = এই গর্ত। সমাধান: DTO তে শুধু অনুমোদিত ফিল্ড (whitelist), NestJS `ValidationPipe({whitelist: true})`।

✓ যাচাই: নিজের update endpoint এ balance/role/isVerified জোর করে বসানো যায় কিনা?

**২. Broken authentication** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 দুর্বল OTP (৪ সংখ্যা, rate-limit নেই = brute force), token expiry না মানা, logout এ token অচল না হওয়া — নিজের auth এ খুঁজুন।

### দিন ৩ — SSRF, injection, rate limit

**১. SSRF** · ⏱ ৭৫ মিনিট · নিরাপত্তা

📋 কোথাও ইউজারের দেওয়া URL সার্ভার নিজে fetch করে? (avatar-by-url, webhook, image proxy)। আক্রমণকারী `http://169.254.169.254/` (cloud metadata) বা internal IP দিতে পারে। সমাধান: allowlist domain, internal IP block।

**২. Rate limiting** · ⏱ ৭৫ মিনিট · নিরাপত্তা

📋 NestJS `@nestjs/throttler`। কোথায় সবচেয়ে জরুরি: login, OTP, gift-send, withdraw। ⚠️ IP-ভিত্তিক rate-limit NAT এর পেছনে (একই wifi তে অনেক ইউজার) সমস্যা করে — user-id ভিত্তিকও ভাবুন।

✓ যাচাই: login এ ১০০ বার ভুল password — থামে কি?

### দিন ৪ — গোপন তথ্য, লগিং, misconfiguration

**১. Secret ব্যবস্থাপনা** · ⏱ ৭৫ মিনিট · নিরাপত্তা

📋 `.env` কি repo তে? (মাস ১ এর filter-repo মনে করুন)। DB password, JWT secret, Agora key, payment key — কোথায়? সার্ভারে env var, কোডে নয়। rotate করার পথ আছে?

**২. নিরাপদ লগিং** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 লগে কী যাচ্ছে দেখুন — password, token, OTP, full card লগে ছাপা হলে = ফাঁস। PII masking। কিন্তু নিরাপত্তা-ঘটনা (failed login, ban, বড় লেনদেন) অবশ্যই লগ হবে — audit এর জন্য।

### দিন ৫–৬ — আসল অডিট (মাসের চূড়ান্ত জমা)

📋 BondhuLive, PHM Live, Probasi Live — তিনটার জন্য একটা করে **লিখিত অডিট রিপোর্ট**:

- প্রতিটা OWASP আইটেম: আছে / নেই / আংশিক
- পাওয়া প্রতিটা গর্ত: কোথায়, কী বিপদ, কীভাবে reproduce, কীভাবে ঠিক
- অগ্রাধিকার: critical (wallet/withdraw BOLA) → high → low
- আপনার fraud-recovery অভিজ্ঞতা (958136786 কেস) এই রিপোর্টে বাস্তব উদাহরণ হিসেবে

✓ জমা: তিনটা অডিট রিপোর্ট (Markdown/PDF)। ⚠️ পাওয়া critical গর্ত এই সপ্তাহেই staging এ ঠিক করার পরিকল্পনা।

---

## সপ্তাহ ১২ — Mobile নিরাপত্তা ও পেমেন্ট

**সপ্তাহের লক্ষ্য:** সার্ভার থেকে সরে অ্যাপ ও লেনদেনের নিরাপত্তা — আর আপনার আসল আয়ের পথ (recharge/withdraw) শক্ত করা।

### দিন ১ — Threat model

**১. নিজের অ্যাপের threat model** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 সহজ কাঠামো: কী রক্ষা করছি (diamond, ইউজার ডেটা, আয়) → কে আক্রমণকারী (fraud ইউজার, প্রতিযোগী, বট) → কীভাবে ঢুকবে → কী করলে থামে। আপনার live অ্যাপের বাস্তব হুমকি: fake recharge, ban-এড়ানো multi-account, gift-farming bot, withdraw fraud।

### দিন ২ — Cert pinning ও integrity

**১. Certificate pinning** · ⏱ ৯০ মিনিট · নিরাপত্তা

📋 কী দেয়: MITM (নকল সার্ভার/proxy দিয়ে token চুরি) কঠিন করে। Dio তে `badCertificateCallback`/pinning। ⚠️ কী দেয় না: রুট করা ফোনে নির্ধারিত আক্রমণকারীকে থামায় না — শুধু বাধা বাড়ায়। আর pin ভুল হলে/সার্ট বদলালে পুরো অ্যাপ অচল — তাই backup pin।

**২. Play Integrity ও App Attest** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 "এটা কি আসল অ্যাপ, নাকি modified APK/emulator/bot?" — সার্ভার যাচাই করে। gift-farming বট আর hacked APK এর বিরুদ্ধে আপনার মূল অস্ত্র। iOS এ App Attest (পড়ুন, বাস্তবায়ন মাস ৪)।

### দিন ৩ — ডিভাইসে গোপন তথ্য ও বায়োমেট্রিক

**১. নিরাপদ storage** · ⏱ ৭৫ মিনিট · নিরাপত্তা

📋 refresh token/sensitive: `flutter_secure_storage` (Android Keystore, iOS Keychain) — কখনো SharedPreferences এ plain নয়। ⚠️ SharedPreferences রুট ফোনে খোলা পড়া যায়।

**২. বায়োমেট্রিক lock** · ⏱ ৬০ মিনিট · নিরাপত্তা

📋 `local_auth` — অ্যাপ/withdraw খুলতে fingerprint। ⚠️ বায়োমেট্রিক = UX সুবিধা, সার্ভার-নিরাপত্তার বিকল্প নয়; আসল যাচাই সবসময় সার্ভারে।

### দিন ৪–৫ — পেমেন্ট (আপনার আয়ের প্রাণ)

**১. SSLCommerz/bKash প্রবাহ + webhook** · ⏱ ১২০ মিনিট · পেমেন্ট

📋 recharge প্রবাহ ধাপে ধাপে: অ্যাপ order বানায় → gateway → ইউজার টাকা দেয় → gateway **webhook** দিয়ে সার্ভারকে জানায় → সার্ভার diamond দেয়।

⚠️ **সবচেয়ে জরুরি:** diamond দেবেন **শুধু webhook এ**, অ্যাপের "success" পাতায় নয় — অ্যাপের কথা নকল করা যায়, webhook (+ signature) যায় না।

**২. Webhook signature ও idempotency** · ⏱ ৯০ মিনিট · পেমেন্ট

📋 প্রতিটা webhook এর signature যাচাই (নাহলে যে কেউ "টাকা এসেছে" নকল করে diamond নেবে)। সপ্তাহ ৯ এর idempotency এখানেই আসল কাজ: একই webhook দুবার এলে diamond একবার। ⚠️ আপনার withdraw ডাবল-রিফান্ড সমস্যা (মেমরিতে আছে) — এর মূলেই idempotency এর অভাব।

✓ যাচাই: নকল webhook (ভুল signature) পাঠালে সার্ভার প্রত্যাখ্যান করে? একই webhook দুবার = diamond একবার?

### দিন ৬ — সপ্তাহ ও মাসের সমাপ্তি

📋 এই সপ্তাহের mobile+payment নিরাপত্তা আইটেমগুলো সপ্তাহ ১১ এর তিন অডিট রিপোর্টে যোগ করুন — এখন রিপোর্ট সম্পূর্ণ (server + mobile + payment)। প্রতিটার জন্য "৩০ দিনের অ্যাকশন প্ল্যান": কোন গর্ত কবে ঠিক হবে।

✓ মাস শেষের যাচাই: "আমার নিজের একটা backend এর নিরাপত্তা অবস্থা লিখিতভাবে বলতে পারি, আর সবচেয়ে বড় ৩টা ঝুঁকি জানি" — পারলে মাস ৪ এ। 🔗 জমা: তিনটা সম্পূর্ণ অডিট + অ্যাকশন প্ল্যান।
