---
title: "[Leetcode]  217. Contains Duplicate"
date: 2026-10-27 16:56 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000217_contains_duplicate/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/contains-duplicate/"
neetcode_url: "https://neetcode.io/problems/duplicate-integer"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️⭐️⭐️"
company: "Google"
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_217_Contains_Duplicate/Document.md
render_with_liquid: false
---

## Question

Given an integer array `nums`, return `true` if any value appears **at least twice** in the array, and return `false` if every element is distinct.

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

## 辨識訊號

- 看到「appears at least twice」→ 要找一樣的數字，想到：
  - 暴力解：每一對都比一次最直覺
  - 排序：一樣的數字排完會黏在一起
  - Set：只要知道這個數字之前看過沒
- 看到「return true / false」→ 排序不影響答案：只問有沒有，不用回傳 index，順序打亂也沒差
- 看到 `nums.length` 最大 10^5 → O(n²) 約 5 × 10^9 次，太慢，暴力解不夠

---

## 解法 1：Brute Force

### 關鍵提問

1. 最直覺怎麼做？
2. 每一對都比，要比幾次？n 最大 10^5 會不會太慢？

### 思路

1. 拿一個數字，往後找有沒有跟它一樣的。
2. 找到就回傳 true；全部比完都沒有，回傳 false。

### Pseudo Code

```text
for i = 0 to len(nums) - 1:
    for j = i + 1 to len(nums) - 1:
        if nums[i] == nums[j]
            return true
    
return false    
```

### 程式碼

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                if nums[i] == nums[j]:
                    return True

        return False
```

### 複雜度

- Time complexity: O(n²)
  - 每一對都比一次，約 n² / 2 對；n = 10^5 時約 5 × 10^9 次，太慢。
- Space complexity: O(1)

### 瓶頸

- 每個數字都要往後走一遍，才知道後面有沒有跟它一樣的。
- 如果一樣的數字會排在一起，只要看旁邊那一個就好。

---

## 解法 2：Sorting

### 關鍵提問

1. 暴力解每個數字都要往後找一遍。如果一樣的數字黏在一起，還要找嗎？
2. 題目只要 true / false，順序打亂可以嗎？
3. 排完之後，要比哪兩個？

### 思路

1. 先排序，一樣的數字就會黏在一起。
2. 從頭走一遍，每個數字跟前一個比，一樣就回傳 true。
3. 走完都沒有一樣的，回傳 false。

### Pseudo Code

```text
sort nums in place

for i = 0 to len(nums) - 2:
    if nums[i] == nums[i + 1]:
        return true

return false
```

### 程式碼

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        nums.sort()

        for i in range(len(nums) - 1):
            if nums[i] == nums[i + 1]:
                return True

        return False
```

### 複雜度

- Time complexity: O(n log n)
  - 排序 O(n log n)，走一遍 O(n)。
- Space complexity: O(1) 或 O(n)
  - 看排序的實作；**Python 的 `sort()` 最壞要 O(n) 的額外空間**，不是 O(1)。

### 瓶頸

- 時間花在排序。
- 排序只是為了讓一樣的數字靠在一起；其實只需要知道「這個數字之前有沒有看過」。

---

## 解法 3：HashSet

### 關鍵提問

1. 排序是瓶頸。不排序的話，怎麼知道一個數字之前出現過？
2. 要記「看過哪些數字」，用什麼裝？
3. 查跟放能不能在同一圈做完？

### 思路

1. 用 Set 記看過的數字。
2. 一個一個看：在 Set 裡就回傳 true；不在就放進去。
3. 走完都沒有重複，回傳 false。
4. 也可以全部丟進 Set，比 Set 跟陣列的長度，不一樣就是有重複。寫法比較短，但**一定要走完整個陣列，不能提早回傳**。

### Pseudo Code

```text
seen = new empty set

for num in nums:
    if num in seen:
        return true
    else:
        add num into seen

return false
```

### 程式碼

```python
class Solution:
    def containsDuplicate(self, nums: list[int]) -> bool:
        seen = set()

        for num in nums:
            if num in seen:
                return True
            else:
                seen.add(num)

        return False
```

### 複雜度

- Time complexity: O(n)
  - 走過 `nums` 一次，每次查 Set、加進 Set 都是 O(1)。
- Space complexity: O(n)
  - 最壞情況沒有重複，Set 要存 n 個數字。

---

## 卡點

**想法：**

- 一開始沒想到 One-pass，先把全部放進 Set，再走一遍查。
  - 下次先問：查詢和加入能不能在同一個迴圈做？

**實作：**

- 無

---

## 解題紀錄

| 類型 | 日期 | 解法 | 結果 | 時間 | 卡點 |
|---|---|---|---|---|---|
| 第一次 | 2025-07-25 | Set | AC | — | 想法：只想到 Two-pass |
| 複習 1 | 2026-07-17 | Set | AC | — | — |
| 複習 2 | 2026-10-27 | 暴力、排序、Set | AC | — | — |
