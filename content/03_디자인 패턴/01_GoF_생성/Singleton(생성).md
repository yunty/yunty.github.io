---
title: Singleton(생성)
modified: 2026-09-21
---
#디자인패턴 #디자인패턴/생성 #객체지향
# Singleton
---
## 개념
#### 딱 **1개** 의 유일한 객체를 만들기 위한 코드 패턴

---
## 장·단점
#### 장점
- 인스턴스를 1번만 생성하므로 ==메모리 절약==이 가능하다.
- 동일한 객체를 ==여러 곳에서 공유== 가 가능하다.
- 객체 ==생성 횟수 제어== 가 가능하다.
- 설정, 로깅처럼 ==공통으로 사용하는 기능을 관리==하기 편하다.

#### 단점
- 여러 클래스가 싱글톤 객체에 의존하면 ==결합도가 높아==진다.
- 전역 상태처럼 사용되기 때문에 ==데이터의 변경 지점 찾기 어려워==진다.
- 단위 테스트에서 ==가짜 객체로 교체하기 어려워==진다.
- 멀티스레드 환경에서의 ==동시성 문제 고려해야== 한다.
- 하나의 객체가 ==너무 많은 책임==을 가지기 쉽다.
- ==상속과 확장이 어려워==진다.
---
## 사용 방법 / Lazy initialization 방법
- 생성자 메서드 private
- getInstance() 메서드를 통해 사용
```java
pulbic class Singleton{
	private static Singleton singleton = null;
	
	private Singleton(){} //기본 생성자 private화
	
	public static Singleton getInstance(){
		if(singleton == null){ // 생성된 싱글톤 객체가 없을때
			singleton == new Singleton(); // 객체 생성
		}
		return singleton; // 객체 반환
	}
}

Singleton singleton = Singleton.getInstance(); // 싱글톤 객체 사용
```
---
## 동시성 문제
- 멀티스레드 환경에서 1번 쓰레드가 if문을 검사 후 null이기 떄문에 객체를 생성하려고 하는 찰나에
  2번 쓰레드가 자리를 뻇어서 if문을 돌고 null이기 때문에 객체 생성 후
  다시 1번 쓰레드가 객체를 생성하는 부분이 실행되면 결국 객체를 2개가 생성된다.
  &rarr; 이것이 동시성 문제
---
## 동시성 문제 해결 방안
---
### Eager Initializtion : 직접 객체 생성 후 초기화
```java
	  class Singleton{
		  private static Singleton singleton = new Singleton();
		  private Singleton(){}
		  public static Singleton getInstance(){
			  return singleton;
		  }
	  }
```

- new Singleton()으로 바로 생성
- getInstance로 singleton객체 반환
- 무조건적인 객체 생성 :  메모리 낭비
- Exception 처리 불가능 : 객체 생성과정에서 예상치 못한 오류 발생 시 처리 불가능
---
### Static Block Initialization : [[Static 블록]]에 넣어서 생성
```java
class Singleton{
	private static Singleton singleton;
	private singleton(){
		try{
			singleton = new Singleton();
		}catch(Exception e){
			throw new Exception("객체 생성 오류");
		}
	}
	public static Singleton getInstance(){
		return singleton
	}
}
```
- Static 블록에 넣어서 초기화 진행 시 try-catch를 통해 예외 발생시 처리
- 무조건적인 객체 생성 : 메모리 낭비
---
### Thread safe Lazy Initialization : [[Synchronized|Synchronized]]를 사용하여 생성
처음 사용 방법에서 보여줬던 Lazy Initialization을 Synchronized를 사용하여 안전하게 처리하는 방식
```java
public class Singleton{
	private static Singleton singleton = null;
	
	private Singleton(){}
	
	public static synchronized Singleton getInstacne(){
		if(singleton == null){
			singleton = new Singleton();
		}
		return singleton;
	}
}
```
- syncronized의 비용이 높음 : 성능 저하 가능성 있음
---
### Double Checked Locking : if문을 2번 사용함
```java
public class Singleton{
	private static Singleton singleton = null;
	
	private Singleton(){}
	
	public static Singleton getInstance(){
		if(singleton == null){
			syncronized (Singleton.class){ // new Singleton으로 생성되면 다 줄 서야함
				if(singleton == null) singleton = new Singleton();
			}
		}
	}
}
```
- if문을 통해 null일때만 syncronized를 사용하게 만들어주는것
- 하지만 if문 첫부분을 통과 즉 null일때를 통과하자마자 다른 스레드가 들어오면 결국 또 다른 객체가 생성되는 문제가 발생한다.
- Visivility 문제 : 서로 다른 쓰레드가 서로 다른 캐시에서 값을 가져와서 사용한다면 같은 객체를 보고 있어도 다른 결과가 나온다.
---
### Double Checked Locking + volatile: volatile메서드가 추가된 더블 체크
```java
public class Singleton{
	private volatile static Singleton singleton = null;
	private Singleton(){};
	public static Singleton getInstance(){
		if(singleton == null){
			synchronized (Singleton.class){
				if(singleton == null){
					singleton = new Singleton();
				}
			}
		}
		return singleton;
	}
}
```
- [[Volatile]] : 변수를 캐시가 아닌 메모리에서 읽어오도록 함
---
### Bill Pugh Singleton Solution / LazyHolder
내부에 정적 클래스를 두어 ==외부 클래스가 사용되기 이전에는 로딩이 되지 않는 방법==을 사용하는 방식이다.
```java
public class Singleton{
	private Singleton(){}
	public static Singleton getInstance(){
		return LazyHolder.INSTANCE;
	}
	private static class LazyHolder{
		public static final Singleton INSTANCE = new Singleton();
	}
}
```
- inner class는 outer class가 로딩될때 같이 로딩되기 때문에 그 이전에 메모리를 차지하지는 않는다.
- 권장되는 싱글톤 패턴 방식 중 1가지
- 하지만 리플렉션(Reflection)을 사용하면 외부에서도 private 생성자, 메서드에 접근이 가능하기 때문에 이경우에는 객체 생성을 막을 수 없다.
---
### Enum Singleton
열거형을 사용하여 Singleton 패턴을 구현하는 가장 권장되는 방법이다.
```java
public enum Singleton{
	INSTANCE;
	
	private final Client dbClient;
	
	Singleton(){
		dbClient = Database.getClient();
	}
	
	public static Singleton getInstance(){
		return INSTANCE;
	}
	public Client getClient(){
		return dbClient;
	}
}

public class Main{
	public static void main(String[] args){
		Singleton singleton = Singleton.getInstance;
		singleton.getClient();// 로 싱글톤 객체 접근 가능
	}
}
```