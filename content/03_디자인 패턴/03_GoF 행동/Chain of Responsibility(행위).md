---
title: Chain of Responsibility(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Chain of Responsibility
책임 연쇄 패턴

---
## 개념
사용자의 요청에 대한 처리를 하나의 객체가 다 처리하는것이 아니라 각각의 처리 객체들로 나누고 이것을 사슬처럼 연결해서 집합 안에서 연쇄적으로 처리하는 패턴
- 보통은 분기문을 각각의 핸들러로 추출해서 사용
#### 구조
- Handler 
	- 요청을 수신하고 처리하는 객체들의 집합을 정의하는 인터페이스
- ConcreteHandler
	- 요청을 처리하는 실제 구현체
- Client
	- 요청을 Handler한테 전달

## 장·단점
#### 장점


#### 단점

---
## 사용 방법 
### 분기문 없애기 / 처리 가능한 하나가 처리하고 종료하는 방식
#### 원본
```java
class CustomerService {
    public void handle(Inquiry inquiry) {
        if (inquiry.getType() == Type.REFUND) {
            System.out.println("환불 처리");
            return;
        }

        if (inquiry.getType() == Type.PAYMENT) {
            System.out.println("결제 문의 처리");
            return;
        }

        if (inquiry.getType() == Type.TECHNICAL) {
            System.out.println("기술 문의 처리");
        }
    }
} // 분기문을 통해 각 타입에 맞는 값을 출력하고 있음
```
#### 핸들러 추상클래스 생성
```java
abstract class InquiryHandler {

    private InquiryHandler next;

    public InquiryHandler setNext(InquiryHandler next) {
        this.next = next;
        return next;
    } // 가장 중요한 코드이며 사용자가 이것을 통해 순서를 지정해둔다.

    public void handle(Inquiry inquiry) {
        if (canHandle(inquiry)) {
            process(inquiry);
            return;
        }

        if (next != null) {
            next.handle(inquiry);
        }
    }

    protected abstract boolean canHandle(Inquiry inquiry);

    protected abstract void process(Inquiry inquiry);
}
```
#### 핸들러 구현체들
```java
class RefundHandler extends InquiryHandler {

    protected boolean canHandle(Inquiry inquiry) {
        return inquiry.getType() == Type.REFUND;
    }

    protected void process(Inquiry inquiry) {
        System.out.println("환불 처리");
    }
}
class PaymentHandler extends InquiryHandler {

    protected boolean canHandle(Inquiry inquiry) {
        return inquiry.getType() == Type.PAYMENT;
    }

    protected void process(Inquiry inquiry) {
        System.out.println("결제 문의 처리");
    }
}
class TechnicalHandler extends InquiryHandler {

    protected boolean canHandle(Inquiry inquiry) {
        return inquiry.getType() == Type.TECHNICAL;
    }

    protected void process(Inquiry inquiry) {
        System.out.println("기술 문의 처리");
    }
}
```
#### 사용법
```java
InquiryHandler refund = new RefundHandler();
InquiryHandler payment = new PaymentHandler();
InquiryHandler technical = new TechnicalHandler();

refund.setNext(payment)
      .setNext(technical);
      
refund.handle(inquiry); // 환불 -> 지불 -> 기술지원 순서대로 돌면서 타입이 맞는지 검사
```
---
---
### 모든 체인을 차례로 처리
#### 핸들러 추상클래스(인터페이스)
```java
// 구체적인 핸들러를 묶는 인터페이스 (추상 클래스)
abstract class Handler {
    // 다음 체인으로 연결될 핸들러
    protected Handler nextHandler = null;

    // 생성자를 통해 연결시킬 핸들러를 등록
    public Handler setNext(Handler handler) {
        this.nextHandler = handler;
        return handler; // 메서드 체이닝 구성을 위해 인자를 그대로 반환함
    }

    // 자식 핸들러에서 구체화 하는 추상 메서드
    protected abstract void process(String url);

    // 핸들러가 요청에 대해 처리하는 메서드 
    public void run(String url) {
        process(url); //본인 작업

        // 만일 핸들러가 연결된게 있다면 다음 핸들러로 책임을 떠넘긴다
        if (nextHandler != null) //무조건 그 다음을 실행시킴
            nextHandler.run(url);
    }
}
```

#### 구현체들
```java
class ProtocolHandler extends Handler {
    @Override
    protected void process(String url) {
        int index = url.indexOf("://");
        if (index != -1) {
            System.out.println("PROTOCOL : " + url.substring(0, index));
        } else {
            System.out.println("NO PROTOCOL");
        }
    }
}

class DomianHandler extends Handler {
    @Override
    protected void process(String url) {
        int startIndex = url.indexOf("://");
        int lastIndex = url.lastIndexOf(":");

        System.out.print("DOMAIN : ");
        if (startIndex == -1) {
            if (lastIndex == -1) {
                System.out.println(url);
            } else {
                System.out.println(url.substring(0, lastIndex));
            }
        } else if (startIndex != lastIndex) {
            System.out.println(url.substring(startIndex + 3, lastIndex));
        } else {
            System.out.println(url.substring(startIndex + 3));
        }
    }
}

class PortHandler extends Handler {
    @Override
    protected void process(String url) {
        int index = url.lastIndexOf(":");
        if (index != -1) {
            String strPort = url.substring(index + 1);
            try {
                int port = Integer.parseInt((strPort));
                System.out.println("PORT : " + port);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
    }
}
```

#### 사용법
```java
class Client {
    public static void main(String[] args) {
        // 1. 핸들러 생성
        Handler handler1 = new ProtocolHandler();
        Handler handler2 = new DomianHandler();
        Handler handler3 = new PortHandler();

        // 2. 핸들러 연결 설정 (handler1 → handler2 → handler3)
        // 순서를 정함
        handler1.setNext(handler2).setNext(handler3);

        // 3. 요청에 대한 처리 연쇄 실행
        String url1 = "http://www.youtube.com:80";
        System.out.println("INPUT: " + url1);
        handler1.run(url1);

        System.out.println();

        String url2 = "https://www.inpa.tistory.com:443";
        System.out.println("INPUT: " + url2);
        handler1.run(url2);

        System.out.println();

        String url3 = "http://localhost:8080";
        System.out.println("INPUT: " + url3);
        handler1.run(url3);
    }
}
```