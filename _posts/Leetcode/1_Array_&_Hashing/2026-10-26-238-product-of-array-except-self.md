---
title: "[Leetcode]  238. Product of Array Except Self"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000238_product_of_array_except_self/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Medium"
leetcode_url: "https://leetcode.com/problems/product-of-array-except-self/"
neetcode_url: "https://neetcode.io/problems/products-of-array-discluding-self"
class: "🧠 Blind 75"
important: "⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_238_Product_of_Array_Except_Self/Document.md
render_with_liquid: false
---

## Question

Given an integer array `nums`, return an array `answer` such that `answer[i]` is equal to the product of all the elements of `nums` except `nums[i]`.

The product of any prefix or suffix of `nums` is guaranteed to fit in a 32-bit integer.

You must write an algorithm that runs in ==`O(n)` time and without using the division operation==.

**Example 1:**

> Input: nums = [1,2,3,4]
>
> Output: [24,12,8,6]

**Example 2:**

> Input: nums = [-1,1,0,-3,3]
>
> Output: [0,0,9,0,0]

**Constraints:**

- 2 <= nums.length <= 10^5
- -30 <= nums[i] <= 30

**Follow-up**: Can you solve the problem in O(1) extra space complexity? (The output array does not count as extra space.)

---

## 主解法：Prefix & Suffix（Optimal）

### 題型

Prefix / Suffix Product

### 思考流程

1. 除了自己以外的乘積怎麼算？
   - ==自己以外的乘積 = 左邊所有數字的乘積 × 右邊所有數字的乘積==。
2. 左右兩邊的乘積怎麼算？
   - 前綴積 prefix[i]：開頭到 i - 1 的乘積，prefix[i] = prefix[i - 1] × nums[i - 1]，prefix[0] = 1。
   - 後綴積 suffix[i]：i + 1 到結尾的乘積，suffix[i] = suffix[i + 1] × nums[i + 1]，suffix[n - 1] = 1。
3. 能不能不要另外開 prefix、suffix 兩個陣列？
   - 前綴積直接存在 result 裡。
   - 後綴積用一個變數 suffixProduct，從右往左邊走邊乘進 result。

### 步驟

1. result[0] = 1。
2. 從左往右，result[i] = result[i - 1] × nums[i - 1]，result 裡先存好前綴積。
3. suffixProduct = 1，從右往左：
   1. result[i] 乘上 suffixProduct（右邊所有數字的乘積）。
   2. suffixProduct 乘上 nums[i]，給左邊下一格用。
4. 回傳 result。

### 程式碼

```java
public class Solution {
    public int[] productExceptSelf(int[] nums) {
        int[] result = new int[nums.length];

        // 1. 前綴積存在 result 裡
        result[0] = 1;

        for (int i = 1; i < nums.length; i++) {
            result[i] = result[i - 1] * nums[i - 1];
        }

        // 2. 從右往左乘上後綴積
        int suffixProduct = 1;

        for (int i = nums.length - 1; i >= 0; i--) {
            result[i] *= suffixProduct;
            suffixProduct *= nums[i];
        }

        return result;
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - 從左到右、從右到左各走一次。
- Space complexity: O(1)
  - 除了輸出的 result，只用了 suffixProduct 一個變數。

### 容易錯

- ==從右往左時，要先乘上 suffixProduct，再更新 suffixProduct==；順序反了會把自己也乘進去。

### 其他解法

- **Brute Force**：雙層迴圈，每個位置把其他所有數字乘起來，O(n^2)，不符合題目要求。
- **Division**：全部乘起來再除以自己，但題目不准用除法，還要另外處理 0：
  - 0 超過一個：全部都是 0。
  - 剛好一個 0：只有 0 的位置是其他數字的乘積，其他都是 0。
  - 沒有 0：每個位置是總乘積除以自己。
- **Prefix & Suffix（兩個陣列）**：另外開 prefix、suffix 兩個陣列，最後 result[i] = prefix[i] × suffix[i]。時間 O(n)，空間 O(n)，是主解法省掉空間前的版本。

---

## 總結

面試時可以先講 Prefix & Suffix 用兩個陣列的版本，說清楚「左邊乘積 × 右邊乘積」，再提出把前綴積存在 result 裡的 Optimal 版本，把額外空間降到 O(1)。

---

## 解題紀錄

### 第一次

- 想法：只想到暴力解。
- 錯誤：其他解法是看答案的。
- 結果：看答案。
