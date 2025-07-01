---
title: Easy | Leetcode 242. Valid Anagram
author: shawn_yu
date: 2025-06-27 01:19:00 +0800
categories: [Leetcode, Easy, Array & Hashing]
tags: [Leetcode, Java]
description: Given two strings s and t, return true if t is an anagram of s, and false otherwise.
image:
  path: /assets/img/2025-06-20-16-16-28.png
math: true
leetcode_url: https://leetcode.com/problems/valid-anagram/description/
leetcode_title: "點此進入LeetCode"
neetcode_url: https://neetcode.io/problems/is-anagram
neetcode_title: "點此進入NeetCode"
---

## Question

給定兩個字串 s 和 t，如果 t 是 s 的「字母異位詞」，就回傳 true，否則回傳 false。

![](/assets/img/2025-06-27-01-20-29.png)

---

## Solution

### Solution1: Sorting

#### 解題概念：

把兩個字串都轉成字元陣列，分別排序，排序後如果陣列完全一樣，代表是異位詞。

#### 程式碼：

```java
public class Solution1 {
    public static boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }

        // 將兩個字串轉換為字元陣列
        char[] s_arr = s.toCharArray();
        char[] t_arr = t.toCharArray();

        // 對兩個字元陣列進行排序
        Arrays.sort(s_arr);
        Arrays.sort(t_arr);

        // 比較兩個排序後的字元陣列是否相等
        return Arrays.equals(s_arr, t_arr);
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n logn + m logm)$
  - 轉換字串成字元陣列：$O(n)$。
  - 排序陣列：$O(n log n)$。
  - 比較兩陣列是否相等：$O(n)$。
- Space complexity: $O(n + m)$
  - 需額外兩個 char[] 陣列，長度為 n / m。

### Solution2: Hash map

#### 解題概念：

分別建立兩個 Map（count_s 和 count_t），紀錄每個字串中每個字母出現的次數；最後比較這兩個 Map 是否完全相等。

#### 程式碼：

```java
public class Solution2 {
    public static boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }

        // 建立兩個 HashMap，用來紀錄兩字串的字母出現次數
        Map<Character, Integer> count_s = new HashMap<Character, Integer>();
        Map<Character, Integer> count_t = new HashMap<Character, Integer>();

        // 遍歷字串 s 與 t，同步更新兩個字串的字母頻率
        for (int i = 0; i < s.length(); i++) {
            count_s.put(s.charAt(i), count_s.getOrDefault(s.charAt(i), 0) + 1);
            count_t.put(s.charAt(i), count_t.getOrDefault(s.charAt(i), 0) + 1);
        }

        // 比較兩個 HashMap 是否完全一致
        return count_s.equals(count_t);
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n + m)$
  - 因為遍歷了兩個字串各一次（雖然是在同一個 for 裡處理），所以加總起來是 $O(n + m)$。
- Space complexity: $O(1)$
  - 在英文字母小寫限定情況下，最多 26 種 → 可以視為常數 → $O(1)$。
  - 即使輸入字串很長，所需額外空間仍然不會變大。

### Solution3: Hash table (using Array)

#### 解題概念：
- 建立一個長度為 26 的陣列 counter（英文有26個字母），用來計算每個字母出現的頻率差。
  - 每讀一個 s 的字元，就把對應的 counter +1。
  - 每讀一個 t 的字元，就把對應的 counter -1。
- 最後遍歷整個 counter 陣列，只要有任何一個值不是 0，就代表兩字串不是異位詞。

#### 程式碼：

```java
public class Solution3 {
    public static boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }

        // 建立一個長度為 26 的陣列來紀錄 a~z 出現次數差異
        int[] counter = new int[26];
        for (int i = 0; i < s.length(); i++) {
            counter[s.charAt(i) - 'a']++; // 將 s 的字元出現次數 +1
            counter[t.charAt(i) - 'a']--; // 將 t 的字元出現次數 -1
        }

        // 檢查每一個字母出現次數是否都為 0
        for (int val: counter) {
            if (val != 0) {
                return false;
            }
        }

        return true;
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n + m)$
  - 因為遍歷了兩個字串各一次（雖然是在同一個 for 裡處理），所以加總起來是 $O(n + m)$。
- Space complexity: $O(1)$
    - int[] counter = new int[26]，但這是 固定大小的空間，不隨輸入長度改變，所以是 $O(1)$。