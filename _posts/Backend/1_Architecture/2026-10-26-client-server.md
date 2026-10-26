---
title: "[Backend]  前後端分離"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Architecture"]
tags: []
order: "000001_architecture/000001.000001_client-server.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/1_Architecture/1.1_Client-Server.md
render_with_liquid: false
---

## Abstract

傳統 MVC 由 Server 組好整頁 HTML 回傳；前後端分離則是前端只負責畫面和互動，後端只回傳 JSON，兩邊透過 API 溝通。
好處是職責分離、可以各自開發部署、多個平台共用同一套 API；代價是要處理 CORS、認證變複雜、部署變成兩套。
簡單的內部工具、SEO 很重要但人力有限時，Server-side Rendering 反而更適合。

---

## 兩種架構

| | 傳統 MVC（Server-side Rendering） | 前後端分離 |
|---|---|---|
| Server 回傳 | 組好的完整 HTML | 純資料（通常是 JSON） |
| 畫面由誰產生 | Server | 前端 |
| 溝通方式 | 瀏覽器直接拿頁面 | 前端呼叫 API |

---

## 好處

- 職責分離：前端專注畫面和互動，後端專注商業邏輯和資料。
- 獨立開發、獨立部署，不用互相等。
- Web、App、第三方系統共用同一套 API。
- 前端框架和後端語言各自演進，不互相綁死。

---

## 代價

- CORS：前端和後端不同來源，後端要設定 `Access-Control-Allow-Origin` 等 Header 才能讓前端呼叫。
- 認證變複雜：傳統 MVC 用 Server-side Session + Cookie 就好；分離後常改用 JWT，又要面對 Token 存哪裡的問題（LocalStorage 怕 XSS，`HttpOnly` Cookie 要防 CSRF）。
- 部署複雜：前後端分開部署、版本要對齊，環境變數和 CI/CD 都變成兩套。

---

## 什麼時候不適合

- 簡單的內部工具、管理後台：SSR 更快、更簡單。
- SEO 很重要但團隊資源有限：SSR / SSG，或 Next.js 這類混合方案。
- 團隊很小，維護兩套技術的成本大於好處。
