---
layout: post
title: Medium | Leetcode 347. Top K Frequent Elements
date: 2025-12-08 18:35 +0800
author: shawn_yu
categories: [Leetcode, Array & Hashing, Medium]
tags: [Leetcode, Java]
image: {path: "/assets/img/2025-06-20-16-16-28.png"}
math: true

topic: "Array & Hashing"
level: "Medium"
class: "🧠 Blind 75"
important: "⭐️⭐️⭐️"
company: "Google, Amazon"
leetcode_url: "https://leetcode.com/problems/top-k-frequent-elements/"
neetcode_url: "https://neetcode.io/problems/top-k-elements-in-list"
---

# 題目描述

給定一個整數陣列 nums 和一個整數 k，請回傳出現頻率最高的 k 個元素。

例如：假設 k = 2，就回傳 nums 陣列中出現頻率較高的 2 個元素。

![](/assets/img/2025-12-08-18-38-39.png)

---

# 解法

## 一開始的想法

這題老實說我一開始沒有什麼頭緒，是看解答才會的。

比較正統的解法應該是 HashMap 跟 Bucket Sort。

---

## 解法 1: Sorting

### 解題概念

1. 用一個 Hashmap 把每個元素跟他出現過的次數記錄起來。
2. 由於 Map 無法排序，我們把 Map 轉為 List，每個 List 的元素為 map 中的 entry。
3. **對 List 的每個元素的 value 做排序**，由大到小（降序）。
4. 最後拿出 List 中前 K 個元素的「數字」（key）做為結果 return。

### 程式碼

```java
public class Solution1 {
    public int[] topKFrequent(int[] nums, int k) {

        // 把 array 轉成 HashMap（key=數字，value=出現次數）
        Map<Integer, Integer> frequencyMap = arrayToMapWithFreqency(nums);

        // 建立一個 list，每個元素為 map 中的 entry
        List<Map.Entry<Integer, Integer>> list = new ArrayList<>();
        
        // 把 map 元素依序放入 List 中，並
        for (Map.Entry<Integer, Integer> entry: frequencyMap.entrySet()) {
            list.add(entry);
        }

        // 將 list 以 value 作為排序
        list.sort(Map.Entry.comparingByValue(Comparator.reverseOrder()));

        // 建立大小為 K 的回傳 array
        int[] topK = new int[k];

        // 將 heap 中的元素的數字部分放入 array 中（由於 min heap：先取出的要放入 array 尾端）
        for (int i = 0; i < k; i++) {
            topK[i] = list.get(i).getKey();
        }

        return topK;

    }

    public Map<Integer, Integer> arrayToMapWithFreqency(int[] nums) {
        
        Map<Integer, Integer> map = new HashMap<>();

        for (int num: nums) {
            map.put(num, map.getOrDefault(num, 0) + 1);
        }

        return map;

    }
}
```

### 複雜度分析

- Time complexity: $O(n \ logn)$
    - 遍歷 num 所有元素存入 Map：O(n)。
    - 將 Map 轉為 List：O(m)，m 為 Map 的 key 個數；最壞為 O(n)，n 為 num 長度。
    - 對 List 做排序：Java 底層使用 Timesort，複雜度為 O(m logm)；最壞為 O(n logn)。
    - 取出前 K 個元素：O(k) => 總共：O(n logn)。
- Space complexity: $O(n)$
    - 儲存 Map：O(m)，最壞O(n)。
    - 儲存 List：O(m)，最壞O(n)。
    - 儲存結果陣列：O(k) => 總共：O(n)。

---

## 解法 2: Min heap

### 解題概念

這題可以用 minHeap 的概念去想：

1. 一樣先用 HashMap 紀錄每個數字與出現頻率。
2. 用一個 minHeap 存放 Map entry，並預設用 value 做排序（也就是出現頻率最小會放 heap 頂端）。
3. **重點：維持 heap大小為K，若超過，移除頂端元素**（出現頻率最低）。
    
    ⇒  這樣 heap 中的元素就會是出現頻率最高的 k 個元素，由小排到大。
    
4. 最後將 heap 中的元素依序取出，並取出數字部分，放入 array 中。

要注意的點：

- PriorityQueue 中存放的是 map entry，語法：`Map.Entry<Integer, Integer>` 。
- PriotiryQueue 括號中可以設定要以什麼欄位排序，我是以 map entry 的 value 做排序（小排到大），也就是每個數字出現頻率由小排到大，語法：`(a, b) -> a.getValue() - b.getValue()` ，a,b 代表 map entry。
- 最後取出 heap 中的數字時，會把頂端元素放到陣列尾端，這樣才會由頻率大排到小。

### **程式碼**

```java
public class Solution2 {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> map = new HashMap<>();

        // 把 array 轉成 HashMap（key=數字，value=出現次數）
        for (int num: nums) {
            map.put(num, map.getOrDefault(num, 0) + 1);
        }
        
        // 建立一個 Min heap，其中每個元素為 map 中的 entry（以 map 的 value 作為排序，升序）
        PriorityQueue<Map.Entry<Integer, Integer>> minHeap = new PriorityQueue<>((a, b) -> a.getValue() - b.getValue());

        // 將 map 中的資料一一加入 heap 中
        for (Map.Entry<Integer, Integer> entry: map.entrySet()) {
            minHeap.offer(entry);

            // heap 維持前 K 大的元素
            if (minHeap.size() > k) {
                minHeap.poll();
            }
        }

        // 建立大小為 K 的回傳 array
        int[] topK = new int[k];

        // 將 heap 中的元素的數字部分放入 array 中（由於 min heap：先取出的要放入 array 尾端）
        for (int i = k - 1; i >= 0; i--) {
            topK[i] = minHeap.poll().getKey();
        }

        return topK;

    }
}
```

