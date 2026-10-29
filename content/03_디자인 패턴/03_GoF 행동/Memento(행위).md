---
title: Memento(행위)
modified: 2026-09-23
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Memento
메멘토 패턴
#### 

---
## 개념
객체의 상태를 특정 시점에 저장해 두었다가, 나중에 그 상태로 복원하는 패턴
#### 구조
- Originator
	- 상태를 가지고 있으며 저장 복원되는 원본 객체
- Memento
	- 특정 시점의 상태를 보관하는 객체
- Caretaker
	- Memento를 보관하고 필요할 때 원본에 돌려주는 객체

## 장·단점
#### 장점
- 객체의 캡슐화를 깨지 않고 상태를 저장할 수 있음
- 실행 취소와 상태 복원을 구현하기 쉬움
- 여러 시점의 상태를 보관할 수 있음
#### 단점
- 상태가 크면 메모리를 많이 사용할 수 있음
- 가변 객체가 있으면 깊은 복사를 고려해야 함
- 상태가 자주 바뀌면 메멘토 객체가 많이 생성됨
- 어떤 시점에 저장할지 별도로 관리해야 함

## 사용 방법 
#### Memento
```java
public record EditorMemento(
    String text,
    int cursorPosition
) {
}
```
#### Originator
```java
class TextEditor {

    private String text;
    private int cursorPosition;

    public void write(String text) {
        this.text = text;
        this.cursorPosition = text.length();
    }

    public EditorMemento save() {
        return new EditorMemento(
            text,
            cursorPosition
        );
    }

    public void restore(EditorMemento memento) {
        this.text = memento.text();
        this.cursorPosition = memento.cursorPosition();
    }

    public void print() {
        System.out.println(text);
    }
}
```
#### Caretaker
```java
class EditorHistory {

    private final Stack<EditorMemento> history =
        new Stack<>();

    public void save(EditorMemento memento) {
        history.push(memento);
    }// 상태를 저장해둠

    public EditorMemento undo() {
        return history.pop();
    }
}
```

#### 사용
```java
TextEditor editor = new TextEditor();
EditorHistory history = new EditorHistory();

editor.write("안녕하세요");
history.save(editor.save());

editor.write("안녕하세요. 반갑습니다.");
editor.print();
```

## 스냅샷과 다른점
스냅샷은 출력과 기록을 위해서만 사용하고
메멘토는 외부에서 상태를 보관하고 원본 객체를 복원하는데 사용하는것이다.