---
title: "[Java]  型別與值"
date: 2026-10-26 18:46 +0800
categories: ["Java", "Basics"]
tags: []
order: "000001_basics/000001.000002_types-and-values.md"
image: {path: "/assets/img/covers/Java.png"}
source: DDAN_Usandbox/0_Personal/Java/1_Basics/1.2_Types-and-Values.md
render_with_liquid: false
---

## Abstract

Java 的型別分成 Primitive（`int`、`long`、`char`…）和 Reference（`String`、陣列、Collection），Collection 只能放 Reference，所以要用 `Integer` 這類 Wrapper。
刷題最容易錯的是 `int` overflow、用 `==` 比較 String 或 Integer、區域變數沒初始化。

範例在本機 `jshell`（OpenJDK 25）跑過，`// →` 後面是實際輸出。

---

## Primitive Types

```java
int number = 10;
long total = 10_000_000_000L;
double average = 3.14;
char letter = 'a';
boolean visited = false;
```

可能超過 `int` 範圍時用 `long`，而且**要先轉型再計算**：

```java
int a = 2_000_000_000, b = 2_000_000_000;
long wrong = a + b;          // 先用 int 加完才轉成 long，已經 overflow
long right = (long) a + b;
System.out.println(wrong + " " + right);
// → -294967296 4000000000
```

---

## Reference Types 與 Wrapper

```java
String text = "hello";
int[] nums = new int[5];
List<Integer> list = new ArrayList<>();
Map<Integer, Integer> map = new HashMap<>();
Set<Integer> set = new HashSet<>();
```

Reference 可以是 `null`，使用前要注意。

Collection 不能放 Primitive：`List<int>` 是錯的，要寫 `List<Integer>`。

| Primitive | Wrapper |
|---|---|
| `int` | `Integer` |
| `long` | `Long` |
| `double` | `Double` |
| `char` | `Character` |
| `boolean` | `Boolean` |

Java 會自動轉換（Boxing / Unboxing）：`list.add(10)` 是 `int` → `Integer`，`int v = list.get(0)` 是 `Integer` → `int`。

---

## 預設值

陣列建立後會自動初始化：

```java
int[] nums = new int[3];           // [0, 0, 0]
boolean[] visited = new boolean[3]; // [false, false, false]
String[] words = new String[3];    // [null, null, null]
```

**區域變數不會自動初始化**，`int number; System.out.println(number);` 會編譯錯誤。

---

## 型別轉換

```java
int n = Integer.parseInt("123");      // String → int
long l = Long.parseLong("123");
double d = Double.parseDouble("3.14");

String s1 = String.valueOf(123);      // int → String
String s2 = Integer.toString(123);

int digit = '5' - '0';                // 數字字元 → int
// → 5

char c = (char) (5 + '0');            // int → 數字字元
// → '5'
```

---

## 比較

Primitive 用 `==`；**String 比內容要用 `equals()`**，`==` 比的是是不是同一個物件：

```java
String s1 = "hello";
String s2 = new String("hello");
System.out.println((s1 == s2) + " " + s1.equals(s2));
// → false true
```

變數可能是 `null` 時把固定值放前面：`"hello".equals(text)`。

Wrapper 也一樣：

```java
Integer x = 127, y = 127, p = 128, q = 128;
System.out.println((x == y) + " " + (p == q) + " " + p.equals(q));
// → true false true
```

-128 到 127 的 `Integer` 有快取，`==` 剛好會是 `true`，超出範圍就是 `false`。
**從 Map 拿出來的 `Integer` 互相比較要用 `equals()`**，小數字測試時通過、大數字就錯。

---

## 常用常數

```java
Integer.MAX_VALUE    Integer.MIN_VALUE
Long.MAX_VALUE       Long.MIN_VALUE
Double.POSITIVE_INFINITY    Double.NEGATIVE_INFINITY
```

表示「還沒有答案」：先設 `int answer = Integer.MAX_VALUE;`，最後 `return answer == Integer.MAX_VALUE ? -1 : answer;`。
