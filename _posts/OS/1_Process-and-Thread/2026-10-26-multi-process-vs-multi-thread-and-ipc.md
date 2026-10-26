---
title: "[OS]  Multi-process vs Multi-thread 與 IPC"
date: 2026-10-26 18:46 +0800
categories: ["OS", "Process and Thread"]
tags: []
order: "000001_process-and-thread/000001.000002_multi-process-vs-multi-thread-and-ipc.md"
image: {path: "/assets/img/covers/OS.png"}
source: DDAN_Usandbox/0_Personal/OS/1_Process-and-Thread/1.2_Multi-process-vs-Multi-thread-and-IPC.md
render_with_liquid: false
---

## Abstract

要加速一個任務時，用多個 Process 還是多個 Thread，看的是要不要隔離、要不要共享資料：要隔離、要吃滿多核心做運算，用 Process；要共享資料、輕量、撐大量並發，用 Thread。
Process 之間記憶體隔離，要靠 IPC 溝通；Thread 之間直接共享記憶體，但要自己處理同步。
Shared Memory 是效能最好的 IPC，也是最危險的，因為它完全不幫你同步。

---

## 怎麼選

| | Multi-process | Multi-thread |
|---|---|---|
| 適合 | 任務要隔離，一個崩潰不能影響其他；CPU-bound，要用多核心平行運算 | 任務要頻繁共享資料；I/O-bound，要處理大量並發 |
| 例子 | Chrome 每個分頁一個 Process；Python 的 CPU-bound 任務（GIL 讓同一時間只有一個 Thread 跑 Python 程式碼） | 爬蟲共用「已爬過的網址」清單；Web Server 同時處理很多在等網路或資料庫的 request |

例子：

- 爬蟲開 100 個 worker：大部分時間在等網路（I/O-bound），又要共用已爬過的清單，用 Multi-thread，清單只要一份記憶體加 Lock 保護。
- 100 張圖片做辨識：CPU-bound、彼此獨立、不用共享，用 Multi-process，真正平行運算，一個出錯也不會拖垮整批。

也常見混合架構：Nginx 用 Multi-process（每個 worker 一個 Process，確保穩定），worker 內部用 event loop 處理大量連線。

---

## IPC：Process 之間怎麼溝通

| 方式 | 說明 |
|---|---|
| Pipe | 有親緣關係的 Process 之間，單向 |
| Named Pipe（FIFO） | 用檔案路徑識別，沒親緣關係也能用 |
| Message Queue | Kernel 維護的訊息佇列，適合一筆一筆離散、有結構的訊息 |
| Shared Memory | 多個 Process 共用同一塊實體記憶體，效能最好 |
| Socket | 唯一能跨機器（TCP / UDP），但要經過網路協定層，開銷較高 |
| Signal | 只通知事件，不帶資料，例如 `SIGKILL`、`SIGTERM` |

快速判斷：

- 只是通知事件：Signal。
- 少量、離散的訊息：Message Queue。
- 大量資料、講求效能：Shared Memory。
- 要跨機器：Socket。

Thread 之間不需要 IPC，本來就共享 Heap 和全域變數，可以直接用共享變數溝通，但要自己處理同步。

---

## Shared Memory

作業系統開一塊實體記憶體，讓多個 Process 各自 map 到自己的虛擬位址空間，讀寫起來就像自己的變數。

為什麼最快：Pipe、Message Queue 的資料要從一個 Process 的 User Space 寫進 Kernel，再複製到另一個 Process，來回複製兩次；Shared Memory 直接讀寫同一塊記憶體，不經過 Kernel 複製。

==代價是作業系統不幫你同步。==
兩個 Process 同時讀到同一個計數器、各自加 1 寫回，就會少加一次。
要自己保護 critical section：

- Semaphore：控制同時能進入的 Process 數量。
- Mutex：同一時間只有一個，等於數量為 1 的 Semaphore。

常見應用：資料庫的 shared buffer pool（多個連線 Process 共用同一份快取，不用重複讀磁碟）、多個 worker 共用設定或快取資料。
