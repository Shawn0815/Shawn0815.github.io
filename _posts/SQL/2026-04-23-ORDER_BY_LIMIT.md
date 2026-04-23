---
layout: post
title: SQL ORDER BY / LIMIT 語法
date: 2026-04-23 10:51 +0800
author: shawn_yu
categories: [SQL]
tags: [SQL, ORDER BY, LIMIT]
image: {path: "assets/img/2026-04-23-MySQL.png"}
math: true
---

# ORDER BY / LIMIT 定義

用來先把查出來的結果做排序，再取出前幾筆資料。

- 最大 / 最小
- 最新 / 最早
- Top N

👉  重點：LIMIT 一定要搭配 ORDER BY 語法，否則不具商業意義。

---

# ORDER BY

將資料做排序，決定 **<mark><font color="#d11f1f">取出的結果以什麼順序呈現</font></mark>**。

## 舉例

將商品以價格升序做排序。

**products**

| product_id | product_name | category | price |
| --- | --- | --- | --- |
| 10 | SQL Book | Book | 300 |
| 11 | Java Book | Book | 400 |
| 12 | Mouse | Device | 500 |
| 13 | Keyboard | Device | 1000 |

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC;
```

**Output:**

| product_id | product_name | category | price |
| --- | --- | --- | --- |
| 13 | Keyboard | Device | 1000 |
| 12 | Mouse | Device | 500 |
| 11 | Java Book | Book | 400 |
| 10 | SQL Book | Book | 300 |

👉  ORDER BY 不會改變資料本身，只是改變順序。

## ASC / DESC

這個語法會接在排序的欄位後面，決定排序的方向。

### **ASC**

- ASC = ascending，將資料由小到大排序。
- 適用情境：最小 / 最便宜 / 最早。

### **DESC**

- DESC = descending，將資料由大到小排序。
- 適用情境：最大 / 最貴 / 最新 / 最高。

## 多欄排序

多欄排序決定的是：**<mark><font color="#d11f1f">先用第一個欄位排序，若第一欄相同，再用第二欄做排序</font></mark>**。

**orders:**

| order_id | user_id | total_amount | status | created_at |
| --- | --- | --- | --- | --- |
| 101 | 1 | 1000 | paid | 2025-01-01 |
| 102 | 1 | 500 | pending | 2025-01-02 |
| 103 | 2 | 800 | paid | 2025-01-03 |
| 104 | 4 | 300 | paid | 2025-01-04 |
| 105 | 2 | 1200 | pending | 2025-01-01 |

```sql
SELECT order_id, status, created_at
FROM orders
ORDER BY status ASC, created_at DESC;
```

**Output:**

| order_id | user_id | total_amount | status | created_at |
| --- | --- | --- | --- | --- |
| 104 | 4 | 300 | paid | 2025-01-04 |
| 103 | 2 | 800 | paid | 2025-01-03 |
| 101 | 1 | 1000 | paid | 2025-01-01 |
| 102 | 1 | 500 | pending | 2025-01-02 |
| 105 | 2 | 1200 | pending | 2025-01-01 |

👉  先用 `status` 欄位排序，若相同，再用 `created_at` 做排序。

---

# LIMIT

LIMIT 的定義是，決定好資料以及順序後，**<mark><font color="#d11f1f">決定最後要取出幾筆資料</font></mark>**。

例如：只取 products table 的前兩筆資料。

```sql
SELECT *
FROM products
LIMIT 2;
```

## LIMIT 本身不具商業意義

LIMIT 只說明要取前幾筆資料，假設今天希望：

- 取最大的幾筆
- 取最新的幾筆
- 取最便宜的幾筆

👉  這些需要靠 ORDER BY 才能完成。

## 常見用途

**orders:**

| order_id | user_id | total_amount | status | created_at |
| --- | --- | --- | --- | --- |
| 101 | 1 | 1000 | paid | 2025-01-01 |
| 102 | 1 | 500 | pending | 2025-01-02 |
| 103 | 2 | 800 | paid | 2025-01-03 |
| 104 | 4 | 300 | paid | 2025-01-04 |
| 105 | 2 | 1200 | pending | 2025-01-01 |

### 1. Top 1 題型

Ｑ：取出最新的訂單？

```sql
SELECT *
FROM orders
ORDER BY created_at DESC
LIMIT 1;
```

Ｑ：取出訂單金額最高的訂單？

```sql
SELECT *
FROM orders
ORDER BY total_amount DESC
LIMIT 1;
```

### 2. Top N 題型

Ｑ：取出最舊的兩筆訂單？

```sql
SELECT *
FROM orders
ORDER BY created_at ASC
LIMIT 2;
```

Ｑ：取出訂單金額最小的三筆訂單？

```sql
SELECT *
FROM orders
ORDER BY total_amount ASC
LIMIT 3;
```

思考順序：

1. 比較的是哪一個欄位？（price / created_at / total_amount）
2. 大的在前面還是小的在前面？（DESC / ASC）
3. 總共要取幾筆？（LIMIT 要填多少）

### 3. Pagination

假設前端限定每頁只能顯示 20 筆商品資料，就需要使用到 LIMIT。

至於有沒有需要排序則需看狀況。

```sql
SELECT *
FROM products
LIMIT 20;
```

---

# 實戰練習題

**products**

| product_id | product_name | category | price |
| --- | --- | --- | --- |
| 10 | SQL Book | Book | 300 |
| 11 | Java Book | Book | 400 |
| 12 | Mouse | Device | 500 |
| 13 | Keyboard | Device | 1000 |
| 14 | Monitor | Device | 4500 |

**orders**

| order_id | user_id | total_amount | status | created_at |
| --- | --- | --- | --- | --- |
| 101 | 1 | 1000 | paid | 2025-01-01 |
| 102 | 1 | 500 | pending | 2025-01-02 |
| 103 | 2 | 800 | paid | 2025-01-03 |
| 104 | 4 | 300 | paid | 2025-01-04 |
| 105 | 2 | 1200 | pending | 2025-01-01 |

## **題型 1：基本排序**

Ｑ：列出所有商品名稱與價格，並依價格由小到大排序？

```sql
SELECT product_name, price
FROM products
ORDER BY price ASC;
```

Ｑ：列出所有商品名稱與價格，並依價格由大到小排序？

```sql
SELECT product_name, price
FROM products
ORDER BY price DESC;
```

## **題型 2：只取前幾筆**

Ｑ：列出前 3 筆商品資料？

```sql
SELECT *
FROM products
LIMIT 3;
```

👉  題目沒有指定順序，可能是用在 pagination 場景，單純取前三筆即可。

## **題型 3：Top 1 題型**

Ｑ：找出最貴的商品？

```sql
SELECT *
FROM products
ORDER BY price DESC
LIMIT 1;
```

Ｑ：找出最新的一筆訂單？

```sql
SELECT *
FROM orders
ORDER BY created_at DESC
LIMIT 1;
```

## **題型 5：Top N 題型**

Ｑ：找出最貴的前 2 個商品？

```sql
SELECT *
FROM products
ORDER BY price DESC
LIMIT 2;
```

Ｑ：找出最早的兩筆訂單？

```sql
SELECT *
FROM orders
ORDER BY created_at ASC
LIMIT 2;
```

## **題型 6：多欄排序**

Ｑ：列出所有訂單，先依 status 排序；同 status 內再依 created_at 由新到舊排序？

```sql
SELECT *
FROM orders
ORDER BY status ASC, created_at DESC;
```

## **題型 7：WHERE + ORDER BY + LIMIT**

Ｑ：找出已付款訂單中最新的 2 筆？

```sql
SELECT *
FROM orders
WHERE status = 'paid'
ORDER BY created_at DESC
LIMIT 2;
```

---

# 補充：Performance 問題

1. 大量資料做排序時，成本可能很高，需要搭配 index。
2. ORDER BY + LIMIT 是後端常用的查詢模式，所以排序欄位常常會用來當作 index，提高查詢效率。
3. 不寫 ORDER BY 的 LIMIT，通常不具穩定的商業意義。