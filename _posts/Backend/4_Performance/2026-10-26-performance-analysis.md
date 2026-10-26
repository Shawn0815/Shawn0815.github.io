---
title: "[Backend]  網站變慢怎麼查"
date: 2026-10-26 18:46 +0800
categories: ["Backend", "Performance"]
tags: []
order: "000004_performance/000004.000001_performance-analysis.md"
image: {path: "/assets/img/covers/Backend.png"}
source: DDAN_Usandbox/0_Personal/Backend/4_Performance/4.1_Performance-Analysis.md
render_with_liquid: false
---

## Abstract

「網站很慢」只是現象，不要一開始就猜資料庫、說要加 Cache。
先縮小範圍（哪個頁面、哪支 API、什麼時間、哪些使用者），再判斷是前端、網路還是後端慢；確定是後端，再拆時間花在 Database、Application 還是 External API。
找到瓶頸之後，才選對應的優化方式。

---

## 先縮小範圍

- 所有頁面慢，還是特定頁面？
- 所有 API 慢，還是某一支？
- 所有使用者，還是特定使用者？
- 一直慢，還是偶爾慢？尖峰時段才慢嗎？
- 最近部署後才變慢嗎？
- 哪個操作慢：搜尋、商品列表、下單、登入？

所有功能都慢，比較像系統層級的問題（流量暴增、CPU / Memory、Connection Pool 用完、資料庫過載）；只有某支 API 慢，比較像那支 API 自己的問題（慢 SQL、N+1、Response 太大、外部 API 慢）。

---

## 前端、網路，還是後端

```txt
Browser → Network → Backend API → Database / Cache / External API → Response → Frontend Render
```

用 Browser Network Tab、API access log、Gateway log 或 Trace 確認 API 本身慢不慢。
看 TTFB（Time To First Byte，送出 request 到收到第一個 byte 的時間）：

- TTFB 很久：後端花很久才開始回應，往後端查。
- TTFB 很短但下載很久：後端很快，問題在 Response 太大或網路。

後端很快、頁面還是慢，可能是 render 太慢、JS bundle 太大、圖片太大、靜態資源太多、CDN 問題。

---

## 所有功能都慢：看系統指標

QPS、API latency、Error rate、CPU、Memory、GC、Thread Pool、DB Connection Pool、資料庫 CPU / IO、External API latency。

常見原因是流量暴增、CPU 打滿、Memory 不足或 GC 頻繁、Thread Pool 滿、Connection Pool 用完、資料庫過載、外部 API 大量 timeout。
不是某支 API 自己慢，而是系統資源或共用的依賴被卡住，大家一起慢。

---

## 某支 API 慢：拆時間

API 總共 5000ms，要知道 SQL、Application、External API、Serialization、傳輸各花多少，有沒有在等 Connection 或 Lock。

| 工具 | 看什麼 |
|---|---|
| Log | 每個重要步驟的耗時 |
| Trace | request 每一段的耗時 |
| Slow Query Log | 慢 SQL |
| `EXPLAIN` | SQL 有沒有走 Index、掃多少列 |
| SQL / ORM Log | 有沒有 N+1 |
| Metrics | CPU、Memory、Connection Pool、Thread Pool |

| 慢在哪 | 判斷 | 常見原因 | 處理方向 |
|---|---|---|---|
| Database | SQL 花了 4800ms | Slow Query、沒有 Index、Full Table Scan、`JOIN` 太重、`ORDER BY` / `GROUP BY` 太重、深分頁、Lock wait | 補 Index、改寫查詢、減少欄位、Keyset Pagination、先聚合再 `JOIN`、縮短 Transaction |
| Application | SQL 和外部 API 都只有 100ms | N+1、業務邏輯太重、大量迴圈或計算、JSON 序列化慢、Response 太大、Memory / GC 壓力 | 見下方 |
| External API | Payment API 花了 4800ms | 第三方變慢、網路抖動、Timeout 太長、Retry 太多、外部 API 卡在主流程上 | Timeout、合理 Retry、Fallback、Cache、Async / Queue |

Application 慢的處理：

- N+1（查 100 個商品，再各查一次 rating，變成 1 + 100 次）：Batch Query、`JOIN`、一次查完用 Map 組裝。
- 業務邏輯太重：優化演算法、減少資料量、可以延後的改成 Background Job。
- Response 太大：分頁、用 DTO 控制欄位、不回不需要的巢狀物件、圖片回 URL。

External API 例子：下單成功後寄 Email，使用者不需要等 Email API，丟進 Queue 非同步處理。

---

## 偶爾才慢：找規律

偶爾慢很難重現，重點是找規律、對時間點：

- 是不是尖峰時段？特定 API？特定使用者？特定資料量？
- 跟排程、部署、外部服務有沒有關係？

常見原因：流量尖峰、GC pause、Lock wait、Connection Pool 短暫用完、外部 API 抖動、特定資料觸發慢查詢、Cache miss。
用 Metrics、Logs、Trace 對照慢的那一刻：CPU、GC、資料庫 CPU、Connection Pool waiting、哪個外部 API、哪支 API 的 latency 特別高。

---

## 對應的優化方式

| 瓶頸 | 優化 |
|---|---|
| 資料庫慢 | `EXPLAIN`、Index、改寫查詢、分頁、縮短 Transaction |
| N+1 | Batch Query、`JOIN`、Map 組裝 |
| 業務邏輯太重 | 減少資料量、優化演算法、Background Job |
| Response 太大 | DTO、分頁、減少欄位和巢狀物件 |
| 外部 API 慢 | Timeout、Retry、Fallback、Cache、Async / Queue |
| CPU / Memory 高 | 找熱點、降低計算和資料量，必要時 scale out |
| Connection Pool 滿 | 縮短 SQL 和 Transaction、查 connection leak、調整 pool size |

==加 Cache、加 Index、加機器都可能是解法，但要先知道瓶頸在哪。==
