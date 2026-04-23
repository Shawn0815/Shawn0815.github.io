---
layout: post
title: Medium | Leetcode 128. Longest Consecutive Sequence
date: 2025-12-08 16:32 +0800
author: shawn_yu
categories: [Leetcode, Array & Hashing, Medium]
tags: [Leetcode, Java]
image: {path: "/assets/img/2025-06-20-16-16-28.png"}
math: true

topic: "Array & Hashing"
level: "Medium"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️⭐️"
company: "Amazon, Google"
leetcode_url: "https://leetcode.com/problems/longest-consecutive-sequence/description/"
neetcode_url: "https://neetcode.io/problems/longest-consecutive-sequence"
---

# 題目描述

給定一個為排序的陣列 nums，請回傳陣列中最長的連續數字個數，**時間複雜度須為 O(n)**。

ps. 如果有多組連續數字串列，請回傳最長的個數。

![](/assets/img/2025-12-08-16-46-17.png)

---

# 解法

## 一開始的想法

我最直覺的想法就是 Sorting，但是我一開始的寫法只考慮從頭開始的連續，沒有考慮如果有多組連續數字，需要把所有可能取最大值（使用 maxCount 紀錄，每次統計完更新）。

後來看解答才知道可以用 HashSet 來解，且 HashSet 也可以優化為最佳解。

---

## 解法 1: Sorting

### 解題概念

這題的核心概念是：

1. 先將陣列從小到大排序，這樣所有連續的數字就會相鄰。
2. 接下來依序 loop 每個數字，統計說到這個數字的連續長度為何（初始化 count = 1）。
    1. 如果這個數字為前一個數字 + 1，代表連續，count + 1。
    2. 如果這個數字不連續，重置 count = 1，代表它是新的連續數字的起點。
3. 每次 **統計完 count 後，記得更新目前為止，連續長度的最大值為何**（用 maxCount 取最大值來維護）。

要注意的點：

- 一開始要先判斷如果陣列為空，回傳 0。
- 如果遇到重複的數字，記得跳過，因為 count 不會改變。

這個解法有一個地方可以優化，就是不需要每次統計完 count 後就更新最大值 maxCount，只需要再 count++ 時更新即可，因為只有這時候連續長度會更長。

不過這個寫法有一個地方需要注意，就是因為不是每次更新，**最後一次統計完還要再額外去更新 maxCount，因為它可能會是連續長度的最大值**。

### 程式碼

```java
public class Solution1 {
    public int longestConsecutive(int[] nums) {
        // 如果 nums 為空陣列，直接回傳 0
        if (nums.length == 0) {
            return 0;
        }
        
        // 排序 nums 陣列
        Arrays.sort(nums);

        // 初始化連續數字個數
        int count = 1;
        int maxCount = 1;

        // 從第二個數字開始遍歷，檢查是否為連續數字
        for (int i = 1; i < nums.length; i++) {
            // 如果跟前一個數字一樣，跳過
            if (nums[i] == nums[i - 1]) {
                continue;
            }

            // 如果為連續數字，count++
            if (nums[i] == nums[i - 1] + 1) {
                count++;
            }
            // 若非連續數字，count 重置，並判斷是否更新 maxCount
            else {
                maxCount = Math.max(maxCount, count);
                count = 1;
            }
        }

        // 最後回傳最大連續數字個數（最後還要比一次）
        return Math.max(maxCount, count);
    }
}
```

### 運算複雜度

- Time Complexity: $O(n logn)$
    - 一開始排序陣列 → O(n logn)。
    - 線性掃描一次整個陣列，更新連續長度 → O(n)。
- Space Complexity: $O(1)$
    - Java 排序是 in-place 操作，不需要額外空間，且只用了幾個常數變數 → O(1)。

<aside>
💡

**總結：**

Sorting 雖然簡單直覺，但 **複雜度為 O(n logn)，不符合題目要求**，題目要求 O(n)。

</aside>

---

## 解法 2: HashSet（暴力解）

### 解題概念

