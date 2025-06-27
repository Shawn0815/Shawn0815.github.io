# 347. Top K Frequent Elements

Description：Given an integer array  `nums`  and an integer  `k`, return  _the_  `k`  _most frequent elements_. You may return the answer in  **any order**.

Leetcode：https://leetcode.com/problems/top-k-frequent-elements/

Neetcode：https://neetcode.io/problems/top-k-elements-in-list

## Question

Given an integer array nums and an integer k, return the k most frequent elements. You may return the answer in any order.

![](./assets/img/IMG_6500.jpeg)

- - -

## Solution

### Solution 1: Sorting

**解題概念：**

1.  用一個hashmap把每個元素跟他出現過的次數記錄起來。
2.  由於Map無法排序，我們把Map轉為list，每個list的元素為一個陣列 [數字, 次數]。
3.  對list的第二個元素（出現次數）做排序，由大到小。
4.  最後拿出list中前K個元素的數字做為結果return。  
<br>

**程式碼：**

```java
public class Solution1 {
    public int[] topKFrequent(int[] nums, int k) {
        // 建立一個Hashmap
        Map<Integer, Integer> map = new HashMap<>();

        // 儲存數字與對應出現次數
        for (int num: nums) {
            map.put(num, map.getOrDefault(num, 0) + 1);
        }

        // 將Map轉為List，List每個元素為一個陣列（數字，出現次數）
        List<int[]> list = new ArrayList<>();

        // 遍歷Map中所有元素，並取出key, value
        for (Map.Entry<Integer, Integer> entry: map.entrySet()) {
            int[] arr = new int[2];
            arr[0] = entry.getKey();
            arr[1] = entry.getValue();
            list.add(arr);
        }

        // 對list的出現次數做排序，降序
        list.sort((a, b) -> Integer.compare(b[1], a[1]));

        // 將前K個元素取出其數字
        int[] result = new int[k];

        for (int i = 0; i < k; i++) {
            result[i] = list.get(i)[0];
        }

        return result;
    }
}

```  
<br>

**複雜度分析：**
- Time complexity: O(n logn)
    - 遍歷num所有元素存入map：O(n)
    -   將map轉為list：O(m)，m為map的key個數，最壞為O(n)
    -   排序：O(m logm)，最壞為 O(n logn)
    -   取出前K個元素：O(k) => 總共：O(n logn)
- Space complexity: O(n)
    - 儲存map：O(m)，最壞O(n)
    - 儲存list：O(m)，最壞O(n)
    - 儲存結果：O(k) => 總共：O(n)
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTQwNjk5Mjk0OV19
-->