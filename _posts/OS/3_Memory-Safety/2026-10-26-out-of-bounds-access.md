---
title: "[OS]  Out-of-bounds Access"
date: 2026-10-26 18:56 +0800
categories: ["OS", "Memory Safety"]
tags: []
order: "000003_memory-safety/000003.000001_out-of-bounds-access.md"
image: {path: "/assets/img/covers/OS.png"}
source: DDAN_Usandbox/0_Personal/OS/3_Memory-Safety/3.1_Out-of-Bounds-Access.md
render_with_liquid: false
---

## Abstract

程式存取陣列或 buffer 時，index 或 offset 超出合法範圍，就是越界存取：越界讀拿到垃圾值，越界寫蓋掉不該動的資料。
最常見的原因是拿不可信任的外部輸入直接當 index，沒有先驗證範圍；即使 buffer 預留了更大的空間，超過邏輯上的合法範圍一樣算越界。
這是資安最經典的漏洞類型之一，也是威脅偵測和沙箱分析要辨識的行為。

---

## 兩種越界

| | 結果 | 嚴重性 |
|---|---|---|
| Out-of-bounds Read | 讀到不屬於自己或還沒賦值的記憶體，拿到垃圾值，後續運算跟著錯 | 可能洩漏不該洩漏的記憶體內容 |
| Out-of-bounds Write | 寫超過合法範圍，蓋掉別的資料或程式狀態 | 可能覆寫執行流程（例如 return address），是 buffer overflow 等 exploit 的基礎 |

---

## 為什麼會發生

用來當 index 或 offset 的值來自外部（網路對端、上層模組、使用者輸入），程式沒先檢查就直接用。

==記憶體實際配置的比合法範圍大，不代表多出來的部分可以讀。==
例如某個欄位規格定義 16 種合法值，為了未來相容 buffer 預留到 64。
外部傳進一個大於 16、小於 64 的值，程式沒擋下來就拿去當 index，讀到的是「保留但沒有賦值」的區域。

---

## 從記憶體內容判斷

很多系統會把未初始化或保留未用的記憶體填成固定 pattern，例如全部 `0xFF`。
dump 出來某個欄位整段都是這種正常資料不可能出現的 pattern，就是讀到不該讀的區域的明顯訊號。

反推方法：

1. 先確認正常情況下這塊記憶體應該長什麼樣子。
2. 對照程式怎麼用外部傳入的值計算 index / offset。
3. 回推外部傳了什麼值才會造成這個結果。

---

## 怎麼預防

- 外部輸入一律做範圍驗證：只要會被拿去當 index / offset，不管來自網路、上層模組還是使用者，都先檢查。
- Assert 加 runtime check：assert 在開發和測試時快速抓出違規；正式環境要有 runtime check 和明確的錯誤處理，不能帶著錯誤的值繼續跑。
- 多層防護（Defense in Depth）：上一層驗證過，下一層也檢查，避免某處驗證被繞過或漏掉時整條路徑失守。
