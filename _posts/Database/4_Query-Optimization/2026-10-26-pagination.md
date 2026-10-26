---
title: "[Database]  Pagination"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Query Optimization"]
tags: []
order: "000004_query-optimization/000004.000003_pagination.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/4_Query-Optimization/4.3_Pagination.md
render_with_liquid: false
---

## Abstract

資料量大時不一次查全部，而是切成多頁、每次只查一小段，減輕資料庫、後端和前端的負擔。
分頁一定要搭配穩定的排序。
`LIMIT` / `OFFSET` 簡單、可以跳頁，但 `OFFSET` 越大越慢；Cursor（Keyset）Pagination 深頁效能穩定，但不能任意跳頁。

---

## 穩定排序

沒有 `ORDER BY` 時，資料庫不保證每次回傳的順序一樣，同一筆可能出現在兩頁，有些會被跳過。
排序欄位有重複值（同一個上架時間）時，最後再加一個唯一欄位當 tie-breaker：

```sql
ORDER BY published_date DESC, book_id DESC
```

---

## LIMIT / OFFSET

```sql
SELECT * FROM books
ORDER BY published_date DESC, book_id DESC
LIMIT 20 OFFSET 40;    -- 第 3 頁：OFFSET = (page - 1) * page_size
```

- 優點：簡單，可以直接跳到第幾頁，適合後台管理列表。
- 缺點：
  - **`OFFSET` 越大越慢**：資料庫不是直接跳到第 100001 筆，而是找出前面全部的資料再丟掉。
  - 翻頁時有新資料插入，會造成重複或漏掉。

---

## Cursor / Keyset Pagination

不用頁碼，而是記住上一頁最後一筆，下一頁從它後面接著查。
上一頁最後一筆是 `published_date = 2026-05-01, book_id = 100`：

```sql
SELECT * FROM books
WHERE (published_date < '2026-05-01')
   OR (published_date = '2026-05-01' AND book_id < 100)
ORDER BY published_date DESC, book_id DESC
LIMIT 20;
```

排序欄位有 index 時，資料庫直接定位到 cursor 附近往下讀，不用跳過前面的資料。

- 優點：深頁效能穩定；新增資料時不容易重複或漏；適合無限捲動。
- 缺點：不能直接跳到任意頁；前端要保存 cursor；SQL 條件比較複雜。

---

## 怎麼選

| | Offset | Cursor / Keyset |
|---|---|---|
| 做法 | 跳過 N 筆再取 | 從上一筆之後繼續取 |
| 優點 | 簡單、可跳頁 | 深頁效能穩定 |
| 缺點 | `OFFSET` 大時變慢 | 不能跳頁 |
| 適合 | 資料量小、需要跳頁（後台列表） | 資料量大、只往下捲（Feed、無限捲動） |

電商專案的商品列表目前用 `LIMIT` / `OFFSET`，資料量不大又要跳頁。
資料量變大、或改成捲動載入時，改用 `(published_date, book_id)` 當 cursor；訂單歷史則可以用 `(created_date, order_id)`。
