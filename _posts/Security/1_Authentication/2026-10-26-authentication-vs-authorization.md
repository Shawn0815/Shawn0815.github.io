---
title: "[Security]  Authentication vs Authorization"
date: 2026-10-26 18:56 +0800
categories: ["Security", "Authentication"]
tags: []
order: "000001_authentication/000001.000001_authentication-vs-authorization.md"
image: {path: "/assets/img/covers/Security.png"}
source: DDAN_Usandbox/0_Personal/Security/1_Authentication/1.1_Authentication-vs-Authorization.md
render_with_liquid: false
---

## Abstract

後端收到一個 request，要先知道「是誰」，才能決定「能不能做」。
Authentication 建立可信的身份（你是誰），Authorization 根據身份判斷權限（你能做什麼）。
Session 和 JWT 不是 Authentication 本身，而是登入成功後把身份保存下來的方法。

---

## 為什麼不能直接傳 userId

建立訂單的 API 要知道訂單是誰的，最直覺的做法是讓前端帶上：

```json
{ "userId": 123 }
```

但 `userId` 只是「我是 123 號」這句話，不是證明，任何人都可以改成 `999` 或 `1`。
**後端不能直接相信使用者自己提供的身份。**

---

## Authentication：建立可信身份

回答「你怎麼證明你是你說的那個人」。
常見方式：帳號密碼、Google Login、Email OTP、2FA。

```txt
POST /login  { "username": "shawn", "password": "123456" }
→ 驗證成功，確認 userId = 123
```

Authentication 得到的不只是 userId，而是一個可信的 userId。

### 登入一次之後

HTTP 是 Stateless，下一個 `POST /orders` 是全新的 request，後端不會自動記得剛剛登入的是誰。
每次都重送帳密既麻煩、密碼又頻繁在網路上傳輸，所以需要把身份保存下來：

```txt
帳號密碼 → Authentication 成功 → 發 Session / JWT
→ 之後每次 request 帶上 Session / JWT → 後端知道你是誰
```

- 帳號密碼：驗證身份。
- Session / JWT：保存已驗證的身份。Session 是 Server 存對照表、查表得知；JWT 是 Token 自己帶身份、驗證簽章得知。

---

## Authorization：根據身份判斷權限

知道你是 Shawn 之後，`GET /orders/123` 還要判斷這張訂單是不是 Shawn 的：是就允許，不是就回 `403 Forbidden`。

常見做法：

- Ownership Check：檢查資源是否屬於目前使用者（只能看自己的訂單、改自己的地址、刪自己的評論）。
- RBAC（Role-Based Access Control）：依角色決定權限，例如 Customer、Seller、Admin，`DELETE /products/1` 只有 `role == ADMIN` 能執行。

---

## 順序與缺一不可

```txt
Authentication（你是誰）→ Authorization（你能做什麼）→ Business Logic
```

- 沒有 Authentication：不知道你是誰，訂單、購物車、評論都無法歸屬。
- 沒有 Authorization：知道你是誰，但你可以看別人的訂單、刪別人的商品、操作管理功能。
