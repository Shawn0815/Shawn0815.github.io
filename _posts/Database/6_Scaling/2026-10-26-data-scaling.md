---
title: "[Database]  Data Scaling：Partitioning 與 Sharding"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Scaling"]
tags: []
order: "000006_scaling/000006.000004_data-scaling.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/6_Scaling/6.4_Data-Scaling.md
render_with_liquid: false
---

## Abstract

Data-heavy 是資料量本身太大，超出單機適合管理的範圍，一天只有 100 個人查也可能很慢。
同一台還放得下時，用 Partitioning 把大表切成多個區塊，查詢只掃需要的部分；一台放不下時，用 Sharding 把資料分到多台資料庫，代價是跨 shard 的查詢、`JOIN`、Transaction 都變難。

---

## 資料太大為什麼會慢

資料庫不只存資料，還要維護 index、統計資訊、備份和復原。
orders 從 10 萬筆長到 100 億筆，即使有 index 也會遇到：

- Index 越來越大，記憶體放不下，只能頻繁讀 Disk。
- 排序、`JOIN`、`GROUP BY` 的 CPU 成本變高。
- 50 TB 的資料庫備份要幾小時甚至幾天，壞掉時復原也很久。
- 30 TB 的資料、20 TB 的硬碟，就是放不下。

---

## Partitioning

大部分查詢只查最近三個月或今年的訂單，很少查 10 年前的，那就沒必要全部放在一起。

Partitioning 把一張大表切成多個區塊，**對程式來說仍然是同一張表**：

```sql
SELECT * FROM orders WHERE order_date >= '2026-01-01';
-- 程式查的還是 orders，資料庫內部是 2024、2025、2026 三個 partition
```

資料庫依 Partition Key 決定資料放在哪一塊。

| 切法 | 怎麼切 | 例子 |
|---|---|---|
| Range Partition | 依範圍，通常是時間 | 每年一塊，訂單系統最常見 |
| Hash Partition | 依某欄位的 hash | `user_id % 4`，資料平均分散 |

上面的查詢只會看 2026 那一塊，不用掃全部，這叫 Partition Pruning，是 Partitioning 變快的主要原因。

### 限制

- Partition Key 要選對：用 `order_date` 切，`WHERE user_id = 123` 不一定有幫助，可能還是要掃多個 partition。
- 跨 partition 的查詢（2024 到 2026）還是要查所有 partition。
- **所有 partition 還在同一台機器上**，CPU、記憶體、儲存空間的上限沒變，單機撐不住時解決不了。

---

## Sharding

一台放不下，就分到很多台，每台只負責一部分資料：

```txt
DB1：User 1 ~ 30 億
DB2：User 30 ~ 60 億
DB3：User 60 ~ 100 億
```

整個系統的儲存、CPU、記憶體都跟著變大。

最常見的是依 `user_id` 切，例如 `user_id % 4` 決定在哪個 shard，User 1 和 User 5 永遠在 Shard 1。
查詢時先算出 shard 再去查，所以需要定義 Shard Key 和 Routing Rule。

### 代價

資料分散在不同資料庫，很多事變複雜：

- 跨 shard 查詢：依 `user_id` 切，查「2026 年以後的所有訂單」就要查每一個 shard 再合併。
- `JOIN` 變難：users 和 orders 可能不在同一台，`JOIN` 要改成在程式裡組裝。
- Transaction 變難：Shard A 扣款、Shard B 加款，變成 Distributed Transaction。

---

## Partitioning vs Sharding

| | Partitioning | Sharding |
|---|---|---|
| 在哪 | 同一台資料庫內切大表 | 分到多台資料庫 |
| 目的 | 提升查詢效率、降低維護成本 | 突破單機容量上限 |
| 程式看到的 | 還是一張表 | 要知道資料在哪個 shard |

同一台還放得下就 Partitioning，一台放不下才 Sharding。
