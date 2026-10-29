---
title: Abstract Factory(생성)
modified: 2026-10-27
---
#디자인패턴 #디자인패턴/생성 #객체지향
# Abstract Factory
---
## 개념
#### 객체 생성 간 공동 그룹을 만드는것
자 **마우스, 키보드, 모니터**가 있다고 예시를 들자면
마우스 인터페이스, 키보드 인터페이스, 모니터 인터페이스가 있을것이다.
**마우스 인터페이스 : 맥 마우스 + 윈도우 마우스**
**키보드 인터페이스 : 맥 키보드 + 윈도우 키보드**
**모니터 인터페이스 : 맥 모니터 + 윈도우 모니터**

자 이것들을 팩토리로 객체를 생성한다고 각 인터페이스 별 생성팩토리가 있을것이다
생성 팩토리 : 생성 추상메서드, 동작 추상메서드

마우스 구현체들 생성 팩토리 : 분기를 통해 맥 or 윈도우 마우스 생성메서드 구현 + 동작 메서드 구현
키보드 구현체들 생성 팩토리 : 분기를 통해 맥 or 윈도우 키보드 생성메서드 구현 + 동작 메서드 구현
모니터 구현체들 생성 팩토리 : 분기를 통해 맥 or 윈도우 모니터 생성메서드 구현 + 동작 메서드 구현

결국 분기를 통해 만들어야하고 확장시에 불필요하게 또 작성할것이 늘어난다.
이때 추상 팩토리를 사용하는것이다.
마우스, 키보드, 모니터 생성 팩토리 &rarr; 맥 생성 팩토리(마우스 + 키보드 + 모니터)
마우스, 키보드, 모니터 생성 팩토리 &rarr; 윈도우 생성 팩토리(마우스 + 키보드 + 모니터)
나중에 리눅스가 추가된다고 해도 리눅스만 추가하면 끝이다.

![[추상클래스 구성도.png]]
근데 그러면 애초에 Mac Interface, Window Inferface에 마우스, 키보드, 모니터 객체를 가지면 되는거 아니냐고 생각했다면 너는 과거의 발전이 없는 나와 동일한 질문을 한것이다.

자 일단 첫번째 UI인터페이스를 만들고 내부에 Mouse, Keyboard, Monitor 객체를 선언하고
class Mac implements UI 에서 기능을 구현하고 팩토리에서 생성자들을 초기화 하면 되는거 아닌가
물론 가능은 하다 물론 UI가 중요하고 UI만 필요한 상태면 문제 없지만 이렇게 된다면 버튼만 필요해서 버튼 초기화 팩토리를 만들려면? 불가능하다. 즉!! 무조건 UI 단위로 필요하다면 괜찮지만 그렇지 않다면 기능별로 분리를해두는게 좋다.

두번째 그럼 그냥 각 인터페이스에서 초기화 하고 맥, 윈도우도 본인들이 초기화 하면 안되는건가요?
우리가 팩토리 쓰는걸 전혀 이해하지 못한 질문이다. 이렇게 할 시 의존성이 높아지기 떄문에 좋지 않다. 불가능한것은 아니지만,,,,

세번째 굳이 중복을 없애고 싶은데 팩토리 메서드 패턴을 사용해서 추상 클래스에서 공통 구현을 하고 그 하위 클래스에서 초기화 하면 안되나요? 가능합니다만 굳이 그럴필요는 없지만 하게 된다면 밑에 코드처럼 가능함
```java
interface HardwareFactory { // 현재의 구조
    Mouse createMouse();
    Keyboard createKeyboard();
    Monitor createMonitor();
}

class MacHardwareFactory implements HardwareFactory {
    public Mouse createMouse() {
        return new MacMouse();
    }

    public Keyboard createKeyboard() {
        return new MacKeyboard();
    }

    public Monitor createMonitor() {
        return new MacMonitor();
    }
}
abstract class HardwareFactory {// 변경구조

    public final Mouse prepareMouse() {
        Mouse mouse = createMouse();
        mouse.initialize();
        mouse.connect();
        return mouse;
    }

    protected abstract Mouse createMouse();
    protected abstract Keyboard createKeyboard();
    protected abstract Monitor createMonitor();
} 
//이제 하위 클래스로 맥하드웨어팩토리, 윈도우하드웨어팩토리를 생성하주면 추상 팩토리 + 팩토리 메서드 패턴 
```
즉! 엄밀히 따지면 추상 팩토리 == 팩토리 메서드 : False이고 서로 다른 개념이라고 생각해야함, 무슨 하위개념 이런것도 아님



---
## 장단점
#### 장점
- 유연한 확장(리눅스 예시처럼)
- 결합도를 낮출 수 있음
#### 단점
- 제품이 추가 되면 팩토리 구현 로직을 수정해야함(만약 스피커가 추가되면 맥, 윈도우 모두 추가해줘야함 코드를)
- 추상 팩토리의 사항이 바뀌면 많은 수정이 따라온다.
- 구현체가 많아질수록 수정이 많아짐
---
## 사용방법
팩토리 인터페이스 생성 간 각 제품군 별 기능을 묶는다.

---
## 정리
즉 추상 팩토리는 구체적인 제품 생성을 위해 추상화된 제품을 팩토리로 만든다 하여 추상 팩토리임
팩토리 메서드는 팩토리의 하위 클래스가 생성을한다는 의미임


---
## 참고
#### 
#### 