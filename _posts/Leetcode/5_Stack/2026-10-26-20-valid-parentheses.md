---
title: "[Leetcode]  20. Valid Parentheses"
date: 2026-10-26 22:23 +0800
categories: ["Leetcode", "Stack"]
tags: []
order: "000005_stack/_000020_valid_parentheses/document.md"
image: {path: "/assets/img/covers/Leetcode.png"}
level: "Easy"
leetcode_url: "https://leetcode.com/problems/valid-parentheses/"
neetcode_url: "https://neetcode.io/problems/validate-parentheses"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company:
source: DDAN_Usandbox/0_Personal/Leetcode/5_Stack/_020_Valid_Parentheses/Document.md
render_with_liquid: false
---

## Question

Given a string `s` containing just the characters `'('`, `')'`, `'{'`, `'}'`, `'['` and `']'`, determine if the input string is valid.

An input string is valid if:

1. Open brackets must be closed by the same type of brackets.
2. Open brackets must be closed in the correct order.
3. Every close bracket has a corresponding open bracket of the same type.

**Example 1:**

> Input: s = "()"
>
> Output: true

**Example 2:**

> Input: s = "()[]{}"
>
> Output: true

**Example 3:**

> Input: s = "(]"
>
> Output: false

**Example 4:**

> Input: s = "([])"
>
> Output: true

**Example 5:**

> Input: s = "([)]"
>
> Output: false

**Constraints:**

- 1 <= s.length <= 10^4
- `s` consists of parentheses only `'()[]{}'`.

---

## 主解法：Stack

### 題型

Matching / Validation

### 思考流程

1. 直覺的想法是什麼？
   - 括號必須成對出現，而且可能括號包著括號，要一層一層檢查。
   - 最直覺的做法：看到成對的就移除，再重新檢查一遍，最後看字串是不是被移除到空。
2. 這樣做有什麼問題？
   - 每次檢查都要掃過整個字串。
   - 最壞要掃 n/2 次，每次長度最長 n，複雜度 O(n^2)。
3. 可以怎麼優化，不要重複掃描？
   - 重複掃描其實是為了找出最裡面的成對括號。
   - 改成邊掃描邊檢查：配對成功的那組就處理完了，之後不用再掃。
4. 要怎麼邊掃描邊檢查？
   - 保留尚未配對的左括號。
   - 遇到右括號時，檢查最近一個尚未配對的左括號能不能跟它配對。
   - 配對成功就移除，最近的未配對左括號變成上一個，等下個右括號繼續檢查。
5. 哪個資料結構符合這個特性？
   - Stack：後進先出（LIFO）。
   - 頂端就是最近尚未配對的左括號；配對成功 pop 掉之後，頂端自然變成上一個未配對的左括號。
6. 實作上有什麼要注意？
   - 有三種 invalid case：
     1. 右括號跟最近的左括號不成對，例如 `([)`，碰到的當下就知道不合法。
     2. 掃描完 stack 裡還有左括號，例如 `(([])(`，要在掃描結束後檢查 stack 是否為空。
     3. 掃描到右括號時 stack 是空的，例如 `[])`，要在 pop 之前先檢查。

### 步驟

1. 建立一個 stack，存放尚未配對的左括號。
2. 依序檢查字串的每個字元：
   1. 左括號：直接 push 進 stack，等待配對。
   2. 右括號：先確認 stack 不是空的，再 pop 出最近的左括號檢查是否配對。
   3. 無法配對：順序錯誤，回傳 false。
3. 全部掃描完後，stack 不是空的代表還有多的左括號，回傳 false；是空的回傳 true。

### 程式碼

```java
class Solution {
    public boolean isValid(String s) {
        Stack<Character> stack = new Stack<>();

        for (char c: s.toCharArray()) {
            if ((c == '(') || (c == '[') || (c == '{')) {
                stack.push(c);
            }
            else if ((c == ')') || (c == ']') || (c == '}')) {

                if (stack.isEmpty()) {
                    return false;
                }

                char lastLeft = stack.pop();

                if ((lastLeft == '(' && c != ')') ||
                    (lastLeft == '[' && c != ']') ||
                    (lastLeft == '{' && c != '}')) {
                    return false;
                }
            }
        }

        return stack.isEmpty();
    }
}
```

### 複雜度分析

- Time complexity: O(n)
  - 每個字元只掃描一次，左括號最多 push 一次，右括號最多 pop 一次。
- Space complexity: O(n)
  - 最壞情況全部都是左括號，stack 會存 n 個字元。

### 容易錯

- ==掃描到右括號時 stack 可能是空的==，要直接 return false，不能 pop。
- 右括號跟最近的左括號不匹配時，直接 return false。
- ==最後要檢查 stack 是否為空==，可能還有多的左括號沒有配對。
- Java：loop 字串前要先用 `toCharArray()` 轉成 char 陣列。

---

## 解題紀錄

### 第一次

- 想法：沒想法。
- 錯誤：無。
- 結果：直接看答案，照著寫。

### 第二次

- 想法：又忘記了，跟 GPT 討論，從直覺開始搞懂。
- 錯誤：漏掉右括號出現時 stack 是空的 case，最後噴 error。
- 結果：Wrong Answer（自己 debug，大概 30 分鐘完成）。
