---
title: "[Database]  模糊搜尋與全文檢索"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Query Optimization"]
tags: []
order: "000004_query-optimization/000004.000004_full-text-search.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/4_Query-Optimization/4.4_Full-Text-Search.md
render_with_liquid: false
---

## Abstract

關鍵字搜尋最直覺的寫法是 `LIKE '%關鍵字%'`，但它前後都不固定，用不到一般 index，資料量大時很慢，也沒辦法依相關性排序。
全文檢索用 Inverted Index 解決這兩件事，Elasticsearch 是建在這套原理上的獨立搜尋引擎。
資料量小、需求單純就用 `LIKE`，資料量大、搜尋體驗是產品重點時才導入 Elasticsearch。

---

## LIKE

`=` 只能比完全相同的字串，`LIKE` 可以用萬用字元比對模式：

- `%`：任意長度（可以是 0 個字元）。
- `_`：剛好一個字元。

| 寫法 | 意思 | 能不能用一般 index |
|---|---|---|
| `LIKE 'A%'` | 開頭是 A | 可以，開頭固定能轉成範圍查詢 |
| `LIKE '%A'` | 結尾是 A | 不行，開頭不固定 |
| `LIKE '%A%'` | 包含 A | 不行，幾乎一定全表掃描 |

關鍵字搜尋最常用的正好是 `%A%`。
它有兩個限制：

- 全表掃描的成本隨資料量線性增加。
- 只能判斷「有沒有比對到」，不能判斷「多相關」：書名完全符合的，和剛好包含這幾個字的，排序上沒有差別。

---

## Inverted Index

一般的查詢是一筆一筆檢查內容裡有沒有關鍵字。
全文檢索反過來：先把每篇文字斷詞（Tokenize），建一張「詞 → 哪些文件有這個詞」的對照表。

```txt
「程式」 → 文件 1, 文件 5, 文件 9
「設計」 → 文件 1, 文件 3
```

搜尋「程式設計」時直接查表，不用一筆一筆比對，這是它比 `LIKE` 快的原因。

### 相關性分數

全文檢索還會幫每筆結果算相關性分數（Relevance Score），常見的演算法是 TF-IDF 和 BM25，概念上：

- 關鍵字在這份文件出現越多次，分數越高。
- 關鍵字越稀有（大部分文件都沒有），包含它的文件分數越高。

所以結果可以依相關性排序，這是 `LIKE` 做不到的。

---

## Elasticsearch

Elasticsearch 是用 Inverted Index 實作的獨立搜尋引擎。
跟資料庫內建的全文檢索（例如 MySQL 的 `FULLTEXT INDEX`）比：

- 斷詞、相關性計分、模糊比對的功能更強，可以調整的空間也大。
- 原生支援分散式，適合大量資料。
- 但要另外維護一套 search cluster，資料也要從主資料庫同步過去，架構和維運成本變高。

### 什麼時候導入

- 資料量小、需求單純：`LIKE` 或資料庫內建的全文檢索就夠。
- 資料量大、需要相關性排序、搜尋體驗是產品重點：導入 Elasticsearch。

書店電商專案的商品數量不多，目前用 `LIKE`；之後要做「依相關性排序搜尋結果」時，才考慮 Elasticsearch。
