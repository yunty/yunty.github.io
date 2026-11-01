---
title: Sealed
modified: 2026-10-30
---
# Sealed
- 상속(구현)할 수 있는 클래스를 `permits`로 **제한**
- 허용된 쪽은 `final` / `sealed` / `non-sealed` 중 하나 필요 (record는 자동 final)
- 같은 파일 안이면 `permits` 생략 가능

## switch 패턴 매칭과 같이 쓰면
- 종류가 컴파일 시점에 고정돼서 `default` 없이 쓸 수 있음
- 새 타입을 추가하고 처리를 빼먹으면 **컴파일 에러**
- sealed가 아니면 `default` 필수, 누락 검사도 없음

```java
sealed interface Payment permits Card, Bank {}
record Card(String number) implements Payment {}
record Bank(String account) implements Payment {}

String describe(Payment p) {
    return switch (p) {
        case Card c -> "카드 " + c.number();
        case Bank b -> "계좌 " + b.account();
    };
}
```
- enum : 상수가 고정이고 상수마다 하나뿐 (상수별 값, 메서드도 가능)
- sealed + record : 종류마다 필드 모양이 다르고, 값마다 객체를 만들 수 있음
