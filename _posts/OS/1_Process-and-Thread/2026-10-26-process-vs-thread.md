---
title: "[OS]  Process vs Thread"
date: 2026-10-26 18:46 +0800
categories: ["OS", "Process and Thread"]
tags: []
order: "000001_process-and-thread/000001.000001_process-vs-thread.md"
image: {path: "/assets/img/covers/OS.png"}
source: DDAN_Usandbox/0_Personal/OS/1_Process-and-Thread/1.1_Process-vs-Thread.md
render_with_liquid: false
---

## Abstract

Process 是作業系統分配資源的單位，目的是隔離：每個 Process 有獨立的記憶體，一個崩潰不會直接波及其他程式。
Thread 是 CPU 排程的單位，目的是並行：同一個 Process 裡的多個 Thread 共享記憶體，一邊等網路，畫面還能繼續回應。
Thread 建立和切換都比 Process 便宜，但共享記憶體也帶來 Race Condition。

---

## Process：程式之間的隔離

Chrome、VS Code、Spotify 同時在跑，如果共用同一塊記憶體，Chrome 的 bug 寫壞記憶體就可能弄壞 VS Code 的資料，甚至讓整台電腦當機。

每個 Process 有自己獨立的：

- Memory Space：Code、Data、Heap、Stack。
- Address Space：虛擬位址空間。
- System Resources：檔案、網路連線。

Chrome 崩潰只發生在自己的記憶體空間裡。

---

## Thread：程式內的並行

如果 Chrome 只有一條執行流程，下載圖片要 3 秒，這 3 秒內畫面就完全卡死。
所以 Process 裡再拆成多個 Thread 同時跑：

- UI Thread：畫面和使用者互動。
- Network Thread：下載資料。
- Render Thread：渲染網頁。

Network Thread 在等網路時，UI Thread 照樣回應使用者。

---

## 差別

| | Process | Thread |
|---|---|---|
| 單位 | 資源分配 | CPU 排程 |
| 記憶體 | 獨立，彼此看不到 | 共享 Code、Data、Heap；各自有 Stack 和 Register |
| 溝通 | 要透過 IPC，成本高 | 直接用共享變數，快 |
| 一個掛掉 | 通常不影響其他 Process（Chrome 每個分頁是獨立 Process） | 寫壞共享資料會影響其他 Thread，甚至整個 Process 一起崩潰 |
| 建立成本 | 高：要建 Address Space、Memory Mapping、Resource Table | 低：共用 Process 的記憶體，只多配一塊 Stack |
| 切換成本 | 高：還要切換 Page Table | 低：同一個 Address Space，不用切 Page Table |

Web Server、資料庫、後端服務要處理大量並發 request，所以大量使用 Multi-thread。

---

## Context Switch

CPU 同時只能跑少量工作，作業系統要不斷在不同流程之間切換，讓每個工作都有機會執行。
切換前保存目前流程的 Register、Program Counter（執行到哪一行）、執行狀態，下次輪到時再恢復。

==Context Switch 本身不做任何業務邏輯==，純粹是保存和恢復狀態的額外開銷，切換越頻繁，浪費的 CPU 時間越多。

---

## 共享記憶體的代價：Race Condition

共享變數 `balance = 100`，兩個 Thread 同時 `balance -= 10`。
如果兩個都先讀到 100、各自扣完再寫回，結果是 90 而不是 80，第二個寫回的蓋掉了第一個。

要用 Mutex、Semaphore 這類同步機制保護共享資源，確保同一時間只有一個 Thread 能存取。
