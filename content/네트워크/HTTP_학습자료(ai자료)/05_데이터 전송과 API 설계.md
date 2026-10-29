---
title: 데이터 전송과 API 설계
modified: 2026-10-19
---
# 5. 데이터 전송과 API 설계

> 출발 질문: 검색 조건, 가입 폼, 파일 업로드, 주문 JSON을 모두 같은 방식으로 보내면 될까?

## 5.1 데이터를 어디에 담을까?

| 상황 | 대표 방식 | 예시 |
|---|---|---|
| 검색·필터·페이지 | URL 쿼리 | `GET /products?q=book&page=2` |
| 단순 HTML 폼 제출 | URL 인코딩 본문 | `name=A&age=20` |
| 파일과 입력값 함께 업로드 | multipart 본문 | 프로필 사진과 닉네임 |
| 프로그램 간 구조화된 데이터 | JSON 본문 등 | 주문 항목 목록 |

메서드는 동작 의미, Content-Type은 본문 형식이다. POST라고 자동으로 JSON인 것은 아니다.

## 5.2 HTML form 전송

기본 HTML 폼은 보통 GET 또는 POST로 제출한다. PUT·PATCH·DELETE는 스크립트 요청이나 별도 처리 등이 필요하다.

```html
<form method="post" action="/users">
  <input name="name" value="A">
  <button type="submit">등록</button>
</form>
```

대표적인 전송 형식:

```http
POST /users HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded

name=A
```

GET 폼이면 입력값을 쿼리로 구성한다. POST 본문이라고 암호화되는 것은 아니므로 전송 보호에는 HTTPS가 필요하다. URL은 방문 기록·로그 등에 남을 수 있으므로 민감한 비밀을 쿼리로 보내지 않는다.

## 5.3 파일 업로드와 multipart

`multipart/form-data`는 본문을 여러 파트로 나누고 각 파트에 이름·파일명·형식 등을 붙일 수 있다.

```text
multipart 본문
├─ 파트 1: name="nickname" → A
└─ 파트 2: name="photo"; filename="profile.png" → 이미지 바이트
```

파트 경계는 boundary 값으로 구분한다. 브라우저의 FormData를 사용할 때는 브라우저가 올바른 경계와 Content-Type을 생성하게 두는 것이 일반적이다. 파일 업로드와 HTTP/1.1 chunked 전송은 서로 다른 개념이다.

## 5.4 JSON API

```http
POST /orders HTTP/1.1
Host: example.com
Content-Type: application/json
Accept: application/json

{"items":[{"productId":10,"quantity":2}]}
```

Content-Type은 **보내는 본문이 무엇인지**, Accept는 **어떤 응답 표현을 선호하는지**를 알린다. 서버는 JSON 문법 검증과 별개로 상품 존재 여부·수량 범위·주문 권한 같은 업무 검증도 수행한다.

요청 형식 참고: [MDN HTTP 메시지](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Messages), [콘텐츠 협상](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Content_negotiation).

## 5.5 자원 중심으로 API를 구성하기

상품·주문을 다루는 예다.

| 목적 | 예시 | 설명 |
|---|---|---|
| 상품 목록 | `GET /products` | 컬렉션 조회 |
| 특정 상품 | `GET /products/10` | 개별 문서·자원 |
| 상품 생성 | `POST /products` | 서버가 생성 URI를 정하는 방식 |
| 특정 경로에 저장 | `PUT /files/report.txt` | 클라이언트가 대상 URI를 지정하는 저장소 방식 |
| 상품 수정 | `PATCH /products/10` | 계약에서 정한 부분 변경 |
| 주문 생성 | `POST /orders` | 주문 자원 생성 |
| 취소 요청 생성 | `POST /orders/123/cancellations` | 취소를 별도 자원으로 모델링한 예 |

복잡한 작업을 항상 CRUD에 억지로 끼워 넣을 필요는 없다. `POST /orders/123/cancel` 같은 동작형 엔드포인트를 선택할 수도 있다. 자원 모델·클라이언트 사용 방식·일관성을 고려해 계약을 명확히 한다.

### URI를 정할 때 확인할 것

- 목록과 개별 항목을 일관되게 구분하는가?
- 필터·정렬·페이지 조건의 의미가 문서화되어 있는가?
- 메서드가 실제 수행하는 동작과 일치하는가?
- 응답 상태·필드·오류 형태가 예측 가능한가?
- 다른 사용자의 자원을 다룰 때 권한 검증이 있는가?

`/users/42`를 안다고 사용자 42의 정보에 접근할 권한이 생기는 것은 아니다. 주소 식별과 인증·인가를 분리한다.

## 5.6 HTTP API와 REST는 같은 말이 아니다

HTTP는 프로토콜, API는 프로그램 간 인터페이스, REST는 아키텍처 스타일이다. REST에는 무상태성·캐시·계층 구조·일관된 인터페이스 등의 제약이 있다. 명사형 URL과 메서드를 사용한 것만으로 모든 REST 제약을 만족하는 것은 아니다. 실무에서 REST API라는 이름이 더 넓게 사용되기도 한다.

이 교재의 API 예시는 **HTTP 의미를 살려 설계하는 연습**이며, 모든 REST 제약을 구현한 완성 모델이라고 가정하지 않는다.

## 5.7 중복 주문과 동시 수정

### 주문 요청 중복

```text
클라이언트 → 주문 생성 요청 → 서버가 주문 저장
클라이언트 ← 응답 손실       ← 서버 응답
클라이언트 → 같은 의도로 재요청
```

처리 방안의 한 예는 애플리케이션의 **중복 방지 키**다. 같은 사용자·같은 키·같은 요청을 다시 받으면 새 주문 대신 기존 결과를 돌려주도록 설계한다. 키가 같지만 본문이 다른 경우, 키 보관 기간, 동시에 들어온 요청의 원자적 처리는 별도로 정의해야 한다. 헤더 이름 하나를 붙이는 것만으로 기능이 생기지 않는다.

### 동시 수정

두 사람이 오래된 상품 정보를 수정하면 뒤의 요청이 앞의 수정을 덮을 수 있다. ETag와 If-Match를 사용해 ‘내가 읽었던 버전일 때만 수정’하도록 구성할 수 있다. 실패하면 `412 Precondition Failed`로 새 상태 확인을 유도한다. [[08_캐시와 조건부 요청]]에서 이어서 다룬다.

HTTP 조건부 요청 근거: [RFC 9110 조건부 요청](https://www.rfc-editor.org/rfc/rfc9110.html#section-13).

## 확인 문제

1. POST라는 사실만으로 서버가 JSON 본문을 기대해도 되는가?
2. 검색 폼과 파일 업로드에 각각 어떤 전송 형식을 선택할 수 있는가?
3. Content-Type과 Accept의 방향 차이를 설명하라.
4. 클라이언트가 URI를 정하는 PUT과 서버가 정하는 POST 생성의 차이는?
5. 중복 방지 키를 사용한다면 서버 쪽에 어떤 동작을 구현해야 하는가?

다음: [[06_HTTP 상태 코드]] · 해설: [[10_복습 문제 해설#5단원]]
