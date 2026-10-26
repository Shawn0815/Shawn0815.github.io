---
title: "[Security]  Session vs JWT"
date: 2026-10-26 18:56 +0800
categories: ["Security"]
tags: ["Security"]
source: DDAN_Usandbox/0_Personal/Security/1_Authentication/1.2_Session-vs-JWT.md
render_with_liquid: false
---

## Abstract

HTTP 是 Stateless，登入成功後要有方法讓後續的 request 還認得使用者。
Session 把身份存在 Server、只給瀏覽器一個 ID；JWT 把身份放進 Token 本身，Server 只驗證簽章。
Session 掌控力強、能立即失效，但要共享 Session Store；JWT 適合分散式系統，但發出去之後很難立即失效。

---

## Session 怎麼運作

1. 使用者登入，Server 驗證帳密後知道 `userId = 123`。
2. Server 在 Session Store 建立一筆 `session_abc123 → userId 123`。
3. Server 把 Session ID 交給瀏覽器，通常放在 Cookie：`Set-Cookie: SESSION_ID=abc123`。
4. 之後每次 request，瀏覽器自動帶上 `Cookie: SESSION_ID=abc123`。
5. Server 用 Session ID 查表，得到 `userId`。

Session 可信的關鍵不是 ID 多難猜，而是 ==ID 對應到誰這張對照表存在 Server，Client 沒辦法自己決定或竄改==。
Cookie 只是 Session ID 的載體，本身不是 Authentication，也不是 Session。

### 優缺點

Session 是 Stateful：Server 要保存每個登入者的狀態。

- 優點：實作直覺、Server 掌控身份資料、登出時刪掉 Session 就立即失效（下次查不到就是 401）。
- 缺點：使用者越多 Session Store 越大；多台 Server 要共享 Session（常見做法是集中放在 Redis），擴展性較差。

JWT 就是為了減少「每個 request 都要查 Session Store」的成本而出現。

---

## 比較

| | Session | JWT |
|---|---|---|
| 身份存在哪 | Server（Session Store） | Token 本身 |
| 每次 request | 查 Session Store | 驗證 Signature，大多不用查 |
| 登出、立即失效 | 簡單，刪掉 Session | 麻煩，要搭配 Refresh Token 或 Blacklist |
| 多台 Server | 要共享 Session Store | 天生適合 |
| 適合 | Monolith、管理後台、內部系統 | API、Microservice、Mobile App、SPA |
