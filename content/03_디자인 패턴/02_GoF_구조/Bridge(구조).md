---
title: Bridge(구조)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Bridge
---
## 개념
==기능 클래스 계층==과 ==구현 클래스 계층==을 분리하여 브릿지로 연결하는 패턴

두 개의 독립적인 변화 축을 분리하려고 설계하였는지가 중요한 패턴

#### 2가지 분류
- 기능 클래스 계층
	- 상속을 통해 하위클래스에서 상위 클래스의 기능에 ==새로운 기능을 추가==하는 방식 
- 구현 클래스 계층
	- 인터페이스나 추상 클래스의 하위 클래스에서 ==상위 클래스의 기능을 구현==하는 방식

#### 합성과의 차이점
Car 객체에 Engine 객체를 필드로 가지고 있으면 이것도 브릿지 패턴 아닌가요~?!
목적에 따라 다르게 얘기 할 수 있다.
- Car가 단순히 부품으로 Engine을 가지고 있다. &rarr; Engine이 별 다른 기능을 제공하지 않는다
	- 그렇다면 그냥 합성
- Car 객체와 Engine 객체를 나누어서 2개의 독립적인 변화 축을 가지고 있다.
	- Car 객체는 Suv, Sedan 처럼 나누어져있다.
	- Engine 객체는 Gas, Electric 처럼 나누어져있다.
	- 그렇다면 2개의 독립적인 변화 축을 통해 자유롭게 조합할 수 있는 브릿지 패턴이다. 

#### 상속을 사용하지 않는 이유
- 그러면 그냥 상위 계층에 Car 클래스가 기본적인 기능을 선언해두고 하위 클래스 GasSedan, GasSuv, ElectricSedan, ElectricSuv 처럼 각각의 조합들을 모두 클래스로 만들어야한다.
- 하지만 브릿지처럼 조합할 수 있게 구분해 둔다면 확장에 열려있음
- 예를 들면 여기에 수소차가 추가 되면 모든 조합을 수소로 바꾼 클래스들을 다시 또 생성해야한다. 
- 즉 상속은 조합될 클래스를 미리 만드는것이다.
---
## 장·단점
#### 장점
- 독립적으로 확장할 수 있다.
- 상속처럼 조합별로 다 클래스를 만들 필요가 없다.
- 실행 중에도 구현 객체를 교체할 수 있다.
- 결합도가 낮아진다
- 테스트하기가 쉬워진다.
#### 단점
- 인터페이스와 구현 클래스가 추가되어 구조가 복잡해진다.
- 단순한 프로그램에서는 오버 스펙이 될 수도 있다.
---
## 사용 방법
#### 기능 클래스 계층
```java
abstract class Car{
	protected final Engine engine; // 브릿지 연결 
	// 기본적인 세팅을 잡아줘야하기 때문에 추상 클래스로 만든것임
	protected Car(Engine engine){
		thsi.engine = engine;
	}
	public void start(){
		engine.start(); // 구현 클래스 계층 메서드 사용
	}
	public abstract void drive();
}

class Sedan extends Car{
	Sedan(Engine engine){
		super(engine);
	}
	public void drice(){
		System.out.println("세단");
	}
}
class Suv extends Car{
	Suv(Engine engine){
		super(engine);
	}
	public void drice(){
		System.out.println("Suv");
	}
}
```

#### 구현 클래스 계층
```java
interface Engine{
	void start();
}

class GasEngine implements Engine{
	public void start(){
		System.out.println("가솔린 엔진 시동");
	}
}
class ElectricEngine implements Engine{
	public void start(){
		System.out.println("전기 모터 시동");
	}
}
```

#### Main에서의 사용
```java
public class main{
	public static void main(String[] args){
		Car gasSedan = new Sedan(new GasEngine());
		car electricSuv = new Suv(new ElectricEngine());
		
		gasSedan.start(); // 가솔린 엔진 시동
		electricSuv.start(); // 전기 모터 시동
	}
}
```

