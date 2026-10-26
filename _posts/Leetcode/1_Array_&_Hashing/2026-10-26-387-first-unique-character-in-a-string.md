---
title: "[Leetcode]  387. First Unique Character in a String"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000387_first_unique_character_in_a_string/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/first-unique-character-in-a-string/"
neetcode_url: "https://neetcode.io/problems/first-unique-character-in-a-string"
class: "🌎 Neetcode All"
important: "⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_387_First_Unique_Character_in_a_String/Document.md
render_with_liquid: false
---

## Question

Given a string `s`, find the ==first non-repeating character== in it and return its index.
If it does not exist, return `-1`.

**Example 1:**

> Input: s = "leetcode"
>
> Output: 0
>
> Explanation: The character 'l' at index 0 is the first character that does not occur at any other index.

**Example 2:**

> Input: s = "loveleetcode"
>
> Output: 2

**Example 3:**

> Input: s = "aabb"
>
> Output: -1

**Constraints:**

- 1 <= s.length <= 10^5
- `s` consists of only lowercase English letters.

---

## 主解法：Frequency Array

### 題型

Frequency Count

### 思考流程

1. 怎麼知道一個字母有沒有重複？
   - 暴力解：每個字母都掃一遍整個字串。
2. 複雜度多少？能不能優化？
   - 每個字母都掃整個字串，O(n^2)。
   - 先統計每個字母出現的次數，再找第一個次數是 1 的字母。
3. 這樣複雜度多少？
   - 只要 loop 字串兩次，O(n)。

### 步驟

1. Loop 一次字串，用 frequency array 統計每個字母出現的次數。
2. 再照字串原本的順序 loop 一次：
   1. 遇到第一個次數是 1 的字元，回傳它的 index。
   2. 全部檢查完都沒有，回傳 -1。

### 程式碼

```java
class Solution {
    public int firstUniqChar(String s) {
        int[] freq = new int[26];

        for (char c: s.toCharArray()) {
            freq[c - 'a']++;
        }

        for (int i = 0; i < s.length(); i++) {
            if (freq[s.charAt(i) - 'a'] == 1) {
                return i;
            }
        }

        return -1;
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - Loop 兩次字串。
- Space complexity: O(1)
  - frequency array 固定 26 格。

### 容易錯

- ==統計完要再照字串的順序掃一次==；用 HashMap 時，不能直接從 map 找第一個次數是 1 的字元，map 的順序不是字串的順序。
- 暴力解檢查重複要掃整個字串（前面也要看），而且要跳過自己。

---

## 解題紀錄

### 第一次

- 想法：用 HashMap 記錄每個字元的次數和位置，最後直接從 map 找第一個次數是 1 的字元。
- 錯誤：map 找到的第一個，不一定是字串裡第一個不重複的字元。
- 結果：Wrong Answer。

### 第二次

- 想法：有想到暴力解和 frequency array。
- 錯誤：暴力解只檢查後面有沒有重複，漏了前面可能已經出現過。
- 結果：最佳解 5 分鐘內完成。
