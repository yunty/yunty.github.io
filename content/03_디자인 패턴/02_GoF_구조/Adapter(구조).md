---
title: Adapter(구조)
modified: 2026-09-23
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Adapter
---
## 개념
#### 호환성이 없는 인터페이스 때문에 함께 동작할 수 없는 클래스들을 함께 작동해주도록 변환해줌
- 기존 시스템의 클래스를 상속하는 방법
- 합성해서 호환 작업을 해주는 방법 총 2가지가 있음
---
## 장·단점
#### 장점
- 프로그램의 기본 비즈니스 로직에서 인터페이스 또는 데이터 변환 코드를 분리할 수 있기 떄문에 SRP를 만족한다.
- 기존 클래스 코드를 건들지 않고 어댑터를 생성하여 변환작업이 이뤄지므로 OCP를 만족한다.
- 추가로 필요한 메서드가 있다면 어댑터를 통해 만들 수 있다.
- 만약 버그가 생기더라도 기존 클래스에는 버그가 없으므로 어댑터만 확인하면 되기때문에 검사가 쉬워진다.
#### 단점
- 새로운 인터페이스와 어댑터 클래스 세트를 도입해야 하기 때문에 코드의 복잡성이 증가한다.
- 가끔은 기존 클래스를 변경하는것이 더 간단할 수 있음
---
## 사용 방법
#### 클래스 상속 사용법
```java
interface SortEngine{
	void sort();
	void sorting(boolean reverse);
}

class CurrentSortEngine implements SortEngine{
	@Override
	public void sort(){
		~~~
	}
	@Override
	public void sorting(boolean reverse){
		~~~
	}
}

//에서 새로운 엔진을 받아서 넣는다면
class NewSortEngine{
	public void sorting(boolean reverse){
	}
}
// 현재의 인터페이스와 맞지 않기 떄문에 어댑터 객체를 사용해야함
// 클래스 상속을 이용한 방법
class SortEngineAdapter extends NewSortEngine implements SortEngine{
	@Override
	public void sort(){
		//CurrentSortEngine꺼를 복사 붙여넣기
	}
	@Override
	public void sorting(boolean reverse){
		sorting(false);
	}
}
// 상속 후 없는것들을 알아서 뗴우면 되는데 이렇게 될 시 여러개를 상속을 못하기 때문에 어댑터가 필요한것들이 많으면 한계가 있다.
```

#### 합성을 사용한 사용법
```java
interface SortEngine{
	void sort();
	void sorting(boolean reverse);
}

class CurrentSortEngine implements SortEngine{
	@Override
	public void sort(){
		~~~
	}
	@Override
	public void sorting(boolean reverse){
		~~~
	}
}

//에서 새로운 엔진을 받아서 넣는다면
class NewSortEngine{
	public void sorting(boolean reverse){
	}
}

class SortEngineAdapter implements SortEngine{
	CurrentSortEngine currentEngine;
	NewSortEngine newEngine;
	
	public SortEngineAdapter(CurrentSortEngine currentEngine,
							 NewSortEngine newEngine){
		this.currentEngine = currentEngine;
		this.newEngine = newEngine;
	}
	
	@Override
	public void sort(){
		currentEngine.sort();
	}
	@Override
	public void sorting(){
		newEngine.sorting();
	}
}

//위 처럼 원래객체와 합쳐서 사용하는 합성방법도 있고
//새로운 메서드의 이름만 변경이 되어야 한다며 그냥 새로운객체만 불러와서 사용할수도 있다.
//즉 메서드 시그니처가 달라도 위임을 통한 호환작업이 가능한것이다.
```
---


#