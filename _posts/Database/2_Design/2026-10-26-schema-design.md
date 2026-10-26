---
title: "[Database]  Schema Design"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Design"]
tags: []
order: "000002_design/000002.000001_schema-design.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/2_Design/2.1_Schema-Design.md
render_with_liquid: false
---

## Abstract

拿到需求時，不要一開始就畫 Table。
先想系統要記錄哪些事情、未來要回答哪些問題，再從中找出需要獨立管理的 Entity、Entity 之間的關係，最後才定欄位和約束。
判斷要拆成 Entity 還是放在 Column，看的是業務複雜度，不是資料型態。

---

## 設計流程

```txt
需求：系統有哪些功能？
↓
要記錄哪些事件？（下單、付款、評論）
↓
每個事件要保存哪些資訊？（誰、買了什麼、多少錢、什麼時間、付款成功沒）
↓
哪些需要獨立管理？（Entity）
↓
Entity 之間有什麼關係？（Relationship）
↓
定義欄位（Column）
↓
補上 Constraint、Index、業務規則
```

從事件開始想，是因為資料庫存在的目的是保存資訊、在未來回答問題，而系統真正要記錄的就是一件件發生的事。

---

## 找出 Entity

Entity 是系統中需要獨立識別、獨立管理、獨立追蹤的核心物件，通常對應一張 Table。

先從需求裡的名詞找候選，例如「使用者可以購買商品，並建立訂單」裡的 User、Product、Order。
但不是每個名詞都要拆成表，再用這幾個問題判斷：

- 需要被單獨查詢嗎？
- 需要被單獨新增、修改、刪除嗎？
- 會被其他資料引用嗎？
- 有自己的狀態和生命週期嗎？（例如 Order 會經歷 `CREATED` → `PAID` → `SHIPPED` → `DELIVERED`）

大部分答「會」就是 Entity。
Product 要新增、修改、上下架，又被 OrderItem、Review 引用，所以是 Entity；price 只是描述 Product 的屬性，沒有自己的狀態，所以是 Column。

### Entity 是從 Column 長出來的

一開始訂單只要記有沒有付款：

```txt
orders (id, user_id, total_amount, paid, created_at)
```

後來要支援信用卡、Line Pay、退款、保存第三方交易紀錄，開始多出 `payment_method`、`transaction_id`、`payment_status`、`paid_at`、`refund_at`。
付款變成一個要獨立管理的領域，Payment Entity 就出現了。

庫存也一樣：一開始 `products.stock` 一個欄位就夠，等到要處理進貨、出貨、退貨、盤點、多倉庫、異動紀錄，才拆出 Inventory。

### 不要過度拆表

如果某個資訊永遠只屬於一個 Entity，不需要獨立查詢，也沒有自己的生命週期，就直接放 Column。
把 users 的名字、email、電話拆成三張表，只會換來一堆不必要的 `JOIN`。

Schema Design 的目標是在一致性、可維護性、查詢效率和業務需求之間取得平衡，不是拆出最多張表。

---

## Entity 常見的欄位

| 種類 | 例子 | 用途 |
|---|---|---|
| 主鍵 | `id` | 唯一識別一筆資料 |
| 業務欄位 | `name`、`price`、`email`、`total_amount` | 描述業務內容 |
| 關聯欄位 | `user_id`、`order_id`、`product_id` | 表示和其他 Entity 的關係 |
| 狀態欄位 | `status` | 表示生命週期走到哪 |
| 時間欄位 | `created_at`、`updated_at` | 排序、除錯、稽核 |

電商常見的 Entity 有 User、Product、Category、Cart、CartItem、Order、OrderItem、Payment、Review、Inventory，但這不是固定答案，都是隨需求演進出來的。
