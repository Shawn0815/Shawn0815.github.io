---
title: "[Backend]  API 參數與回應格式"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "API Design"]
tags: []
order: "000002_api-design/000002.000003_api-parameters.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/2_API-Design/2.3_API-Parameters.md
render_with_liquid: false
---

## Abstract

設計一支實際的 API 時要決定：參數放 Path 還是 Query、Response 長什麼樣子、分頁篩選排序的參數怎麼命名。
判斷 Path 或 Query 看「少了這個參數，API 還有沒有意義」。
最重要的原則是整個專案一致，排序欄位一定要用白名單限制。

---

## Path Param vs Query Param

```txt
GET /books/123                                          123 是這本書的識別，少了就沒有這筆資源 → Path
GET /books?category=fiction&sort=price&page=1&limit=8   都是可選，不帶也能查全部 → Query
```

- 少了這個參數 API 就沒意義（商品 ID）：Path Param。
- 少了還是有意義，只是範圍不同（篩選、排序、分頁）：Query Param。

---

## Request 與 Response

Request 要想清楚哪些欄位必填、哪些可選，格式驗證放在哪一層。
Response 要格式一致（例如都包一層 `data`），錯誤訊息的格式也要統一。

列表型 API 常見的 Response：

```json
{
  "data": [ ... ],
  "page": 1,
  "limit": 8,
  "total": 120
}
```

總筆數和目前頁數由後端回傳，前端不用自己推算。

---

## 分頁、篩選、排序

### 分頁

```txt
?page=1&limit=8                   Offset-based，page 對使用者比較直觀
?offset=0&limit=8                 Offset-based
?cursor=eyJpZCI6MTIzfQ&limit=8    Cursor-based，也常叫 after
```

### 篩選

直接用欄位名當參數：`?category=fiction&author=Shawn`。

範圍篩選常見兩種寫法：

```txt
?minPrice=100&maxPrice=500
?price[gte]=100&price[lte]=500
```

用哪種都可以，==同一支 API 裡的篩選參數命名要一致==。

### 排序

```txt
?sort=price&order=asc
?sort=-price                  - 前綴代表降序，可以多欄位：sort=-price,createdAt
```

==排序欄位一定要用白名單或 Enum 限制==，不能把使用者傳的字串直接拼進 SQL 的 `ORDER BY`，否則會有 SQL Injection。

---

## 命名慣例

- URL 用複數名詞、不用動詞：`/books`，不是 `/getBooks`。
- 整個專案統一用 camelCase 或 snake_case，不要混用。
- 同一個概念用同一個名字：一支 API 叫 `category`，別支就不要叫 `categoryId` 或 `cat`。