### 複雜度分析

- Time complexity: $O(n\ logk)$
    - 遍歷 num 所有元素存入 Map → O(n)。
    - **Heap insert 跟 poll 複雜度都為 O(log k)**，k 為 heap 大小。
        - 將 map 中元素放入 heap，總共最多 n 次，heap 大小為 k → O(n logk)。
        - 若 heap 大小大於 k，需要移除 heap 元素，最多 n 次 → O(n logk)。
        - 最後依序取出 heap 元素放入陣列 → O(k logk)。
- Space complexity: $O(n + k)$
    - 儲存 Hashmap，最壞狀況大小為 n → O(n)。
    - 儲存 Heap：最多 k 個元素 → O(k)。
    - 儲存結果陣列，大小為 k → O(k)。

<aside>
💡

**總結：**

Heap 解法已經很好了，複雜度符合題目要求，但還有更好的解法：Bucket Sort。

</aside>

---

## 解法 3: Bucket Sort

### 解題概念

這題的核心想法不好想但也不難：

1. 先用 HashMap 紀錄每個數字與出現次數。
2. **用一個 frequency Array 統計每一種出現次數對應的數字：**
    1. Array 的 index 為出現次數，**最大為 num 個數**（若所有數字相同，num 個數為最大出現次數）。
    2. Array 的 value 為對應到這個次數的數字 List，**記得要初始化 array 每個元素為空的 List**。
3. 依序 loop Map 中每個數字加入 frequency array 對應的次數格子中。
4. 最後從 index 最大開始遍歷整個 freqncy array（出現次數最多），依序加入 result 陣列中，若收集到 k 個數字，則停止並回傳。

需要特別注意的是：

- 創建 List Array 的語法如下：`List<Integer>[] freqArray = new List[arrSize];` ，不能用平常習慣的 `new ArrayList<>[arrSize]` ，因為 **Java 的陣列類型是不支援泛型的**。
- 最後收集結果陣列時，記得考慮一格的數量可能會使收集數字大於 k，所以只要收集到 k 個數字，就要提前回傳結果。

**&lt;示意圖&gt;**

![](/assets/img/2025-12-08-18-38-55.png)

### 程式碼

```java
public class Solution {
    
    public int[] topKFrequent(int[] nums, int k) {

        // 把 array 轉成 HashMap（key=數字，value=出現次數）
        Map<Integer, Integer> map = arrayToMapWithFreqency(nums);

        // 建立 freqArray：index 為出現次數，value 是對應到這個次數的所有數字 List
        List<Integer>[] freqArray = new List[nums.length + 1];

        // 初始化 List
        for (int i = 0; i < freqArray.length; i++) {
            freqArray[i] = new ArrayList<>();
        }

        // Loop map 中的元素，依序加入 freqArray
        for (Map.Entry<Integer, Integer> entry: map.entrySet()) {
            freqArray[entry.getValue()].add(entry.getKey());
        }

        // 建立大小為 K 的回傳 array
        int[] topK = new int[k];
        int index = 0;

        // 從 freqArray 最後一個元素開始 loop（出現次數最多的數字 list）
        for (int i = freqArray.length - 1; i >= 0; i--) {
            
            // 將 list 中的數字依序加入回傳 array
            for (int num: freqArray[i]) {
                
                topK[index] = num;
                index++;
            }

            // 如果回傳 array 大小 = k，return 結果
            if (index == k) {
                return topK;
            }
        }

        return topK;
    }

    public Map<Integer, Integer> arrayToMapWithFreqency(int[] nums) {
        
        Map<Integer, Integer> map = new HashMap<>();

        for (int num: nums) {
            map.put(num, map.getOrDefault(num, 0) + 1);
        }

        return map;

    }
}
```

### 複雜度分析

- Time complexity: $O(n)$
    - 遍歷 num 所有元素存入 Map：O(n)。
    - 初始化 List：O(n)。
    - 將 Map 中的元素加入 freqArray：O(m)，最壞為 O(n)。
    - 從 freqArray 中取出前 k 個數字：O(k)，最壞為 O(n)  ⇒  總共 O(n)。
- Space complexity: $O(n)$
    - HashMap大小：O(n)。
    - 桶空間最多 n+1：O(n)
    - 結果陣列大小為 k：O(k)。

<aside>
💡

**總結：**

這題用 Bucket Sort 最好是因為：頻率最大不會超過 n，可以用大小 n+1 的 bucket 統計所有可能頻率。

這樣就 **只需要掃描一次 bucket 陣列**，從頻率高到低，就可以找出 top k 數字。

</aside>

---

# 總結

這題 **面試優先使用 Min heap**，因為複雜度已經足夠，且簡單直覺，又能夠呈現自己懂 heap 的操作邏輯。

如果還有時間，可以再提出 Bucket Sort 解法做為最佳解。

---

# 參考資料

- [[LeetCode] 347. Top K Frequent Elements 前K个高频元素](https://www.cnblogs.com/grandyang/p/5454125.html)