---
title: Proxy(구조)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Proxy
#### 프록시 패턴
사전적 의미 : 대리, 대리인

---
## 개념
사용자가 원본 객체에 직접 접근하지 못하게 중간에 대리 전달자 객체를 두고 사용하는것이다.
프록시 객체를 통해 접근하게 된다면 추가적으로 검증이나 로직을 처리한 뒤 접근하게 사용도 가능
#### 효과
- **보안** : 프록시는 클라이언트가 작업을 수행할 수 있는 권한이 있는지 확인하고 넘김
- **캐싱** : 프록시가 내부 캐시를 유지하여 데이터가 캐시에 아직 존재하는지 확인하고 넘김
- **데이터 유효성** 검사 : 입력받은 값이 유효한지 확인 후 넘김
- **지연 초기화** : 원본 객체의 인스턴스 객체를 생성하는 비용이 비싸다면 진짜 필요할때까지 미루다 넘김
- **로깅** : 입력값, 매개변수, 어떤 메소드를 호출했는지 기록할  수 있음
- **원격 객체** : 원격 위치에 있는 객체를 가져와서 로컬처럼 보이게 할 수 있다.
---
## 장·단점
#### 장점


#### 단점

---
## 사용 방법 / Lazy initialization 방법
- 원본 객체를 합성으로 사용한다.
- Subject : 원본 객체와 프록시를 묶어줄 인터페이스
- 원본객체의 메서드를 그대로 호출해서 사용하지만 이에 추가 작업을 실시할수 있음
- 결과값에 대해 조작이나 변경을 하면 안됨

#### Subject 인터페이스 생성
```java
interface ISubject {
    void action();
}// 원본 객체의 메서드를 그대로 작성해둔 인터페이스

class RealSubject implements ISubject {
    public void action() {
        System.out.println("원본 객체 액션 !!");
    }
}// 원본 객체
```
#### 프록시 생성
```java
class Proxy implements ISubject {
    private RealSubject subject; // 대상 객체를 composition

    Proxy(RealSubject subject) {
        this.subject = subject;
    }

    public void action() {
	    //호출하기 전에 다른 메서드를 추가해서 검증할 수 잇음
        subject.action(); // 위임
        System.out.println("프록시 객체 액션 !!");
    }
    
    //다른 메서드 추가
}

class Client {
    public static void main(String[] args) {
        ISubject sub = new Proxy(new RealSubject());// 프록시로 생성
        sub.action();
    }
}
```
#### 지연 초기화
```java
class Proxy implements ISubject {
    private RealSubject subject; // 대상 객체를 composition

    Proxy() {
    }

    public void action() {
    	// 프록시 객체는 실제 요청(action(메소드 호출)이 들어 왔을 때 실제 객체를 생성한다.
        if(subject == null){
            subject = new RealSubject();
        }
        subject.action(); // 위임
        /* do something */
        System.out.println("프록시 객체 액션 !!");
    }
}

class Client {
    public static void main(String[] args) {
        ISubject sub = new Proxy();
        sub.action();
    }
}
```
---
[출처 : Inpa Dev tistory](https://inpa.tistory.com/entry/GOF-💠-프록시Proxy-패턴-제대로-배워보자#)