---
title: Visitor(행위)
modified: 2026-09-23
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Visitor
방문자 패턴

---
## 개념
객체 구조는 그대로 유지하면서, 객체 종류마다 다르게 수행해야 하는 작업을 별도의 방문자 객체로 분리하는 패턴
즉 각 객체에 동일한 작업을 해야하는데 객체마다 적용법이 다르다 생각해야함
따라서 객체들은 Visitor한테 자신을 넘기는 메서드를 구현하고
방문자는 각 객체별 처리를 작성해두면 됨

작업을 가진 객체가 여러 객체를 차례대로 찾아가서 작업한다 해서 방문자패턴

나중에 또 작업이 추가된다고 하면 새로운 방문자를 만들면 그만이기 때문에 OCP를 만족하는 기본적인 패턴임
#### 구조
- Element
	- 방문자를 받아들이는 공통 인터페이스
- ConcreteElement
	- 실제 객체들 / Element를 구현해야지 방문자가 방문 가능
- Visitor
	- 객체 종류별 처리 메서드 정의
	- 방문자 정의하는거임
- ConcreteVisitor
	- 실제 방문자 구현
	- 실제 객체들 별 실제 방문자들을 다 구현해야함

## 장·단점
#### 장점


#### 단점

## 사용 방법 
#### Element
```java
interface DocumentElement {
    void accept(DocumentVisitor visitor);
}
```
#### ConcreteElement
```java
class Paragraph implements DocumentElement {

    private final String text;

    @Override
    public void accept(DocumentVisitor visitor) {
        visitor.visit(this);
    }

    public String getText() {
        return text;
    }
}
class Image implements DocumentElement {

    private final String url;

    @Override
    public void accept(DocumentVisitor visitor) {
        visitor.visit(this);
    }

    public String getUrl() {
        return url;
    }
}
```
#### Visitor
```java
interface DocumentVisitor {
    void visit(Paragraph paragraph);
    void visit(Image image);
    void visit(Table table);
}
```
#### ConcreteVisitor
```java
class HtmlExportVisitor implements DocumentVisitor {

    public void visit(Paragraph paragraph) {
        System.out.println(
            "<p>" + paragraph.getText() + "</p>"
        );
    }

    public void visit(Image image) {
        System.out.println(
            "<img src=\"" + image.getUrl() + "\">"
        );
    }

    public void visit(Table table) {
        System.out.println("<table>...</table>");
    }
}
// 다른 기능을 추가할 수 있음
class AccessibilityVisitor implements DocumentVisitor {

    public void visit(Paragraph paragraph) {
        // 글자 명암 검사
    }

    public void visit(Image image) {
        // 대체 텍스트 검사
    }

    public void visit(Table table) {
        // 제목 행 존재 여부 검사
    }
}
```
#### 사용
```java
List<DocumentElement> elements = List.of(
    new Paragraph("방문자 패턴"),
    new Image("diagram.png"),
    new Table()
);

DocumentVisitor visitor = new HtmlExportVisitor();

for (DocumentElement element : elements) {
    element.accept(visitor);
}
```