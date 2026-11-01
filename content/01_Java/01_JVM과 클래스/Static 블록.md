---
title: Static 블록
modified: 2026-09-19
---
#자바 #static #초기화 #객체생성
# Static 블록
Java 에서 클래스가 처음 초기화 될 때 1번만 실행되는 코드 영역
**즉** 클래스가 처음 사용될때 딱 1번 실행된다.

## 사용하는 이유
- 초기화 과정에서 계산이나 조건문처럼 여러 코드가 필요하면 static 블록 사용
- 여러 단계로 **정적 객체** 초기화
- 실행 환경에 따라 정적 값 설정
- 비용이 큰 객체를 한 번 생성
- 싱글톤 객체 생성
- 즉 복잡한 정적 객체 혹은 정적 변수 초기화를 위한 블록임

## 사용 방법
```java
class Config {
    static String environment;

    static {
        if (System.getenv("MODE") == null) {
            environment = "development";
        } else {
            environment = System.getenv("MODE");
        }
        System.out.print("생성");
    }
}
```
- 정적 객체에 대한 조건이 필요하거나, 출력을 할때 사용가능
## 유의 사항
- 정적 변수 초기화 &rarr; static블럭 실행