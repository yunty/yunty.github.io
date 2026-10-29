---
title: Decorateor(구조)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Decorateor
---
## 개념
객체에 대해 추가 기능을 동적으로 추가하는 패턴
#### 
---
## 장·단점
#### 장점
- 유연한 기능 확장 가능
- 객체를 여러 데코레이터로 래핑하여 여러 동작 결합 가능
- 런타임에 동적 기능 변경 가능

#### 단점
- 데코레이터 스택 순서에 의존하는 방식임

---
## 사용 방법
#### 공통 기능 정의
```java
public interface Coffe{
	String getDescription();
	int getPrice();
}
```
#### 공통 기능 구현
```java
public class BasicCoffe implements Coffe{
	@Override
	public String getDescription(){
		return "기본 커피";
	}
	@Override
	public int getPrice(){
		return 3_000;
	}
}
```

#### 데코레이터 추상 클래스 정의
```java
abstract class CoffeDecorator implements Coffe{
	protected final Coffe coffe;
	protected CoffeDecorator(Coffe coffe){
		this.coffe = coffe;
	}
	@Override
	public String getDescription(){
		return coffe.getDescription();
	}
	@Override
	public int getPrice(){
		return coffe.getPrice();
	}

}
```

#### 데코레이터 구현 클래스들
```java
public class Milk extends CoffeDecorator{
	Milk(Coffe coffe){
		super(coffe);
	}
	
	@Override
	public String getDescription(){
		return super.getDescription()+", 우유";
	}
	@Override
	public int getPrice(){
		return super.getPrice()+500;
	}
	//위 처럼 뭔가 값을 추가할 수도 있고
	//데코레이터 구현체만의 메서드를 생성해서 공통 기능에 넣어서 사용시킬수도 있음
}
public class Ice extends CoffeDecorator{
	Ice(Coffe coffe){
		super(coffe);
	}
	
	@Override
	public String getDescription(){
		return super.getDescription()+", 얼음";
	}
	@Override
	public int getPrice(){
		return super.getPrice()+500;
	}
}
```
#### Main에서의 사용
```java
public class Main{
	public static void main(String[] args){
		Coffe coffe = new MilkCoffe(new BasicCoffe());
		coffe.getPrice(); //3500;
		
		coffe = new Ice(new Milk(new BasicCoffe()));
		coffe.getPrice() //4000;
	}
}
//즉 공통 기능이 제일 안쪽에 들어간다. 
```

---


#