---
title: Iterator(행위)
modified: 2026-09-23
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Iterator
반복자 패턴
#### 

---
## 개념
데이터 집합에 대하여 순차적인 접근 즉 순회를 지원하는 패턴이다.
리스트, 트리, 그래프, 테이블 등

#### 구조
- Aggregate
	- ConcreateIterator 객체를 반환하는 팩토리 메서드 선언
- ConcreateAggregate
	- 여러 요소들이 이루어져 있는 데이터 집합체 즉 데이터 집합을 필드로 가지고 있음
- Iterator
	- hasNext() : 순회할 다음 요소가 있는지 boolean 값
	- next() : 요소를 반환하고 다음 요소를 반환할 준비를 하기 위해 넘어감
- ConcreateIterator
	-  데이터 집합 필드
	- 생성자로 컬렉션을 받아 데이터 집합체 초기화
	- hasNext, next 사용할 객체에 맞춰 오버라이딩
즉 Aggregate는 단지 Iterator를 생성하는 메서드를 선언해두고
ConcreateAggregate는 데이터들과 본인을 사용하는 Iterator를 구현시켜둠
iterator는 hasNext, next를 선언해둠
ConcreateIterator는 ConcreateAggregate의 데이터를 받아서 처리하는 클래스임

## 장·단점
#### 장점


#### 단점

## 사용 방법 
#### Iterator 없을때
```java
// 게시글
class Post {
    String title; // 게시글 제목
    LocalDate date; // 게시글 발행일

    public Post(String title, LocalDate date) {
        this.title = title;
        this.date = date;
    }
}

// 게시판
class Board {
    // 게시글을 리스트 집합 객체로 저장 관리
    List<Post> posts = new ArrayList<>();

    public void addPost(String title, LocalDate date) {
        this.posts.add(new Post(title, date));
    }

    public List<Post> getPosts() {
        return posts;
    }
}
------------------------------------------------------------------------------
public static void main(String[] args) {
    // 1. 게시판 생성
    Board board = new Board();

    // 2. 게시판에 게시글을 포스팅
    board.addPost("디자인 패턴 강의 리뷰", LocalDate.of(2020, 8, 30));
    board.addPost("게임 하실분", LocalDate.of(2020, 2, 6));
    board.addPost("이거 어떻게 하나요?", LocalDate.of(2020, 6, 1));
    board.addPost("이거 어떻게 하나요?", LocalDate.of(2021, 12, 22));

    List<Post> posts = board.getPosts();
    
    // 3. 게시글 발행 순서대로 조회하기
    for (int i = 0; i < posts.size(); i++) {
        Post post = posts.get(i);
        System.out.println(post.title + " / " + post.date);
    }

    // 4. 게시글 날짜별로 조회하기
    Collections.sort(posts, (p1, p2) -> p1.date.compareTo(p2.date)); // 집합체를 날짜별로 정렬
    for (int i = 0; i < posts.size(); i++) {
        Post post = posts.get(i);
        System.out.println(post.title + " / " + post.date);
    }
}
```

#### Iterator를 썻을때
```java
// 저장 순서 이터레이터
class ListPostIterator implements Iterator<Post> {
    private Iterator<Post> itr;

    public ListPostIterator(List<Post> posts) {
        this.itr = posts.iterator();// 반복자 설정
    }

    @Override
    public boolean hasNext() {
        return this.itr.hasNext(); // 자바 내부 이터레이터에 위임해 버림
    }

    @Override
    public Post next() {
        return this.itr.next(); // 자바 내부 이터레이터에 위임해 버림
    }
}

// 날짜 순서 이터레이터
class DatePostIterator implements Iterator<Post> {
    private Iterator<Post> itr;

    public DatePostIterator(List<Post> posts) {
        // 최신 글 목록이 먼저 오도록 정렬
        Collections.sort(posts, (p1, p2) -> p1.date.compareTo(p2.date));
        this.itr = posts.iterator(); // 반복자 설정
    }

    @Override
    public boolean hasNext() {
        return this.itr.hasNext(); // 자바 내부 이터레이터에 위임해 버림
    }

    @Override
    public Post next() {
        return this.itr.next(); // 자바 내부 이터레이터에 위임해 버림
    }
}
```

```java
// 게시판
class Board {
    // 게시글을 리스트 집합 객체로 저장 관리
    List<Post> posts = new ArrayList<>();

    public void addPost(String title, LocalDate date) {
        this.posts.add(new Post(title, date));
    }

    public List<Post> getPosts() {
        return posts;
    }

    // ListPostIterator 이터레이터 객체 반환
    public Iterator<Post> getListPostIterator() {
        return new ListPostIterator(posts);
    }

    // DatePostIterator 이터레이터 객체 반환
    public Iterator<Post> getDatePostIterator() {
        return new DatePostIterator(posts);
    }
}
```

```java
public static void main(String[] args) {
    // 1. 게시판 생성
    Board board = new Board();

    // 2. 게시판에 게시글을 포스팅
    board.addPost("디자인 패턴 강의 리뷰", LocalDate.of(2020, 8, 30));
    board.addPost("게임 하실분", LocalDate.of(2020, 2, 6));
    board.addPost("이거 어떻게 하나요?", LocalDate.of(2020, 6, 1));
    board.addPost("이거 어떻게 하나요?", LocalDate.of(2021, 12, 22));

    // 게시글 발행 순서대로 조회하기
    print(board.getListPostIterator());

    // 게시글 날짜별로 조회하기
    print(board.getDatePostIterator());
}

public static void print(Iterator<Post> iterator) {
    Iterator<Post> itr = iterator;
    while(itr.hasNext()) {
        Post post = itr.next();
        System.out.println(post.title + " / " + post.date);
    }
}
```
