---
title: "[Leetcode]  704. Binary Search"
date: 2026-10-26 22:23 +0800
categories: ["Leetcode", "Binary Serach"]
tags: []
order: "000004_binary_serach/_000704_binary_search/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/binary-search/"
neetcode_url: "https://neetcode.io/problems/binary-search"
class: "🚀 Neetcode 150"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/4_Binary_Serach/_704_Binary_Search/Document.md
render_with_liquid: false
---

## Question

Given an array of integers `nums` which is sorted in ascending order, and an integer `target`, write a function to search `target` in `nums`.
If `target` exists, then return its index.
Otherwise, return `-1`.

You must write an algorithm with ==`O(log n)` runtime complexity==.

**Example 1:**

> Input: nums = [-1,0,3,5,9,12], target = 9
>
> Output: 4
>
> Explanation: 9 exists in nums and its index is 4

**Example 2:**

> Input: nums = [-1,0,3,5,9,12], target = 2
>
> Output: -1
>
> Explanation: 2 does not exist in nums so return -1

**Constraints:**

- 1 <= nums.length <= 10^4
- -10^4 < nums[i], target < 10^4
- All the integers in `nums` are unique.
- `nums` is sorted in ascending order.

---

## 主解法：Binary Search

### 題型

Basic Binary Search

### 思考流程

1. 題目要什麼？
   - 要能夠快速找到 target，複雜度要求 O(log n)。
2. 可以怎麼做到這件事？
   - 掃描一遍陣列很簡單，但複雜度是 O(n)。
   - 題目說陣列已排序，可以利用這個特性，用 Binary Search 搜尋。
3. Binary Search 如何做到 O(log n)？
   - 因為已排序，每次只要砍半搜尋：
     1. 比中間小：範圍縮成左半邊。
     2. 比中間大：範圍縮成右半邊。
     3. 等於中間：直接回傳答案。
4. 什麼時候停止搜尋？
   - 已經找到答案。
   - 左指針大於右指針，代表全部搜尋完畢，找不到答案，回傳 -1。

### 步驟

1. 初始化 left、right 指針。
2. 用 while 迴圈持續砍半搜尋：
   1. 計算 middle = (left + right) / 2。
   2. nums[middle] == target：直接回傳 index。
   3. nums[middle] > target：答案在左側，right = middle - 1。
   4. nums[middle] < target：答案在右側，left = middle + 1。
3. 重複直到 left > right，代表搜尋完畢。
4. 搜尋完畢還沒有 return，回傳 -1。

### 程式碼

```java
class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length;

        while (left <= right) {
            int middle = (left + right) / 2;

            if (nums[middle] == target) {
                return middle;
            }
            else if (nums[middle] > target) {
                right = middle - 1;
            }
            else {
                left = middle + 1;
            }
        }

        return -1;
    }
}
```

### 複雜度分析

- Time complexity: O(log n)
  - 每次都砍半搜尋，只需要檢查 log n 次。
- Space complexity: O(1)
  - 沒有使用額外的記憶體空間。

### 容易錯

- ==while 條件要寫 left <= right==，因為兩個指針相遇的時候，可能才找到答案。

---

## 解題紀錄

### 第一次

- 想法：
- 錯誤：
- 結果：
