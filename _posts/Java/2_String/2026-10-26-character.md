---
title: "[Java]  Character"
date: 2026-10-26 18:46 +0800
categories: ["Java", "String"]
tags: []
order: "000002_string/000002.000002_character.md"
image: {path: "/assets/img/covers/Java.png"}
source: DDAN_Usandbox/0_Personal/Java/2_String/2.2_Character.md
render_with_liquid: false
---

## Abstract

`char` 是 Primitive，可以直接用 `==`、`<` 比較（比的是 Unicode 數值），也可以和數字做加減。
刷題最常用的是 `ch - 'a'` 把字母轉成 0～25，搭配長度 26 的陣列統計頻率；以及 `Character` 的判斷方法（`isLetterOrDigit` 等）。

範例在本機 `jshell`（OpenJDK 25）跑過，`// →` 後面是實際輸出。

---

## 基本

```java
char ch = 'a';      // 單引號是 char，雙引號 "a" 是 String
ch1 == ch2;         // 直接比
ch1 < ch2;          // 依 Unicode 數值比順序
```

---

## 判斷與轉換

| 方法 | 用途 |
|---|---|
| `Character.isLetter(ch)` | 英文字母 |
| `Character.isDigit(ch)` | 數字，也可以寫 `ch >= '0' && ch <= '9'` |
| `Character.isLetterOrDigit(ch)` | 字母或數字，Valid Palindrome 常用 |
| `Character.isUpperCase(ch)` / `isLowerCase(ch)` | 大小寫 |
| `Character.toLowerCase(ch)` / `toUpperCase(ch)` | 轉大小寫，忽略大小寫比較時用 |

```java
if (!Character.isLetterOrDigit(ch)) continue;
```

---

## 數字、字母與 index 互轉

```java
int n = '7' - '0';              // 數字字元 → int
// → 7

char c = (char) (7 + '0');      // int → 數字字元
// → '7'

int index = 'c' - 'a';          // 小寫字母 → 0～25，大寫用 - 'A'
// → 2

char letter = (char) ('a' + 2); // 0～25 → 字母
// → c
```

`Character.getNumericValue(ch)` 也可以，但確定是 `'0'`～`'9'` 時直接 `ch - '0'` 就好。

---

## 字元頻率

只有小寫字母時用長度 26 的陣列：

```java
int[] count = new int[26];
for (char ch : text.toCharArray()) {
    count[ch - 'a']++;
}
int freq = count[ch - 'a'];
```

字元範圍不固定時改用 Map：

```java
Map<Character, Integer> count = new HashMap<>();
for (char ch : text.toCharArray()) {
    count.put(ch, count.getOrDefault(ch, 0) + 1);
}
```

---

## char 與 String

```java
String s = String.valueOf(ch);     // 或 Character.toString(ch)；ch + "" 可以但可讀性差
char ch = text.charAt(0);
```

走過所有字母或數字：

```java
for (char ch = 'a'; ch <= 'z'; ch++) { }
for (char ch = '0'; ch <= '9'; ch++) { }
```