這題也可以用 HashSet 做暴力解：

1. 先把所有數字放進 HashSet 中。
2. 針對每個數字 num，去統計它的連續長度為多少：
    
    透過在 HashSet 中尋找是否有 num + 1，有的話 count + 1，重複以上動作直到不連續為止（使用 while）。
    
3. 最後更新 maxCount。

### 程式碼

```java
public class Solution2 {
    public int longestConsecutive(int[] nums) {
        // 如果 nums 為空陣列，直接回傳 0
        if (nums.length == 0) {
            return 0;
        }

        // 用一個 set 紀錄所有數字
        Set<Integer> set = new HashSet<>();
        
        for (int num: nums) {
            set.add(num);
        }

        // 初始化 maxCount
        int maxCount = 0;

        // 遍歷每個數字，計算由他開始的連續數字個數
        for (int num: set) {
            // 預設每個數字的初始 count = 1
            int count = 1;
            
            // 如果陣列中有 (num+1) 這個數，count++，並重複檢查
            while (set.contains(num + 1)) {
                count++;
                num++; // 更新 num 為 num+1
            }

            // 如果連續數字斷掉，更新 maxCount
            maxCount = Math.max(maxCount, count);
        }

        return maxCount;
    }        
}
```

### 運算複雜度

- Time Complexity: $O(n^2)$
    - 外層迴圈遍歷每個數字 → O(n)。
    - 內層 while 迴圈遍歷這個數字開始的連續數字，最多 n 個  ⇒  總共 O(n^2)。
- Space Complexity: $O(n)$
    - 用 HashSet 儲存所有元素：O(n)。

<aside>
💡

**總結：**

這個解法會 **重複計算**（同一條序列被數好幾次），複雜度比 Sorting 更高，不符合題目需求。

</aside>

---

## 解法 3: HashSet（Optimal）

### 解題概念

這個解法是解法 2 的進階版。

- 關鍵：只在**「連續數字的起點」**才去計算它的連續數字個數長度。
- 方法：**檢查 set 中是否存在 num - 1**，如果有，代表他不是連續數字起點，跳過它，避免重複算。

### 程式碼

```java
public class Solution3 {
    public int longestConsecutive(int[] nums) {
        // 如果 nums 為空陣列，直接回傳 0
        if (nums.length == 0) {
            return 0;
        }

        // 用一個 set 紀錄所有數字
        Set<Integer> set = new HashSet<>();
        
        for (int num: nums) {
            set.add(num);
        }

        // 初始化 maxCount
        int maxCount = 0;
        
        // 遍歷每個數字，計算由他開始的連續數字個數
        for (int num: set) {
            // 只有他是連續數字的最小數字才去計算 count
            if (!set.contains(num - 1)) {
                // 初始化 count
                int count = 1;
                int cur = num;
                
                // 如果陣列中有 (num+1) 這個數，count++，並重複檢查
                while (set.contains(cur + 1)) {
                    count++;
                    cur++; // 更新 num 為 num+1
                }

                // 如果連續數字斷掉，更新 maxCount
                maxCount = Math.max(maxCount, count);
            }
        }

        return maxCount;
    }
}
```

### 運算複雜度

- Time Complexity: $O(n)$
    - 每個元素只遍歷一次。
- Space Complexity: O(n)
    - 用 HashSet 儲存所有元素：O(n)。

<aside>
💡

**總結：**

這個解法 **每個元素只會處理一次**，統計它是否有往後連續的數字，不會有重複檢查的問題。

</aside>

---

# 總結

面試時可以先提 Sorting 的方法（直觀想到的）。

接著提出 HashSet 的想法，說明複雜度問題，**延伸引導到 HashSet (Optimal)，做為最佳解。**

---

# 參考資料

- [[Python][Leetcode] 練習題目Longest Consecutive Sequence](https://vocus.cc/article/685e6d47fd897800012cc5d6)
- [[LeetCode] Longest Consecutive Sequence 求最长连续序列](https://www.cnblogs.com/grandyang/p/4276225.html)