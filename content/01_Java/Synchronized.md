---
title: Synchronized
modified: 2026-09-20
---
#멀티스레드 #동시성 #스레드_동기화
# Synchronized
1개의 쓰레드만 사용할 수 있게 lock을 걸어두는 방식

## 사용방법
---
### 메서드에 설정
```java
public synchronized void increase(){
	count++;
	System.out.println(count);
}
```

### 코드블럭에 설정
```java
void increase(){
	synchronized(this){
		count++;
	}
	System.out.println(count);
}
```
- sychronized(참조변수)로 사용하게 된다.
- 참조변수는 어떤 객체의 락(열쇠)를 사용할것인지 즉 어떤 객체의 열쇠만 사용할것인지 지정하는것이다.
- this는 이 메서드를 불러온 객체를 의미
- `Block block = new Block()`으로 선언 후 `block.increase`를 하면 this 는 block을 의미함

### 장점
- [[Mutual Exclusion]]과 [[Visibility]]를 모두 지원해준다.
- 원자성(atomic)을 보장해준다