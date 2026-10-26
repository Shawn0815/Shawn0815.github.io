---
title: "[Leetcode]  242. Valid Anagram"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000242_valid_anagram/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/valid-anagram/"
neetcode_url: "https://neetcode.io/problems/is-anagram"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_242_Valid_Anagram/Document.md
render_with_liquid: false
---

## Question

Given two strings `s` and `t`, return `true` if `t` is an anagram of `s`, and `false` otherwise.

**Example 1:**

> Input: s = "anagram", t = "nagaram"
>
> Output: true

**Example 2:**

> Input: s = "rat", t = "car"
>
> Output: false

**Constraints:**

- 1 <= s.length, t.length <= 5 * 10^4
- `s` and `t` consist of lowercase English letters.

---

## 主解法：Frequency Array

### 題型

Frequency Count

### 思考流程

1. 怎麼判斷兩個字串是 anagram？
   - ==每個字母出現的次數都一樣==，不是只有字母種類一樣。
2. 怎麼記錄每個字母出現的次數？
   - HashMap 或 frequency array 都可以。
3. HashMap 和 frequency array 哪個好？
   - 複雜度一樣，但 frequency array 是連續記憶體，比較快。
   - 題目保證只有小寫英文字母，優先用長度 26 的 frequency array。

### 步驟

1. 兩個字串長度不同，一定不是 anagram，回傳 false。
2. 用一個長度 26 的陣列，同時 loop 兩個字串：s 的字母 +1，t 的字母 -1。
3. 最後陣列每一格都是 0 才是 anagram。

### 程式碼

```java
public class Solution {
    public boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }

        // a ~ z 出現次數的差
        int[] counter = new int[26];

        for (int i = 0; i < s.length(); i++) {
            counter[s.charAt(i) - 'a']++;
            counter[t.charAt(i) - 'a']--;
        }

        for (int val: counter) {
            if (val != 0) {
                return false;
            }
        }

        return true;
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - 字串 loop 一次。
- Space complexity: O(1)
  - 陣列固定 26 格。

### 容易錯

- ==不能只比字母種類，要比每個字母的次數==。
- HashMap 寫法容易忘記 `getOrDefault()`。
- 兩個 HashMap 可以直接用 `map.equals()` 比較。
- 題目限定小寫字母時，要想到 frequency array。

### 其他解法

把兩個字串排序後比較是否相同。
寫法簡單，但排序是 O(n log n)，比較慢。

---

## 解題紀錄

### 第一次

- 想法：把字母放進 Set，最後比較兩個 Set 是否相同。
- 錯誤：只能判斷字母種類一樣，不能確定是 anagram。
- 結果：Wrong Answer。

### 第二次

- 想法：有想到 HashMap 寫法。
- 錯誤：忘記 `getOrDefault()` 怎麼用、兩個 map 怎麼比較。
- 結果：AC。

### 第三次

- 想法：有想到 HashMap 和 frequency array 寫法。
- 錯誤：無。
- 結果：3 分鐘內完成。
