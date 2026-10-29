---
title: Class.class  Java.lang.Class
modified: 2026-09-24
---
# Class.class
java.lang.Class

## 개념
- java.lang 패키지에 담겨있는 Class라는 클래스를 뜻함
- 어떤 타입인지, 어떤 메서드, 생성자, 필드가 있는지 등의 정보를 담는 객체이다.
- 런타임 환경에서 동적으로 저장된 클래스나 인터페이스 정보를 가져오는데 사용한다.
- JVM에서 어떤 클래스가 사용되고 클래스 로더가 그 클래스를 읽으면 Class<객체> 객체를 생성한다.
- 만약 4개의 클래스가 사용되고 있다면 Class객체도 4개가 생성되는것이다.
- 대신 클래스는 같고 참조변수가 여러개(여러 객체를 뽑는다)면 그것은 1개로 모두 공유한다.
	- 다만 그 객체를 읽어온 클래스 로더가 다르면 다른 객체로 본다
	- 클래스의 정체성 : 클래스 이름 + 클래스를 정의한 클래스로더
	- 자동으로 힙영역에 객체화 되기 때문에 new를 통한 인스턴스화는 필요없고 그냥 바로 사용 가능
## GC의 처리
#### 저장되는 공간
Class도 객체이기 때문에 힙 영역에 자동으로 올라간다
따라서 **GC의 관리대상**이지만 제거 조건이 더 까다롭다
#### 조건
`Class<ex>` 객체를 참조하는 곳이 없고 객체를 로딩해온 클래스로더 또한 참조하는곳이 없어진다면 제거 및 메타스페이스에서 언로딩 가능
	- ex는 그냥 예시 객체
	- 클래스로더 또한 힙영역에 있기에 GC 관리대상
	- 클래스로더가 클래스를 JVM에 로딩하고
	- 클래스로더가 끝나면 GC가 힙에서 없애고 JVM은 메타스페이스에서 클래스의 메타데이터 제거

## Class 객체 얻기
#### Class.getClass()로 얻기
```java
public static void main(String[] args){
	String str = new String();
	Class<? extends String> cls = str.getClass();
	System.out.println(cls);
}
```
#### .class 리터럴로 얻기
```java
public static void main(String[] args){
	Class<? extends String> cls = String.class;
}
```
#### .forName() 으로 얻기
```java
public static void main(String[] args){
	Class<? extends String> cls = Class.forName("java.lang.String");
	//파일 경로를 넣어주면 되는거임
}
```