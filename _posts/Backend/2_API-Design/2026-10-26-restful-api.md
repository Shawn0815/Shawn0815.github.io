---
title: "[Backend]  RESTful API"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "API Design"]
tags: []
order: "000002_api-design/000002.000001_restful-api.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/2_API-Design/2.1_RESTful-API.md
render_with_liquid: false
---

## Abstract

四個工程師寫「查詢商品」可能寫出 `GET /products`、`GET /getProducts`、`POST /queryProducts`、`POST /searchProductList`，全部都能用，問題是每個人的設計方式都不一樣。
REST 是一套 API 設計理念，核心是圍繞 Resource 而不是 Action：URL 表示操作哪個資源，HTTP Method 表示怎麼操作。
它適合 CRUD 類型的 API；即時通訊、複雜查詢、動作導向的操作就不一定適合。

---

## API、REST、RESTful API

- API：程式之間溝通的介面（前端呼叫後端、App 呼叫後端、後端呼叫後端）。
- REST：設計 API 的理念（Architectural Style），不是技術。
- RESTful API：照 REST 理念設計出來的 API。

REST 解決的不是「API 能不能用」，而是「API 怎麼設計才一致、好懂、好維護」。

---

## 圍繞 Resource 設計

商品、訂單、使用者都是 Resource，URL 只描述資源：

```txt
不好：/getProducts、/createOrder、/deleteUser
好：  /products、/orders、/users
```

要做什麼交給 HTTP Method：

```txt
GET    /products      查詢商品
POST   /products      新增商品
PATCH  /products/1    修改商品
DELETE /products/1    刪除商品
```

大家都照同一套方式設計，看到 URL 就大概知道用途，不用每個 API 重新學。

### 設計步驟

1. 找出系統有哪些 Resource（Product、Order、User）。
2. 用 URL 表示 Resource，不把動作寫進 URL。
3. 操作交給 HTTP Method。
4. 整套 API 的命名方式保持一致。

---

## 重要特性

| 特性 | 意思 | 好處 |
|---|---|---|
| Stateless | Server 不保存 Client 狀態，每個 request 都帶完整資訊 | 降低耦合，容易水平擴充、做 Load Balancing |
| Uniform Interface | 所有 API 遵守一致的設計方式 | 新人看到 API 就懂用途 |
| Client-Server | Client 負責畫面，Server 負責邏輯和資料 | 分工明確，各自開發維護 |

另外還有 Cacheable、Layered System 等原則，目的都是讓 API 容易擴充、容易維護。

---

## 優點與限制

優點都來自「一致」：容易理解、容易維護、前後端和第三方有共同語言、大型系統容易擴充。

REST 以操作 Resource 為核心，最適合 CRUD，下面這些情境就不一定適合：

- 即時通訊：Request / Response 模式，Server 不能主動推送。
- 複雜查詢：不同 Client 要不同資料時，固定的 Response 格式不夠彈性。
- 動作導向的操作：登入、付款、AI 推論比較像執行一個動作，不是操作某個資源。

重點不是所有 API 都要 REST，而是知道什麼情況適合用它。
