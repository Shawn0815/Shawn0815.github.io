---
title: "[Leetcode]  217. Contains Duplicate"
date: 2026-10-26 18:46 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000217_contains_duplicate/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/contains-duplicate/"
neetcode_url: "https://neetcode.io/problems/duplicate-integer"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_217_Contains_Duplicate/Document.md
render_with_liquid: false
---

## Question

Given an integer array `nums`, return `true` if any value appears ==at least twice== in the array, and return `false` if every element is distinct.

**Example 1:**

> Input: nums = [1,2,3,1]
>
> Output: true
>
> Explanation: The element 1 occurs at the indices 0 and 3.

**Example 2:**

> Input: nums = [1,2,3,4]
>
> Output: false
>
> Explanation: All elements are distinct.

**Example 3:**

> Input: nums = [1,1,1,3,3,4,3,2,4,2]
>
> Output: true

**Constraints:**

- 1 <= nums.length <= 10^5
- -10^9 <= nums[i] <= 10^9

---

## 主解法：HashSet

### 題型

Existence Check

### 思考流程

1. 怎麼判斷是否重複？
   - 對每個數字搜尋是否已經出現過。
2. 搜尋複雜度能不能從 O(n) 變 O(1)？
   - 用 HashSet 判斷存在。
3. 搜尋與加入能不能合併？
   - One-pass，一邊查詢、一邊加入 Set。

### 步驟

1. Loop array 中的每一個元素。
2. 檢查是否已經存在於 HashSet。
   1. 存在：回傳 true。
   2. 不存在：將元素加入 HashSet 中。

### 程式碼

```java
class Solution {
    public boolean hasDuplicate(int[] nums) {
        Set<Integer> set = new HashSet<>();

        for (int num: nums) {
            if (set.contains(num)) {
                return true;
            }

            set.add(num);
        }

        return false;
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - Loop nums 一次，每次 HashSet 查找跟插入都是 O(1)。
- Space complexity: O(n)
  - 最壞情況沒有重複，HashSet 要存 n 個數字。

### 容易錯

- 沒有想到 One-pass 解法。
- 沒想到更簡單的寫法：直接比較 HashSet 與 array 的長度。

### 其他解法

先把所有數字加入 HashSet，再比較 HashSet 的大小跟 array 的長度。
長度不同就代表有重複。

---

## 解題紀錄

### 第一次

- 想法：有想到 HashSet 解法。
- 錯誤：無。
- 結果：AC。

### 第二次

- 想法：有想到 HashSet 標準解，以及比較長度的解法。
- 錯誤：無。
- 結果：5 分鐘內完成。
