---
title: "[Leetcode]  49. Group Anagrams"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000049_group_anagrams/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Medium"
leetcode_url: "https://leetcode.com/problems/group-anagrams/"
neetcode_url: "https://neetcode.io/problems/anagram-groups"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_049_Group_Anagrams/Document.md
render_with_liquid: false
---

## Question

Given an array of strings `strs`, group the anagrams together.
You can return the answer in any order.

**Example 1:**

> Input: strs = ["eat","tea","tan","ate","nat","bat"]
>
> Output: [["bat"],["nat","tan"],["ate","eat","tea"]]
>
> Explanation:
> - There is no string in strs that can be rearranged to form "bat".
> - The strings "nat" and "tan" are anagrams as they can be rearranged to form each other.
> - The strings "ate", "eat", and "tea" are anagrams as they can be rearranged to form each other.

**Example 2:**

> Input: strs = [""]
>
> Output: [[""]]

**Example 3:**

> Input: strs = ["a"]
>
> Output: [["a"]]

**Constraints:**

- 1 <= strs.length <= 10^4
- 0 <= strs[i].length <= 100
- `strs[i]` consists of lowercase English letters.

---

## 主解法：HashMap + Frequency Array

### 題型

Grouping by Signature

### 思考流程

1. 怎麼判斷兩個字串是同一組（anagram）？
   - 用 frequency array 算每個字母出現的次數。
   - 兩個字串的 frequency array 一樣，就是同一組。
2. 怎麼把同一組的字串放在一起？
   - 用 HashMap 分組：key 是共同特徵（signature），value 是屬於這組的字串 list。
3. frequency array 可以直接當 key 嗎？
   - ==不行，array 比的是 reference，不是內容==。
   - 要先把 frequency array 轉成字串，再當 HashMap 的 key。

### 步驟

1. Loop 每個字串。
2. 建立這個字串的 frequency array。
3. 把 frequency array 轉成字串，當作 key。
4. HashMap 裡還沒有這個 key，就建立新的 list。
5. 把目前的字串加進對應的 list。
6. 回傳 HashMap 所有的 value。

### 程式碼

```java
public class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        // key：frequency array 轉成的字串，value：同一組的字串
        Map<String, List<String>> group = new HashMap<>();

        for (String str: strs) {
            int[] counter = new int[26];

            for (char c: str.toCharArray()) {
                counter[c - 'a']++;
            }

            // 直接 put 會蓋掉原本的 list，所以用 putIfAbsent
            group.putIfAbsent(Arrays.toString(counter), new ArrayList<>());
            group.get(Arrays.toString(counter)).add(str);
        }

        // values() 是 Collection，轉成 ArrayList
        return new ArrayList<>(group.values());
    }
}
```

### 複雜度分析

- Time complexity: O(n * k)
  - n 是字串數量，k 是字串長度，每個字串都要統計一次。
- Space complexity: O(n * k)
  - HashMap 存所有字串，每個 key 也要空間。

### 容易錯

- 要想到用 HashMap 分組：key 放共同特徵，value 放字串 list。
- ==key 不能直接放 array，要先轉成字串==。
- 每個字串都要重新建立 frequency array，不能共用。
- Java：
  - Array 轉字串用 `Arrays.toString(arr)`，`arr.toString()` 得到的是物件的 reference。
  - 不存在就建立 list 再加入，可以寫成 `computeIfAbsent(key, k -> new ArrayList<>()).add(str)`。
  - `map.values()` 是 Collection，要用 `new ArrayList<>(map.values())` 轉成 List。

### 其他解法

把每個字串排序後當作 signature。
排序要 O(k log k)，所以 frequency array 通常比較快。

---

## 解題紀錄

### 第一次

- 想法：沒有想法。
- 錯誤：不會做。
- 結果：沒完成。

### 第二次

- 想法：有想到用 Valid Anagram 判斷是否同一組。
- 錯誤：沒想到用 HashMap 分組，以及用 frequency array 字串當 signature。
- 結果：看答案後理解。

### 第三次

- 想法：有想到 frequency array + HashMap 分組。
- 錯誤：忘記每個字串要重新建立 array，也忘了一些 Java 語法。
- 結果：AC。
