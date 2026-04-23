---
layout: post
title: SQL SELECT/WHERE 語法
date: 2026-04-23 11:38 +0800
author: shawn_yu
categories: [SQL]
tags: [SQL, ORDER BY, LIMIT]
image: {path: "assets/img/2026-04-23-MySQL.png"}
math: true
---

# SELECT + WHERE 核心慨念

SQL 的核心觀念是：拿資料 → 篩選資料 → 決定顯示的欄位。

## SELECT

SELECT 語法就是拿完資料 + 篩選完資料，決定 **<mark><font color="#d11f1f">要顯示什麼欄位（column）</font></mark>**。

### 1. 選欄位（基本）：

可以選擇要輸出的欄位：

```sql
SELECT user_id, name
FROM users;
```

也可以輸出所有欄位：

```sql
SELECT *
FROM users;
```

練習或 debug 上很常這樣用，但實務上不建議：

1. 可讀性差，不知道輸出哪些欄位。
2. 若表很大、欄位很多，會降低搜尋效能。

### 2. 做計算：

```sql
SELECT price * 2
FROM products;
```

👉 SQL 會幫你「每一列都算一次」。

也可以將兩個欄位做計算：

```sql
SELECT price * quantity
FROM orders;
```

### 3. 改名字（alias）：

```sql
SELECT price * 2 AS double_price
```

## WHERE

WHERE 語法就是 **<mark><font color="#d11f1f">篩選只留下符合條件的資料（row）</font></mark>**。

```sql
SELECT *
FROM orders
WHERE price > 100;
```

只留下價格大於 100 的資料，並顯示所有欄位。

## SELECT vs. WHERE

| 功能 | 做什麼 |
| --- | --- |
| WHERE | 篩資料（先） |
| SELECT | 決定輸出（後） |

👉 WHERE 是「先發生」，SELECT 是「後發生」。

## 總結：SQL 執行順序

```
1. FROM（拿資料）
2. WHERE（篩資料）
3. SELECT（決定輸出）
```

1. 先把資料表整個拿出來
2. 篩選掉不需要的資料
3. 決定要顯示哪些欄位

---

# WHERE 詳細語法

## 比較運算子

### 等於

```sql
WHERE city = 'Taipei'
```

### 不等於

```sql
WHERE city <> 'Taipei'
```

有些資料庫也支援 `!=` ，但 `<>` 比較標準。

### 大於/小於

```sql
WHERE age > 30
WHERE age < 30
WHERE age >= 30
WHERE age <= 30
```

通常用在數值或日期條件。

## 範圍（BETWEEN）

```sql
WHERE age BETWEEN 25 AND 30
```

等同於：

```sql
WHERE age >= 25 AND age <= 30
```

BETWEEN 是包含邊界的。

## 多個值（IN）

IN 用來表示值屬於某個集合。

```sql
WHERE city IN ('Taipei', 'Taichung')
```

等同於：

```sql
WHERE city = 'Taipei' OR city = 'Taichung'
```

但 IN 更簡潔。

## 模糊搜尋（LIKE）

LIKE 用來做字串模糊搜尋，% 指的是任意長度的字元。

### 開頭

```sql
WHERE name LIKE 'A%'
```

### 結尾

```sql
WHERE name LIKE '%A'
```

### 包含

```sql
WHERE name LIKE '%A%'
```

## 條件語法（AND / OR / NOT）

AND：兩個條件都要成立。

```sql
WHERE city = 'Taipei' AND age > 30
```

OR：成立一個條件即可。

```sql
WHERE city = 'Taipei' OR city = 'Taichung'
```

NOT：條件的反向（可以用 <> 取代）。

```sql
WHERE NOT city = 'Taipei'
```

```sql
WHERE city <> 'Taipei'
```

<aside>
💡

**補充：**

SQL 中 AND 的優先順序要優先於 OR，所以 **<mark><font color="#d11f1f">混用的時候要加括號</font></mark>**，以免優先順序造成條件誤判。

假設我們寫這樣：

```sql
WHERE city = 'Taipei' OR city = 'Taichung' AND age > 28
```

其實等同於：

```sql
WHERE city = 'Taipei' OR (city = 'Taichung' AND age > 28)
```

而不是我們期望的：

```sql
WHERE (city = 'Taipei' OR city = 'Taichung') AND age > 28
```

</aside>

## NULL

NULL 在 SQL 中代表：未知 / 沒有值 / 缺失值，而不是 0、空字串或 false。

他是 SQL 裡很特殊的一種狀態，並不是一個值。

**錯誤寫法：**

```sql
WHERE city = NULL
```

**正確寫法：**

```sql
WHERE city IS NULL
```

或

```sql
WHERE city IS NOT NULL
```

👉  因為 NULL 不是一般的值，所以 **<mark><font color="#d11f1f">不能用等號來作比較</font></mark>**。

---

# 實戰練習題

假設我們有以下一張 table：

**users**

| user_id | name | city | age |
| --- | --- | --- | --- |
| 1 | Alex | Taipei | 25 |
| 2 | Bob | Taichung | 30 |
| 3 | Cathy | Tainan | 28 |
| 4 | David | Taipei | 35 |
| 5 | Eric | NULL | 22 |

## 題型 1：單一條件過濾

Q：找出台北的使用者姓名？

```sql
SELECT name
FROM users
WHERE city = 'Taipei';
```

## 題型 2：數值條件

Ｑ：找出年齡大於 30 的使用者？

```sql
SELECT *
FROM users
WHERE age > 30;
```

## 題型 3：區間條件

Ｑ：找出年齡介於 25 到 30 的使用者？

```sql
SELECT *
FROM users
WHERE age BETWEEN 25 AND 30;
```

## 題型 4：多值條件

Ｑ：找出台北或台中的使用者？

```sql
SELECT *
FROM users
WHERE city IN (Taipei, Taiching);
```

或

```sql
SELECT *
FROM users
WHERE city = 'Taipei' OR city = 'Taichung';
```

## 題型 5：模糊搜尋

Ｑ：找出名字中包含字母 `a` 的使用者？

```sql
SELECT *
FROM users
WHERE name LIKE '%a%';
```

## 題型 6：複合條件

Ｑ：找出台北且年齡大於 30 的使用者？

```sql
SELECT *
FROM users
WHERE city = 'Taipei' AND age > 30;
```

## 題型 7：NULL 處理

Ｑ：找出 city 沒填的使用者？

```sql
SELECT *
FROM users
WHERE city IS NULL;
```

👉  考點：要用 IS NULL，不可以用 = NULL。

## 題型 8：AND / OR 混用

Ｑ：找出「住在台北或台中」而且「年齡大於 25」的使用者？

```sql
SELECT *
FROM users
WHERE (city = 'Taipei' OR city = 'Taichung') AND (age > 25);
```

👉  考點：AND / OR 混用的時候記得括號。