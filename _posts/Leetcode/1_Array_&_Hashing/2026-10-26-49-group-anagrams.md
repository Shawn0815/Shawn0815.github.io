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
important: "⭐️⭐️⭐️⭐️"
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
> - There is no string in strs that can be rearranged to form `"bat"`.
> - The strings `"nat"` and `"tan"` are anagrams as they can be rearranged to form each other.
> - The strings `"ate"`, `"eat"`, and `"tea"` are anagrams as they can be rearranged to form each other.

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

## 辨識訊號

- 看到「anagram」→ 字母一樣、只是順序不同，想到：
  - 排序：排完就一模一樣，可以當 key
  - 數字母：同一組的字串，每個字母出現的次數一樣，也可以當 key
- 看到「group the anagrams together」→ 想到 HashMap：特徵一樣的放同一組
- 看到「lowercase English letters」→ 想到 26 格陣列：只有 26 種字母
- 看到 `strs.length` 最大 10^4 → 不能兩兩比較：O(n²) 約 10^8 次，太慢

---

## 解法 1：Sorting

### 關鍵提問

1. 同一組的字串，有什麼東西會長得一樣？
2. 這個東西能不能拿來當 Map 的 key？value 放什麼？
3. 能不能每個字串只看一次，就知道它是哪一組？

### 思路

1. 同一組的字串排完會一模一樣，就拿排完的字串當 key。
   例：`"eat"`、`"tea"`、`"ate"` 排完都是 `"aet"`。
2. 用 Map 分組，key 是排完的字串，value 是這一組的字串 list。
3. 每個字串算出 key，丟進對應的那組；還沒有這組就先建一個。
4. 最後把 Map 裡所有的 value 拿出來回傳。

### Pseudo Code

```text
groups = new empty map (key = sorted string, value = list of anagrams)

for word in strs:
    key = word with letters sorted

    if key not in groups:
        group = new empty list
        groups[key] = group
    else:
        group = groups[key]

    add word into group

return groups.values() and convert to list
```

### 程式碼

```python
class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        groups = {}

        for word in strs:
            key = "".join(sorted(word))

            if key not in groups:
                group = []
                groups[key] = group
            else:
                group = groups[key]

            group.append(word)

        return list(groups.values())
```

### 複雜度

- n 是字串的數量，k 是最長字串的長度。
- Time complexity: O(n · k log k)
  - 每個字串都要排序一次，O(k log k)。
  - 用 key 查 map、放進去是 O(k)，比排序小，不影響整體。
- Space complexity: O(n · k)
  - key：最多 n 個（每個字串都自成一組時），每個最長 k。
  - value：所有組加起來剛好 n 個字串，每個最長 k。

### 瓶頸

- 時間都花在排序，每個字串 O(k log k)。
- 排序只是為了算出「同一組都一樣」的特徵，如果有更快的方法算出特徵，就不用排序。

---

## 解法 2：Frequency Array

### 關鍵提問

1. 排序是瓶頸。除了排完的字串，同一組還有什麼一樣？
2. 字母只有 26 種，能不能用固定大小的陣列來數？
3. 陣列能不能當 key？不能的話要轉成什麼？

### 思路

1. 同一組的字串，每個字母出現的次數一樣，改用次數當 key。
   例：`"eat"`、`"tea"`、`"ate"` 都是 a、e、t 各 1 次，其他字母 0 次。
2. 每個字串用 26 格陣列數一次字母，O(k)，比排序的 O(k log k) 快。
3. **陣列不能當 key**，要先轉：Python 轉 tuple，Java 用 `Arrays.toString`。
   **不能直接把數字接成字串**，`[1, 11]` 跟 `[11, 1]` 都會變成 `"111"`。
4. 分組跟回傳的方式跟解法 1 一樣。

### Pseudo Code

```text
groups = new empty map (key = frequency array, value = list of anagrams)

for word in strs:
    freq = new array with 26 zeros
    
    for c in word:
        freq[c - 'a'] += 1
    
    key = convert freq to tuple or string
    
    if key not in groups:
        group = new empty list
        groups[key] = group
    else:
        group = groups[key]
    
    group.add(word)

return groups.values() and convert to list
```

### 程式碼

```python
class Solution:
    def groupAnagrams(self, strs: list[str]) -> list[list[str]]:
        groups = {}

        for word in strs:
            freq = [0] * 26

            for c in word:
                freq[ord(c) - ord('a')] += 1

            key = tuple(freq)

            if key not in groups:
                group = []
                groups[key] = group
            else:
                group = groups[key]

            group.append(word)

        return list(groups.values())
```

### 複雜度

- Time complexity: O(n · k)
  - 每個字串數字母 O(k)，建 key O(26) 是常數。
  - 每個字母至少要看一次，O(n · k) 已經是下限。
- Space complexity: O(n · k)
  - key：最多 n 個，每個固定 26 個數字，O(n)，比解法 1 小。
  - value：跟解法 1 一樣是 O(n · k)，所以整體不變。

---

## 卡點

**想法：**

- 覺得 Constraints 沒影響，沒讀出「只有 26 個小寫字母」可以用 26 格陣列計數，這是解法 2 的關鍵。
  - 下次先問：每一條 Constraint 限制了什麼、又讓什麼做法變得可行？

**實作：**

- Pseudo Code 跟腦中想的不一樣，三次都是漏寫一步（value 寫成字串、新的 list 沒放進 Map、漏了加進 group）。
  - 下次先問：照寫下來的 Pseudo Code，用小 Example 一行一行走，結果對嗎？

---

## 解題紀錄

| 類型 | 日期 | 解法 | 結果 | 時間 | 卡點 |
|---|---|---|---|---|---|
| 第一次 | 2025-08-10 | 計數陣列 | 看答案 | — | 想法：完全沒想法，沒想到用 HashMap 分組、字母次數當 key |
| 複習 1 | 2026-07-30 | 計數陣列 | AC | — | 實作：每個字串沒重建陣列，次數一直累加 |
| 複習 2 | 2026-10-27 | 排序、計數陣列 | AC | — | 實作：Pseudo Code 三次都漏寫一步 |
