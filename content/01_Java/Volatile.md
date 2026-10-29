---
title: Volatile
modified: 2026-09-20
---
# Volatile : 휘발성
### 사용하는 이유
- 서로 다른 쓰레드는 각각의 코어별 캐시에서 값을 꺼내 쓰는데
	- 다중 쓰레드 작업 간에 효율을 위해 캐시에서 값을 꺼냄
-  이때 같은 객체를 사용하고 있다고 해도 서로 다른 캐시에 있다보니 결과 값이 엇갈릴수 있음
- 이럴때 volatile 키워드를 변수 앞에 붙이면 ==캐시 메모리==가 아니라 ==메인 메모리==에서 값을 불러오게 시킴

### 단점
- 여러개의 쓰레드가 write를 하는 상황이라면 race condition을 해결할 수 없음
- 즉 쓰레드1이 값을 읽어서 추가하는 연산을 진행중일때 다른 쓰레드에서 그 값을 사용한다면 변경된 값이 반영되기 이전이기 때문에 엇갈리게 됨
- 이 단점을 synchronized와 같이 사용하면 원자성을 보장해준다.

### 사용방법
```java
public class YMD {
    private int years;
    private int months;
    private volatile int days;

    public void update(int years, int months, int days){
        this.years  = years;
        this.months = months;
        this.days   = days;
    }
    
    public int totalDays() {
        int total = this.days;
        total += months * 30;
        total += years * 365;
        return total;
    }
}
```
- 대신 volatile 키워드는 선언한 변수 외에도 같이 사용되는 변수들이 있다면 그 변수들은 다 같이 메인 메모리에 기록된다.
- 위에서는 years와 months도 메인 메모리에 기록된다.
- 이것은 Full Visibility를 지원한다고 한다.