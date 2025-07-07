---
title: Easy | Leetcode 217. Contains Duplicate
author: shawn_yu
date: 2025-06-19 16:15:03 +0800
categories: [Leetcode, Easy, Array & Hashing]
tags: [Leetcode, Java]
description: Given an integer array nums, return true if any value appears at least twice in the array, and return false if every element is distinct.
image: /assets/img/2025-06-20-16-16-28.png
math: true
leetcode_url: "https://leetcode.com/problems/contains-duplicate/description/"
leetcode_title: "點此進入LeetCode"
neetcode_url: "https://neetcode.io/problems/duplicate-integer"
neetcode_title: "點此進入NeetCode"
---

## Question 問題

給定一個整數陣列，判斷是否存在重複元素。

![](/assets/img/2025-07-03-00-27-20.png)

---

## Solution 解法

### Solution1：Brute Force（暴力解）

#### 解題概念：

一個一個元素跟後面元素比較，看是否相等（重複）。

#### 程式碼：

``` java
public class Solution1 {
    public static boolean containsDuplicate(int[] nums) {
        // 外層迴圈，從第一個元素開始
        for (int i = 0; i < nums.length; i++) {
            // 內層迴圈，從 i+1 開始，與外層迴圈中的元素進行比對
            for (int j = i + 1; j < nums.length; j++) {
                // 如果 nums[i] 和 nums[j] 相等，表示有重複元素，返回 true
                if (nums[i] == nums[j]) {
                    return true;
                }
            }
        }

        return false;
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n^2)$
  - 兩層嵌套迴圈，對陣列元素進行兩兩比較。
- Space complexity: $O(n)$
  - 不需要額外的資料結構來存儲元素，僅使用了少量的變數。

### Solution2: Sorting（排序法）

#### 解題概念：

先排序陣列，並逐一比較陣列元素跟他下一個元素是否相等，如果有相等，代表有重複。

#### 程式碼：

``` java
public class Solution2 {
    public static boolean containsDuplicate(int[] nums) {
        // 先把陣列排序，重複的數字會排在一起
        Arrays.sort(nums);

        // 逐一比較相鄰的兩個數字是否一樣即可
        for(int i = 0; i < nums.length - 1; i++) {
            if (nums[i] == nums[i + 1]) {
                return true;
            }
        }

        return false;
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n*logn)$
  - 排序：Java內建使用Quick Sort: O(nlogn)。
  - 比較：loop整個array：O(n)
- Space complexity: $O(n)$
  - Arrays.sort() 使用的是 in-place 排序（就地排序），不需要額外空間。  

### Solution3: HashSet

#### 解題概念：

array中一個個元素依序放入set中，並檢查是否重複放。  

#### 程式碼：

``` java
public class Solution3 {
    public static boolean containsDuplicate(int[] nums) {
        // 創建一個 HashSet 來記錄已經出現過的數字
        Set<Integer> seen = new HashSet<>();

        // 依序loop陣列中的元素，並檢查set中是否已存在
        for (int num: nums) {
            if (seen.contains(num)) {
                return true; // 已存在：回傳true
            }
            
            seen.add(num); // 未存在：放入set中
        }

        return false;
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n)$
  - 會loop陣列中每個元素。
- Space complexity: $O(n)$
  - 使用了 HashSet 來儲存最多 n 個數字。  

### Solution4: HashSet Length

#### 解題概念：

把array轉成set並計算長度，接著跟原始array長度做比較，如果set比較小，代表重複（set會自動去重）。  

#### 程式碼：

``` java
public class Solution4 {
    public static boolean containsDuplicate(int[] nums) {
        // 1. Arrays.stream(nums): 轉為Java的steam，做後續操作（型態：IntStream）
        // 2. .boxed: 把IntStream每個int值轉為Integer物件，因為set只能裝物件（型態：Stream<Integer>）
        // 3. .collect(Collectors.toSet()): 把Steam裡的元素收集起來並轉為set（型態：Set<Integer>）
        // 4. 計算set的長度，並跟原始array做比較（set會去重複）
        return Arrays.stream(nums).boxed().collect(Collectors.toSet()).size() < nums.length;
    }
}
```

![](/assets/img/2025-06-20-02-51-28.png)  

#### 複雜度分析：

- Time complexity: $O(n)$
  - stream(nums), boxed() 和 collect(Collectors.toSet()) 會分別把各個元素轉成stream/Integer以及放入set中，操作是 O(n)。
  - 其餘操作都是O(1)。
- Space complexity: $O(n)$
  - 主要的空間使用來自於 boxed() 和 collect(Collectors.toSet())，這兩者皆需要 O(n) 的額外空間來存儲 Integer 物件和 Set。
  - 其餘操作都是O(1)。

> 💡**Question: 為什麼isSubtree還要檢查subroot跟root是否為null，isSametree不是會檢查？**  
> 
> 因為如果不檢查上面標示的那兩個部分，如果今天root==null，但subRoot != null，會出問題。
> 
> Ex: 這段會返回false，然後往下一段走（把root的左右子樹跟subroot比對）
> 
> ``` java
> // root跟subroot相等，return true
> if (isSametree(root, subRoot)) {
>      return true;
> }
> ```
> 
> 這行就會出現null pointer的問題，因為root是null
> 
> ``` java
> // 繼續往root的左右子樹跟subroot比對
> return isSametree(root.left, subRoot) || isSametree(root.right, subRoot);
> ```
> 
> **結論：**  
> **在一開始就排除root=null的狀況，分為：(1) subroot是null 跟 (2) subroot不是null**  
> (1) 前者直接return true（因為null一定是任何樹的subtree）  > (2) 後者> return false（也就是上面討論的root==null, subroot != null）**