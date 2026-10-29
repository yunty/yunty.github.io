---
title: Composite(구조)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Composite
#### 복합체 패턴
---
## 개념
복합 객체와 단일 객체를 동일한 컴포넌트로 취급하여, 동일한 인터페이스를 사용하게 하는 구조

#### Composite - Leaf
- Composite : 복합객체
	- 자식이 존재하는, 폴더같은 존재
- Leaf : 단일객체
	- 자식이 존재하지 않는, 파일같은 존재
- Component : 컴포넌트
	- 부품의 의미로 모두 같은 부품이다라고 생각하고 사용
	- 즉 복합 객체와 단일 객체 모두 동일하다라고 보고 같이 사용할 인터페이스를 컴포넌트라고 함
---
## 장·단점
#### 장점
- 단일체와 복합체를 동일하게 여기기 때문에 묶어서 연산 혹은 관리할 때 편하다.
- 다형성 재귀를 통해 트리 구조를 보다 편리하게 구성할 수 있다.
- 수평적, 수직적 모든 방향으로 객체를 확장할 수 있다.
- 새로운 Leaf가 추가되어도 사용하는곳에서는 인터페이스를 사용하기 때문에 OCP 준수

#### 단점
- 재귀의 단점인 depth가 깊어질수록 힘들다
- 복합 객체에서 구성 요소에 제약을 갖기 힘들다.
- 공통 인터페이스 설계가 까다로울 수 있다.
---
## 사용 방법 
#### 복합 객체와 단일 객체가 사용할 인터페이스 정의
```java
interface Component{
	void operation();
}
```
#### 단일 객체 정의
```java
public class Leaf implements Component{
	@Override
	public void operation(){
		System.out.println("Leaf 호출");
	}
}
```
#### 복합 객체 정의
```java
public class Composite implements Component{
	List<Component> components = new ArrayList<>();
	
	public void add(Component c){
		components.add(c);
	}
	public void remove(Component c){
		components.remove(c);
	}
	
	@Override
	public void operation(){
		System.out.println("Composite 호출");
		
		for(Component component : components){
			component.operation();
		}
	}
	
	...
}
```

#### Main에서의 사용
```java
public class Main{
	public static void main(String[] args){
		Composite composite1 = new Composite(); // 가장 상위 노드가 될 복합객체 생성
		// 복합객체가 상위인 이유는 Leaf는 하위 객체를 갖기 못하기 때문임
		Leaf leaf1 = new Leaf();
		Composite composite2 = new Composite();
		
		composite1.add(leaf1);
		composite1.add(composite2);
		
		composite2.add(new Leaf);
		
		composite1.operation(); // 전체 노드가 출력이 됨
	}
}
```



---
## 사용시기
- 트리 구조를 가질때
- 복합체 안에 복합체가 들어갈때
- 반복문이랑 타입 검사가 사용하는 곳마다 반복될때

#