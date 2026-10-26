---
title: "[Backend]  DTO vs Entity"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "API Design"]
tags: []
order: "000002_api-design/000002.000004_dto-vs-entity.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/2_API-Design/2.4_DTO-vs-Entity.md
render_with_liquid: false
---

## Abstract

Entity 描述資料怎麼存（對應資料表），DTO 描述資料怎麼傳（API 的格式）：Entity 對內，DTO 對外。
不直接回傳 Entity，是為了避免洩漏內部欄位、避免 API 跟資料庫結構綁死，並依每支 API 的需求裁切欄位。
轉換發生在 API 邊界附近：Controller 對外收送 DTO，Service 和 Repository 內部用 Entity。

---

## 差別

User Entity 可能有 `id`、`email`、`passwordHash`、`createdAt`、`updatedAt`。
登入成功的 Response DTO 只需要 `userId`、`email`、`token`，不需要 `passwordHash`。

---

## 為什麼不直接回傳 Entity

- 洩漏內部資料：`passwordHash`、內部狀態欄位、不該對外的關聯資料都會被回傳。
- API 跟資料庫綁死：資料庫欄位改名、拆分、新增，前端就跟著壞。DTO 把資料庫結構和 API 合約拆開，各自演進。
- 每支 API 要的欄位不同：商品列表只要 `id`、`name`、`price`，商品詳情還要 `description`、`stock`、`category`，共用 Entity 會拿太多或不夠。

==API 合約不應該等於資料庫結構。==

---

## Request DTO 與 Response DTO

| | 方向 | 例子 |
|---|---|---|
| Request DTO | 前端送進來 | 建立商品：`productName`、`category`、`price`、`stock`，搭配必填、格式、範圍驗證 |
| Response DTO | 後端回出去 | `productId`、`productName`、`price`、`createdAt` |

兩者不一定一樣，前端要送的資料和要顯示的資料本來就不同。

---

## 在哪裡轉換

```txt
Controller 接收 Request DTO
→ Service 操作 Entity
→ 回傳前轉成 Response DTO
→ Controller 回給前端
```

Entity 盡量不要流出 API 邊界。
轉換放在 Service，或另外寫 Mapper / Converter，責任清楚就好。

很小的 demo、欄位很少又沒有敏感資料時，有人會直接回 Entity；正式的系統（例如電商）還是建議分開。
