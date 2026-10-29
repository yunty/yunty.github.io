---
title: Prototype(생성)
modified: 2026-09-21
---
#디자인패턴 #디자인패턴/생성 #객체지향
# Prototype 패턴
---
## 개념
new 키워드로 생성하는것이 아닌 이미 만들어진 객체의 값을 깊은 복사를 통해 반환 받아서 사용하는 방법
`List<Student> student2= student.clone();`


---
## 장단점
#### 장점
- 복잡하게 설정된 객체를 간단히 복제 가능
- 생성 비용이 큰 객체를 매번 처음부터 만들지 않아도 됨
	- DB에서 값을 가져오는 상황에서 매번 가져오면 1번도 큰 값인데 여러번이면 굉장히 큰 값이 든다
	- 따라서 1번 가져온 값을 복사하여 계속 사용하는것이다.
#### 단점
- 가변 객체 즉 참조값으로 저장되는 값들이 있으면 깊은 복사를 구현해줘야함
- 복사 코드가 복잡해질 수 있음
---
## 사용방법
#### 예시
```java
class Monster {

    private String name;
    private int hp;

    public Monster(String name, int hp) {
        this.name = name;
        this.hp = hp;
    }

    // 복사 생성자
    private Monster(Monster source) {
        this.name = source.name;
        this.hp = source.hp;
    }

    public Monster copy() {
        return new Monster(this);
    }

    public void setName(String name) {
        this.name = name;
    }
}

Monster prototype = new Monster("슬라임", 100);

Monster monster1 = prototype.copy();
Monster monster2 = prototype.copy();

monster2.setName("강한 슬라임");
```
---

---
## 정리

---
## 참고
#### 
#### 