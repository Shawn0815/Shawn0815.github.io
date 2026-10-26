---
title: "[Security]  Refresh Token"
date: 2026-10-26 18:56 +0800
categories: ["Security"]
tags: ["Security"]
source: DDAN_Usandbox/0_Personal/Security/1_Authentication/1.4_Refresh-Token.md
render_with_liquid: false
---

## Abstract

JWT 的效期設長，被偷之後的風險就長；設短，使用者一直要重新登入。
實務上拆成短效的 Access Token 和長效的 Refresh Token：前者 Stateless、拿來呼叫 API，後者 Stateful、存在 DB 或 Redis，只拿來換發新的 Access Token。
登出就是刪掉 Refresh Token，讓現有的 Access Token 自然過期。

---

## 兩種 Token

| | Access Token | Refresh Token |
|---|---|---|
| 用途 | 每次呼叫 API 都帶上 | 只在 Access Token 過期時換新的 |
| 效期 | 短（例如 15 分鐘） | 長（例如 30 天） |
| 狀態 | Stateless，驗證 Signature 就好 | Stateful，存在 DB / Redis |

```txt
Authorization: Bearer <access_token>
```

換發流程：

1. Access Token 過期，Server 回 `401`。
2. Client 帶 Refresh Token 呼叫 `/refresh`。
3. Server 驗證通過，發一個新的 Access Token。

---

## Refresh Token 為什麼要存起來

因為它需要被管理：

- 使用者登出。
- 強制某個裝置登出。
- 限制同時登入的裝置數。
- 帳號異常時撤銷。

通常存成 `refreshToken → userId + device + expireTime + status`，Server 才能主動撤銷。

---

## Logout

Session 登出直接刪 Session 就好；JWT 的 Access Token 發出去之後在過期前都還有效。

常見做法是==登出時刪掉 Refresh Token==：使用者換不到新的 Access Token，現有的那張讓它自然過期，所以 Access Token 效期要設短。
如果連 Access Token 都要立即失效，就要加 Blacklist 或 Token Version，但設計會變得更 Stateful，看安全需求決定。
