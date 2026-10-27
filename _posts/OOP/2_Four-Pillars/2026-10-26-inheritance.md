---
title: "[OOP]  Inheritance"
date: 2026-10-26 18:46 +0800
categories: ["OOP", "Four Pillars"]
tags: []
order: "000002_four-pillars/000002.000002_inheritance.md"
image: {path: "/assets/img/covers/OOP.png"}
source: DDAN_Usandbox/0_Personal/OOP/2_Four-Pillars/2.2_Inheritance.md
render_with_liquid: false
---

## Abstract

Inheritance 在 Class 之間建立 Parent / Child 關係，Child 取得 Parent 的共同資料和行為，再加入或改寫自己的部分。
它更重要的作用是建立「Child is-a Parent」的共同類型，讓 Child 能用在需要 Parent 的地方，這是 Polymorphism 的基礎。
只在穩定、合理的 is-a 關係用 Inheritance；只是想用某個功能時，優先用 Composition。

---

## 基本寫法

```java
class Animal {
    protected String name;

    public void eat() {
        System.out.println("Animal eats");
    }
}

class Dog extends Animal {
    public void bark() {
        System.out.println("Dog barks");
    }
}

Dog dog = new Dog();
dog.name = "Lucky";
dog.eat();     // 從 Animal 來
dog.bark();    // Dog 自己的
```

建立 Dog 時只有一個 Dog Object，裡面同時有 Animal 定義的部分（`name`）和 Dog 新增的部分。

---

## 解決的兩個問題

- 集中共同內容：Dog、Cat、Lion 都有 `name`、`eat()`、`sleep()`，各寫一份的話規則一改就要到處改、容易不一致。放到 Animal，共同規則只維護一份。
- 建立共同類型：Dog is an Animal、Cat is an Animal，所以可以 `Animal a = new Dog()`、`List<Animal>` 同時放 Dog 和 Cat。

Parent 是比較一般的類型，Child 是更具體的一種：每個 Dog 都是 Animal，但不是每個 Animal 都是 Dog。

---

## Child 能用 Parent 的哪些成員

| Parent 的成員 | Child 能直接用嗎 |
|---|---|
| `public` | 可以，外部也可以 |
| `protected` | 可以 |
| `private` | 不行，Child Object 裡還是有這個狀態，但要透過 Parent 提供的方法操作 |
| Constructor | 不會被繼承 |

---

## Constructor 與 super

建立 Child Object 時，先初始化 Parent 的部分，再初始化 Child 的部分：

```java
class Animal {
    protected String name;

    Animal(String name) {
        this.name = name;
        System.out.println("Animal Constructor");
    }
}

class Dog extends Animal {
    private String breed;

    Dog(String name, String breed) {
        super(name);               // 呼叫 Parent 的 Constructor
        this.breed = breed;
        System.out.println("Dog Constructor");
    }
}

new Dog("Lucky", "Shiba");
// → Animal Constructor
// → Dog Constructor
```

沒寫 `super(...)` 時，Compiler 會自動補 `super()`。
**Parent 只有帶參數的 Constructor 時，Child 一定要明確呼叫 `super(...)`**，否則會去找不存在的 `super()`，編譯失敗。

`super.speak()` 是在 Override 之後仍然呼叫 Parent 原本的版本。

- `this`：目前這個 Object。
- `super`：指定用 Parent Class 定義的版本，不是另一個 Parent Object。

---

## Method Override

Child 保留 Parent Method 的形式，重新提供自己的實作：

```java
class Animal {
    public void speak() { System.out.println("Animal sound"); }
}

class Dog extends Animal {
    @Override
    public void speak() { System.out.println("Woof"); }
}

class Cat extends Animal {
    @Override
    public void speak() { System.out.println("Meow"); }
}
```

規則：

- 名稱和參數必須相同，回傳型別相同或相容。
- 存取權限不能比 Parent 嚴格。
- `private`、`final` Method 不能 Override。
- `static` Method 是 Method Hiding，不是 Override。

**加上 `@Override`**：不小心把參數寫錯（`speak(String message)`），Compiler 會指出它沒有覆寫任何 Method。

Parent 和 Child 定義同名的 Field 會兩個同時存在（Field Hiding），用哪一個看 Reference 的型別，很容易混淆，避免這樣寫。

---

## 問題

- 耦合高：Child 依賴 Parent 的 Field、Method、Constructor、`protected` 成員，Parent 一改所有 Child 都可能受影響。
- 只為了重用而錯誤繼承：Car 和 AirConditioner 都有 `turnOn()`，但 Car is not an AirConditioner。
- Parent 的內容不適用所有 Child：Penguin 是 Bird 但不會飛，問題是 `fly()` 根本不是所有 Bird 共有的。**Child 常常需要把 Parent Method 寫成空的或丟出不支援的錯誤，代表 Parent 抽錯了。**
- 層級太深：A → B → C → D，理解 D 要一路追 Field 和 Override 在哪一層。

---

## 什麼時候適合

- 真的有 is-a 關係：Dog is an Animal 合理，Car is an Engine 不合理。
- Parent 的內容適用所有 Child。
- 需要 Parent 的地方傳入 Child 仍能正常運作：`feed(Animal a)` 傳 Dog、Cat 都能合理 `eat()`。
- 類型關係穩定；需要經常替換、動態組合的功能，改用 Composition。

---

## Inheritance vs Composition

Composition 是讓一個 Object 持有另一個，使用它的功能（has-a / uses-a）：

```java
class Car {
    private final Engine engine;

    Car(Engine engine) {
        this.engine = engine;
    }

    void start() {
        engine.start();    // 交給 Engine 做（Delegation）
    }
}
```

不能因為 Car 需要引擎的功能就寫 `class Car extends Engine`，那代表 Car is an Engine。

| | Inheritance | Composition |
|---|---|---|
| 關係 | is-a | has-a / uses-a |
| 功能來源 | 從 Parent 取得 | 呼叫持有的 Object |
| 彈性 | Class 定義時就固定 | 元件容易替換 |
| 耦合 | 通常較高 | 較容易控制 |
| 適合 | 穩定的類型關係 | 功能組合和替換 |

Composition over Inheritance 不是不用 Inheritance，而是不要只為了取得某個功能就建立不合理的 Parent / Child 關係。
