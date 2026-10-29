---
title: AOP
modified: 2026-10-28
date: 2026-10-28
tags: [스프링, AOP]
---

# AOP
Aspect Oriented Programming

---
## 왜 필요한가
- 메서드마다 시간 측정 같은 코드를 넣으면 핵심 로직이랑 섞이고, 바꾸려면 전부 찾아서 고쳐야 함
- 그래서 둘을 분리함
	- **핵심 관심사** : 비즈니스 로직 (회원가입, 조회)
	- **공통 관심사** : 시간 측정, 로깅 같이 여러 곳에 걸치는 것

## 사용
```java
@Aspect
@Component
public class ExecutionTimer {

	@Around("execution(* com.example..*Service.*(..))")  // 서비스 클래스의 모든 메서드
	public Object measure(ProceedingJoinPoint pjp) throws Throwable {
		long start = System.nanoTime();
		try {
			return pjp.proceed();  // 진짜 메서드 실행
		} finally {
			long ms = (System.nanoTime() - start) / 1_000_000;
			System.out.println(pjp.getSignature() + " : " + ms + "ms");
		}
	}
}
```
- 공통 로직을 한 곳에 두고, 적용 대상은 패턴으로 고름
- 서비스 코드는 하나도 안 고쳤는데 시간이 찍힘

---
## 원리 : 프록시
- AOP를 적용하면 스프링이 진짜 서비스 앞에 **가짜(프록시)** 를 만들어서 주입
```
컨트롤러 → 프록시 → proceed() → 진짜 서비스
```
- 콘솔에 찍어보면 클래스 이름에 `$$EnhancerBySpringCGLIB`가 붙어있어서 프록시인걸 확인할 수 있음
- `@Transactional`도 같은 프록시 방식으로 동작
- 앞에서 본 커넥션 풀의 `close()`가 반납이 되는 것도 진짜 연결을 감싼 프록시라서 → [[07_백엔드/스프링/07_DB 접근 기술|DB 접근 기술]]
