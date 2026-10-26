---
title: "[Database]  SQL 基本查詢"
date: 2026-10-26 18:46 +0800
categories: ["Database", "SQL"]
tags: []
order: "000003_sql/000003.000001_query-basics.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/3_SQL/3.1_Query-Basics.md
render_with_liquid: false
---

## Abstract

`SELECT` 查詢最基本的寫法和容易寫錯的地方：`WHERE` 條件、`NULL` 判斷、Alias、`DISTINCT`、`ORDER BY` / `LIMIT`、`UNION`。
理解查詢可以先記一句話：`FROM` 決定資料來源，`WHERE` 決定要哪些列，`SELECT` 決定要看哪些欄位。

範例在本機 `sqlite3 3.54.0` 跑過，`-- →` 後面是實際輸出。

---

## 執行順序

SQL 的寫法是 `SELECT` 在最前面，但邏輯上的執行順序是：

```txt
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT / OFFSET
```

很多規則都是從這個順序推出來的，例如 `WHERE` 不能用 `SELECT` 才產生的 alias，但 `ORDER BY` 可以。

---

## WHERE

`WHERE` 從資料來源中留下符合條件的列，沒寫就是全部。

```sql
WHERE name = 'Amy'                     -- 等於
WHERE name <> 'Amy'                    -- 不等於（標準寫法，很多資料庫也接受 !=）
WHERE age > 25                         -- 數字、日期、時間都能比
WHERE age BETWEEN 10 AND 25            -- 包含頭尾，等於 age >= 10 AND age <= 25
WHERE name IN ('Amy', 'Bob', 'Shawn')  -- 屬於某個集合，比一長串 OR 清楚
WHERE name LIKE 'A%'                   -- % 任意長度，_ 一個字元
```

### AND 比 OR 先算

```sql
SELECT name FROM users WHERE name = 'Amy' OR name = 'Bob' AND id >= 3;
-- → Amy
```

實際上被當成 `name = 'Amy' OR (name = 'Bob' AND id >= 3)`，Bob 的 id 是 2，所以只剩 Amy。
==AND 和 OR 混用時一律自己加括號。==

---

## NULL

`NULL` 是「未知、沒有值」，不是字串 `'NULL'`、不是 `0`、也不是空字串。

SQL 對 `NULL` 用三值邏輯（TRUE、FALSE、UNKNOWN），任何值跟 `NULL` 用 `=` 比較都是 UNKNOWN，不會被 `WHERE` 留下來：

```sql
SELECT COUNT(*) FROM users WHERE email = NULL;
-- → 0

SELECT COUNT(*) FROM users WHERE email IS NULL;
-- → 1
```

**判斷 NULL 一定要用 `IS NULL` / `IS NOT NULL`。**
常見用法：找出沒填的資料、過濾掉沒填的資料、找出流程還沒完成的資料（例如 `WHERE paid_at IS NULL` 找未付款訂單）。

---

## Alias

幫欄位或表取別名，讓計算欄位有名字、讓 `JOIN` 時欄位來源清楚。

```sql
SELECT price * quantity AS total_price     -- Column Alias
FROM order_items;

SELECT u.name, o.id                        -- Table Alias
FROM users AS u
JOIN orders AS o ON u.id = o.user_id;
```

照執行順序，`WHERE` 比 `SELECT` 先執行，所以 `WHERE` 不能用 Column Alias，`ORDER BY` 可以：

```sql
SELECT price * 2 AS double_price FROM products WHERE double_price > 200;  -- MySQL、PostgreSQL 會報錯
SELECT price * 2 AS double_price FROM products WHERE price * 2 > 200;     -- 正確
SELECT price * 2 AS double_price FROM products ORDER BY double_price DESC; -- 可以
```

SQLite 比較寬鬆，第一句也會執行成功，==不要因為在 SQLite 試過可以就以為其他資料庫也行==。

---

## SELECT 欄位與 DISTINCT

正式的查詢（API、效能敏感的地方）列出需要的欄位，不要用 `SELECT *`：

- 回傳的資料量比較小，也不會不小心查出敏感欄位。
- 只查需要的欄位時，有機會用 covering index。
- Schema 改了，回傳欄位不會跟著變。
- `JOIN` 時不會有一堆同名欄位。

`SELECT *` 留給 debug 和臨時查資料用。

`DISTINCT` 去除重複的結果，==判斷重複看的是 SELECT 出來的所有欄位組合，不是只看第一個欄位==：

```txt
name | age          SELECT DISTINCT name, age  →  Amy | 20
Amy  | 20                                         Amy | 25
Amy  | 25
Amy  | 20
```

`(Amy, 20)` 和 `(Amy, 25)` 是不同組合，都會留下。

---

## ORDER BY / LIMIT

```sql
SELECT name, price
FROM products
WHERE category = 'book'
ORDER BY price DESC     -- 沒寫方向時預設 ASC（小到大）
LIMIT 10;
```

常用在取前 N 名、最新幾筆、最高／最低、分頁。

要注意三件事：

1. **沒有 `ORDER BY` 的 `LIMIT` 不保證拿到哪幾筆**，要「最新 10 筆」就一定要寫 `ORDER BY created_at DESC`。
2. 排序欄位有重複值時順序不穩定，加一個 tie-breaker：`ORDER BY created_at DESC, id DESC`。
3. `LIMIT` 只是硬取前幾筆，不會處理並列名次；要並列就用 Window Function 的 `RANK()`、`DENSE_RANK()`。

---

## UNION vs UNION ALL

把兩個查詢結果上下接起來（列變多，欄位不變）。
`JOIN` 則是左右接起來（欄位變多）。

```sql
SELECT id, name FROM students
UNION ALL
SELECT id, name FROM teachers;
```

| | 去重 | 什麼時候用 |
|---|---|---|
| `UNION` | 會，完全相同的列只留一筆 | 兩邊資料可能重疊，結果不能重複 |
| `UNION ALL` | 不會 | 允許重複、或兩邊本來就不會重疊 |

沒有去重需求時用 `UNION ALL`，省掉去重的成本。

兩邊的 `SELECT` 要：

- 欄位數量相同。
- 對應欄位的型別相容。
- **欄位順序的意義一致**：一邊 `id, name`、另一邊 `name, id`，數量對了也能執行，但結果是錯的。

結果的欄位名稱由第一個 `SELECT` 決定，alias 要寫在第一個。
