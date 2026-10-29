---
title: RESTful 맛보기
modified: 2026-10-25
date: 2026-10-25
tags: [스프링, REST, API]
---

# RESTful 맛보기
스프링 공식 가이드(Building a RESTful Web Service)로 기초를 해보고, 그걸 응용해봄

---
## REST란
- 자원(URI)을 **HTTP 메서드**로 다루는 방식

| 메서드 | 의미 | 예 |
|---|---|---|
| GET | 조회 | `GET /todos/1` |
| POST | 생성 | `POST /todos` |
| PUT | 수정 | `PUT /todos/1` |
| DELETE | 삭제 | `DELETE /todos/1` |

- 응답은 보통 **JSON + 상태 코드**(200, 201, 404 ...)

---
## 공식 가이드에서 한 것 (기초)
- 요청이 오면 JSON을 돌려주는 가장 단순한 API

```java
@RestController
public class GreetingController {
	private final AtomicLong counter = new AtomicLong();

	@GetMapping("/greeting")
	public Greeting greeting(@RequestParam(defaultValue = "World") String name) {
		return new Greeting(counter.incrementAndGet(), "Hello, " + name);
	}
}
```
- 객체를 그냥 `return` 했는데 JSON이 나감. 이유는 아래

## @Controller랑 뭐가 다른가
| @Controller | @RestController |
|---|---|
| `return "hello"` → 뷰 이름 | `return 객체` → 응답 본문(JSON) |
| ViewResolver → View로 HTML 만듦 | 뷰를 안 거침 |

- `@RestController` = `@Controller` + `@ResponseBody`
- 객체 → JSON 변환은 `HttpMessageConverter`(Jackson)가 해줌
- 즉 데이터 응답은 Response에 바로 쓰고 끝나서 ViewResolver, View 단계를 건너뜀 → [[07_백엔드/스프링/05_스프링 MVC 요청 흐름|스프링 MVC 요청 흐름]]

---
## 응용
- GET만 있던걸 POST, PUT, DELETE까지 넓힘 ex) 자원 하나를 만들고 조회, 수정, 삭제
- `@PathVariable`로 주소의 `{id}` 받기, `@RequestBody`로 JSON 요청 받기
- 없는 id면 404, 잘못된 입력이면 400 → 상태 코드도 신경쓰기
