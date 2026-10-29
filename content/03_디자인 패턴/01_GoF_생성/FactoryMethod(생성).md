---
title: FactoryMethod(생성)
modified: 2026-09-21
---
#디자인패턴 #디자인패턴/생성 #객체지향
# Factory Method Pattern
---
## 개념
객체 생성을 공장(Factory)클래스로 캡슐화 처리하여 대신 생성하게 하는 생성 디자인 패턴
**즉** 기능을 구성하는 인터페이스와 그것을 구현하는 구현체들이 중심이 되는것이 아니라
**그** 구현체들을 객체로 생성하는 팩토리 인터페이스 혹은 ==추상 클래스로 공동 기능을 작성==해두고 ==추상 메서드를 구현하는 하위 클래스들로부터 객체 생성을 받는것==이 팩토리 메서드의 핵심이다.
#### 즉 하위 클래스가 생성 메서드를 재정의하는것이 팩토리 메서드 패턴의 핵심 

---
## 장단점
#### 장점
- 클래스 생성과 사용의 처리 로직을 분리하게 되어 결합도가 낮아짐
- 팩토리 메서드를 통해 객체의 생성 후 공통으로 할 일을 지정 가능
- 객체 생성 코드를 한 곳으로 모아두었기에 SRP원칙 준수
- 새로운 제품 인스턴스가 도입되면 이곳만 바꾸면 되기때문에 OCP원칙 준수
#### 단점
- 구현체가 늘어날때 마다 서브 클래스가 증가한다.
- 코드의 복잡성이 증가한다.

---
## 사용방법
#### 역할
1. 기능을 제공하는 인터페이스 : Product
2. 기능을 구현한 구현체들 : Concrete Product
3. 생성 메서드와 공통 작업을 가진 추상 클래스 : Creator
4. 생성 메서드를 구현하는 하위 클래스들 : Concrete Creator
---
#### 기능을 제공하는 인터페이스
```java
public interface Notification{
	void send();
}
```
---
#### 기능을 구현한 구현체들
```java
public class EmailNotification implements Notification{
	@Override
	public void send(String message){
		System.out.println("이메일 : " + message);
	}
}
public class SmsNotification implements Notification{
	@Override
	public void send(String message){
		System.out.println("문자 : "+message);
	}
}
```
---
#### 생성 메서드와 공통 작업을 가진 추상 클래스
```java
public abstract class NotificationService{
	public void notify(String message){
		Notification notification = createNotification();
		
		notification.send(message);	
	}
	
	protected abstract Notification createNotification();
}
```
생성된 기능을 구현한 객체들을 반환하려면 void notify 말고 Notification을 반환하게 하면 된다.

```java
public interface NotificationService{
	default Notification notify(String message){// Defalut로 공통 구현 메서드 작성 가능
		Notification notification = createNotification();
		
		notification.send(message);	
	}
	
	Notification createNotification(); // 추상 생성 메서드
}
```
인터페이스로도 생성 가능

---
#### 생성 메서드를 구현하는 하위 클래스들
```java
public class EmailNotificationService extends NotificationService{
	@Override
	protected Notification createNotification(){
		return new EmailNotification(); // 기능 구현체들 반환
	}
}
public class SmsNotificationService extends NotificationService{
	@Override
	protected Notification createNotification(){
		return new SmsNotification(); // 기능 구현체들 반환
	}
}
```
---
#### 사용하는 main 메서드
```java
public class Main{
	public static void main(String[] args){
		NotificationService notififcation = new SmsNotificationService;
		notification.notify();
	}
}
```
---
#### ENUM으로 사용
```java
enum EnumNotification{
	SMS_NOTI_SERVICE{
		public Notification createNotification(){
			return SmsNotification();
		}
	}
	EMAIL_NOTI_SERVICE{
		public Notification createNotification(){
			return EmailNotification();
		}
	}
	public void notify(String message){ 
		Notification noti = createNotification();
		noti.read(message);
	}
	abstract protected Notification createNotification(); // 추상 팩토리 메서드
	
}
```
---
## 정리
- 기능을 제공하는 인터페이스 + 기능을 구현한 구현체들이 있을때 이 구현체들 생성을 담당하는 클래스를 생성하는것
- 추상 메서드에서 protected abstract 메서드로 생성 메서드 선언해두고 이 메서드를 사용 및 가공하는 메서드 구현
- 추상 메서드를 구현하는 구현체들을 생성
---
## 참고
#### 정적 팩토리 메서드
- 생성자 대신 이름 있는 static 메서드로 생성하는 방식
- 디자인 패턴은 아님
#### 심플 팩토리 
```java
class NotificationFactory {
    Notification create(Type type) {
        return switch (type) {
            case SMS -> new SmsNotification();
            case CALL -> new CallNotification();
        };
    }
}
```
- 하위 클래스에서 처리하는게 아니라 그냥 클래스 1개 생성 및 그 안에서 다 처리한다.
- 팩토리 메서드 패턴은 다형성으로 타입을 선택했다면 심플 팩토리는 분기문으로 처리
- 디자인 패턴은 아님