---
title: 스프링 MVC 요청 흐름
modified: 2026-10-26
date: 2026-10-26
tags: [스프링, MVC, 구조]
---

# 스프링 MVC 요청 흐름
톰캣 → 서블릿 → 톰캣. 요청 하나가 지나가는 순서를 따라가보기

---
## 전체 흐름
```
HTTP 요청
 → 톰캣
 → DispatcherServlet
 → HandlerMapping      (누가 처리할지 찾기)
 → HandlerAdapter      (실제로 실행)
 → 내 컨트롤러
 → (화면 응답이면) ViewResolver → View
 → 톰캣
 → HTTP 응답
```

## 누가 뭘 담당하나
| 이름 | 하는 일 |
|---|---|
| 톰캣 | 소켓, HTTP 해석, Request/Response 만들기, `service()` 호출, 응답 전송 |
| DispatcherServlet | **지휘자**. 직접 일하지 않고 "누구에게 물을지"만 정함 |
| HandlerMapping | 주소 + HTTP 메서드 → 핸들러(컨트롤러 메서드) 찾기. 표는 시작할 때 한 번 만들어둠 |
| HandlerAdapter | 핸들러를 실제로 실행. 매개변수 준비 → 호출 → 반환값 처리 |
| ArgumentResolver | 매개변수 값 만들기 (`@RequestParam`, `Model`, `@RequestBody` 등) |
| ReturnValueHandler | 반환값 처리. 데이터면 JSON 기록, 화면이면 뷰 이름 저장 |
| ViewResolver | 뷰 이름 → View 찾기 |
| View | Model 값으로 HTML을 만들어서 Response에 기록 |

---
## DispatcherServlet 순서 (doDispatch)
```java
chain = mapping.getHandler(req);                  // 1. 핸들러 + 인터셉터 묶음
adapter = getHandlerAdapter(chain.handler());     // 2. supports가 true인 첫 어댑터
chain.applyPreHandle(req, resp);                  // 3. 인터셉터 (앞에서부터)
mv = adapter.handle(req, resp, chain.handler());  // 4. 실행
chain.applyPostHandle(req, resp, mv);             // 5. 인터셉터 (뒤에서부터)
// 6. mv가 null이 아니면 → ViewResolver → View.render
chain.triggerAfterCompletion(req, resp, ex);      // 7. 예외가 나도 실행
```
- 그 뒤에 톰캣이 Response를 HTTP로 바꿔서 전송
- 반복해서 나오는 모양 : `for` 문으로 **부품들에게 차례로 물어보고** 처음 맞는 걸 사용

## 어댑터 안쪽 (handle)
1. 보관함(`ModelAndViewContainer`, mav) 만들기 : 요청마다 새로
2. 매개변수마다 `resolver.supports` → `resolveArgument` → `args`
3. `method.invoke(bean, args)` : 컨트롤러 실행
4. ReturnValueHandler로 반환값 처리
5. 데이터 응답이면 `requestHandled = true` → **null 반환** / 화면 응답이면 `ModelAndView` 반환

---
## 데이터 응답 vs 화면 응답
| | @RestController | @Controller + 뷰 이름 |
|---|---|---|
| 반환값 처리 | 컨버터가 JSON을 Response에 씀 | 뷰 이름만 mav에 저장 |
| 어댑터가 돌려주는 값 | `null` | `ModelAndView` |
| ViewResolver, View | 건너뜀 | 실행 |

---
## 헷갈렸던 것
> 맞는 매핑을 먼저 고르고, 그다음에 핸들러를 꺼내는건가?
- 한 동작이다. 각 매핑에게 `getHandler(req)`를 물어서 체인을 돌려준 쪽이 곧 맞는 매핑

> 데이터 응답일 때 null은 누가 반환?
- 컨트롤러가 아니라 **어댑터**가 DispatcherServlet에 반환. 컨트롤러는 데이터 자체를 반환함

> mav랑 mv 차이?
- mav : 어댑터 안쪽에서 진행 상태까지 담아 쓰는 **작업대**
- mv : 작업이 끝난 뒤 뷰 이름과 Model만 추려서 돌려주는 **결과물**

> ViewResolver랑 View?
- ViewResolver는 **찾기**, View는 HTML을 만들어서 Response에 **쓰기**

---
## 참고
- 위 코드는 이해하려고 줄인 모양이고 실제 스프링 소스는 아님
- 실제 이름 : `RequestMappingHandlerMapping`, `RequestMappingHandlerAdapter`, `HandlerMethodArgumentResolver`, `HandlerMethodReturnValueHandler`
- 직접 확인하려면 `DispatcherServlet.doDispatch`에 중단점 걸고 디버깅
- 앞 → [[07_백엔드/스프링/02_톰캣과 서블릿|톰캣과 서블릿]]

---
## 같이 보는 자료
공부할 때 쓴 html 2개 (**AI 생성 자료**). 파일을 눌러서 브라우저로 열면 됨
- [코드 따라가기 (AI 생성)](https://yunty.github.io/static/materials/%EC%8A%A4%ED%94%84%EB%A7%81MVC-%EC%BD%94%EB%93%9C%EB%94%B0%EB%9D%BC%EA%B0%80%EA%B8%B0.html) : 톰캣부터 View까지 **각 클래스 안에서 뭘 하는지** 줄인 코드로 순서대로 봄
- [호출 흐름, 변수 색상 보기 (AI 생성)](https://yunty.github.io/static/materials/%EC%8A%A4%ED%94%84%EB%A7%81MVC-%ED%98%B8%EC%B6%9C%ED%9D%90%EB%A6%84-%ED%95%98%EC%9D%B4%EB%9D%BC%EC%9D%B4%ED%8A%B8.html) : 호출 문장에서 **같은 값은 같은 색**으로 칠해서, 값이 어디서 만들어져 어디로 넘어가는지 따라감
