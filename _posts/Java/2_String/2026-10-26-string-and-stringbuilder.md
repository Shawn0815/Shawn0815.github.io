---
title: "[Java]  String 與 StringBuilder"
date: 2026-10-26 18:46 +0800
categories: ["Java", "String"]
tags: []
order: "000002_string/000002.000001_string-and-stringbuilder.md"
image: {path: "/assets/img/covers/Java.png"}
source: DDAN_Usandbox/0_Personal/Java/2_String/2.1_String-and-StringBuilder.md
render_with_liquid: false
---

## Abstract

String 不能修改，任何「修改」都會產生新的 String；要在迴圈裡拼接、反轉、Backtracking 時改用 StringBuilder。
要修改字元、排序字元、用左右指標時，先轉成 `char[]`。
容易錯的地方：用 `==` 比內容、`substring` 的範圍不含 end、`split` 吃的是 Regular Expression。

範例在本機 `jshell`（OpenJDK 25）跑過，`// →` 後面是實際輸出。

---

## 基本操作

```java
int len = text.length();            // String 用 length()，陣列用 length
char first = text.charAt(0);
char last = text.charAt(text.length() - 1);

for (int i = 0; i < text.length(); i++) {
    char ch = text.charAt(i);
}
```

### 比較

```java
text1.equals(text2);              // 比內容，不要用 ==
text1.equalsIgnoreCase(text2);
"apple".compareTo("banana");      // 字典順序：< 0 在前、0 相同、> 0 在後
// → -1
```

### 子字串與搜尋

```java
"abcdef".substring(1, 4);         // [start, end)，不含 end
// → bcd

text.substring(start);            // 到結尾
text.indexOf("abc");              // 第一次出現的位置，找不到回傳 -1
text.lastIndexOf('a');
text.contains("abc");
text.startsWith("pre");
text.endsWith("ing");
```

### 切割、空白、替換、大小寫

`split()` 的參數是 Regular Expression：

```java
"a.b.c".split(".");               // . 在 regex 是任意字元，全部被切掉
// → []

"a.b.c".split("\\.");
// → [a, b, c]

"  hello   world ".trim().split("\\s+");    // 先 trim，再切一個或多個空白
// → [hello, world]

"a,b,,".split(",");               // 尾端的空字串會被丟掉
// → [a, b]
```

```java
text.trim();                       // 只去前後空白
text.replace("old", "new");        // 換掉所有符合的
text.replaceAll("\\s+", "");       // 用 regex 替換：移除所有空白
text.toLowerCase();
text.toUpperCase();
text.isEmpty();                    // 長度是 0
```

判空要先確認不是 `null`：`if (text != null && !text.isEmpty())`。

---

## 轉成 char[]

```java
char[] chars = text.toCharArray();
Arrays.sort(chars);
String sorted = new String(chars);
// "listen" → eilnst

new String(chars, start, length);    // 只轉一段
```

Anagram 題目：兩個字串各自轉 `char[]` 排序，再用 `Arrays.equals(chars1, chars2)` 比。

反轉字串時，題目要求自己實作就用左右指標：

```java
char[] chars = text.toCharArray();
int left = 0, right = chars.length - 1;
while (left < right) {
    char temp = chars[left];
    chars[left++] = chars[right];
    chars[right--] = temp;
}
String reversed = new String(chars);
```

數字轉換：`Integer.parseInt(text)`、`Long.parseLong(text)`、`String.valueOf(number)`。

---

## StringBuilder

```java
StringBuilder sb = new StringBuilder();      // 或 new StringBuilder(text)

sb.append("abc").append(123).append('a');    // 加到最後，可以連續呼叫
sb.insert(index, "abc");
sb.delete(start, end);                       // [start, end)
sb.deleteCharAt(index);
sb.setCharAt(index, 'a');
sb.charAt(index);
sb.length();
sb.reverse();
sb.substring(start, end);                    // 回傳的是 String
sb.toString();
sb.setLength(0);                             // 清空，保留物件
```

```java
StringBuilder sb = new StringBuilder("abc");
sb.append('d').insert(0, "x");
// → xabcd

sb.deleteCharAt(sb.length() - 1);
// → xabc

new StringBuilder("hello").reverse().toString();
// → olleh
```

### 常見情境

```java
// 迴圈裡組字串
StringBuilder sb = new StringBuilder();
for (String word : words) {
    sb.append(word);
}

// Backtracking：加進去、往下走、再拿掉
sb.append(ch);
dfs(...);
sb.deleteCharAt(sb.length() - 1);
```

**在迴圈裡用 `+` 拼接 String，每一圈都會建一個新物件**，n 圈就是 O(n²)，要改用 StringBuilder。

| | String | StringBuilder |
|---|---|---|
| 可不可以改 | 不可（Immutable） | 可以（Mutable） |
| 修改時 | 建立新物件 | 直接改原物件 |
| 適合 | 少量操作 | 大量修改、迴圈拼接 |
