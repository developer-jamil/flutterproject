# Git ও GitHub নোট

> নিয়ম: প্রতিদিনের কাজ = ব্রাঞ্চ → কাজ → commit → push → merge → ব্রাঞ্চ মুছি।
> main সবসময় ছাড়ার যোগ্য থাকবে।

---

## ১. একবারের সেটআপ (নতুন পিসিতে একবারই)

```bash
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global rebase.autosquash true
git config --global rebase.autostash true
git config --global rebase.updateRefs true
git config --global rerere.enabled true
```

- `pull.rebase` → pull করলে history জট পাকায় না
- `rerere` → একই conflict দ্বিতীয়বার এলে আগের সমাধান নিজেই বসায়

যাচাই: `git config --global --list`

---

## ২. নতুন প্রজেক্ট → GitHub এ পাঠানো

GitHub এ আগে একটা **খালি** repo বানাতে হবে (README/gitignore টিক দেবো না)।

```bash
flutter create my_app
cd my_app
git init                 # flutter create নিজেই করে দেয়
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/username/my_app.git
git push -u origin main  # -u দিলে পরেরবার শুধু git push
```

---

## ৩. প্রতিদিনের চক্র (মুখস্থ এটাই)

```bash
git switch -c feat/kaj-er-nam   # নতুন ব্রাঞ্চ
# ... কাজ ...
git status                       # কী বদলেছে দেখি
git add .
git commit -m "feat(x): ki korlam"
git switch main
git merge feat/kaj-er-nam
git branch -d feat/kaj-er-nam    # কাজ শেষ, ব্রাঞ্চ মুছি
git push
```

সংক্ষেপে: **status → add → commit → push**

---

## ৪. Clone ও remote বদলানো (হাতের নোট থেকে)

```bash
git clone https://repo-link.git   # অন্যের repo নিজের কম্পিউটারে
cd PROJECT-NAME

git remote -v                     # কোন GitHub এ connected, দেখি
git remote remove origin          # পুরনো repo থেকে disconnect
git remote add origin https://new-repo-link.git
git branch -M main
git push -u origin main           # নিজের কোড নিজের GitHub এ
```

---

## ৫. Conventional Commits (মেসেজের শুরুর শব্দ)

| prefix | কখন | উদাহরণ |
|---|---|---|
| `feat` | নতুন ফিচার | `feat(auth): add fingerprint login` |
| `fix` | bug/crash ঠিক | `fix(cart): fix total price calculation` |
| `docs` | README/ডকুমেন্ট | `docs: add installation step in readme` |
| `style` | spacing, রং, UI সাজ | `style(home): change banner padding` |
| `refactor` | কোড re-write/optimize (আচরণ এক) | `refactor(user): simplify profile data logic` |
| `perf` | speed/performance | `perf(image): optimize image caching` |
| `test` | টেস্ট লেখা | `test(auth): add logic validation unit tests` |
| `build` | gradle/dependency | `build: bump gradle wrapper to 9.31` |
| `ci` | GitHub Actions/CI script | `ci: add workflow for automated testing` |
| `chore` | টুকটাক (gitignore ইত্যাদি) | `chore: update gitignore for secret keys` |
| `revert` | আগের commit ফেরানো | `revert: revert feat(auth) changes` |

---

## ৬. switch ও restore (checkout এর বদলে)

```bash
git switch -c feat/thing     # নতুন ব্রাঞ্চ বানিয়ে যাও
git switch main              # ব্রাঞ্চ বদলাও
git restore file.dart        # ফাইলের পরিবর্তন ফেলে দাও
git restore --staged file.dart  # ভুলে add করা ফাইল unstage
```

## ৭. পুরনো commit ঠিক করা (সাবধানে)

```bash
git commit --amend --no-edit   # শেষ commit এ যোগ
```

⚠️ **push করা commit এ amend নয়।** করতেই হলে `git push --force-with-lease`
(কখনো খালি `--force` নয়)।

---

## ৮. PR — একা কাজ করলেও কেন

1. diff আলাদা করে পড়া যায় → ভুলে রাখা print/TODO/গোপন তথ্য ধরা পড়ে
2. CI ভাঙা কোড main এ ঢোকার **আগে** আটকায়
3. প্রতিটা PR = "কেন এই বদল" এর স্থায়ী রেকর্ড (ক্লায়েন্টের ডকুমেন্টেশন)
4. পরে টিমে কেউ এলে খরচ শূন্য

PR চক্র (gh CLI দিয়ে):

```bash
git switch -c feat/day6-git-setup
# ... কাজ, add, commit ...
git push -u origin feat/day6-git-setup
gh pr create --fill
gh pr merge --squash --delete-branch
git switch main && git pull
```

মনে রাখি:
- নিজের PR নিজে approve করা যায় না → "require approval" নিয়ম দেবো না, status check চাইব
- Free প্ল্যানে private repo তে ruleset নেই (public এ আছে)
- Repo Settings → General: ✅ Allow auto-merge, ✅ Auto delete head branches

---

## ৯. CI (GitHub Actions) — সারমর্ম

ফাইল: `.github/workflows/ci.yml` → প্রতি push/PR এ চলে: format check → analyze → test

খেয়াল রাখি:
- `actions/checkout@v7` (v4 বা পুরনো নয় — Node 20 বন্ধ হচ্ছে সেপ্টে ২০২৬)
- `subosito/flutter-action@v2` + `flutter-version` হুবহু পিন + `cache: true`
- `concurrency` ব্লক দিলে একই PR এ বারবার push করলে পুরনো রান বাতিল হয়
- Dependabot: `.github/dependabot.yml` — সাপ্তাহিক, minor+patch এক গ্রুপে

(পুরো yml টা ক্লাসের শিটে আছে — দরকারে ওখান থেকে কপি।)

---

## ১০. গোপন তথ্য (keystore/API key) ফাঁস হলে — জরুরি ক্রম

খোঁজা (সব repo তে চালাই):

```bash
git log --all --full-history -- "*.jks" "android/key.properties" ".env"
```

কিছু পেলে ক্রমটা **এই সাজেই**:

1. **আগে চাবি বদলাই/বাতিল করি** — ইতিহাস মোছা যথেষ্ট নয় (clone, fork, CI লগে থেকে যায়; public এ push মানেই ফাঁস)
2. ইতিহাস মুছি: `git filter-repo --sensitive-data-removal --invert-paths --path <file>` (আগে তাজা clone নিতে হয়)
3. `git push --force --all` + `--force --tags`
4. GitHub Support কে ক্যাশ মুছতে বলি

আগে থেকে ঠেকানো: `.gitignore` এ key.properties/.jks/.env রাখি; GitHub এর push protection চালু থাকে।
