---
title: "[Backend]  Exception 與 Error Response"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Error Handling"]
tags: []
order: "000003_error-handling/000003.000002_exception-and-error-response.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/3_Error-Handling/3.2_Exception-and-Error-Response.md
render_with_liquid: false
---

## Abstract

API 出錯時，前端不該看到 `NullPointerException`、SQL 錯誤、stack trace，而是格式固定、安全的 Error Response。
常見做法是：出錯的地方丟出有語意的 Exception，沿著 call stack 往上拋，由 Global Exception Handler 統一接住，轉成 HTTP Status Code、Error Code 和 Response Body。
業務上「不能做」不是系統壞掉，要回 4xx 而不是 500；內部細節只留在 Log。

---

## 流程

```txt
錯誤發生
→ 丟出 Exception，中斷正常流程
→ 沿著 call stack 往上拋
→ Global Exception Handler 接住
→ 轉成 Status Code、Error Code、Response Body
→ 回給前端
```

Exception 本身不是 Error Response，它只是告訴上層「這個流程不能繼續了」。
沒有人接住的話，框架會用預設的 500 回應，通常不是你要的格式。

---

## 為什麼不在每個 Controller 自己 try-catch

- 格式不一致：有人回 `{ "error": ... }`，有人回 `{ "success": false, "message": ... }`，有人回 `{ "code": 1001, "msg": ... }`，前端要為每支 API 寫不同的處理。Error Response 也是 API 合約，要一致。
- 規則散落各處：庫存不足從 400 改成 409，要到每個 Controller 去改。

分工：

- Service 判斷業務能不能做，不行就丟 Exception。
- Controller 不做錯誤轉換。
- Global Exception Handler 統一轉成 Response。

---

## Exception 的兩種來源

| 來源 | 例子 |
|---|---|
| 系統或框架產生 | JSON 格式錯、Body 解析失敗、型別轉換失敗、Validation failed、Authentication / Authorization failed、違反 Database Constraint、資料庫連不上 |
| 自己定義的 Business Exception（在 Service 丟） | 庫存不足、訂單已出貨不能取消、Email 已註冊、操作別人的訂單 |

Business Exception 代表「request 格式正確，但業務上不能做」。
可以一個錯誤一個類別（`OrderAlreadyShippedException`、`EmailAlreadyExistsException`），也可以用統一的 `AppException(code = ORDER_ALREADY_SHIPPED, details = { orderId: 1001 })`。
重點是 Exception 要表達清楚是什麼錯，Handler 才知道怎麼轉。

---

## Global Exception Handler

把內部 Exception 翻譯成 HTTP Response 的統一出口，不做業務判斷：

```txt
OrderAlreadyShippedException
→ 409 Conflict
→ ORDER_ALREADY_SHIPPED
→ 固定格式的 Error Response
```

```json
{
  "code": "ORDER_ALREADY_SHIPPED",
  "message": "This order has already been shipped and cannot be cancelled.",
  "details": { "orderId": 1001 },
  "traceId": "req-def-456"
}
```

未知錯誤（Null Pointer、未處理的 Exception、資料庫連線異常）統一 fallback：

```json
{
  "code": "INTERNAL_SERVER_ERROR",
  "message": "Something went wrong. Please try again later.",
  "traceId": "req-xyz-999"
}
```

stack trace 和內部細節留在後端 Log。

---

## Error Response 的組成

- HTTP Status Code：粗分類，前端、Client Library、監控工具都看得懂（400、401、403、404、409、500）。
- Error Code：系統自己定義的細分類（`VALIDATION_FAILED`、`EMAIL_ALREADY_EXISTS`、`ORDER_OUT_OF_STOCK`）。同樣是 409，可能是 Email 已註冊，也可能是訂單已出貨。
- Response Body：`code`、`message`、`details`、`fieldErrors`、`traceId`、`timestamp`。

欄位驗證錯誤加上 `fieldErrors`：

```json
{
  "code": "VALIDATION_FAILED",
  "message": "Invalid request fields.",
  "fieldErrors": [
    { "field": "email", "message": "Invalid email format." }
  ],
  "traceId": "req-abc-123"
}
```

欄位名稱可以依團隊調整，**同一個系統的格式要一致**。

---

## Business Error 不要回 500

500 是 Server 未預期的錯誤（Null pointer、資料庫掛掉、外部服務不可用）。
庫存不足、訂單不能取消是業務規則拒絕，不是系統壞掉，要回合理的 4xx。

全部回 500，前端會以為系統故障，監控也會把正常的業務拒絕當成 Server Error。

---

## Response 和 Log 怎麼分

| | Response（給前端） | Log（給工程師） |
|---|---|---|
| 要求 | 清楚、安全、格式固定 | 詳細，方便排查 |
| 放什麼 | `code`、`message`、`details`、`fieldErrors`、`traceId` | exception type、stack trace、request path、traceId、user id、重要參數 |
| 不能放 | stack trace、SQL 原文、table / column、class / method 名稱 | token、密碼、信用卡、個資 |

**Log 也不能記 token、密碼、信用卡、個資。**

---

## 常見錯誤

- 每個 Controller 自己 `try-catch`。
- 所有錯誤都回 200，或都回 500。
- Business Exception 沒有語意。
- Error Response 格式不一致。
- 把 stack trace、SQL、內部 class 名稱回給前端。
- catch 了 Exception，但沒記 Log，也沒回正確的 Response。
