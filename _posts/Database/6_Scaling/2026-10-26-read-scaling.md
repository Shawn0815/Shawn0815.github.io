---
title: "[Database]  Read Scaling：Cache 與 Read Replica"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Scaling"]
tags: []
order: "000006_scaling/000006.000002_read-scaling.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/6_Scaling/6.2_Read-Scaling.md
render_with_liquid: false
---

## Abstract

Read-heavy 是大量使用者一直在讀資料，壓力來自 `SELECT`。
先問「這個查詢能不能不打資料庫」：能就用 Cache 減少查詢；不能就用 Read Replica 把查詢分散到多台；連舊資料都不能接受的就查 Primary。
兩者都可能讀到舊資料，這是要接受的取捨。

---

## Cache

首頁的熱門商品，100 萬人進站就執行同一個查詢 100 萬次：

```sql
SELECT * FROM products ORDER BY sales_count DESC LIMIT 20;
```

但排行榜可能 10 分鐘才變一次，這 100 萬次的結果幾乎一樣。
Cache 就是把常用資料暫存在更快的地方（例如 Redis），之後直接回傳，不打資料庫。

### Cache Aside

業界最常見的用法：

```txt
查詢 → Cache Miss → 查資料庫 → 寫入 Cache → 回傳
查詢 → Cache Hit → 直接回傳
```

### 適合什麼資料

- 適合：讀很多、改很少的資料，例如熱門商品、排行榜、首頁推薦、分類列表、商品資訊。
- 不適合：變化頻繁的資料，例如購物車、即時庫存、銀行餘額。

### 資料會過期

商品價格從 100 改成 120，資料庫更新了，Cache 還是 100，使用者看到舊資料（Stale Data）。
==Cache 很快，但不保證是最新的。==

兩種處理方式：

- TTL：設定有效時間（例如 5 分鐘），時間到自動刪除，下次查詢重建。
- Cache Invalidation：更新資料庫後刪除 Cache，下次查詢 Cache Miss 再重建。

### 放不下全部

記憶體很貴，1 TB 的資料庫不可能全部放進 32 GB 的 Redis。
Cache 只放熱門、重複查詢多的資料。

100 萬次查詢中 95 萬次直接命中 Cache、只有 5 萬次查資料庫，就是 95% 的 Cache Hit Rate。
提高 Hit Rate 不是放更多資料，而是把最常被查的放進去。

---

## Read Replica

訂單查詢、搜尋結果、個人資料每個人查到的都不同，Cache 效果有限，一定要查資料庫。
這時用多台分擔：

```txt
Primary      → 負責寫入
Replica 1~3  → 負責讀取（100 萬次查詢分給多台）
```

- Cache：盡量不要查資料庫（減少查詢）。
- Read Replica：查資料庫沒關係，但不要只查一台（分散查詢）。

### Replication Lag

Primary 同步到 Replica 需要時間。
Primary 的庫存已經是 8，Replica 還是 9，這時查 Replica 會看到舊資料。

沒有完美解法，看資料能接受多舊：

| 資料 | 做法 |
|---|---|
| 商品列表、排行榜、文章列表 | 接受幾百毫秒到幾秒的不一致 |
| 剛改的個人資料、剛建立的訂單 | Read Your Own Write：剛寫入的人暫時直接查 Primary |
| 銀行餘額、付款結果、即時庫存 | 永遠查 Primary |

---

## 怎麼選

```txt
很多人查同一份資料，能避免查 DB → Cache
一定要查 DB                     → Read Replica
連舊資料都不能接受               → Primary
```
