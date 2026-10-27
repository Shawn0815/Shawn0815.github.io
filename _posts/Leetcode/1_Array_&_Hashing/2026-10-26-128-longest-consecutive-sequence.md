---
title: "[Leetcode]  128. Longest Consecutive Sequence"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000128_longest_consecutive_sequence/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Medium"
leetcode_url: "https://leetcode.com/problems/longest-consecutive-sequence/"
neetcode_url: "https://neetcode.io/problems/longest-consecutive-sequence"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_128_Longest_Consecutive_Sequence/Document.md
render_with_liquid: false
---

## Question

Given an unsorted array of integers `nums`, return the length of the longest consecutive elements sequence.

You must write an algorithm that runs in ==`O(n)` time==.

**Example 1:**

> Input: nums = [100,4,200,1,3,2]
>
> Output: 4
>
> Explanation: The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4.

**Example 2:**

> Input: nums = [0,3,7,2,5,8,4,6,0,1]
>
> Output: 9

**Example 3:**

> Input: nums = [1,0,1,2]
>
> Output: 3

**Constraints:**

- 0 <= nums.length <= 10^5
- -10^9 <= nums[i] <= 10^9

---

## 主解法：HashSet

### 題型

Sequence Expansion

### 思考流程

1. 如何更快判斷數字是否連續？
   - 用 HashSet 存所有數字，num - 1 在 HashSet 裡就代表連續。
   - 這樣每次檢查是 O(1)。
2. 每個數字都去算一次連續長度，會不會重複計算？
   - 會，複雜度變成 O(n^2)。
   - 很多數字根本不是連續序列的開頭，不需要算。
3. 怎麼避免重複計算？
   - 只從連續序列的開頭開始算。
   - 判斷方法：num - 1 不在 HashSet 裡，num 就是開頭。

### 步驟

1. 把陣列所有數字存進 HashSet。
2. Loop HashSet 的每個數字，判斷是不是連續序列的開頭：
   1. num - 1 在 HashSet 裡：不是開頭，跳過。
   2. 不在：是開頭，用 while 一路往右走，統計連續長度。
3. 每算完一段，更新最大長度。
4. 回傳最大長度。

### Pseudo Code

```java
for each num in nums:
    add num into HashSet;

maxLen = 0;

for each num in HashSet:
    if (num - 1) exist in HashSet:
        continue;
    len = 1;
    cur = num;
    while (cur + 1) exist in HashSet:
        cur++;
        len++;
    maxLen = max(maxLen, len);

return maxLen;
```

### 複雜度分析

- Time complexity: O(n)
  - 只從序列起點往右延伸，每個數字最多被走過一次。
- Space complexity: O(n)
  - HashSet 存所有數字。

### 容易錯

- **進 while 前要用 cur 記住目前的數字，每次往右走時更新 cur**；只寫 num + 1 的話，num 不會變。

---

## 其他解法：Sorting

### 題型

Sort + Scan

### 思考流程

1. 怎麼找連續序列？
   - 先排序，下一個數字等於上一個數字 + 1 就是連續。
2. 怎麼統計最長序列？
   - 連續時累加 len，斷掉時更新 maxLen。
3. 複雜度如何？
   - 排序是 O(n log n)，不符合題目要求，所以主解法用 HashSet。

### 步驟

1. 陣列是空的，直接回傳 0。
2. 先排序。
3. 從第二個數字開始，跟前一個比：
   1. 重複：跳過。
   2. 連續：len++。
   3. 不連續：更新 maxLen，len 重置為 1。
4. 迴圈結束後再更新一次 maxLen，回傳。

### Pseudo Code

```java
if length of nums == 0:
    return 0;

sort nums;
len = 1, maxLen = 1;

for i from 1 to n - 1:
    if nums[i] == nums[i - 1]:
        continue;

    if nums[i] == nums[i - 1] + 1:
        len++;
    else:
        maxLen = max(maxLen, len);
        len = 1;

maxLen = max(maxLen, len);

return maxLen;
```

### 複雜度分析

- Time complexity: O(n log n)
  - 排序是 O(n log n)。
- Space complexity: O(1)
  - 只用了幾個變數。

### 容易錯

- 要考慮陣列是空的。
- 遇到重複的數字要跳過。
- **迴圈結束後要再更新一次 maxLen**，最長的序列在最後一段時才算得到。

---

## 解題紀錄

### 第一次

- 想法：有想到 Sorting 解法。
- 錯誤：沒有另外記 maxLen，也沒想到不連續時要重置 len。
- 結果：Wrong Answer。

### 第二次

- 想法：只想到 Sorting 解法，沒想到 HashSet 解法。
- 錯誤：Sorting 沒想到最後要再更新一次；HashSet 看答案。
- 結果：Wrong Answer。
