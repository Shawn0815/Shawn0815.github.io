---
title: "[Database]  Write Scaling：Queue 與 Batch"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Scaling"]
tags: []
order: "000006_scaling/000006.000003_write-scaling.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/6_Scaling/6.3_Write-Scaling.md
render_with_liquid: false
---

## Abstract

Write-heavy 是 `INSERT` / `UPDATE` 太多，資料庫來不及寫。
讀取可以靠 Cache 擋掉，寫入最後一定要落到資料庫，所以通常更難處理。
能接受延遲的寫入先丟進 Queue 把瞬間流量攤平，再用 Batch 一次寫一批提高效率；付款、扣庫存這種要立刻知道結果的，仍然同步寫入。

---

## 寫入為什麼比讀取貴

一次寫入不只是「把資料存進去」，資料庫還要寫 Log（Redo Log 等）、更新所有相關的 index、處理 Transaction Commit。

---

## Queue：攤平瞬間流量

平常每秒 1 萬筆寫入沒問題，活動開始時突然變成每秒 100 萬筆。
問題不是總量太多，而是瞬間流量太大，就像 1000 個客人同時衝向超商櫃台。

Queue 就是等待區：

```txt
原本：User → Database                    1 秒 100 萬筆直接打進去，爆掉
現在：User → Queue → 慢慢消化 → Database   資料庫照自己的速度處理
```

==前提是允許延遲。==

- 適合：瀏覽紀錄、點擊紀錄、分析 Log、推薦系統事件，晚幾秒寫入沒關係。
- 不適合：付款、扣庫存、轉帳，使用者要立刻知道結果，還是同步寫入。

---

## Batch：一次寫一批

Queue 只是把「瞬間寫入」變成「延後寫入」，100 萬筆最後還是要寫進去。
一筆一筆 `INSERT` 就是 100 萬次，還是很慢。

Batch 是先累積一批再一起寫：

```sql
INSERT INTO logs VALUES
    (...),
    (...),
    (...);   -- 1000 筆合成一次 INSERT
```

1000 次 `INSERT` 變成 1 次，資料庫的壓力少很多。

---

## Queue vs Batch

- Queue 解決瞬間流量太大。
- Batch 解決單次寫入效率太差。

常見的組合是 User → Queue → Batch → Database：先用 Queue 接住流量，再用 Batch 提高寫入效率。

---

## 思考流程

不要先想 Kafka、RabbitMQ，先問「這些資料一定要立刻寫進資料庫嗎？」

1. 一定要立刻寫（付款、扣庫存、轉帳）：同步寫入。
2. 可以延遲（Log、點擊紀錄、分析事件）：Queue。
3. Queue 消化時寫入量還是太大：Batch。
