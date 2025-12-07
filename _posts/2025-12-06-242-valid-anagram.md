---
layout: post
title: Easy | Leetcode 242. Valid Anagram
date: 2025-12-06 22:42 +0800
author: shawn_yu
categories: [Leetcode, Array & Hashing, Easy]
tags: [Leetcode, Java]
image: {path: "/assets/img/2025-06-20-16-16-28.png"}
math: true

topic: "Array & Hashing"
level: "Easy"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company: "Amazon, Google, Uber"
leetcode_url: "https://leetcode.com/problems/valid-anagram/"
neetcode_url: "https://neetcode.io/problems/is-anagram"
---

# 題目描述

給定兩個字串 s 和 t，如果 **t 字串是 s 字串的字母異位詞**，就回傳 true，否則回傳 false。

所謂字母異位詞指的是兩個字串中的所有字母跟出現次數都相同，但位置不一定相同。

![](/assets/img/2025-12-06-22-54-17.png)

---

# 解法

## 一開始的想法

本來最直覺的想法是：把字串中的字母一個一個放入到 set 當中，最後比較兩個 set 是否一樣。

但這個做法有問題：如果兩個字串**只是由相同的字母「種類」構成**，並非每個字母的個數都相同，這樣會判斷錯誤。

<aside>
💡

**例如：**

s = "abb"
t = "aab"

s_set = [a, b]
t_set = [a, b]

s_set.equals(t_set) → true ❌ 錯誤

</aside>

---

## 解法 1: Sorting

### 解題概念

比起放入 set 在中再比較，更好的做法是直接把字串先轉成 array，然後對 array 做排序，接著比較兩個 array 是否相等。

### 程式碼

```java
public class Solution1 {
    public static boolean isAnagram(String s, String t) {
        // 如果兩個字串長度不相同，一定不是異位詞
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

### 複雜度分析

- Time complexity: $O(n logn + m logm)$
    - 轉換字串成字元陣列：O(n)。
    - 排序陣列：O(n log n)。
    - 比較兩陣列是否相等：O(n)。
- Space complexity: $O(n + m)$
    - 需額外兩個 char[] 陣列，長度為 n / m。

<aside>
💡

**注意：**

使用 Sorting 的做法時間複雜度相對較高。

</aside>

---

## 解法 2: Hash map

### 解題概念

使用 HashMap 的概念，針對兩個字串分別 **建立一個 map 記錄「字母：出現次數」**，最後在比較兩個 map 是否相等。

### 程式碼

```java
public class Solution2 {
    public boolean isAnagram(String s, String t) {
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

**&lt;補充&gt;**

Java map 的 `getOrDefault(key, defaultValue)` 方法：指的是如果用這個 key（字母）去取得他的 value（出現次數）但取得不到時，就使用 dafaultValue 作為期值。

### 複雜度分析

- Time complexity: O(n + m)
    - 因為遍歷了兩個字串各一次（雖然是在同一個 for 裡處理），所以加總起來是 O(n + m)。
- Space complexity: O(1)
    - 在英文字母小寫限定情況下，最多 26 種 → 可以視為常數 → O(1)。
    - 即使輸入字串很長，所需額外空間仍然不會變大。

<aside>
💡

**優化版：**

這個方法更優化的版本是只使用一個 Map 即可，**紀錄每個字母出現的頻率差**。

其中 s 字串字母出現，map 對應的次數 +1，而 t 字串則相反，次數 - 1，最後再檢查 map 中的所有 key 對應的 value 是否為 0。

```java
public class Solution2_1 {
    public boolean isAnagram(String s, String t) {
        if (s.length() != t.length()) {
            return false;
        }

        // 建立一個 map，用來記錄每個字母在兩個陣列出現的頻率差
        Map<Character, Integer> map = new HashMap<Character, Integer>();

        // 遍歷字串 s 與 t，同步更新兩個字串的字母頻率
        for (int i = 0; i < s.length(); i++) {
            map.put(s.charAt(i), map.getOrDefault(s.charAt(i), 0) + 1);
            map.put(t.charAt(i), map.getOrDefault(t.charAt(i), 0) - 1);
        }

        // 檢查 map 中的所有元素是否為 0
        for (int value : map.values()) {
            if (value != 0) {
                return false;
            }
        }

        return true;
    }
}
```

不過這個方法還可以優化，把 Map 改成使用 array 來記錄每個字幕的出現次數。

</aside>

---

## 解法 3: Frequency Array

### 解題概念：

既然總共只有 26 個字母，我們就可以**直接用一個長度為 26 的 array 紀錄每個字母出現在頻率差**。

紀錄的方式是使用 ASCII code，`count[0]` 代表字母 ‘a’ 的出現次數，`count['c'-'a']` 代表字母 ‘c’ 的出現次數，以此類推。

最後再檢查這個 array 每個元素是否都為 0。

### 程式碼：

```java
public class Solution3 {
    public boolean isAnagram(String s, String t) {
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
        for (int val : counter) {
            if (val != 0) {
                return false;
            }
        }

        return true;
    }
}
```

### 複雜度分析：

- Time complexity: O(n + m)
    - 因為遍歷了兩個字串各一次（雖然是在同一個 for 裡處理），所以加總起來是 O(n + m)。
- Space complexity: O(1)
    - int[] counter = new int[26]，但這是固定大小的空間，不隨輸入長度改變，所以是 O(1)。

---

# 總結

面試時 **優先使用 Frequency Array 解法**，這是最佳解，可以用兩個陣列去比較，或是用一個陣列加減次數。

可以先提出 HashMap 解法，概念是一樣的，延伸說明如何提升運算複雜度。

---

# 參考資料

- [[Day 29] LeetCode - 242 Valid Anagram](https://ithelp.ithome.com.tw/articles/10252956)
- [【LeetCode】242. Valid Anagram 解題報告](https://bclin.tw/2022/01/10/leetcode-242/)