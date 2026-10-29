---
title: 리플렉션 Reflection
modified: 2026-09-24
---
# 리플렉션
## 개념
- 구체적인 클래스 타입을 알지 못하더라도 해당 클래스의 method, type, variable에 접근할 수 있도록 해주는 자바 API이다.
- 런타임에 동적으로 특정 클래스의 정보를 추출할 수 있는 프로그래밍 기법이다.
- 결국 [[Class.class _Java.lang.Class|Class 객체]]를 사용해서 동적으로 접근하는것을 리플렉션 기법이며 Class 객체를 사용하는 대표적인 기법이다.

## 사용방법
#### 기본 클래스
```java
// 필요 패키지 로드
import java.lang.reflect.*;

class Person {
    public String name; // public 필드
    private int age; // private 필드

    public static int height = 180; // static 필드

    // 이름, 나이를 입력받는 생성자
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    // 기본 생성자
    public Person() {
    }

    public void getField() {
        System.out.printf("이름 : %s, 나이 : %d\n", name, age);
    }

    // public 메소드
    public int sum(int left, int right) {
        return left + right;
    }

    // static 메소드
    public static int staticSum(int left, int right) {
        return left + right;
    }

    // private 메소드
    private int privateSum(int left, int right) {
        return left + right;
    }
}
```

#### 동적으로 생성자 가져와서 사용하기
```java
public static void main(String[] args) throws Exception {
    // 클래스 객체 가져오기 (forName 메소드 방식)
    Class<Person> personClass = (Class<Person>) Class.forName("Person");

    // 생성자 가져오기 - Person(String name, int age)
    Constructor<Person> constructor = personClass.getConstructor(String.class, int.class); // getConstructor 인자로 생성자의 매개변수 타입을 바인딩 해주어야 한다.

    // 가져온 생성자로 인스턴스 만들기
    Person person1 = constructor.newInstance("홍길동", 55);
    person1.getField(); // 이름 : 홍길동, 나이 : 55
}
// getConstructor()를 호출할때 인자로 생성자의 매개변수 타입을 바인딩 해주어야 한다.
// 만일 어떠한 매개변수 타입을 지정해주지 않으면 기본 생성자가 호출된다.
// 만약 해당하는 생성자를 찾지 못하면 NoSuchMethodException이 발생한다.
```

#### 동적으로 메서드 가져와 실행하기
```java
public static void main(String[] args) throws Exception {
    Class<Person> personClass = (Class<Person>) Class.forName("Person");

    // 특정 public 메서드 가져와 실행
    // getMethod("메서드명", 매개변수타입들)
    Method sum = personClass.getMethod("sum", int.class, int.class);
    int result = (int) sum.invoke(new Person(), 10, 20);
    System.out.println("result = " + result); // 30


    // 특정 static 메서드 가져와 실행
    Method staticSum = personClass.getMethod("staticSum", int.class, int.class);
    int staticResult = (int) staticSum.invoke(null, 100, 200);
    System.out.println("staticResult = " + staticResult); // 300


    // 특정 private 메서드 가져와 실행
    Method privateSum = personClass.getDeclaredMethod("privateSum", int.class, int.class);
    privateSum.setAccessible(true); // private 이기 때문에 외부에서 access 할 수 있도록 설정
    int privateResult = (int) privateSum.invoke(new Person(), 1000, 2000);
    System.out.println("privateResult = " + privateResult); // 3000
}
// getMethod()를 호출할때 인자로 생성자의 매개변수 타입을 바인딩 해주어야 한다.
// 만약 매개변수가 없는 메소드라면 메소드 명만 입력해주면 된다.
// 실행은 Method 타입에서 제공하는 invoke()를 호출하여 실행하면 된다.
```

#### 동적으로 필드 가져와 조작하기
```java
public static void main(String[] args) throws Exception {
    Class<Person> personClass = (Class<Person>) Class.forName("Person");

    // static 필드를 가져와 조작하고 출력하기
    Field height_field = personClass.getField("height");
    height_field.set(null, 200);
    System.out.println(height_field.get(null)); // 200
}
public static void main(String[] args) throws Exception {
    Person person = new Person("홍길동", 55);

    // 클래스 객체 가져오기
    Class<Person> personClass = (Class<Person>) Class.forName("Person");

    // public 필드를 가져온다.
    Field name_field = personClass.getField("name");

    // private 필드를 가져온다.
    Field age_field = personClass.getDeclaredField("age");
    age_field.setAccessible(true); 
    // private 이기 때문에 외부에서 access 할 수 있도록 설정

    // 필드 조작하기
    name_field.set(person, "임꺽정");
    age_field.set(person, 88);

    System.out.println(name_field.get(person)); // 임꺽정
    System.out.println(age_field.get(person)); // 200
}
```