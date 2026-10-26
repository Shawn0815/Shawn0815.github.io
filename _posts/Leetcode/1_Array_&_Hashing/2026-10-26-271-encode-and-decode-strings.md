---
title: "[Leetcode]  271. Encode and Decode Strings"
date: 2026-10-26 23:22 +0800
categories: ["Leetcode", "Array & Hashing"]
tags: []
order: "000001_array_&_hashing/_000271_encode_and_decode_strings/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Medium"
leetcode_url: "https://leetcode.com/problems/encode-and-decode-strings/"
neetcode_url: "https://neetcode.io/problems/string-encode-and-decode"
class: "🧠 Blind 75"
important: "⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/1_Array_&_Hashing/_271_Encode_and_Decode_Strings/Document.md
render_with_liquid: false
---

## Question

Design an algorithm to encode a list of strings to a single string.
The encoded string is then decoded back to the original list of strings.

Implement `encode` and `decode`.

**Example 1:**

> Input: ["neet","code","love","you"]
>
> Output: ["neet","code","love","you"]

**Example 2:**

> Input: ["we","say",":","yes"]
>
> Output: ["we","say",":","yes"]

**Constraints:**

- 0 <= strs.length < 100
- 0 <= strs[i].length < 200
- `strs[i]` contains only UTF-8 characters.

---

## 主解法：Length Prefix

### 題型

String Encoding

### 思考流程

1. 直覺的做法是什麼？
   - 每個字串之間用特殊符號隔開，例如 `neet#code#love#you`，解碼時再用 `#` 切開。
2. 這樣做有什麼問題？
   - ==字串本身就有特殊符號時，會被多切出幾段==。
   - 例如 `["nice", "to", "me#et", "you"]` 編碼成 `nice#to#me#et#you`，解碼變成 `["nice", "to", "me", "et", "you"]`。
3. 怎麼讓字串裡的符號不影響解碼？
   - 每個字串前面加上「長度 + `#`」：`4#neet4#code4#love3#you`。
   - 解碼時先讀到 `#` 前的數字，就知道後面要取幾個字元。
   - 字串裡的 `#` 會被包在取出來的那段裡，不會被當成分隔：`4#nice2#to5#me#et3#you`。

### 步驟

1. Encode：每個字串依序加上 `長度`、`#`、字串本身，接成一個字串。
2. Decode：用兩個指針，i 指向數字開頭，j 找 `#`：
   1. j 從 i + 1 往右走，直到遇到 `#`。
   2. i 到 j 之間是長度 len。
   3. 從 j + 1 取長度 len 的字串，就是原本的字串。
   4. i 移到 j + 1 + len，也就是下一個數字的開頭。

### 程式碼

```java
public class Solution {
    public String encode(List<String> strs) {
        StringBuilder encode = new StringBuilder();

        for (String str : strs) {
            // 每個字串前面加上：長度 + '#'
            encode.append(str.length()).append("#").append(str);
        }

        return encode.toString();
    }

    public List<String> decode(String str) {
        List<String> decode = new ArrayList<>();

        // i：數字的開頭
        int i = 0;

        while (i < str.length()) {
            // j：從 i + 1 往右找 '#'
            int j = i + 1;

            while (str.charAt(j) != '#') {
                j++;
            }

            // i ~ j 是字串長度
            int len = Integer.valueOf(str.substring(i, j));

            // '#' 後面長度 len 的字串
            decode.add(str.substring(j + 1, j + 1 + len));

            // 移到下一個數字的開頭
            i = j + 1 + len;
        }

        return decode;
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - Encode 和 Decode 都只掃過每個字元一次，n 是所有字串的總長度。
- Space complexity: O(n)
  - Decode 結果的 list 存所有字串；Encode 除了輸出不需要額外空間。

### 容易錯

- 只用特殊符號分隔，字串本身有特殊符號就會解錯。
- ==長度可能是好幾位數==，要一直往右找到 `#`，不能只讀一個字元。

---

## 解題紀錄

### 第一次

- 想法：用特殊符號 `#` 分隔每個字串。
- 錯誤：字串本身有 `#` 時會被多切出幾段。
- 結果：看答案，改成長度 + `#` 的編碼。
