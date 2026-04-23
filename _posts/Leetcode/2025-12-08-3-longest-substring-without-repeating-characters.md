---
layout: post
title: Medium | Leetcode 3. Longest Substring Without Repeating Characters
date: 2025-12-08 20:52 +0800
author: shawn_yu
categories: [Leetcode, Sliding window, Medium]
tags: [Leetcode, Java]
image: {path: "/assets/img/2025-06-20-16-16-28.png"}
math: true

topic: "Sliding window"
level: "Medium"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️⭐️⭐️"
company: "Google, Amazon, Facebook"
leetcode_url: "https://leetcode.com/problems/longest-substring-without-repeating-characters/description/"
neetcode_url: "https://neetcode.io/problems/longest-substring-without-duplicates"
---

# 題目描述

給定一個字串 s，請找出其中 **不包含重複字元的最長子字串**，並回傳這個子字串的長度。

![](/assets/img/2025-12-08-20-54-42.png)

---

# 解法

這題一開始的想法就是暴力解，針對每個起點算最大長度（用 set 統計出現過的字母），不過複雜度太高。

這題最經典的解法是 Sliding window，維護一個不重複字母的窗口，掃描一遍就可以得到結果。

---

## 解法 1: Brute Force

### 解題概念

最直覺的暴力解，計算每個字母做為起點，最長的不重複子字串長度為多少。

其中判斷字元是否重複，會使用 HashSet 來記錄出現過的字母。

### 程式碼

```java
public class Solution1 {

    public int lengthOfLongestSubstring(String s) {

        // 紀錄目前最長的 subString 長度
        int maxLen = 0;

        // 固定 subString 的開頭
        for (int i = 0; i < s.length(); i++) {
            
            // 用 set 紀錄目前 subString 中有的字母
            Set<Character> set = new HashSet<>();
            set.add(s.charAt(i));

            // 一個個往後檢查字母是否重複
            for (int j = i + 1; j < s.length(); j++) {

                // 若字母重複，代表找到以 i 為開頭的最長 subString
                // 跳出迴圈，找下一個開頭的最長 subString
                if (set.contains(s.charAt(j))) {
                    break;
                }
                // 若字母不重複，將字母放入 set 中，再往後檢查
                else {
                    set.add(s.charAt(j));
                }
            }

            // 更新最大長度（set 的大小）
            maxLen = Math.max(maxLen, set.size());
        }

        return maxLen;
    }
}
```

### 複雜度分析

- 時間複雜度：$O(n * m)$
    - 外層迴圈會重複 n 次（字串長度）。
    - 內層迴圈最多重複 m 次（字串中不相同字母個數）。
- 空間複雜度：$O(m)$
    - Set 中最多存放 m 個字母。

<aside>
💡

**總結：**

這個解法要使用雙迴圈遍歷每個起點的最大長度，複雜度太高。

</aside>

---

## 解法 2: Sliding window (HashSet)

### 解題概念

基本概念就是：

設計一個滑窗紀錄連續不重複字母，從左到右掃描，檢查當前字母是否重複。

- **若重複，縮減左邊界** 到不重複為止（或直接移動到重複的下一個）。
- **若不重複，持續擴展右邊界**，並計算最大長度。

這個解法的關鍵是：

1. 如果字元重複，左邊接一定要持續縮減到整個 window 不重複為止。
2. 每次縮減左 window 時，一定要將 set 中的元素移除，因為那些元素已經不存在於 window，如果不移除的話，會以那些元素還存在。ex: abba，遇到第二個 b 時，重複了，前面 a, b 都不會在 widnow 中，剩 b。

### 程式碼

