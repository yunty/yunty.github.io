---
title: Template Method(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Template Method 패턴
#### 
디자인패턴에서 템플릿이란 변하지 않는것을 의미한다.

---
## 개념
상속을 사용하며 공통으로 사용하는 메서드들을 템플릿화 하여 정의해 두고 추가되는 메서드는 자식 클래스를 생성하여 추가할 수 있게 하는것이다.
#### 구조
- 추상 클래스
	- 추상 메소드에 공통기능을 작성해둔다.
	- hook메서드, 부모의 템플릿 메서드의 영향이나 순서를 제어하고 싶을때 사용하는 메서드 형태를 의미
		- 즉 하위 클래스에서 사용할 필요가 없는것들은 hook을 통해 생략 가능하게 생성해둠
- 구현 클래스
	- 추상 메서드를 구현 및 기능을 추가할 수 있다.

## 장·단점
#### 장점
- 사용자가 대규모 알고리즘의 특정 부분만 재정의하여, 다른 부분에 발생하는 변경 사항의 영향을 더 끼친다.
- 공통 기능 구현을 통해 코드 중복을 줄인다.
- 서브 클래스의 역할을 줄이고, 핵심 로직을 상위 클래스에서 관리하므로 관리가 편하다.

#### 단점
- 알고리즘이 복잡할 수록 템플릿 로직 형태를 유지하기 어려워진다.
- 추상 메소드가 많아지면서 크랠스의 생성, 관리가 어려워질 수 있다.
- 상위 클래스에 추상 메서드 추가시 하위 객체들을 다 수정해야함
- 리스코프 치환 법칙 즉 LSP를 위반할 여지가 있다.

## 사용 방법 
#### 추상 클래스
```java
abstract class AbstractTemplate {

    // 템플릿 메소드 : 메서드 앞에 final 키워드를 붙이면 자식 클래스에서 오버라이딩이 불가능함.
	// 자식 클래스에서 상위 템플릿을 오버라이딩해서 자기마음대로 바꾸도록 하는 행위를 원천 봉쇄
    public final void templateMethod() {
        // 상속하여 구현되면 실행될 메소드들
        step1();
        step2();
        
        if(hook()) { // 안의 로직을 실행하거나 실행하지 않음
            // ...
        }
        
        step3();
    }

    boolean hook() {
        return true;
    }

    // 상속하여 사용할 것이기 때문에 protected 접근제어자 설정
    protected abstract void step1();
    protected abstract void step2();
    protected abstract void step3();
}
```

#### 구현 클래스
```java
class ImplementationA extends AbstractTemplate {

    @Override
    protected void step1() {}

    @Override
    protected void step2() {}

    @Override
    protected void step3() {}
}

class ImplementationB extends AbstractTemplate {

    @Override
    protected void step1() {}

    @Override
    protected void step2() {}

    @Override
    protected void step3() {}

    // hook 메소드를 오버라이드 해서 false로 하여 템플릿에서 마지막 로직이 실행되지 않도록 설정
    @Override
    protected boolean hook() {
        return false;
    }
}
```

## 전략 패턴과 다른점
#### 전략 패턴은 합성을, 템플릿 메서드는 상속을 이용한다.
- 전략 패턴은 합성을 통해 알고리즘 전체를 바꿀 수 있다.
- 템플릿 메서드는 상속을 통해 공통구현에서 일부 단계만 수정가능하다.

#### 템플릿 메서드는 작업 순서가 반드시 유지되어야 할 때 사용
- 정렬할건데 어떤 확장자 타입을 가져올것인지 모를때
	- 정렬하는 순서는 똑같은데 어떻게 읽을지만 자식 클래스에서 재정의
#### 전략 패턴은 목적은 동일하지만 알고리즘 전체가 달라야 할때 사용
- 정렬할건데 입력값에 따라 어떤 정렬알고리즘을 쓸지 정할때
	- 결국 목적은 정렬이고 어떤 것을 사용할지를 정해야할때