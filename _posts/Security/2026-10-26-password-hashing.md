---
title: "[Security]  密碼雜湊與加鹽"
date: 2026-10-26 18:56 +0800
categories: ["Security"]
tags: ["Security"]
source: DDAN_Usandbox/0_Personal/Security/1_Authentication/1.5_Password-Hashing.md
render_with_liquid: false
---

## Abstract

密碼系統只需要「驗證」輸入對不對，不需要「知道」原始密碼，所以要用不可逆的 Hash 存，不是可以解密的 Encrypt。
每個使用者加上隨機 Salt，相同密碼才不會算出相同的值；演算法要用 BCrypt 這種刻意設計得慢的，拉高暴力破解的成本。

---

## 為什麼不能明文存

資料庫一外洩，密碼直接被拿走。
很多人在不同網站用同一組密碼，一次外洩會連帶影響其他服務的帳號。

---

## Hash vs Encrypt

| | Encrypt | Hash |
|---|---|---|
| 能不能還原 | 有 Key 就能解密 | 設計上不可逆 |
| 適合 | 之後要拿回原文（信用卡卡號） | 只要驗證是否相同（密碼） |

---

## Salt

只做 Hash 的話，相同密碼會算出相同的值。
攻擊者可以預先把常見密碼的 Hash 算好做成對照表（Rainbow Table），拿外洩的 Hash 一查就知道原文。

加鹽是 Hash 之前幫每個使用者加一段隨機字串一起算，相同密碼也會得到不同的結果，Rainbow Table 就失效了。
Salt 不用保密，跟 Hash 結果存在一起，驗證時取出來重算。

---

## 為什麼用 BCrypt，不用 MD5 / SHA256

MD5、SHA256 的設計目標是快，適合檢查檔案完整性。
**密碼雜湊剛好相反，要越慢越好**：算一次越久，攻擊者一組一組硬猜的速度就越慢。

BCrypt 這類專門給密碼用的演算法內建加鹽，運算成本（Cost Factor）也能調，硬體變快時調高就能維持破解難度。

---

## 登入時怎麼驗證

不會、也不能把 Hash 還原。
把這次輸入的密碼用同樣的演算法和 Salt 再算一次，跟資料庫存的值比對，相同就是密碼正確。
