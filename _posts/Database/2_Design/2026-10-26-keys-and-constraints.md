---
title: "[Database]  Keys 與 Constraints"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Design"]
tags: []
order: "000002_design/000002.000003_keys-and-constraints.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/2_Design/2.3_Keys-and-Constraints.md
render_with_liquid: false
---

## Abstract

資料存進去之後還要有意義：訂單要找得到下單的人、登入帳號不能重複、必要欄位不能是空的。
Keys 和 Constraints 就是讓資料庫幫忙守住這些規則（Data Integrity），每一種保護資料的一個面向。

---

## 每種約束保護什麼

| 約束 | 保護什麼 | 沒有它會怎樣 |
|---|---|---|
| Primary Key | Identity：這筆資料是誰 | 三個同名的 Shawn，訂單寫 `user = Shawn` 分不出是哪一個 |
| Foreign Key | Relationship：被引用的資料必須存在 | `orders.user_id = 999999` 但沒有這個 User，變成孤兒資料（Orphan Data） |
| Unique | 業務規則上的唯一 | 兩個 User 的 email 都是 `aaa@gmail.com`，登入時不知道是誰 |
| NOT NULL | 必要資料 | `email = NULL` 無法登入、`created_at = NULL` 不知道何時建立 |

### Primary Key vs Unique

兩者都不能重複，但目的不同。
Primary Key 是資料的身份，一張表只有一個；Unique 是業務規則（email、手機、學號），一張表可以有很多個。

名字可以重複，id 不行。

---

## Composite Key

用多個欄位一起當 Primary Key。

```txt
student_courses (student_id, course_id)
```

`(student_id, course_id)` 已經能唯一識別一筆選課紀錄，就不一定需要另外的 `id`。
純 Bridge Table 常這樣設計，因為關係本身就是身份。

---

## 為什麼有些公司不用 Foreign Key

Microservice、Sharding、跨資料庫的系統裡，User 和 Order 可能根本不在同一個資料庫，Foreign Key 無法使用。
這時改由程式負責，例如建立 Order 前先確認 User 存在。

所以 Foreign Key 不是一定要開，而是在資料完整性和系統複雜度之間取捨。
