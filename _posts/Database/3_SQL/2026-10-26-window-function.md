---
title: "[Database]  Window Function"
date: 2026-10-26 18:46 +0800
categories: ["Database", "SQL"]
tags: []
order: "000003_sql/000003.000004_window-function.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/3_SQL/3.4_Window-Function.md
render_with_liquid: false
---

## Abstract

Window Function 在每一列旁邊加上「這一列在它那組裡的排名或統計」，但不會把多列壓成一列。
最常用在 Top K：整體 Top K 而且不在乎同分，用 `ORDER BY` + `LIMIT` 就好；要保留同分，或要找「每一組」的 Top K，就用 Window Function 排名，再篩選排名。

範例在本機 `sqlite3 3.54.0` 跑過，`-- →` 後面是實際輸出。

---

## 排名函式

scores 有 math：A 90、B 90、C 80、D 70，eng：E 95、F 85。

```sql
SELECT name, subject, score,
       ROW_NUMBER() OVER (PARTITION BY subject ORDER BY score DESC) AS row_num,
       RANK()       OVER (PARTITION BY subject ORDER BY score DESC) AS rnk,
       DENSE_RANK() OVER (PARTITION BY subject ORDER BY score DESC) AS dense
FROM scores;
-- → name  subject  score  row_num  rnk  dense
-- → E     eng         95        1    1      1
-- → F     eng         85        2    2      2
-- → A     math        90        1    1      1
-- → B     math        90        2    1      1
-- → C     math        80        3    3      2
-- → D     math        70        4    4      3
```

| 函式 | 同分 | 之後的名次 |
|---|---|---|
| `ROW_NUMBER()` | 不管同分，每列唯一序號 | 連續 |
| `RANK()` | 同分同名次 | 跳號（1, 1, 3） |
| `DENSE_RANK()` | 同分同名次 | 不跳號（1, 1, 2） |

要保留並列的名次，就不能用 `ROW_NUMBER()`。

---

## PARTITION BY vs GROUP BY

`PARTITION BY` 讓每一組各自從第 1 名開始排，上面每個科目各排各的。

- `GROUP BY`：多列壓成一列（一個科目只剩一列平均分數）。
- `PARTITION BY`：每一列都還在，只是旁邊多了組內的排名或統計。

---

## 篩選排名要包一層

照執行順序，`WHERE` 在 `SELECT` 之前執行，那時排名還沒算出來，不能直接篩：

```sql
SELECT name, RANK() OVER (ORDER BY score DESC) AS r FROM scores WHERE r <= 2;
-- → Parse error: misuse of aliased window function r
```

用 CTE（`WITH`）或子查詢先算排名，外層再篩：

```sql
WITH ranked AS (
    SELECT name, subject, score,
           RANK() OVER (PARTITION BY subject ORDER BY score DESC) AS rnk
    FROM scores
)
SELECT name, subject, score
FROM ranked
WHERE rnk <= 3;
```

CTE 就是先幫子查詢取一個名字，寫在最前面，讀起來比巢狀的子查詢清楚。
