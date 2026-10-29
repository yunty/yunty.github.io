---
title: Builder(생성)
modified: 2026-09-21
---
#디자인패턴 #디자인패턴/생성 #객체지향
#
---
## 개념
객체를 초기화할때 생성자를 통해서 하는것이 아닌 빌더객체를 통해서 하는 방법
빌더 객체에는 .멤버 메서드들을 만들고 각 메서드들은 객체 본인을 반환(return this)하면 된다.
마지막에 .build를 통해 원래 객체의 생성자에 값을 넣어서 반환

---
## 장단점
#### 장점
- 객체 생성 과정을 일관된 프로세스로 표현 가능
- 디폴트 매개변수 생략을 간접적으로 지원
- 필수 멤버와 선택적 멤버를 분리 가능(Builder를 생성할때 꼭 받아오게 시키면 됨 생성자에 매개변수로 넣어서)
- 객체 생성 단계 지연 가능
- 초기화 검증을 멤버별로 분리 가능(각자의 메서드에 각자의 검증을 넣으면 됨)
- Setter를 쓰지 않기 때문에 원래 가지고 있던값을 변경하는건 아님
#### 단점
- 코드 복잡성 증가
- 생성자보다 성능 하락
- 지나친 빌더 남용은 금지(필드의 개수가 4개보다 적거나 변경 가능성이 없다면 사용하지 않는것 추천)

---
## 사용방법
#### 예시 공통 객체
```java
public class Student{
	private int id;
	private int age;
	private String name;
	private String address;
	
	public Student(int id, int age, String name, String address){
		this.id = id;
		this.age = age;
		this.name = name;
		this.address = address;
	}
}
```
#### 기본 빌더 패턴
```java
public class StudentBuilder{
	private int id;
	private int age;
	private String name;
	private String address;
	
	/*public StudnetBuilder(int id){
		this.id = id;
	}*/
	//필수 값을 생성자 매개변수로 지정하면 설정 가능
	
	public StudnetBuilder id(int id){
		this.id = id;
		return this;
	}
	public StudnetBuilder age(int age){
		this.age = age;
		return this;
	}
	public StudnetBuilder name(String name){
		this.name = name;
		return this;
	}
	public StudnetBuilder address(String address){
		this.address = address;
		return this;
	}
	
	public Student build(){
		return new Student(id, age, name, address);
	}
}
```

#### 심플 빌더 패턴
```java
public class Student{
	private int id;
	private int age;
	private String name;
	private String address;
	
	public static class Builder{
		private int id;
		private int age;
		private String name;
		private String address;
		
		public Builder id(int id){
			this.id = id;
			return this;
		}
		...
		public Student build(){
			return new Student(this);
		}
	}
	
	private Student(Builder builder){// private
		this.id = builder.id;
		this.age = builder.age;
		this.name = builder.name;
		this.address = builder.address;
	}
}
```

#### 디렉터 빌더 패턴(GOF)
디렉터 객체 : 빌더 구현체들을 어떤 순서로 사용할것인지를 통해 결과값 뽑아내기, 어떻게 조합할지는 얘가 정함
빌더 : 추상클래스를 통해 공통 구현 + 구현해야할 메서드 작성
A라는 객체가 있으면 ABuilder builder = new ABuilder1(A)처럼 원하는 빌더 구현체를 넣어서 객체를 넘기고 빌더에서 들어온 값으로 조합할 수 있는 메서드들을 재정의해둠
ADirector aDirector = new ADirector(builder)를 넘겨서 빌더를 넘기고
String result  = aDirector.build();를 통해 결과값을 얻을 수 있음
## 정리

---
## 참고
#### 
#### 