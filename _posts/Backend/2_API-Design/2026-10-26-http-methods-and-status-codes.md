---
title: "[Backend]  HTTP Method 與 Status Code"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "API Design"]
tags: []
order: "000002_api-design/000002.000002_http-methods-and-status-codes.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/2_API-Design/2.2_HTTP-Methods-and-Status-Codes.md
render_with_liquid: false
---

## Abstract

HTTP API 要說清楚兩件事：Client 想做什麼（Method），Server 處理完的結果是什麼（Status Code）。
Method 不只是功能名稱，還帶有 Safe（會不會改資料）和 Idempotent（重送會不會出事）的語意，Browser、Cache、Proxy、Crawler 都依賴這些語意運作。
選錯 Method 或亂回 Status Code，程式可能還能跑，但 API 的行為會變得難以預期。

---

## Method 的語意

URL 表示 Resource，Method 表示怎麼操作它。
`GET /products` 不只代表「我要查商品」，也代表「這次只讀資料，不會改任何東西」，所以 Browser 才敢 Cache、Crawler 才敢爬、Proxy 才敢重送。

`GET /buy?productId=1` 送一次就買一件，程式可以跑，但語意是錯的。

### Safe 與 Idempotent

- Safe：這個 request 不應該改變業務資料狀態。寫 access log、更新 metrics 這類內部副作用可以接受。
- Idempotent：同一個 request 執行一次或多次，最後結果一樣。

Idempotent 重要是因為網路不可靠：Server 已經更新成功，但 Response 在網路上掉了，Client 不知道成功沒，只好重送。
`PUT /users/1 { "name": "Shawn" }` 送十次結果都一樣；`POST /orders` 送兩次可能變成兩張訂單。

| Method | 語意 | Safe | Idempotent |
|---|---|---|---|
| GET | 取得 Resource | 是 | 是 |
| POST | 建立 Resource 或交給 Server 處理一個操作 | 否 | 通常否 |
| PUT | 完整取代一個已知 Resource | 否 | 是 |
| PATCH | 部分更新 Resource | 否 | 看更新語意 |
| DELETE | 刪除 Resource | 否 | 是 |

---

## 各 Method 的重點

### GET

只讀資料。
**GET 絕對不能拿來刪除、付款、下單**：重新整理頁面、Crawler 爬網站、Cache 重送都可能觸發，造成非預期的副作用。

### POST

把 request 交給 Server 處理，通常產生新狀態，例如 `POST /orders`，新資料的 id 由 Server 決定。
重送可能建立多筆，所以下單、付款、註冊要特別處理重複送出，例如加 Idempotency Key。

### PUT vs PATCH

- PUT：用整份內容取代這個 Resource，是 Idempotent。
- PATCH：只改送來的欄位，例如 `PATCH /users/1 { "nickname": "Shawn" }`。

PATCH 是否 Idempotent 看更新語意：`{ "nickname": "Shawn" }` 是設定值，送幾次都一樣；`{ "increment": 100 }` 是累加，送兩次變 200。

實務上有些團隊的 PUT 也是「沒傳的欄位不動」。
不管用哪個，都要在 API 規範裡定義清楚：沒傳的欄位是清空還是保持原值、`null` 是清空還是不更新、多傳的欄位要忽略還是回錯誤。

### DELETE

第一次刪掉商品，第二次商品已經不存在、可能回 404，但 Server 的最終狀態一樣（商品不存在），所以還是 Idempotent。
第二次回 204 還是 404 是設計選擇，不影響語意。

### 怎麼選

| 操作 | Method | 例子 |
|---|---|---|
| 只讀 | GET | `GET /products/1` |
| 建立、提交操作 | POST | `POST /orders` |
| 完整更新 | PUT | `PUT /users/1` |
| 部分更新 | PATCH | `PATCH /orders/100` |
| 刪除 | DELETE | `DELETE /products/1` |

---

## Status Code

用標準方式告訴 Client 結果的類型，Response Body 再補細節。

| 類別 | 意思 |
|---|---|
| 2xx | 成功 |
| 3xx | 重新導向（瀏覽器跳轉時常見） |
| 4xx | Client 送來的 request 有問題 |
| 5xx | Server 出問題 |

| Code | 什麼時候用 |
|---|---|
| `200 OK` | 成功，有資料回傳 |
| `201 Created` | 建立了新的 Resource，常用在 POST |
| `204 No Content` | 成功但沒有 Body，常用在 DELETE；回 204 就不要再放 Body |
| `400 Bad Request` | JSON 格式錯、參數格式錯、缺必要欄位 |
| `401 Unauthorized` | 還沒驗證身份：沒帶 Token、Token 過期或無效 |
| `403 Forbidden` | 知道你是誰，但你沒權限，例如看別人的訂單 |
| `404 Not Found` | Resource 不存在；有時也用來隱藏「這筆資料存在但你沒權限」 |
| `409 Conflict` | 跟目前狀態衝突：Email 已註冊、版本衝突、訂單已取消又要取消 |
| `422 Unprocessable Entity` | 格式對但驗證不通過：password 太短、age 不符規則 |
| `500 Internal Server Error` | 未預期的錯誤：未處理的 Exception、程式 Bug |
| `503 Service Unavailable` | 暫時無法提供服務：過載、維護、下游服務或資料庫暫時連不上 |

- 401 vs 403：401 是「我不知道你是誰」，403 是「我知道你是誰，但你不能做」。
- 400 vs 422：有些團隊混用。常見區分是 400 偏格式或語法錯，422 偏格式正確但驗證不通過，重點是團隊規範要一致。
- 500 vs 503：500 是內部發生未預期錯誤，503 是暫時不可用、之後可能恢復。

---

## 常見錯誤

| 錯誤 | 問題 |
|---|---|
| 全部用 POST（`POST /getProducts`、`POST /deleteProduct`） | Method 失去語意，看不出是讀還是寫，也用不到 GET 的 Cache 等特性 |
| GET 拿來修改資料 | 重新整理、Crawler、Cache、Retry 都可能觸發副作用 |
| PUT / PATCH 語意沒定義清楚 | Client 不知道沒傳的欄位、`null` 會怎麼處理 |
| 全部回 200，錯誤寫在 Body 的 `success: false` | Client 很難判斷結果，也破壞 HTTP 的標準語意 |
| Client 錯誤回 500 | 密碼太短、沒登入、找不到資料都不是 Server 壞掉，Monitoring 和 Alert 會失準 |
| 401 和 403 混用 | 沒帶 Token 回 401，已登入但沒權限回 403 |
