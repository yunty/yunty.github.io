---
title: Strategy(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Strategy
전략 패턴

---
## 개념
실행(런타임) 중에 알고리즘 전략을 선택하여 객체 동작을 실시간으로 바뀌도록 하는 패턴
**같은 목적의 여러 처리 방법을 하나의 인터페이스로 묶고, 상황에 맞는 구현체를 선택해서 사용하는 패턴**이 전략 패턴
- 평소에 많이 쓰던 입력값에 따라 게임 난이도를 조절한다든가 하는 그 방식이 바로 전략 패턴
#### 구조
1. 전략 인터페이스
	- 모든 전략 구현체에 대한 공용 인터페이스
2. 전략 알고리즘 객체들
	- 인터페이스를 구현한, 전략을 구현해둔 구현체
3. 컨텍스트
	- 알고리즘을 실행해야 할 때마다 해당 알고리즘과 연결된 전략 객체의 메소드를 호출
4. 클라이언트
	- 실질적으로 전략객체를 선택하고 그 결과를 받는 객체
클라이언트 &rarr; 컨텍스트 &rarr; 전략 인터페이스 &rarr; 전략 구현체들

## 장·단점
#### 장점
- 분기문을 통해 알고리즘을 선택하는 코드를 줄일 수 있음
- 새로운 전략이 추가되어도 확장 간에 수정이 필요 없음
- 실행중에도 변경 가능

#### 단점
- 전략마다 클래스가 생기기 때문에 오히려 복잡할수도 있음
- 사용하는 쪽에서 적절한 전략을 선택해야함

## 사용 방법 
- 각각의 전략을 인터페이스로 추상화 시켜둔다
- 컨텍스트에서 전략 인터페이스를 합성 받아 사용한다
- 사용자는 컨텍스트에 자신의 전략을 넣고 사용한다.

#### 전략 인터페이스 추상화
```java
// 전략 - 추상화된 알고리즘
interface Weapon {
    void offensive();
}

class Sword implements Weapon {
    @Override
    public void offensive() {
        System.out.println("칼을 휘두르다");
    }
}

class Shield implements Weapon {
    @Override
    public void offensive() {
        System.out.println("방패로 밀친다");
    }
}

class CrossBow implements Weapon {
    @Override
    public void offensive() {
        System.out.println("석궁을 발사하다");
    }
}
```

#### 컨텍스트 작성
```java
// 컨텍스트 - 전략을 등록하고 실행
class TakeWeaponStrategy {
    Weapon wp;

    void setWeapon(Weapon wp) {
        this.wp = wp;
    }

    void attack() {
        wp.offensive();
    }
}
```

#### 사용자 컨텍스트 사용
```java
// 클라이언트 - 전략 제공/설정
class User {
    public static void main(String[] args) {
        // 플레이어 손에 무기 착용 전략을 설정
        TakeWeaponStrategy hand = new TakeWeaponStrategy();

        // 플레이어가 검을 들도록 전략 설정
        hand.setWeapon(new Sword());
        hand.attack(); // "칼을 휘두르다"

        // 플레이어가 방패를 들도록 전략 변경
        hand.setWeapon(new Shield());
        hand.attack(); // "방패로 밀친다"
        
        // 플레이어가 석궁을 들도록 전략 변경
        hand.setWeapon(new Crossbow());
        hand.attack(); // "석궁을 발사하다"
    }
}
```

## 열거형 사용
```java
public enum GameLevel {

    BEGINNER(1),
    MIDDLE(2),
    ADVANCED(3);

    private final int inputNumber;

    GameLevel(int inputNumber) {
        this.inputNumber = inputNumber;
    }

    public static GameLevel from(int input) {
        return Arrays.stream(values())
            .filter(level -> level.inputNumber == input)
            .findFirst()
            .orElseThrow(
                () -> new IllegalArgumentException("잘못된 입력")
            );
    }
}
```

## 열거형 vs 클래스
|기준|enum|전략 클래스|
|---|---|---|
|전략 종류|고정적|계속 추가 가능|
|객체 개수|상수마다 하나|필요할 때마다 생성|
|상태|고정된 값에 적합|인스턴스별 상태 가능|
|의존성 주입|불편함|자연스러움|
|로직 크기|작고 단순함|크고 복잡해도 분리 가능|
|확장 방식|enum 수정|구현 클래스 추가|

#### 상황에 따라 선택
|열거형을 선택하는 상황|전략 클래스를 선택하는 상황|
|---|---|
|종류가 고정돼 있음|종류가 계속 추가될 수 있음|
|상수마다 하나의 객체면 충분함|실행마다 새로운 객체가 필요함|
|값이나 로직이 단순함|알고리즘이 복잡함|
|외부 의존성이 없음|DB, API 등 의존성 주입이 필요함|
|인스턴스마다 상태가 필요 없음|사용자마다 다른 상태를 가져야 함|

