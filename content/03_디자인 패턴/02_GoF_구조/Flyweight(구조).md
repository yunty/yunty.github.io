---
title: Flyweight(구조)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/구조 #객체지향
# Flyweigth
#### 경량패턴
---
## 개념
재사용 가능한 객체의 인스턴스를 공유시켜 메모리 사용량을 최소화하는 패턴이다.
#### Intrinsic & Extrinsic 상태
- Intrinsic : 본질, 고유를 뜻하며, 언제 어디서든 값이 고정되어있음 &rarr; 공유 가능
- Extrinsic : 외적, 비본적을 의미하며, 언제 어디인지에 따라 값이 변경됨 &rarr; 공유 불가능

---
## 장·단점
#### 장점
- 메모리 사용량 최소화
- 그에 따른 프로그램 속도 개선

#### 단점
- 코드 복잡도 증가
---
## 사용 방법 / Lazy initialization 방법
1. 사용되고 있는 객체에서 공유해도 되는 필드는 따로 추출해서 객체를 새로 만든다.
2. 그 객체에 대한 Flyweight 팩토리 생성
	1. Map<key, newField>로  공유된 값들을 모아둔다
	2. 만약 map에 있으면 이전에 썻던 공유되는 값을 그대로 사용
	3. 없으면 새로 추가
3. 사용

#### 사용되고 있는 객체에서 필드 추출
```java
public class Tree {
    private final String name; // 나무의 종류에 따라 모든값이 고정이므로 공유 가능
    private final String texture;
    private final String color;

    private final int x; // 나무의 위치마다 다 다르므로 공유 불가능
    private final int y;
}
//Tree객체에 공유 안되는것들을 남기고 TreeType으로 추출
public class Tree {

    private final int x;
    private final int y;
    private final TreeType type;

    public Tree(int x, int y, TreeType type) {
        this.x = x;
        this.y = y;
        this.type = type;
    }

    public void draw() {
        type.draw(x, y);
    }
}
public class TreeType {

    private final String name;
    private final String color;
    private final String texture;

    public TreeType(String name, String color, String texture) {
        this.name = name;
        this.color = color;
        this.texture = texture;
    }

    public void draw(int x, int y) {
        System.out.println(
            name + \" 나무를 \" + x + \", \" + y + \"에 그리기\"
        );
    }
}
```
#### 공유 객체에 대한 Flyweight 팩토리 생성
```java
public class TreeTypeFactory {

    private static final Map<String, TreeType> cache =
        new HashMap<>();

    public static TreeType getTreeType(
        String name,
        String color,
        String texture
    ) {
        String key = name + color + texture; // 해쉬맵의 키값

        return cache.computeIfAbsent(
            key,
            ignored -> new TreeType(name, color, texture) // 없으면
        );
    }
    //있다는건 이전에 썼던거라는거고 그대로 사용하면 됨
    //없다는건 처음 쓰는거기때문에 새로 만들어서 넣고 반환
}
```
#### 사용
```java
public class Client{
	public static void main(String[] args){
		Tree tree1 = new Tree(10,20,
		                      TreeTypeFactory.getTreeType(name,color,texture));
		
	}
}
```

---


#