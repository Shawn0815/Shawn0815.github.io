---
title: "[Database]  Aggregation"
date: 2026-10-26 18:46 +0800
categories: ["Database", "SQL"]
tags: []
order: "000003_sql/000003.000003_aggregation.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/3_SQL/3.3_Aggregation.md
render_with_liquid: false
---

## Abstract

Aggregation 把多筆原始資料依 Group Key 分組，再用 `COUNT`、`SUM`、`AVG`、`MIN`、`MAX` 算出每組的統計。
`GROUP BY` 會改變 Row Grain：原本一列是一張訂單，`GROUP BY user_id` 後一列是一位使用者的訂單統計。
容易出錯的地方是 `NULL` 的處理、`WHERE` 和 `HAVING` 的分工，以及 `JOIN` 之後的 Double Count。

範例在本機 `sqlite3 3.54.0` 跑過，`-- →` 後面是實際輸出。
範例資料：orders 有 Amy（user 1）的 101 paid 500、102 pending 300，Bob（user 2）的 103 paid 800；users 還有沒訂單的 Cindy、Dan。

---

## GROUP BY

把 Group Key 相同的列放進同一組，結果一組一列。

```sql
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category;
```

`GROUP BY` 的欄位越多，Group Key 越細：`GROUP BY category` 一列是一個分類，`GROUP BY category, status` 一列是一個「分類 + 狀態」的組合。

題目裡的「每個」通常就是 Group Key：每位使用者 → `GROUP BY user_id`，每個分類 → `GROUP BY category`。

### SELECT 只能放 Group Key 和統計結果

```sql
SELECT category, name, COUNT(*)   -- name 不合理
FROM products
GROUP BY category;
```

一個分類有很多商品，分組後一列只代表一個分類，資料庫不知道要顯示哪一個 `name`。
==不是 Group Key 的欄位要包在 Aggregate Function 裡。==
有些資料庫設定允許這樣寫，但會隨便挑一個值，不要依賴。

---

## Aggregate Function

| 函式 | 算什麼 | 例子 |
|---|---|---|
| `COUNT` | 筆數 | 每個分類幾個商品 |
| `SUM` | 總和 | 總營收 |
| `AVG` | 平均 | 平均評分 |
| `MIN` / `MAX` | 最小／最大，日期也可以 | 第一筆、最新一筆訂單時間 |

### COUNT 的三種寫法

users 有 4 列，email 分別是 `amy@example.com`、`NULL`、`bob@example.com`、`bob@example.com`：

```sql
SELECT COUNT(*), COUNT(email), COUNT(DISTINCT email) FROM users;
-- → 4   3   2
```

- `COUNT(*)`：算列數。
- `COUNT(column)`：只算該欄位不是 `NULL` 的列。
- `COUNT(DISTINCT column)`：不是 `NULL` 而且不重複的值。

### NULL 不是 0

`SUM`、`AVG`、`MIN`、`MAX` 會忽略 `NULL`。
`amount` 是 100、`NULL`、200 時，`AVG(amount)` 是 (100 + 200) / 2 = 150，不是除以 3。

整組都沒有值時 `SUM` 回傳 `NULL`，要顯示 0 就用 `COALESCE(SUM(amount), 0)`（回傳第一個不是 `NULL` 的值）。

---

## WHERE vs HAVING

- `WHERE`：過濾原始的列，條件描述單筆資料。
- `HAVING`：過濾分組後的組，條件描述統計結果。

```sql
SELECT user_id, SUM(amount) AS total
FROM orders
GROUP BY user_id
HAVING SUM(amount) > 500;
-- → 1   800
-- → 2   800
```

`WHERE SUM(amount) > 500` 是錯的：執行 `WHERE` 時還沒分組，`SUM` 還不存在。

有些資料庫允許 `HAVING` 用 SELECT 的 alias，要跨資料庫就直接寫 `HAVING SUM(amount) > 500`。

### DISTINCT vs GROUP BY

- 只要不重複的值（有哪些分類）：`SELECT DISTINCT category`。
- 要分組統計（每個分類幾個商品）：`GROUP BY category` + `COUNT(*)`。

---

## JOIN 之後再統計

`JOIN` 一對多會把主表的資料展開，主表層級的值在統計時會被重複計算：

```sql
SELECT o.id, SUM(o.amount) AS total_amount, SUM(oi.quantity) AS qty
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id;
-- → 101   1000   3
```

101 有兩筆 Order Item，`amount = 500` 被展開成兩列，加起來變 1000。
`SUM` 沒算錯，錯在 `amount` 是訂單粒度，`JOIN` 後變成了 Order Item 粒度。

**不能用 `SUM(DISTINCT amount)` 修**：它去掉的是相同的數值，兩張不同訂單剛好都是 500 時只會加一次。

### 先 Aggregate，再 JOIN

先把細表整理成跟主表一樣的粒度，再接回主表：

```sql
SELECT o.id, o.amount, COALESCE(oi.qty, 0) AS qty
FROM orders o
LEFT JOIN (
    SELECT order_id, SUM(quantity) AS qty
    FROM order_items
    GROUP BY order_id
) oi ON o.id = oi.order_id;
-- → 101   500   3
-- → 102   300   0
-- → 103   800   0
```

子查詢的結果一列就是一張訂單，`JOIN` 後不會展開。

### LEFT JOIN + COUNT 要數右表的欄位

所有使用者的訂單數，包含沒有訂單的人：

```sql
SELECT u.name, COUNT(*) AS count_star, COUNT(o.id) AS count_id,
       SUM(o.amount) AS sum_amt, COALESCE(SUM(o.amount), 0) AS sum0
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;
-- → Amy     2   2   800   800
-- → Bob     1   1   800   800
-- → Cindy   1   0         0
-- → Dan     1   0         0
```

`LEFT JOIN` 沒配對時左表仍有一列，**`COUNT(*)` 會把這列算成 1**，要用 `COUNT(o.id)`。
`SUM` 沒資料時是 `NULL`，用 `COALESCE` 轉成 0。

---

## CASE WHEN：條件統計

`CASE WHEN` 是 SQL 的 if / else，搭配 Aggregate Function 可以在一次查詢裡算多種條件的統計：先把每列轉成要統計的值，再對每組加總。

```sql
SELECT user_id,
       SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END) AS paid_amount,
       COUNT(CASE WHEN status = 'paid' THEN 1 END) AS paid_cnt
FROM orders
GROUP BY user_id;
-- → 1   500   1
-- → 2   800   1
```

條件計數有兩種寫法：

- `SUM(CASE WHEN 條件 THEN 1 ELSE 0 END)`：符合的轉成 1，再加總。
- `COUNT(CASE WHEN 條件 THEN 1 END)`：不符合時 `CASE` 回傳 `NULL`，`COUNT` 不算。

---

## 寫 Aggregation 的步驟

1. 確認來源表的一列代表什麼。
2. 從題目的「每個」找出 Group Key，決定結果的一列代表什麼。
3. 選 Aggregate Function：幾筆用 `COUNT`、總和用 `SUM`、平均用 `AVG`、最大最小用 `MAX` / `MIN`。
4. 單筆條件放 `WHERE`，統計結果的條件放 `HAVING`。
5. 有 `JOIN` 就重新確認 Row Grain，會展開就先 Aggregate 再 `JOIN`。
6. 確認 `NULL`：要 `COUNT(*)` 還是 `COUNT(column)`，`SUM` 要不要 `COALESCE`。
