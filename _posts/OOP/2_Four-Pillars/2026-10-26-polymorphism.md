---
title: "[OOP]  Polymorphism"
date: 2026-10-26 18:46 +0800
categories: ["OOP", "Four Pillars"]
tags: []
order: "000002_four-pillars/000002.000003_polymorphism.md"
image: {path: "/assets/img/covers/OOP.png"}
source: DDAN_Usandbox/0_Personal/OOP/2_Four-Pillars/2.3_Polymorphism.md
render_with_liquid: false
---

## Abstract

Polymorphism 讓不同的 Object 透過同一個 Parent Type 或 Interface 被操作，但執行各自的實作。
呼叫端只依賴共同型別，不用知道每個具體 Class，可以減少 `instanceof` 和大量 `if-else`，新增實作時也不用改既有流程。
規則是：能呼叫哪些 Method 看 Compile-time Type（變數的型別），Override 的 Method 實際跑哪個版本看 Runtime Type（實際的 Object）。

---

## 基本例子

```java
Animal first = new Dog();
Animal second = new Cat();

first.speak();
// → Woof
second.speak();
// → Meow
```

變數型別都是 `Animal`，實際 Object 分別是 Dog 和 Cat，所以執行各自 Override 的 `speak()`。

---

## 解決什麼問題

沒有多型時，結帳流程要知道每一種付款方式：

```java
void checkout(Object payment) {
    if (payment instanceof CreditCardPayment) {
        ((CreditCardPayment) payment).payByCreditCard();
    } else if (payment instanceof LinePayPayment) {
        ((LinePayPayment) payment).payByLinePay();
    }
    // 每多一種付款方式就要改這裡
}
```

定義共同的 Interface，結帳只依賴它：

```java
interface Payment {
    void pay();
}

class CreditCardPayment implements Payment {
    @Override
    public void pay() { System.out.println("Pay by credit card"); }
}

void checkout(Payment payment) {
    payment.pay();
}

checkout(new CreditCardPayment());
checkout(new LinePayPayment());
```

新增 `ApplePayPayment` 時，`checkout` 不用改。

---

## Compile-time Type 與 Runtime Type

```java
Animal animal = new Dog();
// Animal：Reference 的型別，Compile-time Type
// Dog：實際 Object 的型別，Runtime Type
```

- Compile-time Type 決定能呼叫什麼：`animal.speak()` 可以，因為 Animal 有定義；`animal.bark()` 編譯錯誤，即使實際是 Dog。
- Runtime Type 決定 Override 的 Method 跑哪個版本：`animal.speak()` 執行 `Dog.speak()`。

執行時依實際 Object 選版本，叫 Dynamic Method Dispatch：

```txt
Compiler：Animal 有沒有 speak()？有，可以編譯
Runtime：animal 實際是 Dog，Dog 有 Override speak()，執行 Dog.speak()
```

Parent Type 能指向 Child Object，是因為 Inheritance 建立了 is-a 關係：Dog 符合 Animal 代表的特徵和行為。

---

## 三者的關係

| | 做什麼 |
|---|---|
| Inheritance（或 Interface） | 建立共同類型：Dog is an Animal |
| Override | Child 提供不同的實作 |
| Polymorphism | 透過共同型別呼叫，依實際 Object 執行不同版本 |

Runtime Polymorphism 只發生在可以被 Override 的 Instance Method：

- `static` Method 是 Method Hiding。
- `private`、`final` Method 不能被 Override。
- ==Field 沒有多型==，用哪個看 Reference Type：

```java
class Animal { String type = "Animal"; }
class Dog extends Animal { String type = "Dog"; }

Animal animal = new Dog();
System.out.println(animal.type);
// → Animal
```

改成 Override 的 `getType()` 才會得到 `Dog`。

---

## Upcasting 與 Downcasting

```java
Animal animal = new Dog();     // Upcasting：Child 當成 Parent，安全，不用明確轉型

Dog dog = (Dog) animal;        // Downcasting：轉回 Child，才能呼叫 bark()
dog.bark();
```

Downcasting 可能失敗：實際是 Cat 卻轉成 Dog，會丟出 `ClassCastException`。
先判斷：

```java
if (animal instanceof Dog dog) {
    dog.bark();
}
```

**程式裡到處都是 `instanceof` 加 Downcasting，通常代表呼叫端還在依賴具體 Class**，要檢查共同型別是不是少定義了需要的行為。

---

## Overloading vs Overriding

| | Overloading | Overriding |
|---|---|---|
| 在哪 | 通常同一個 Class | Parent / Child |
| 參數 | 必須不同 | 必須相同 |
| 誰決定 | Compiler 依參數決定 | Runtime 依實際 Object 決定 |
| 又稱 | Compile-time Polymorphism | Runtime Polymorphism |

Parent 是 `speak()`、Child 寫 `speak(String message)`，參數不同，這是 Overloading，不是 Override。

---

## 限制

- 只能用共同型別提供的操作：選擇依賴 Animal，就只依賴 Animal 承諾的行為。
- Parent 設計不合理會影響所有 Child：Bird 有 `fly()`，Penguin 就無法遵守。
- 不是所有 `if-else` 都要改成多型；適合的是「不同 Object、共同操作、各自實作」的情況。
