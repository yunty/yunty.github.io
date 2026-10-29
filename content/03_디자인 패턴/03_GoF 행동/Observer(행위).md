---
title: Observer(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Observer
옵저버 패턴
사전적 의미 : 관찰자
#### 

---
## 개념
관찰하고 있는 대상의 상태가 변화될때마다 대상은 직접 목록의 각 관찰자들에게 통지하고 ,관찰자는 조치를 취하는 패턴
- 발행, 구독과도 같은 패턴
-  구독 해지를 안한사람들에게 계속 알림이 가는것과 같은것

#### 형태
1. ISubject
	- 관찰 대상자를 정의하는 인터페이스
	- Observer가 어떤걸 관찰할건지,,, 등
2. ConcreteSubject
	- 관찰 당하는 대상자 / 발행자 / 게시자
	- 관찰자들을 리스트로 모아서 합성하여 가지고 있음
	- 관찰자들을 등록, 삭제하는 인프라를 가지고 있다
	- 상태가 변하거나 동작을 실행할 때 관찰자들에게 알림을 보낸다.
3. IObserver
	- 구독자들을 묶는 인터페이스
4. Observer
	- 관찰자들은 Subject가 발행한 알림에 대해 현재 상태를 취득한다.
	- 업데이트에 대해 전후 정보를 처리한다.



## 장·단점

#### 장점
- 상태 변경을 계속 확인할 필요 없이 상태 변경시 알람이 오게 설정
- 새로운 관찰자를 확장할때 발행자의 코드를 수정하지 않아도 된다.
- 느슨한 결합으로 구성되어 결합도가 낮다.

#### 단점
- 무작위 순서로 알림
- 코드 복잡도 증가
- 해지를 제때 안하면 메모리 누수가 발생할 수도 있음

## 사용 방법 
```java
// 관찰 대상자 / 발행자
interface ISubject { // 관찰자들을 등록, 삭제, 알림보내기 할 수 있는 기능 선언
    void registerObserver(IObserver o);
    void removeObserver(IObserver o);
    void notifyObserver();
}

class ConcreteSubject implements ISubject {
    // 관찰자들을 등록하여 담는 리스트
    List<IObserver> observers = new ArrayList<>();

    // 관찰자를 리스트에 등록
    @Override
    public void registerObserver(IObserver o) {
        observers.add(o);
        System.out.println(o + " 구독 완료");
    }

    // 관찰자를 리스트에 제거
    @Override
    public void removeObserver(IObserver o) {
        observers.remove(o);
        System.out.println(o + " 구독 취소");
    }

    // 관찰자에게 이벤트 송신
    @Override
    public void notifyObserver() {
        for(IObserver o : observers) { // 관찰자 리스트를 순회하며
            o.update(); // 위임
        }
    }
}
```

#### 관찰자 설정
```java
// 관찰자 / 구독자
interface IObserver {
    void update();
}

class ObserverA implements IObserver {
    public void update() {
        System.out.println("ObserverA 한테 이벤트 알림이 왔습니다.");
        //알림을 받으면 뭘할지 추가 작성
    }

    public String toString() { return "ObserverA"; }
}

class ObserverB implements IObserver {
    public void update() {
        System.out.println("ObserverB 한테 이벤트 알림이 왔습니다.");
    }

    public String toString() { return "ObserverB"; }
}
```

#### 사용 방법
```java
public class Client {
    public static void main(String[] args) {

        // 발행자 등록
        ISubject publisher = new ConcreteSubject();

        // 발행자를 구독할 관찰자들 리스트로 등록
        IObserver o1 = new ObserverA();
        IObserver o2 = new ObserverB();
        publisher.registerObserver(o1);
        publisher.registerObserver(o2);

        // 관찰자에게 이벤트 전파
        publisher.notifyObserver();

        // ObserverB가 구독 취소
        publisher.removeObserver(o2);

        // ObserverA 한테만 이벤트 전파
        publisher.notifyObserver();
    }
}
```
