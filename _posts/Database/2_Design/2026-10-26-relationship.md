---
title: "[Database]  Relationship 與 Bridge Table"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Design"]
tags: []
order: "000002_design/000002.000002_relationship.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/2_Design/2.2_Relationship.md
render_with_liquid: false
---

## Abstract

找出 Entity 之後，下一步是判斷彼此的關係，因為它決定 Foreign Key 放哪、要不要拆表、要不要 Bridge Table。
判斷方法是兩邊各問一次「一個 A 對應幾個 B」。
Many-to-Many 要用 Bridge Table 拆成兩個 One-to-Many，而很多 Bridge Table 會隨需求長成獨立的 Entity。

---

## 判斷方式

兩邊各問一次：

```txt
一個 User 可以有幾個 Order？ → 很多個
一個 Order 屬於幾個 User？   → 一個
→ User 1 : N Order，One-to-Many
```

| 關係 | 意思 | 例子 | 怎麼實作 |
|---|---|---|---|
| One-to-One | A 對一個 B，B 也只對一個 A | User ↔ UserProfile、Order ↔ Invoice | 其中一邊放對方的 id |
| One-to-Many | 一個 A 對很多 B，一個 B 只屬於一個 A | User → Order、Category → Product | Foreign Key 放在 Many 那一側（`orders.user_id`） |
| Many-to-Many | 兩邊都對很多個 | Student ↔ Course | Bridge Table |

---

## Bridge Table

資料表沒辦法直接表示 Many-to-Many。
把 `course_ids` 塞進 Student 的一個欄位，查詢和維護都會很難，也違反正規化。

Bridge Table 把關係獨立成一張表，拆成兩個 One-to-Many：

```txt
Student 1 ── N student_courses N ── 1 Course

student_courses (student_id, course_id)
```

### 要不要自己的 id

單純記錄關係時不用，`(student_id, course_id)` 本身就唯一，可以直接當 Composite Primary Key，例如 `user_roles (user_id, role_id)`。

當這張表開始有自己的業務資料，就會加上自己的 id。
例如 `order_items` 除了 `order_id`、`product_id`，還有 `quantity`、`price`、`discount`、`subtotal`，之後退款、換貨、物流都會掛在它上面，所以通常會有 `order_item_id`。

### OrderItem 是 Bridge Table 也是 Entity

Order ↔ Product 是 Many-to-Many，所以需要 OrderItem 當橋。
但它有了數量、價格，甚至 `refund_status`、`shipment_status`，就已經是一筆有自己規則的購買紀錄，也是 Entity。

---

## 有些 Many-to-Many 會長出新的 Entity

「一個 User 買很多 Product，一個 Product 被很多 User 買」是 Many-to-Many，但實際系統不會建 `user_products`。
因為真正要記錄的是「購買」這件事：什麼時間、買幾個、多少錢、哪張訂單。
所以設計是 User → Order → OrderItem → Product。

很多 Entity 不是從需求的名詞直接找到，而是從關係長出來的：

```txt
Student ↔ Course  → Enrollment
Order ↔ Product   → OrderItem
User ↔ Role       → UserRole
```

設計時的思考順序：

1. 找出 Entity。
2. 找出 Relationship。
3. 是 Many-to-Many 就加 Bridge Table。
4. 判斷 Bridge Table 是否已經成長為獨立的 Entity。
