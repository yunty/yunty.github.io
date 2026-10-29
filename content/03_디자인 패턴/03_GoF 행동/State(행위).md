---
title: State(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# State
상태 패턴

---
## 개념
객체가 특정 상태에 따라 동작 혹은 결과가 달라지는 구조라면 상태 자체를 객체화하는 패턴임
- 예를 들면 `boolean litght` 에서 light가 켜지고 꺼지고에 따라 다른 동작을 해야한다면?

#### 구조
- State 인터페이스
	- 상태를 추상화
- ConcreteState
	- 인터페이스를 구현 및 상태별 동작에 대해서도 구현한다.
- Context
	- 구현해둔 상태를 합성을 통해 사용하는 공간
	- 원래는 여기에 상태가 있고 그 상태별 메소드가 있었다면
	- 여기의 상태를 객체로 뺸게 State패턴 그자체

## 장·단점
#### 장점


#### 단점

## 사용 방법 
#### State 인터페이스
```java
interface PowerState {
    void powerButtonPush(LaptopContext cxt);

    void typebuttonPush();
}
```
#### Concrete State
```java
class OnState implements PowerState {
    @Override
    public void powerButtonPush(LaptopContext cxt) {
        System.out.println("노트북 전원 OFF");
        cxt.changeState(new OffState());
    }

    @Override
    public void typebuttonPush() {
        System.out.println("키 입력");
    }

    @Override
    public String toString() {
        return "노트북이 전원 ON 인 상태 입니다.";
    }
}

class OffState implements PowerState {
    @Override
    public void powerButtonPush(LaptopContext cxt) {
        System.out.println("노트북 전원 ON");
        cxt.changeState(new OnState());
    }

    @Override
    public void typebuttonPush() {
        throw new IllegalStateException("노트북이 OFF 인 상태");
    }

    @Override
    public String toString() {
        return "노트북이 전원 OFF 인 상태 입니다.";
    }
}

class SavingState implements PowerState {
    @Override
    public void powerButtonPush(LaptopContext cxt) {
        System.out.println("노트북 전원 on");
        cxt.changeState(new OnState());
    }

    @Override
    public void typebuttonPush() {
        throw new IllegalStateException("노트북이 절전 모드인 상태");
    }

    @Override
    public String toString() {
        return "노트북이 절전 모드 인 상태 입니다.";
    }
}

//혹은 싱글톤 패턴 적용
class OnState implements PowerState {

	// Thread-Safe 한 싱글톤 객체화
    private OnState() {}
    private static class SingleInstanceHolder {
        private static final OnState INSTANCE = new OnState();
    }
    public static OnState getInstance() {
        return SingleInstanceHolder.INSTANCE;
    }

    @Override
    public void powerButtonPush(LaptopContext cxt) {
        System.out.println("노트북 전원 OFF");
        cxt.changeState(OffState.getInstance()); // 싱글톤 객체 얻기
    }

    @Override
    public void typebuttonPush() {
        System.out.println("키 입력");
    }

    @Override
    public String toString() {
        return "노트북이 전원 ON 인 상태 입니다.";
    }
}

// ...
```
#### Context
```java
class LaptopContext {
    PowerState powerState; // 합성하여 사용

    LaptopContext() {
        this.powerState = new OffState();
    }

    void changeState(PowerState state) {
        this.powerState = state;
    }

    void setSavingState() {
        System.out.println("노트북 절전 모드");
        changeState(new SavingState());
    }

    void powerButtonPush() {
        powerState.powerButtonPush(this);
    }

    void typebuttonPush() {
        powerState.typebuttonPush();
    }

    void currentStatePrint() {
        System.out.println(powerState.toString());
    }
}
```
#### 사용자
```java
class Client {
    public static void main(String[] args) {
        LaptopContext laptop = new LaptopContext();
        laptop.currentStatePrint();
    
        // 노트북 켜기 : OffState -> OnState
        laptop.powerButtonPush();
        laptop.currentStatePrint();
        laptop.typebuttonPush();
 
        // 노트북 절전하기 : OnState -> SavingState
        laptop.setSavingState();
        laptop.currentStatePrint();

        // 노트북 다시 켜기 : SavingState -> OnState
        laptop.powerButtonPush();
        laptop.currentStatePrint();
 
        // 노트북 끄기 : OnState -> OffState
        laptop.powerButtonPush();
        laptop.currentStatePrint();
    }
}
```



[출처 : inpa.tistory.com](https://inpa.tistory.com/entry/GOF-💠-상태State-패턴-제대로-배워보자)