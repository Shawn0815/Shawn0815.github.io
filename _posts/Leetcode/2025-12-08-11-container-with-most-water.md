---
layout: post
title: Medium | Leetcode 11. Container With Most Water
date: 2025-12-08 19:36 +0800
author: shawn_yu
categories: [Leetcode, Two pointers, Medium]
tags: [Leetcode, Java]
image: {path: "/assets/img/2025-06-20-16-16-28.png"}
math: true

topic: "Array & Hashing"
level: "Medium"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️⭐️"
company: "Google, Amazon, Facebook"
leetcode_url: "https://leetcode.com/problems/container-with-most-water/description/"
neetcode_url: "https://neetcode.io/problems/max-water-container"
---

# 題目描述

給你一個整數陣列 height[]，每個索引 i 代表一條垂直線，座標為 (i, 0) 到 (i, height[i])。

你需要選出兩條線，**讓它們和 x 軸一起構成一個容器，使得容器能裝的水量最大**。

回傳這個容器最多能裝多少水。

![](/assets/img/2025-12-08-19-38-12.png)

---

# 解法

我原本只有想到暴力解，雙指針解法是看解答的，不過這題還算偏簡單。

---

## 解法 1: Brute Force

### 解題概念

最直覺的解法，**窮舉所有可能的左右邊界組合**，計算出最大面積，其中面積公式如下：

$$
area=(j−i)×min(height[i],height[j])
$$

### 程式碼

```java
public class Solution1 {
    public int maxArea(int[] height) {
        int maxArea = 0;

        // 設定左邊界
        for (int i = 0; i < height.length - 1; i++) {
            // 嘗試每一個右邊界，計算圍起來的面積
            for (int j = i + 1; j < height.length; j++) {
                // 底 = 兩邊界的水平距離；高 = 兩邊界中相對較矮邊界高
                int area = (j - i) * Math.min(height[i], height[j]);

                // 更新最大面積
                maxArea = Math.max(maxArea, area);
            }
        }

        return maxArea;
    }
}
```

### 複雜度分析

- Time Complexity: $O(n^2)$
    - 雙層迴圈，總共比較次數為 n×(n−1) /2。
- Space Complexity: $O(1)$
    - 只使用了變數 maxArea 與 area 來暫存計算結果。

---

## 解法 2: Two pointer

### 解題概念

雙指針解法的基本概念就是：

1. 初始化左右指針在最左跟最右的邊界上，並計算面積與更新最大面積。
2. 關鍵：根據哪一邊是矮邊決定要移動左或右指標：
    1. 面積 = 寬度 × 高度（**取決於較短邊**）。
    2. 移動高邊並不會增加高度，反而讓寬度變小，面積變小。
    3. **移動矮邊才有機會增加高度，進而增加面積**。
3. 重複直到左右指標相遇。

我本來的想法是：

兩邊都持續移動直到變高為止，不過這樣會錯過某些答案，因為只要短邊變高就有可能面積增加，重點還是短邊，不過可以利用這個想法稍微優化：**短邊移動時，持續移動到變高的地方**。

不過這個優化的 gain 並不是很大，且寫法更複雜，還要多考慮 left < right，因此參考即可（如下）。

```java
if (height[left] < height[right]) {
    left++;

    while (left < right && height[left] < height[left - 1]) {
        left++;
    }
}
```

### 程式碼

```java
public class Solution2 {
    public int maxArea(int[] height) {
        int maxArea = 0;
        int left = 0, right = height.length - 1;

        while (left < right) {
            // 計算當前面積
            int area = (right - left) * Math.min(height[left], height[right]);

            // 更新最大面積
            maxArea = Math.max(maxArea, area);

            // 移動矮邊
            if (height[left] < height[right]) {
                left++;
            }
            else {
                right--;
            }
        }

        return maxArea;
    }
}
```

### 複雜度分析

- Time Complexity: $O(n)$
    - 每次迭代都會移動一個指標，最多移動 n 次  ⇒  O(n)。
- Space Complexity: $O(1)$
    - 僅用到常數額外變數。

---

# 總結

面試時 **優先使用雙指標解法** 做為最佳解，也可以先提出暴力解再提更好的解法。

---

# 參考資料

- [雙指針應用題 : Leetcode #11 Container With Most Water](https://medium.com/@cutesciuridae/%E9%9B%99%E6%8C%87%E9%87%9D%E6%87%89%E7%94%A8%E9%A1%8C-leetcode-11-container-with-most-water-9ce0dac5c904)
- [Leetcode 11 — Container with most water](https://medium.com/@flyotlin/leetcode-11-container-with-most-water-7ac4d9203d44)