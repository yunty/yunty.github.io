---
title: HTTP 헤더와 쿠키
modified: 2026-10-19
---
# 7. HTTP 헤더와 쿠키

> 출발 질문: 같은 URL의 응답을 한국어·영어, JSON·HTML로 다르게 줄 수 있을까?

## 7.1 헤더는 메시지 해석·처리에 필요한 정보다

```http
GET /products/10 HTTP/1.1
Host: example.com
Accept: application/json
Accept-Language: ko, en;q=0.8

```

본문이 없는 요청도 헤더를 가질 수 있다. 헤더가 모두 ‘부가적인 선택 사항’인 것은 아니다. 예를 들어 HTTP/1.1 요청의 Host는 필수이며, 메시지 경계에 필요한 필드도 있다.

## 7.2 자원과 표현

자원은 상품 10번이라는 대상이고, 표현은 그 대상을 클라이언트에 보여 주는 형태다. 같은 상품을 JSON이나 HTML로 표현할 수 있다.

| 헤더 | 의미 | 예시 |
|---|---|---|
| Content-Type | 콘텐츠의 미디어 타입 | `application/json` |
| Content-Encoding | 콘텐츠에 적용한 인코딩 | `gzip` |
| Content-Language | 표현의 언어 | `ko` |
| Content-Length | 해당 메시지에서 규칙에 따라 해석하는 바이트 길이 | `12` |

gzip 압축과 UTF-8 문자 인코딩은 다르다. 문자셋은 `Content-Type: text/html; charset=utf-8`처럼 전달할 수 있다. 압축된 메시지에서 Content-Length를 사용한다면 일반적으로 압축된 콘텐츠의 전송 바이트 길이를 나타낸다.

## 7.3 콘텐츠 협상

클라이언트는 선호를 알리고 서버는 지원 가능한 표현을 선택한다.

| 요청 헤더 | 원하는 응답의 조건 |
|---|---|
| Accept | 미디어 타입 |
| Accept-Language | 언어 |
| Accept-Encoding | 압축 등 콘텐츠 인코딩 |

`en;q=0.8`의 q는 상대적 선호도다. 큰 값을 우선 선호하며, 0은 허용하지 않음을 나타낸다. 서버가 모든 요청 언어를 지원하는 것은 아니다.

응답이 Accept-Language에 따라 달라진다면 `Vary: Accept-Language`처럼 캐시가 구분해야 할 요청 헤더를 알릴 수 있다. [[08_캐시와 조건부 요청]]과 연결되는 부분이다.

근거: [MDN 콘텐츠 협상](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Content_negotiation).

## 7.4 길이·청크·범위 전송

| 방식 | 핵심 |
|---|---|
| 길이를 아는 전송 | Content-Length 등으로 경계 지정 |
| HTTP/1.1 chunked | 본문을 크기가 붙은 청크들로 나눠 전송 |
| 압축 | gzip 등으로 콘텐츠 자체의 크기 감소 |
| 범위 요청 | Range로 원하는 부분만 요청하고 206 등으로 응답 |

청크 전송은 ‘한 HTTP 본문을 어떻게 구분해 전달하는가’, 범위 요청은 ‘자원의 어느 부분을 달라는가’다. 둘은 별개다. HTTP/2·3에서는 프레임으로 전달하며 HTTP/1.1의 chunked 방식을 그대로 쓰지 않는다.

```http
GET /large-file HTTP/1.1
Host: example.com
Range: bytes=0-999

```

