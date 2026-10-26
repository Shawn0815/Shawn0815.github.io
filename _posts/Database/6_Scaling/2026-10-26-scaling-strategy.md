---
title: "[Database]  Database Scaling 怎麼判斷"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Scaling"]
tags: []
order: "000006_scaling/000006.000001_scaling-strategy.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/6_Scaling/6.1_Scaling-Strategy.md
render_with_liquid: false
---

## Abstract

系統成長後，資料庫開始出現 CPU 飆高、記憶體不足、Disk I/O 過高、查詢變慢、連線不夠。
第一反應不該是加機器，而是先找出瓶頸屬於哪一類：讀太多、寫太多，還是資料本身太大。
三類問題的解法完全不同，Cache、Read Replica、Queue、Partitioning、Sharding 都只是對應的工具。

---

## 三類瓶頸

| 類型 | 特徵 | 例子 | 解法方向 |
|---|---|---|---|
| Read-heavy | 讀遠多於寫，一天查 100 萬次、只更新幾百次 | 商品列表、首頁推薦、排行榜、新聞網站 | Cache、Read Replica |
| Write-heavy | 大量 `INSERT` / `UPDATE`，寫入速度跟不上 | Log、聊天訊息、監控、IoT | Queue、Batch、非同步處理 |
| Data-heavy | 資料量本身太大（數億、數十億筆），查詢不多也會慢 | users、orders、logs 大表 | Partitioning、Sharding |

---

## 思考流程

1. 系統變慢。
2. 找出瓶頸：查詢太多？寫入太多？資料太大？
3. 判斷屬於哪一類。
4. 選對應的解法，不要直接套某個技術。
