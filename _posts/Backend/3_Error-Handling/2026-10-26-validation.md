---
title: "[Backend]  Validation"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Error Handling"]
tags: []
order: "000003_error-handling/000003.000001_validation.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/3_Error-Handling/3.1_Validation.md
render_with_liquid: false
---

## Abstract

Validation 要回答兩個問題：這個 request 系統能不能接受、這個操作業務上能不能執行。
前端驗證只是使用者體驗，後端驗證才是系統防線，因為 API 可以被直接呼叫。
格式驗證放在 Controller / Request DTO，業務驗證放在 Service，Database Constraint 是最後防線。

---

## 為什麼後端一定要驗證

使用者可以關掉前端檢查、用 Postman 或 curl 直接打 API、改 Request Body、用舊版 App。
==後端不能假設前端一定送正確的資料。==

前端驗證讓使用者早點知道哪裡填錯；後端驗證保護系統，確保不合法的資料不會被處理或寫進資料庫。

---

## 兩種驗證

| | Request Validation | Business Validation |
|---|---|---|
| 問什麼 | Request 長得對不對 | 這件事業務上能不能做 |
| 例子 | 必填、email 格式、`quantity > 0`、page size 上限、enum 值、字串長度、日期格式 | 商品存在嗎、庫存夠嗎、能取消這張訂單嗎、已出貨了嗎、Email 註冊過了嗎、折扣碼有效嗎 |
| 需要查資料庫 | 不用 | 通常要 |
| 放哪 | Controller / Request DTO | Service |

`quantity = 2` 格式沒問題，但庫存只剩 1，這就是 Business Validation 要擋的。

---

## Database Constraint

`not null`、`unique`、`foreign key`、`check` 是資料一致性的最後防線。

Email 不能重複：Service 先查一次，但兩個 request 同時註冊時，先查後寫還是可能 race condition，這時 `unique` constraint 確保資料庫最後不會有兩筆。

但不能只靠 constraint：它只懂資料層的規則，不知道業務流程，也給不出前端看得懂的錯誤（庫存不足怎麼提示、為什麼已出貨不能取消）。
Service 負責業務規則，Database Constraint 負責最後防線，兩者一起用。

---

## 一支 API 的驗證流程

以建立訂單為例：

1. Request 進來，先做 Request Validation：`productId` 有沒有傳、`quantity > 0`、`address` 不是空的。
2. 格式通過後進入 Service，做 Business Validation：商品存在、庫存足夠、使用者能下單。
3. 通過後才執行業務流程（計算金額、建立訂單）。
4. 寫入資料庫時，constraint 作為最後防線。

---

## 常見錯誤

| 錯誤 | 問題 |
|---|---|
| 只靠前端檢查 | 前端可以被繞過 |
| 只驗格式，沒驗業務 | 格式對不代表操作合法 |
| 業務驗證放 Controller | Controller 變胖，邏輯難重用、難測 |
| 業務驗證放 Repository | 資料存取和業務規則混在一起 |
| 完全靠 Database Constraint | 只能擋資料層規則，給不出好的錯誤訊息 |
| 同一個規則散在前端、Controller、Service、Repository | 需求一改容易漏改、不一致；重要規則集中在 Service |
