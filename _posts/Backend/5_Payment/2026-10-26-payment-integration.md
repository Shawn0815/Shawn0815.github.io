---
title: "[Backend]  第三方金流整合"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Payment"]
tags: []
order: "000005_payment/000005.000001_payment-integration.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/5_Payment/5.1_Payment-Integration.md
render_with_liquid: false
---

## Abstract

電商的付款流程是：建立訂單、交給第三方金流、使用者付款、金流通知後端、更新訂單狀態。
設計的核心是怎麼把本地資料的一致性和外部的付款結果安全地接起來。
金流不放進下單的 Transaction；先建立待付款訂單，付款結果以 Webhook 為準，並處理重複通知。

---

## 金流不放進下單的 Transaction

下單的本地 Transaction 包含建立 Order、建立 OrderItem、扣庫存，都在自己的資料庫，可以保證一起成功或失敗。
第三方金流是外部 API：慢、可能 timeout、無法控制。

```sql
BEGIN;
-- 建立訂單、扣庫存
-- 呼叫金流（可能卡好幾秒）
COMMIT;
```

包進去會讓 Lock 持有太久、堵住其他下單，timeout 時本地資料和外部付款狀態也更難對齊。
**Transaction 只包本地一定要一起成功的資料變動，外部金流放在 Transaction 外面。**

---

## 流程

1. 本地 Transaction：建立訂單、扣庫存。
2. 訂單狀態設成 `PENDING_PAYMENT`。
3. 導向或呼叫第三方金流。
4. 等金流的 Webhook。
5. 依結果更新成 `PAID` 或 `FAILED`。

**付款結果不能只信前端說「我付完了」**：使用者可能關掉頁面、重送，或偽造成功訊息。

---

## 訂單狀態

```txt
CREATED → PENDING_PAYMENT → PAID / FAILED
```

更完整可以再加 `CANCELLED`、`REFUNDED`。
狀態轉換要有清楚的規則，不能亂跳：`PENDING_PAYMENT` 可以變 `PAID`，但已經 `PAID` 的不能被一個失敗通知改回 `FAILED`（除非走退款流程）。

---

## Webhook

金流伺服器主動通知後端付款成功或失敗，是可信的付款結果來源：

- 使用者付款後可能沒回到你的網站。
- 前端的成功頁可以偽造。

收到 Webhook 要：

- 驗證簽名或來源。
- 用訂單編號找到對應的 Order。
- 依結果更新狀態。
- 記錄通知內容方便追查。

### 重複通知

金流常會重送 Webhook，同一筆成功通知可能來兩次。
已經是 `PAID` 就不要再扣庫存、再出貨；用訂單狀態或通知編號判斷是否處理過。
同一筆付款結果處理兩次，系統狀態仍然要正確。

---

## 專案現況

電商專案目前先模擬付款：建立訂單成功後，付款狀態 `PENDING` → `PAID`，還沒接綠界或 Stripe。
要上線時，補上真實的金流串接和 Webhook 處理。
