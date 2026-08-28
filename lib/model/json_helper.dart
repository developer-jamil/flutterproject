// সার্ভার যা-ই পাঠাক (int, string, null) — নিরাপদে কাঙ্ক্ষিত টাইপে আনে।
// প্রতিটা মডেলের fromJson এ এগুলোই ব্যবহার করব।

int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

double toDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

bool toBool(dynamic v) => v is bool ? v : (v == 1 || v == '1' || v == 'true');

String toStr(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;