```java
public class Solution2 {

    public int lengthOfLongestSubstring(String s) {

        // 紀錄目前最長的 subString 長度
        int maxLen = 0;

        // 紀錄 sliding window 的左右邊界
        int left = 0, right = 0;
        
        // 用 set 紀錄目前 window 中擁有的字母
        Set<Character> set = new HashSet<>();

        // sliding window 的右邊界從零開始滑動
        for (right = 0; right < s.length(); right++) {

            // 如果字母重複，持續縮減左邊界直到 window 中字母沒有重複為止
            // 每移動一次左邊界也要同步把 set 中的字母移除！
            while (set.contains(s.charAt(right))) {
                set.remove(s.charAt(left));
                left++;
            }

            // 將字母放入 set 中
            set.add(s.charAt(right));

            // 更新目前最大長度（比較 sliding window 長度）
            maxLen = Math.max(maxLen, right - left + 1);
        }

        return maxLen;
    }
}
```

### 複雜度分析

- 時間複雜度：$O(n)$
    - left, right 指針最多各走 n 次，總共為 O(2n)。
- 空間複雜度：$O(m)$
    - Set 中最多存放 m 個字母。

---

## 解法 3: Sliding window (HashMap)

### 解題概念

這個解法式 Sliding window (HashSet) 的進階版：

差別在於，如果遇到重複的字母，我們會 **直接移動左邊界到重複字母的下一個位置**。

具體作法：

1. 改用 HashMap 去記錄每個字母以及他 **最後一次出現的位置**。
2. 針對每個新的字母，會先檢查他是否重複（檢查 map 中是否存在此 key）。
    1. 若重複，就收縮左邊界到最後一次出現的位置 + 1。
    2. 若不重複，擴展右邊界，將字母放入 map 中，並更新最後一次出現的位置以及目前最大長度。
3. 由於我們是一次移動左邊界，並不會移除 map 中的內容，所以在判斷是否為重複字母的時候，要 **多判斷字母最後一次出現的位置是否在 window 中**，如果不在，代表他是過時的字母，不算是重複，不需要移動左邊界。

<aside>
💡

**注意：**

一定要記得多判斷重複字母是否出現在 window 當中，因為這個方法在移動完 left 之後並不會去清掉 map 裡面的內容。

</aside>

### 程式碼

```java
public class Solution3 {

    public int lengthOfLongestSubstring(String s) {

        // 紀錄目前最長的 subString 長度
        int maxLen = 0;

        // 紀錄 sliding window 的左右邊界
        int left = 0, right = 0;
        
        // key: 字母, value: 這個字母最後一次出現的 index
        Map<Character, Integer> map = new HashMap<>();

        // sliding window 的右邊界從零開始滑動
        for (right = 0; right < s.length(); right++) {

            // 如果 map 中已經有這個字母，且字母的最後出現的 index 在 window 中
            // 更新 window 的左邊界到重覆字母的下一個位置
            if (map.containsKey(s.charAt(right)) && map.get(s.charAt(right)) >= left) {
                left = map.get(s.charAt(right)) + 1;
            }

            // 將字母放入 map 中，並更新他最後一次出現的 index
            map.put(s.charAt(right), right);

            // 更新目前最大長度（比較 sliding window 長度）
            maxLen = Math.max(maxLen, right - left + 1);
        }

        return maxLen;
    }
}
```

### 複雜度分析

- 時間複雜度：$O(n)$
    - right 指針最多走 n 次，總共為 O(n)。
- 空間複雜度：$O(m)$
    - Map 中最多存放 m 個字母以及其最後一次出現的位置。

---

# 總結

面試可以 **先提出 HashSet 的版本，解釋 Sliding window 是如何運作** 的，接著再提出 HashMap 的優化版本，說明有更有效率的解法。

---

# 參考資料

- [最長的不重複區間 Leetcode #3 Longest Substring w/o Repeating Chars](https://vocus.cc/article/650c25e8fd8978000147b6b2)
- [[LeetCode 解題紀錄] 3. Longest Substring Without Repeating Characters](https://medium.com/%E6%8A%80%E8%A1%93%E7%AD%86%E8%A8%98/leetcode-%E8%A7%A3%E9%A1%8C%E7%B4%80%E9%8C%84-3-longest-substring-without-repeating-characters-6431d3e8fc9c)