지원하는 서버는 206과 Content-Range 등을 보낼 수 있다. 서버가 Range를 항상 수용하는 것은 아니다. [HTTP/1.1 전송 구문](https://www.rfc-editor.org/rfc/rfc9112.html), [RFC 9110 범위 요청](https://www.rfc-editor.org/rfc/rfc9110.html#section-14).

## 7.5 자주 만나는 일반·특수 정보

| 헤더 | 읽는 법 |
|---|---|
| Host | 요청 대상 호스트. HTTP/2·3에는 대응하는 `:authority`가 있음 |
| User-Agent | 요청을 생성한 소프트웨어 정보. 신원 보증은 아님 |
| Referer | 유입 문서 등의 정보. 정책에 따라 생략·축소될 수 있음 |
| Date | 메시지 생성 시각 |
| Server | 서버 소프트웨어 정보 등. 생략될 수 있음 |
| Location | 리다이렉션 대상 또는 생성한 자원 위치 등 |
| Allow | 대상에서 허용하는 메서드 |
| Retry-After | 다시 시도할 시점·대기 시간 안내 |
| Content-Disposition | 인라인 표시나 다운로드, 파일명 등의 힌트 |

헤더의 존재만으로 특정 업무 결과를 단정하지 말고 상태 코드·메서드와 함께 읽는다. [헤더·메시지 의미 RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html).

## 7.6 인증과 인가

- **인증(Authentication):** 누구인지 또는 유효한 자격을 가졌는지 확인.
- **인가(Authorization):** 그 대상에게 어떤 작업을 허용할지 결정.

```http
Authorization: Bearer <토큰>
```

Bearer는 그 값을 가진 주체가 사용할 수 있는 자격 증명 방식이다. Bearer라고 항상 JWT인 것은 아니다. Basic 인증은 자격 정보를 Base64로 표현하지만 Base64는 암호화가 아니다. 민감한 자격 증명의 전송에는 HTTPS가 필요하다.

서버는 필요한 인증 방식을 WWW-Authenticate로 알릴 수 있다. 인증 성공 후에도 자원별 권한 검사는 별도로 해야 한다. [MDN HTTP 인증](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Authentication).

## 7.7 쿠키: 브라우저의 저장·자동 전송 기능

서버 응답:

```http
Set-Cookie: sid=abc123; Path=/; Secure; HttpOnly; SameSite=Lax
```

이후 조건에 맞는 요청:

```http
Cookie: sid=abc123
```

브라우저는 쿠키를 자신이 관리하는 저장소에 기록하고, 요청 대상·보안 조건·정책에 맞을 때 전송한다. 디스크와 메모리 등 실제 관리 방식은 구현에 따라 다르다. 다운로드 폴더에 사용자가 지정한 파일로 저장하는 기능은 아니다.

| 속성 | 의미 |
|---|---|
| Domain | 전송 대상 도메인 범위. 생략하면 보통 설정한 호스트에 한정 |
| Path | 경로에 따른 전송 범위. 접근 제어 수단 자체는 아님 |
| Max-Age / Expires | 쿠키의 수명 설정 |
| Secure | 일반적으로 HTTPS 같은 안전한 연결로만 전송 |
| HttpOnly | 브라우저 스크립트의 일반적인 쿠키 읽기 접근 제한 |
| SameSite | 다른 사이트 문맥의 요청에 쿠키를 보낼 조건 제어 |

서로 다른 사이트의 모든 요청에 쿠키가 무조건 붙는 것은 아니다. SameSite·브라우저 개인정보 정책 등도 적용된다. SameSite의 site와 CORS의 origin은 같은 기준이 아니다.

HttpOnly여도 브라우저의 정상 HTTP 요청에는 쿠키가 포함될 수 있다. 쿠키가 자동 전송되므로 권한 있는 동작에는 CSRF 방어 등도 필요하다. SameSite 하나가 모든 공격을 해결하지는 않는다.

근거: [쿠키 RFC 6265](https://www.rfc-editor.org/rfc/rfc6265.html), [MDN 쿠키와 현대 브라우저 속성](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Cookies).

## 7.8 웹 세션: 여러 요청을 같은 이용 상태로 연결

```text
브라우저 쿠키                   서버의 세션 저장소
sid=abc123 ─────────────────→ abc123 → userId=42, 만료 시각 등
```

로그인 성공 시 서버가 세션을 만들고 ID를 전달한다. 다음 요청에서 ID를 받아 세션을 조회한다. 세션 저장소는 메모리·DB·공유 저장소 등으로 구성할 수 있다.

브라우저 쿠키의 수명과 서버 세션의 수명은 다르다. 쿠키가 있어도 세션이 만료되면 인증이 실패할 수 있다. 로그아웃은 일반적으로 서버 세션 무효화와 쿠키 제거를 함께 처리한다.

**TCP 연결을 새로 만들어도 같은 세션 ID로 로그인 상태를 이어 갈 수 있다.** 로그인 세션은 전송 연결과 별개다. 세션은 익명 장바구니 등 로그인 외의 상태에도 사용한다.

## 7.9 JWT와 비교하기

일반적인 서명형 JWT는 다음처럼 구성된다.

```text
헤더.페이로드.서명
```

페이로드에는 사용자 식별자·발급자·대상·만료 시각 등의 클레임을 담을 수 있다. 서버는 신뢰하는 키와 허용한 알고리즘으로 서명, 발급자·대상·유효기간 등 필요한 조건을 검증한다. 문자열을 디코딩해 사용자 ID를 읽었다고 인증이 끝난 것은 아니다.

| 개념 | 분류 |
|---|---|
| 쿠키 | 브라우저 저장·전송 수단 |
| 서버 측 세션 | 서버가 유지하는 이용 상태 |
| JWT | 정보를 담는 토큰 형식 |

JWT를 쿠키에 넣을 수도 있고 Authorization 헤더로 보낼 수도 있다. JWT 서명은 암호화가 아니므로 일반적인 서명형 토큰의 내용은 읽을 수 있다. 별도의 암호화 토큰 형식도 있지만 여기서는 서명형을 기준으로 한다.

서버 세션은 저장소에서 무효화할 수 있다. 자체 검증 JWT는 이미 발급된 값을 즉시 폐기하려면 별도 상태·설계가 필요할 수 있다. JWT를 쓴다고 전체 시스템이 무상태가 되는 것도 아니다. [JWT RFC 7519](https://www.rfc-editor.org/rfc/rfc7519.html).

## 확인 문제

1. Content-Type, Accept, Content-Encoding은 각각 무엇을 설명하는가?
2. chunked 전송과 파일 범위 요청의 차이는?
3. 인증된 사용자가 403을 받을 수 있는 이유는?
4. 쿠키·서버 세션·JWT가 서로 같은 분류가 아닌 이유는?
5. HttpOnly 쿠키는 브라우저가 서버에 보내지 않는 쿠키인가?

다음: [[08_캐시와 조건부 요청]] · 해설: [[10_복습 문제 해설#7단원]]
