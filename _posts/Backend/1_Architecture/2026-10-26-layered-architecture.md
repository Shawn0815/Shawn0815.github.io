---
title: "[Backend]  Controller、Service、Repository 分層"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Architecture"]
tags: []
order: "000001_architecture/000001.000002_layered-architecture.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/1_Architecture/1.2_Layered-Architecture.md
render_with_liquid: false
---

## Abstract

一個 API 裡混著好幾種責任：處理 HTTP、驗證輸入、業務邏輯、存取資料庫、控制 Transaction。
全部塞進 Controller 會難讀、難測、難重用，所以分成三層：Controller 接 API，Service 做邏輯，Repository 存取資料。
分層的目的不是檔案變多，而是每一層的責任清楚。

---

## 為什麼要分層

建立訂單的 API 要檢查使用者、檢查商品和庫存、計算金額、建立 Order 和 OrderItem、扣庫存、回傳結果。
全部寫在 Controller 會出現三個問題：

- 難讀：HTTP 處理、業務規則、資料庫操作混在一起，看不出業務邏輯在哪。
- 難重用：後台、排程、Message Consumer 也要下單時，邏輯綁在 Controller 拿不出來。
- 難測：只想測「庫存不足不能下單」，卻要連 HTTP 和資料庫一起準備。

---

## 三層各自負責什麼

```txt
Controller → Service → Repository → Database
```

| 層 | 負責 | 不該做 |
|---|---|---|
| Controller | HTTP Request / Response、基本格式驗證、呼叫 Service | 業務邏輯、直接操作資料庫、控制 Transaction |
| Service | Use Case、業務邏輯、業務驗證、Transaction 邊界、協調多個 Repository | 只是轉呼叫 Repository |
| Repository | 查詢、新增、更新、刪除，封裝資料庫操作 | 決定業務規則 |

### Controller：薄，但不是沒有責任

接收 Path Variable、Query Parameter、Request Body，做格式驗證，呼叫 `orderService.createOrder(...)`，回傳 Response。

格式驗證是「這個 Request 長得對不對」：必填欄位、email 格式、`quantity > 0`、字串長度、enum 值。
Spring Boot 常寫在 Request DTO 上：`@NotNull`、`@Email`、`@Min`、`@Size`。

### Service：業務流程的核心

Use Case 是一個完整的業務操作（建立訂單、取消訂單、註冊帳號）。
業務規則是裡面的判斷：庫存不足不能下單、只能取消自己的訂單、已出貨不能取消、Email 不能重複註冊。

業務驗證是「這件事在業務上能不能做」，要看資料庫狀態或業務規則，所以放在 Service：

- 格式驗證：靠近 Controller / Request DTO。
- 業務驗證：放在 Service。

**Transaction 放在 Service**，因為它要包住一個完整的 Use Case。
建立訂單會呼叫好幾個 Repository（建立 Order、建立 OrderItem、扣庫存），任何一步失敗都要全部 rollback。
放在 Controller 會讓 HTTP 層管到資料一致性；只放在單一 Repository 又包不住整個流程。

### Repository：資料要怎麼查、怎麼存

`findById`、`findByEmail`、`save`、`delete`、`updateStock`，可以有複雜查詢、分頁，但只管資料怎麼存取。
「使用者能不能下單」「折扣碼能不能用」這類問題放在 Service。

Database Constraint（unique、foreign key、not null、check）是最後防線。
例如 Email 不能重複，資料庫用 unique constraint 擋重複資料；但檢查是否已存在、回什麼錯誤訊息，還是 Service 的事。

---

## 好處

- 可讀：API 入口看 Controller，業務邏輯看 Service，資料存取看 Repository。
- 可維護：API 格式改了改 Controller，業務規則改了改 Service，查詢方式改了改 Repository。
- 可測試：業務邏輯在 Service，可以不經過 HTTP 單獨測。
- 可重用：Service 的 Use Case 可以給排程、後台工具、Message Consumer 呼叫。

---

## 常見錯誤

| 錯誤 | 問題 |
|---|---|
| Fat Controller | 查資料、判斷規則、算金額、更新資料庫、控制 Transaction 全在 Controller |
| Thin Service | Service 只轉呼叫 Repository，業務規則散在 Controller 或 Repository |
| Repository 混入業務邏輯 | 改業務規則時不知道要去 Service 還是 Repository 找 |
| Transaction 邊界放錯 | 放 Controller 綁太緊；只放單一 Repository 包不住流程，Order 建好了庫存卻沒扣 |
| 分層過度 | 簡單功能拆成一堆沒意義的層，理解成本反而變高 |
