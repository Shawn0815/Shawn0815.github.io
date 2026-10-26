---
title: "[Database]  Slow Query 分析"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Query Optimization"]
tags: []
order: "000004_query-optimization/000004.000002_slow-query-analysis.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/4_Query-Optimization/4.2_Slow-Query-Analysis.md
render_with_liquid: false
---

## Abstract

網站變慢時，不要第一個反應就加 Index、加 Cache、加 Replica，因為還不知道慢在哪。
先確認瓶頸是不是在資料庫，再用 `EXPLAIN` 看資料庫怎麼執行這個查詢，找到原因後才選優化方式。

查詢計畫範例在本機 `sqlite3 3.54.0` 跑過；MySQL、PostgreSQL 的 `EXPLAIN` 欄位不同，但要看的重點一樣。

---

## 先確認是不是資料庫慢

API 回應 5 秒，原因可能是：

- 資料庫查詢慢。
- 外部 API 慢。
- N+1 Query（迴圈裡一筆一筆查）。
- 回傳的資料太大，序列化 JSON 太久。

量過之後確定「5 秒裡有 4.8 秒是 SQL」，才進入下面的分析。

---

## EXPLAIN

`EXPLAIN` 不回傳查詢結果，而是回傳資料庫打算怎麼執行：

- 有沒有用 index、用哪一個。
- 大概要掃多少資料。
- 需不需要額外排序。

```sql
EXPLAIN QUERY PLAN SELECT * FROM orders WHERE user_id = 123;
-- → SCAN orders                       全表掃描

EXPLAIN QUERY PLAN SELECT * FROM orders ORDER BY amount DESC;
-- → SCAN orders
-- → USE TEMP B-TREE FOR ORDER BY      額外排序
```

MySQL 的 `EXPLAIN` 常看這幾個欄位：

| 欄位 | 看什麼 |
|---|---|
| `type` | 存取方式，`ALL` 是全表掃描 |
| `possible_keys` / `key` | 可以用、實際用了哪個 index |
| `rows` | 預估要掃幾筆 |
| `Extra` | `Using filesort`（額外排序）、`Using temporary`（暫存表）等 |

---

## 常見瓶頸

| 瓶頸 | 為什麼慢 | 常見解法 |
|---|---|---|
| Full Table Scan | 條件欄位沒有 index，從第一筆看到最後一筆；1 億筆時非常慢 | 建 index、改善條件、縮小範圍 |
| `JOIN` | 兩邊資料量大；`JOIN` Key 沒有 index；一對多造成 JOIN Explosion | `JOIN` Key 建 index、先縮小資料再接 |
| `GROUP BY` | 要讀完所有資料、分組、計算，幾千萬筆以上特別明顯 | 適合的 index、Summary Table、預先計算 |
| `ORDER BY` | 先找出資料再整批排序 | 排序欄位建 index，直接用 index 的順序 |
| 結果集太大 | 查了不需要的大欄位（`description`、`content`），讀取、傳輸、記憶體都浪費 | 只 `SELECT` 需要的欄位、分頁 |

---

## 分析流程

1. 確認慢的是 SQL，不是外部 API 或序列化。
2. 跑 `EXPLAIN`。
3. 有沒有 Full Table Scan？有沒有用到 index？
4. `JOIN`、`GROUP BY`、`ORDER BY` 是否太重？
5. 結果集是否太大？
6. 找到真正的瓶頸，再選 index、改寫查詢、分頁或 Summary Table。
