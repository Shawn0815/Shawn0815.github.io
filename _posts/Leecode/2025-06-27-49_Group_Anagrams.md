---
title: Easy | Leetcode 49. Group Anagrams
author: <author_id>
date: 2025-06-27 03:33:00 +0800
categories: [Leetcode, Easy, Array & Hashing]
tags: [Leetcode, Java]
description: Given an array of strings strs, group the anagrams together. You can return the answer in any order.
image:
  path: /assets/img/2025-06-20-16-16-28.png
math: true
leetcode_url: https://leetcode.com/problems/group-anagrams/description/
leetcode_title: "點此進入LeetCode"
neetcode_url: https://neetcode.io/problems/anagram-groups
neetcode_title: "點此進入NeetCode"
---

## Question

![](/assets/img/2025-06-27-15-38-27.png)

---

## Solution

### Solution1: Sorting

#### 解題概念：

1. 用Map來存放排序後的string，跟對應到此排序的string list。
2. 依序loop每個string並將其作排序。
3. 把排序的string當成key，原本的string當成value加到map中（value會是一個string list）。
4. 最後回傳這個map的value集合（每個元素為一個List），並將這個集合轉為list。

#### 程式碼：

```java
public class Solution1 {
    public List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> group = new HashMap<>();

        for (String str: strs) {
            // 轉成字元陣列
            char[] charArray = str.toCharArray();
            // Java的sort是原地排序
            Arrays.sort(charArray);
            // 將排序後的字元陣列轉回string
            String sorted_str = new String(charArray);

            // 如果不存在這個key，加入並把value初始化為空arraylist
            group.putIfAbsent(sorted_str, new ArrayList<>());
            // 將string加入這個arraylist
            group.get(sorted_str).add(str);
        }

        // group.values()回傳的是Collection，用ArrayList<>轉成list
        return new ArrayList<>(group.values());
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n * m logm)$
    - 依序loop每個字串：O(n)；每個字串排序：O(m logm) => 總共：O(n * m logm)。
- Space complexity: $O(n*m)$
    - 最壞情況有n個key，每個key對應到一個list，而這個list儲存一個string，長度m => 總共：O(n*m)。

### Solution2: Hash Table

#### 解題概念：

1. 用Map來存放counter: key（參考valid anagram：每個字母出現的次數array），跟對應的string list: value。
2. 依序loop每個string並計算其counter。
3. 如果此key不存在，將value初始化為一個空的array list。（直接put key, value會把原先key對應到的value直接覆蓋，我們希望加進list）
4. 將string加到key對應到的value（一個list）中。
5. 最後回傳這個map的value集合（每個元素為一個List），並將這個集合轉為list。

#### 程式碼：

```java
public class Solution2 {
    public List<List<String>> groupAnagrams(String[] strs) {
        // 建立一個map來放counter跟他對應到的string list
        Map<String, List<String>> group = new HashMap<>();

        // 依序loop每個string計算其counter
        for (String str: strs) {
            int[] counter = new int[26];

            for (char c: str.toCharArray()) {
                counter[c - 'a']++;
            }

            // 如果不存在counter這個key，加入並把value初始化為空arraylist
            // 直接put會把原先key對應到的value給覆蓋
            group.putIfAbsent(Arrays.toString(counter), new ArrayList<>());

            // 將string加入這個arraylist
            group.get(Arrays.toString(counter)).add(str);
        }

        // group.values()回傳的是Collection，用ArrayList<>轉成list
        return new ArrayList<>(group.values());
    }
}
```

#### 複雜度分析：

- Time complexity: $O(n*m)$
    - 外層迴圈loop每個字串：O(n)；內層迴圈loop每個字串的字母：O(m)
    - 處理Hash Map最多有26個key：O(26) => 總共為O(n*m*26)=O(n*m)。
- Space complexity: $O(n*m)$
    - 用Map來儲存結果，總共有n個string，每個string長度為m，需要O(n*m)個空間儲存。