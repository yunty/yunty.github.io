---
title: Build the REST services with Spring 가이드 공부
modified: 2026-11-03
---
# Build the Rest services with Spring
https://spring.io/guides/tutorials/rest
스프링의 공식 가이드 중 1가지로 CRUD API를 실제로 작성해보고 응용해볼 수 있으며 RESTful에 대해 생각해볼 수 있다.

## 빌드에 필요한 Dependency
- Spring Web
- Spring Data JPA
- H2 Database
- Hateoas

## 시작하며
https://start.spring.io 에서 쉽게 생성가능하다.

==목차==
1. nonrest
2. HATEOAS
3. Simplifying Link Creation
4. Evolving REST APIs
5. Building links into your REST API

# nonrest
REST스럽지 않은, PRC(원격 프로시저 호출) 방식으로 작성해보기
>[!warning]- REST가 아닌것을 명심

## 코드의 구성
- Entity(Employee) : 식별자를 가진 객체로 DB의 한 행을 표현하는 객체
	- @Entity, @Id, @GeneratedValue 등
- Repository(EmployeeRepository) : DB 접근 방식을 정의해둔 객체 및 인터페이스(사용법에 따라 다름)
- Configuration(LoadDatabase) : 앱이 시작될때 스프링이 관리 할 bean 객체들을 등록하고 설정하는 객체 
- Controller(EmployeeController) : HTTP요청을 받아 처리하는 객체
	- @RestController, @Controller, @Component
- Exception(EmployeeNotFoundException) : 예외를 정의해둔 객체
- ExceptionHandler(EmployeeNotFoundAdvice) : 해당하는 예외를 잡아서 처리하는 객체
	- @RestControllerAdvice, @ControllerAdvice, @ExceptionHandler, @ResponseStatus등

### Entity
- @Entity를 붙여서 JPA가 사용할 수 있게 설정
- Entity들은 각각의 기본 키(Primary Key)가 존재하기때문에 이를 설정해준다.
- 
> [!code]- Employee.java
> ```java
> package com.example.demo;
>
> import jakarta.persistence.Entity;
> import jakarta.persistence.GeneratedValue;
> import jakarta.persistence.Id;
> import java.util.Objects;
> //Spring Data JPA 리포지토리는 백엔드 데이터 저장소에 대한 레코드 생성, 읽기, 업데이트 및 삭제를 지원하는 메서드를 포함하는 인터페이스입니다.
>
> @Entity //이 객체를 JPA 기반 데이터 저장소에 저장할 수 있도록 준비하는 JPA 어노테이션
> public class Employee {
>     private @Id //이 객체의 primary key가 이 변수임을 나타냄
>     @GeneratedValue Long id; //JPA의 구현체가 값을 자동으로 생성해서 넣어줌
>     private String name;
>     private String role;
>
>     Employee() {
>     }
>
>     Employee(String name, String role) {
>         this.name = name;
>         this.role = role;
>     }
>
>     public Long getId() {
>         return id;
>     }
>
>     public void setId(Long id) {
>         this.id = id;
>     }
>
>     public String getName() {
>         return name;
>     }
>
>     public void setName(String name) {
>         this.name = name;
>     }
>
>     public String getRole() {
>         return role;
>     }
>
>     public void setRole(String role) {
>         this.role = role;
>     }
>
>     @Override
>     public boolean equals(Object o) {
>         if (this == o) {
>             return true;
>         }
>         if (!(o instanceof Employee)) {
>             return false;
>         }
>         Employee employee = (Employee) o;
>         return Objects.equals(getId(), employee.getId()) && Objects.equals(getName(),
>                 employee.getName()) && Objects.equals(getRole(), employee.getRole());
>     }
>
>     @Override
>     public int hashCode() {
>         return Objects.hash(getId(), getName(), getRole());
>     }
>
>     @Override
>     public String toString() {
>         return "Employee{" +
>                 "id=" + id +
>                 ", name='" + name + '\'' +
>                 ", role='" + role + '\'' +
>                 '}';
>     }
> }
> ```

### Repository
- JPA를 사용할 시 인터페이스 생성 후 JpaRepository를 상속시키면 스프링이 실행시점에 자동으로 구현 객체를 생성해준다.
> [!code]- EmployeeRepository.java
> ```java
> package com.example.demo;
>
> import org.springframework.data.jpa.repository.JpaRepository;
>
> public interface EmployeeRepository extends JpaRepository<Employee,Long> {
>     /**
>      * JpaRepository<관리할 엔티티 타입, 기본키 타입>을 상속하는 인터페이스를 생성만 해도 아래의 기능들을 포함한 여러 기능들을
>      * 실행 시점에 이 인터페이스를 사용할 수 있는 구현 객체를 만들어 줌
>      *
>      * repository.save(employee); // 직원 저장
>      * repository.findById(1L);   // ID로 직원 조회
>      * repository.findAll();     // 전체 직원 조회
>      * repository.deleteById(1L); // ID로 직원 삭제
>      * ... 더 많은 메서드들을 제공해주고 있음
>      */
>
>      //List<Employee> findByName(String name); 을 선언만 해둬도 자동으로 로직을 작성해줌
> }
> ```

### Configuration
- 기본 Bean을 설정할 수 있다.
- CommandLineRunner 객체는 스프링부트에서 애플리케이션 컨텍스트가 모두 로드될 시 실행하는 서버가 열리기 전에 시킬 명령을 담는다.
> [!code]- LoadDatabase.java
> ```java
> package com.example.demo;
>
> import org.slf4j.Logger;
> import org.slf4j.LoggerFactory;
> import org.springframework.boot.CommandLineRunner;
> import org.springframework.context.annotation.Bean;
> import org.springframework.context.annotation.Configuration;
>
> @Configuration
> class LoadDatabase {
>
>     private static final Logger LOG = LoggerFactory.getLogger(LoadDatabase.class);
>
>     @Bean
>     CommandLineRunner initDatabase(EmployeeRepository repository){ // 스프링부트에서 애플리케이션 컨텍스트가 모두 로드되면 CommandLineRunner를 실행한다.
>
>         return args -> {// run() 메서드 1개만 보유하고 있기때문에 람다로 축약가능
>             LOG.info("preloading "+ repository.save(new Employee("Bilbo Baggins", "burglar")));
>             LOG.info("preloading "+ repository.save(new Employee("Frodo Baggins", "thief")));
>         };
>     }
> }
> ```

### Controller
- @RestController를 붙이게 될시 데이터를 반환하여 HandlerAdapter에서 ModelAndView 객체를 서블릿객체로 반환할때 null을 반환하여 화면 구성을 하는 ViewResolver를 건너 뛴다.
- 어댑터 내부의 컨버터에서 직접 response객체에 작성해준다.
> [!code]- EmployeeController.java
> ```java
> package com.example.demo;
>
> import java.util.List;
> import org.springframework.beans.factory.annotation.Autowired;
> import org.springframework.web.bind.annotation.DeleteMapping;
> import org.springframework.web.bind.annotation.GetMapping;
> import org.springframework.web.bind.annotation.PathVariable;
> import org.springframework.web.bind.annotation.PostMapping;
> import org.springframework.web.bind.annotation.PutMapping;
> import org.springframework.web.bind.annotation.RequestBody;
> import org.springframework.web.bind.annotation.RestController;
>
> @RestController //화면을 반환하는것이 아닌 데이터를 반환 즉 ModelAndView는 null
> class EmployeeController {
>     private final EmployeeRepository repository;
>
>     @Autowired//객체를 주입 받음 생성자가 1개일때는 생략가
>     public EmployeeController(EmployeeRepository repository) {
>         this.repository = repository;
>     }
>
>     @GetMapping("/employees")
>     List<Employee> all(){
>         return repository.findAll();
>     }
>
>     @PostMapping("/employees")
>     Employee newEmployee(@RequestBody Employee newEmployee){
>         return repository.save(newEmployee);
>     }
>
>     @GetMapping("/employees/{id}")
>     Employee one(@PathVariable Long id){
>         return repository.findById(id)
>                 .orElseThrow(() -> new EmployeeNotFoundException(id));
>     }
>
>     @PutMapping("/employees/{id}")
>     Employee replaceEmployee(@RequestBody Employee newEmployee, @PathVariable Long id){
>         return repository.findById(id)
>                 .map(employee -> {
>                     employee.setName(newEmployee.getName());
>                     employee.setRole(newEmployee.getRole());
>                     return repository.save(employee);
>                 })
>                 .orElseGet(()->{
>                     return repository.save(newEmployee);
>                 });
>     }
>
>     @DeleteMapping("/employees/{id}")
>     void deleteEmployee(@PathVariable Long id){
>         repository.deleteById(id);
>     }
> }
> ```

### Exception
- 기본적인 예외를 정의해둔 객체
> [!code]- EmployeeNotFoundException.java
> ```java
> package com.example.demo;
>
> class EmployeeNotFoundException extends RuntimeException {
>     EmployeeNotFoundException(Long id) {
>         super("Could not find employee "+ id);
>     }
> }
> ```

### ExceptionHandler
- 지정한 예외가 발생시 이 객체가 받아서 처리한다.
- 실행시 미리 목록에 이 객체를 넣어두고 예외 발생시 찾아서 전달해준다.
> [!code]- EmployeeNotFoundAdvice.java
> ```java
> package com.example.demo;
>
> import org.springframework.http.HttpStatus;
> import org.springframework.web.bind.annotation.ExceptionHandler;
> import org.springframework.web.bind.annotation.ResponseStatus;
> import org.springframework.web.bind.annotation.RestControllerAdvice;
>
> @RestControllerAdvice //여러 컨트롤러에 공통으로 적용할 예외 처리 등을 정의해서 메서드 반환값은 응답 본문에 담음
> class EmployeeNotFoundAdvice {
>     @ExceptionHandler(EmployeeNotFoundException.class)
>     @ResponseStatus(HttpStatus.NOT_FOUND)
>     String employeeNotFoundHandler(EmployeeNotFoundException ex){
>         return ex.getMessage();
>     }
> }
> ```

## 빌드 후 결과
### Get
`curl -v http://localhost:8080/employees`
![[get.png]]
Get /employees HTTP/1.1 을 통해 get을 보냈고 그에 따라 맨 밑에 기본으로 들어간 필드값들을 얻었다.
또한 상태코드도 200으로 잘 나왔다.

### Get(findByID) 예외 발생 결과
`curl -v localhost:8080/employees/99`
![[예외발생.png]]
ID를 통한 조회를 실시 했지만 id가 99인 직원을 찾지 못하였기 때문에 미리 설정해둔 예외가 발생하였고 예외처리를 거쳐서 Response에 =="Could not find employee 99"==가 잘 나온것을 확인할 수 있다.

### POST
`curl -X POST localhost:8080/employees -H 'Content-type:application/json' -d '{"name": "Samwise Gamgee", "role": "gardener"}'`

`{"id":3,"name":"Samwise Gamgee","role":"gardener"}%`로 결과가 잘 나온다.

### PUT
`curl -X PUT localhost:8080/employees/3 -H 'Content-type:application/json' -d '{"name": "Samwise Gamgee", "role": "ring bearer"}'`

`{"id":3,"name":"Samwise Gamgee","role":"ring bearer"}%` 수정이 잘 되었음을 알 수 있다.

## 결과
기본적인 엔티티 1개를 생성 후 컨트롤러로 요청에 대한 처리 로직을 작성하였고 컨트롤러에서 DB에 접근가능하게 JPA를 통한 레포지를 생성하여서 기본적인 CRUD를 구성해보았다.

실제로 브라우저를 통해 접속도 해보고 터미널에서 curl을 통해 요청도 보내보고 하면서 코드를 작성한게 실제로 보이는듯한 느낌이였다.

사실 HTTP에 대해 공부하면서 REST에 대해 공부해본적은 있지만 지금까지 깊게 생각해본적이 없어서 GET, PUT 등을 사용하면서 HTTP 요청을 처리면 REST라고 생각했던 적이 있다.

하지만 이 서비스와 어떻게 상호작용 하는지 이 자체만으로 파악할 수가 없기때문에 RESTful이라고 하기에는 부족한 부분이 많은 코드이다.

>I am getting frustrated by the number of people calling any HTTP-based interface a REST API. Today’s example is the SocialSite REST API. That is RPC. It screams RPC. There is so much coupling on display that it should be given an X rating.
> 
> What needs to be done to make the REST architectural style clear on the notion that hypertext is a constraint? In other words, if the engine of application state (and hence the API) is not being driven by hypertext, then it cannot be RESTful and cannot be a REST API. Period. Is there some broken manual somewhere that needs to be fixed?
>
>— Roy Fielding

즉 로이 필링이 얘기하는건 REST 아키텍처 스타일에서 하이퍼 텍스트는 필수이고 API를 움직이는 동력이 하이퍼 텍스트가 아니라면 그것은 RESTful할 수 없고 REST API일 수도 없다는 것이다.

결제를 예를 들자면
``` json
{
  "id": 10,
  "status": "결제 대기",
  "_links": {
    "pay": { "href": "/orders/10/payment" },
    "cancel": { "href": "/orders/10/cancellation" }
  }
}
```
클라이언트는 이 응답을 받으면 하이퍼 텍스트를 따라 결제를 하거나 취소를 할 수 있다.
즉 서버가 클라이언트의 현재 상태에 따라 다음에 가능한 행동들을 안내해준다.


# HATEOAS
REST 아키텍처의 핵심 제약 조건 중에 1가지이다.
- 클라이언트-서버 구조
- 무상태성
- 캐시 가능
- 계층형 구조
- 일관된 인터페이스
- ==HATEOAS==

## HATEOAS란?
Hypermedia As The Engine Of Application State의 약자로 응답 데이터 내에 링크 정보를 포함해 클라이언트가 동적으로 당므 행동을 할 수 있도록 유도하는 방식이다.
즉 Response에 링크를 담아주는것이다.

## SpringHATEOAS
스프링에서 HATEOAS원칙을 지키게 도와주는 라이브러리 이름이 SpringHATEOAS이다.

## 적용
### 단일 아이템 조회
>`EntityModel<> `사용

>[! 적용 전]-
>```java
>@GetMapping("/employees/{id}")
>Employee one(@PathVariable Long id){
>	return repository.findById(id)
>		.orElseThrow(() -> new EmployeeNotFoundException(id));
>}
>```

>[! 적용 후]-
>```java
>@GetMapping("/employees/{id}")
>EntityModel<Employee> one(@PathVariable Long id){
>	Employee employee = repository.findById(id)
>			.orElseThrow(() -> new EmployeeNotFoundException(id));
>	return EntityModel.of(employee,
>		linkTo(methodOn(EmployeeController.class).one(id)).withSelfRel(),
>		linkTo(methodOn(EmployeeController.class).all()).withRel("employeee"));
>}
>```

- 반환값을 `EntityModel<Entity 객체>`로 바꾸었으며 링크와 엔티티 데이터를 담을 수 있다.
- EntityModel.of 정적 팩토리 생성자를 통해 객체 1개를 만든다.
- 찾은 employee의 정보를 넘기고
- methodOn(사용할 객체)를 통해 프록시 객체를 생성하고 .메서드()를 지정한다.
- 이후 linkTo는 기록된 정보로 주소를 계산. `one`의 `@GetMapping("/employees/{id}")`에 `id`를 채워 `/employees/1` 완성한다.
- 이를 통해 링크 + 데이터의 모음을 반환한다.

#### 결과
![[EntityModel 사용결과.png]]
- 지정해둔 링크들이 잘 나온다.

### 복수의 아이템 조회하기
>`CollectionModel<EntityModel<>>` 사용하기

>[! 적용 전]-
>```java
>@GetMapping("/employees)
>List<Employee> all(){
>	return repository.findAll();
>}
>```

> [! 적용 후]-
> ```java
> @GetMapping("/employees")
> CollectionModel<EntityModel<Employee>> all() {
>
>   List<EntityModel<Employee>> employees = repository.findAll().stream()
>       .map(employee -> EntityModel.of(employee,
>           linkTo(methodOn(EmployeeController.class).one(employee.getId())).withSelfRel(),
>           linkTo(methodOn(EmployeeController.class).all()).withRel("employees")))
>       .collect(Collectors.toList());
>
>   return CollectionModel.of(employees, linkTo(methodOn(EmployeeController.class).all()).withSelfRel());
> }
> ```

- `CollectionModel<>`은 컬렉션과 그 컬렉션에 대한 링크를 넣을 수 있다.
- findAll()을 .stream으로 만든 후 각 employee에 대한 단일 조회 방식과 동일하게 EntityModel생성
- 전체에 대한것을 List로 모은 후
- 그 리스트에 대한 링크를 생성하여 CollectionModel로 모아서 반환한다.

#### 결과
- 조금 잘렸지만 잘 나오는것을 확인할 수 있다.
![[CollectionModel 결과.png]]

### 결론
우리는 **왜** 응답에 링크를 추가하여야 하는가

> What is the point of adding all these links? It makes it possible to evolve REST services over time. Existing links can be maintained while new links can be added in the future. Newer clients may take advantage of the new links, while legacy clients can sustain themselves on the old links. This is especially helpful if services get relocated and moved around. As long as the link structure is maintained, clients can still find and interact with things.

- 변경에 강하다
	- 서버가 링크를 추가하거나 주소를 옮겨도, 링크를 따라가는 클라이언트는 그대로 동작한다.
- 현재 가능한 동작을 알려준다
	- 상태에 따라 링크가 달라진다.
- 탐색 가능하다
	- 클라이언트가 문서를 보지 않아도 응답의 링크를 따라가며 API를 둘러볼 수 있다.
- 주소를 외우지 않는다
	- 클라이언트가 URL을 코드에 박지 않아도 된다.

물론 이 코드를 작성해보면서 느낀점은 그렇다면 만약에 보내야 하는 링크가 수백만 개라면 오히려 응답속도가 현저히 느려지지 않을까라는 생각이 들었고 이에 대한 방안으로는 우리가 잘 아는 페이지 번호로 나누는 방식이 있다.
만약 게시글을 보여준다고 한다면 링크들을 다 거는것이 아니라 Page, Pageable을 사용해서 각 페이지별 20개 30개와 같이 지정하여 전송량을 나누어 보내는 방식이 있다.

물론 실무에서도 많이 안지켜지는걸로 알고있긴한데 이에 대해서는 좀 더 공부해보고 어느정도의 합의가 최상의 효율이 나오는지를 또 판단해보면 될것같다.



## Simplifying Link Creation
앞에서 지속적으로 나오는 EntityModel 생성 코드를 따로 객체로 빼서 컨트롤러에서 주입받아서 사용할 수 있게 리팩토링 해보자

### 코드
> [! 객체로 분리]-
> ```java
> package payroll;
>
> import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;
>
> import org.springframework.hateoas.EntityModel;
> import org.springframework.hateoas.server.RepresentationModelAssembler;
> import org.springframework.stereotype.Component;
>
> @Component
> class EmployeeModelAssembler implements RepresentationModelAssembler<Employee, EntityModel<Employee>> {
>
>   @Override
>   public EntityModel<Employee> toModel(Employee employee) {
>
>     return EntityModel.of(employee, //
>         linkTo(methodOn(EmployeeController.class).one(employee.getId())).withSelfRel(),
>         linkTo(methodOn(EmployeeController.class).all()).withRel("employees"));
>   }
> }
> ```

> [! 생성자 주입]- 
> ```java
> @RestController
> class EmployeeController {
>
>   private final EmployeeRepository repository;
>
>   private final EmployeeModelAssembler assembler;
>
>   EmployeeController(EmployeeRepository repository, EmployeeModelAssembler assembler) {
>
>     this.repository = repository;
>     this.assembler = assembler;
>   }
>
>   ...
>
> }
> ```

> [!단일 조회 메서드 변경]- 
> ```java
> 	@GetMapping("/employees/{id}")
> 	EntityModel<Employee> one(@PathVariable Long id) {
>
> 		Employee employee = repository.findById(id) //
> 				.orElseThrow(() -> new EmployeeNotFoundException(id));
>
> 		return assembler.toModel(employee);
> 	}
> ```

> [!복수 조회 메서드 변경]-
> ```java
> @GetMapping("/employees")
> CollectionModel<EntityModel<Employee>> all() {
>
>   List<EntityModel<Employee>> employees = repository.findAll().stream() //
>       .map(assembler::toModel) //
>       .collect(Collectors.toList());
>
>   return CollectionModel.of(employees, linkTo(methodOn(EmployeeController.class).all()).withSelfRel());
> }
> ```


### 결론
이처럼 RepresentationModelAssembler를 구현하여 toModel로 원하는 객체를 Model 객체로 변경가능하다.


# Evolving REST APIs
하이퍼미디어를 붙였다고 REST가 완성되는 것은 아니다. REST는 기술 스택도, 단일 표준도 아니고 **적용하면 애플리케이션이 훨씬 탄력적(resilient)이 되는 아키텍처 제약의 모음**이다.
탄력성의 핵심은 ==서버를 업그레이드해도 클라이언트가 다운타임을 겪지 않는 것==이다.

- 예전에는 서버를 업그레이드하면 클라이언트도 같이 고쳐야 했다.
- 요즘은 몇 시간, 몇 분의 다운타임도 큰 손실이고 일요일 새벽 2시에 업그레이드하는 전략은 해외 고객이 있는 서비스에서는 통하지 않는다.
- SOAP, CORBA 기반 서비스는 신구 클라이언트를 동시에 지원하기 어려웠지만 REST 방식에서는 스프링으로 훨씬 쉽게 가능하다.

## API 변경 지원하기
### 상황
Employee 기반 시스템이 여러 회사에 팔렸는데 갑자기 직원의 `name`을 `firstName`과 `lastName`으로 나눠야 한다.

`name` 필드를 바로 교체하기 전에 생각해볼 것들
- 클라이언트가 깨지지는 않는가?
- 클라이언트를 업그레이드하는 데 얼마나 걸리는가?
- 내가 모든 클라이언트를 통제하고 있는가?
- 다운타임은 곧 손실이다.

### 원칙
> Never delete a column in a database.
> — Unknown

- DB 컬럼은 추가할 수 있지만 제거하지 않는다. REST도 같다.
- ==JSON에 새 필드는 추가하되, 기존 필드는 제거하지 않는다.==
- 정보가 중복되더라도 옛 클라이언트와 새 클라이언트를 모두 지원할 수 있어서 서버를 먼저 업그레이드할 수 있다.

> [!code]- 신구 클라이언트를 모두 지원하는 JSON
> ```json
> {
>   "id": 1,
>   "firstName": "Bilbo",
>   "lastName": "Baggins",
>   "role": "burglar",
>   "name": "Bilbo Baggins",
>   "_links": {
>     "self": {
>       "href": "http://localhost:8080/employees/1"
>     },
>     "employees": {
>       "href": "http://localhost:8080/employees"
>     }
>   }
> }
> ```

## 코드
> [! Entity]- 
> ```java
> package payroll;
>
> import java.util.Objects;
>
> import jakarta.persistence.Entity;
> import jakarta.persistence.GeneratedValue;
> import jakarta.persistence.Id;
>
> @Entity
> class Employee {
>
>   private @Id @GeneratedValue Long id;
>   private String firstName;
>   private String lastName;
>   private String role;
>
>   Employee() {}
>
>   Employee(String firstName, String lastName, String role) {
>
>     this.firstName = firstName;
>     this.lastName = lastName;
>     this.role = role;
>   }
>
>   public String getName() {
>     return this.firstName + " " + this.lastName;
>   }
>
>   public void setName(String name) {
>     String[] parts = name.split(" ");
>     this.firstName = parts[0];
>     this.lastName = parts[1];
>   }
>
>   public Long getId() {
>     return this.id;
>   }
>
>   public String getFirstName() {
>     return this.firstName;
>   }
>
>   public String getLastName() {
>     return this.lastName;
>   }
>
>   public String getRole() {
>     return this.role;
>   }
>
>   public void setId(Long id) {
>     this.id = id;
>   }
>
>   public void setFirstName(String firstName) {
>     this.firstName = firstName;
>   }
>
>   public void setLastName(String lastName) {
>     this.lastName = lastName;
>   }
>
>   public void setRole(String role) {
>     this.role = role;
>   }
>
>   @Override
>   public boolean equals(Object o) {
>
>     if (this == o)
>       return true;
>     if (!(o instanceof Employee))
>       return false;
>     Employee employee = (Employee) o;
>     return Objects.equals(this.id, employee.id) && Objects.equals(this.firstName, employee.firstName)
>         && Objects.equals(this.lastName, employee.lastName) && Objects.equals(this.role, employee.role);
>   }
>
>   @Override
>   public int hashCode() {
>     return Objects.hash(this.id, this.firstName, this.lastName, this.role);
>   }
>
>   @Override
>   public String toString() {
>     return "Employee{" + "id=" + this.id + ", firstName='" + this.firstName + '\'' + ", lastName='" + this.lastName
>         + '\'' + ", role='" + this.role + '\'' + '}';
>   }
> }
> ```

- 보여줄 때만이 아니라 ==받을 때도 옛 방식과 새 방식을 모두 처리==해야 한다.
- `name` 필드를 `firstName`, `lastName`으로 대체
- `getName()` : 두 필드를 합쳐서 옛 `name` 값을 만들어주는 **가상 getter**
- `setName()` : 들어온 문자열을 공백으로 쪼개서 두 필드에 저장하는 **가상 setter**
- 모든 API 변경이 문자열을 나누고 합치는 것만큼 쉽지는 않지만 대부분 변환 규칙을 만들 수 있다.

> [! Configuration]-
> ```java
> LOG.info("preloading "+ repository.save(new Employee("Bilbo", "Baggins", "burglar")));
> LOG.info("preloading "+ repository.save(new Employee("Frodo", "Baggins", "thief")));
> ```

> [! post]-
> ```java
> @PostMapping("/employees")
> ResponseEntity<?> newEmployee(@RequestBody Employee newEmployee) {
>
>   EntityModel<Employee> entityModel = assembler.toModel(repository.save(newEmployee));
>
>   return ResponseEntity //
>       .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri()) //
>       .body(entityModel);
> }
> ```

- `ResponseEntity<?>`를 반환
- 저장된 객체를 `assembler.toModel`로 `EntityModel`로 변환
- `ResponseEntity.created(URI)`로 **201 Created**를 만들고, `Location` 헤더에 모델의 self 링크 URI를 넣는다.
- 본문에는 저장된 객체의 모델 버전을 담는다.
- 하이퍼미디어 클라이언트는 이 `Location`을 따라 새 리소스로 이동할 수 있다.


> [! put]- 
> ```java
> @PutMapping("/employees/{id}")
> ResponseEntity<?> replaceEmployee(@RequestBody Employee newEmployee, @PathVariable Long id) {
>
>   Employee updatedEmployee = repository.findById(id) //
>       .map(employee -> {
>         employee.setName(newEmployee.getName());
>         employee.setRole(newEmployee.getRole());
>         return repository.save(employee);
>       }) //
>       .orElseGet(() -> {
>         return repository.save(newEmployee);
>       });
>
>   EntityModel<Employee> entityModel = assembler.toModel(updatedEmployee);
>
>   return ResponseEntity //
>       .created(entityModel.getRequiredLink(IanaLinkRelations.SELF).toUri()) //
>       .body(entityModel);
> }
> ```

- POST와 비슷하게 `save()`의 결과를 assembler로 `EntityModel`로 변환
- `getRequiredLink(IanaLinkRelations.SELF)`로 self 링크를 꺼내고 `toUri()`로 URI로 바꾼다.
- PUT은 꼭 새로 생성하는 것은 아니라서 **201 Created가 의미상 맞는지는 논란**이 있다. 다만 `Location` 헤더를 쉽게 달 수 있어서 가이드에서는 사용한다.

> [! delete]- 
> ```java
> @DeleteMapping("/employees/{id}")
> ResponseEntity<?> deleteEmployee(@PathVariable Long id) {
>
>   repository.deleteById(id);
>
>   return ResponseEntity.noContent().build();
> }
> ```
- 삭제 후 돌려줄 내용이 없으므로 **204 No Content**를 반환한다.
`curl -v -X DELETE localhost:8080/employees/1` 을 실행하면 `HTTP/1.1 204`가 나온다.

### 정리
| 메서드 | 상태 코드 | 비고 |
|---|---|---|
| POST | 201 Created | `Location` 헤더 + 모델 본문 |
| PUT | 201 Created | `Location` 헤더 + 모델 본문 (의미상 논란) |
| DELETE | 204 No Content | 본문 없음 |

### 결론
- ==하위 호환==을 지키며 서버를 진화시키려면 기존 필드를 지우지 않고 새 필드를 추가한다.
- 응답으로 내보내는 것뿐 아니라 요청으로 받는 것도 옛 방식과 새 방식을 모두 처리해야 한다.
- 각 메서드는 상황에 맞는 상태 코드(201, 204)와 `Location` 헤더를 돌려준다.
- `Employee`의 필드를 바꾸는 일은 DB 담당 팀과 조율해서 기존 데이터를 새 컬럼으로 옮겨야(마이그레이션) 한다.
- 전송하는 정보가 많아지는 것이 걱정될 수 있지만, 영향을 측정하기 전에는 섣부른 최적화를 하지 않는다. (앞에서 생각한 페이지 처리는 필요해질 때 적용)
- 결국 이 단계는 ==상황(이름 분리)을 주고 하위 호환 원칙에 맞춰 코드를 수정하는 과정==이고, 응답 코드 개선은 그와 별개로 함께 다룬 내용이다.


# Building links into your REST API
지금까지 기본적인 링크만 가진, 발전 가능한 API를 만들었다. 한 단계 더 나아가려면 ==하이퍼미디어를 애플리케이션 상태의 엔진(HATEOAS)으로 활용==해야 한다.

- 비즈니스 로직에는 프로세스에 대한 규칙이 생긴다.
- 위험한 것은 ==서버의 규칙을 클라이언트가 그대로 복제해서 강하게 결합==되는 것이다.
- REST는 이 결합을 끊고 최소화하는 것이 목표이다.
- 이를 보이기 위해 ==주문 처리 시스템==을 추가한다.

## 개념 : 왜 링크로 알려주는가
주문 상태(`IN_PROGRESS`, `COMPLETED`, `CANCELLED`)를 응답으로 주고 클라이언트가 그것을 보고 할 수 있는 동작을 판단하게 하는 것이 자연스러워 보이지만 ==잘못된 방식==이다.
- 흐름에 새로운 상태가 생기면 UI의 버튼 배치가 틀어질 수 있다.
- 다국어 지원 등으로 상태 이름을 바꾸면 모든 클라이언트가 깨질 수 있다.

해결은 ==HATEOAS==이다.
- 클라이언트가 페이로드를 해석하는 대신 ==유효한 동작을 링크로 제공==한다.
- 상태에 따른 동작을 데이터 페이로드에서 분리한다.
- 취소와 완료가 유효할 때만 해당 링크를 동적으로 추가하고, 클라이언트는 **링크가 있을 때만** 그 버튼을 보여준다.
- 클라이언트가 동작이 언제 유효한지 알 필요가 없으므로 서버와 클라이언트가 상태 전환 로직에서 어긋날 위험이 줄어든다.

| | 상태를 내려줌 | 링크를 내려줌 |
|---|---|---|
| 클라이언트가 아는 것 | 언제 취소할 수 있는지 규칙 | 규칙을 모름, 링크가 있는지만 확인 |
| 규칙이 있는 곳 | 서버 + 클라이언트 | 서버 한 곳 |
| 규칙이 바뀌면 | 양쪽 모두 수정 | 서버만 수정 |

- 조건은 서버만 알고, 서로 약속하는 것은 ==링크 이름(rel)의 의미와 응답 형식==이다.
- 주소, 동작이 가능한 조건, 상태 이름은 약속이 아니라서 서버가 바꿔도 클라이언트가 깨지지 않는다.

## 코드
> [! Order]- 
> ```java
> package payroll;
>
> import java.util.Objects;
>
> import jakarta.persistence.Entity;
> import jakarta.persistence.GeneratedValue;
> import jakarta.persistence.Id;
> import jakarta.persistence.Table;
>
> @Entity
> @Table(name = "CUSTOMER_ORDER")
> class Order {
>
>   private @Id @GeneratedValue Long id;
>
>   private String description;
>   private Status status;
>
>   Order() {}
>
>   Order(String description, Status status) {
>
>     this.description = description;
>     this.status = status;
>   }
>
>   public Long getId() {
>     return this.id;
>   }
>
>   public String getDescription() {
>     return this.description;
>   }
>
>   public Status getStatus() {
>     return this.status;
>   }
>
>   public void setId(Long id) {
>     this.id = id;
>   }
>
>   public void setDescription(String description) {
>     this.description = description;
>   }
>
>   public void setStatus(Status status) {
>     this.status = status;
>   }
>
>   @Override
>   public boolean equals(Object o) {
>
>     if (this == o)
>       return true;
>     if (!(o instanceof Order))
>       return false;
>     Order order = (Order) o;
>     return Objects.equals(this.id, order.id) && Objects.equals(this.description, order.description)
>         && this.status == order.status;
>   }
>
>   @Override
>   public int hashCode() {
>     return Objects.hash(this.id, this.description, this.status);
>   }
>
>   @Override
>   public String toString() {
>     return "Order{" + "id=" + this.id + ", description='" + this.description + '\'' + ", status=" + this.status + '}';
>   }
> }
> ```

- `@Table(name = "CUSTOMER_ORDER")` : `ORDER`는 SQL 예약어라서 유효한 테이블 이름이 아니므로 테이블 이름을 바꿔준다.
- `description`과 `status` 필드를 가진다.

> [! Status]- 
> ```java
> package payroll;
>
> enum Status {
>
>   IN_PROGRESS, //
>   COMPLETED, //
>   CANCELLED
> }
> ```

- 주문이 거치는 상태 흐름 : 제출된 시점부터 처리(`COMPLETED`) 또는 취소(`CANCELLED`)될 때까지

> [! OrderRepository]- 
> ```java
> interface OrderRepository extends JpaRepository<Order, Long> {
> }
> ```

> [! OrderNotFoundException]- 
> ```java
> package payroll;
>
> class OrderNotFoundException extends RuntimeException {
>
>   OrderNotFoundException(Long id) {
>     super("Could not find order " + id);
>   }
> }
> ```

> [! OrderController import]- 
> ```java
> import java.util.List;
> import java.util.stream.Collectors;
>
> import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;
>
> import org.springframework.hateoas.CollectionModel;
> import org.springframework.hateoas.EntityModel;
> import org.springframework.http.ResponseEntity;
> import org.springframework.web.bind.annotation.GetMapping;
> import org.springframework.web.bind.annotation.PathVariable;
> import org.springframework.web.bind.annotation.PostMapping;
> import org.springframework.web.bind.annotation.RequestBody;
> import org.springframework.web.bind.annotation.RestController;
> ```

> [! OrderController]- 
> ```java
> @RestController
> class OrderController {
>
>   private final OrderRepository orderRepository;
>   private final OrderModelAssembler assembler;
>
>   OrderController(OrderRepository orderRepository, OrderModelAssembler assembler) {
>
>     this.orderRepository = orderRepository;
>     this.assembler = assembler;
>   }
>
>   @GetMapping("/orders")
>   CollectionModel<EntityModel<Order>> all() {
>
>     List<EntityModel<Order>> orders = orderRepository.findAll().stream() //
>         .map(assembler::toModel) //
>         .collect(Collectors.toList());
>
>     return CollectionModel.of(orders, //
>         linkTo(methodOn(OrderController.class).all()).withSelfRel());
>   }
>
>   @GetMapping("/orders/{id}")
>   EntityModel<Order> one(@PathVariable Long id) {
>
>     Order order = orderRepository.findById(id) //
>         .orElseThrow(() -> new OrderNotFoundException(id));
>
>     return assembler.toModel(order);
>   }
>
>   @PostMapping("/orders")
>   ResponseEntity<EntityModel<Order>> newOrder(@RequestBody Order order) {
>
>     order.setStatus(Status.IN_PROGRESS);
>     Order newOrder = orderRepository.save(order);
>
>     return ResponseEntity //
>         .created(linkTo(methodOn(OrderController.class).one(newOrder.getId())).toUri()) //
>         .body(assembler.toModel(newOrder));
>   }
> }
> ```

- 지금까지 만든 컨트롤러와 같은 구성이며 `OrderRepository`와 (아직 만들지 않은) `OrderModelAssembler`를 주입받는다.
- 처음 두 경로는 aggregate root(목록)와 단일 `Order` 요청을 처리한다.
- 세 번째 경로는 새 주문을 ==`IN_PROGRESS` 상태로 시작==해서 생성한다.
- 모든 메서드는 하이퍼미디어를 제대로 렌더링하기 위해 `RepresentationModel`의 하위 타입(또는 그것을 감싼 타입)을 반환한다.
- `newOrder`는 Employee와 달리 self 링크를 꺼내지 않고 `linkTo(...).toUri()`로 링크 빌더에서 바로 `Location`용 URI를 만든다.
- 반환 타입이 `EntityModel<Order>`를 감싸므로 `ResponseEntity<EntityModel<Order>>`로 선언한다.

### OrderModelAssembler
> [! OrderModelAssembler]- 
> ```java
> package payroll;
>
> import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;
>
> import org.springframework.hateoas.EntityModel;
> import org.springframework.hateoas.server.RepresentationModelAssembler;
> import org.springframework.stereotype.Component;
>
> @Component
> class OrderModelAssembler implements RepresentationModelAssembler<Order, EntityModel<Order>> {
>
>   @Override
>   public EntityModel<Order> toModel(Order order) {
>
>     // Unconditional links to single-item resource and aggregate root
>
>     EntityModel<Order> orderModel = EntityModel.of(order,
>         linkTo(methodOn(OrderController.class).one(order.getId())).withSelfRel(),
>         linkTo(methodOn(OrderController.class).all()).withRel("orders"));
>
>     // Conditional links based on state of the order
>
>     if (order.getStatus() == Status.IN_PROGRESS) {
>       orderModel.add(linkTo(methodOn(OrderController.class).cancel(order.getId())).withRel("cancel"));
>       orderModel.add(linkTo(methodOn(OrderController.class).complete(order.getId())).withRel("complete"));
>     }
>
>     return orderModel;
>   }
> }
> ```

- `self`(단건)와 `orders`(목록) 링크는 ==항상== 포함한다.
- `cancel`과 `complete` 링크는 주문 상태가 ==`IN_PROGRESS`일 때만== 포함한다. (`EntityModel.add`로 조건부 추가)
- 어셈블러에서 하는 이유 : 목록, 단건, 생성, 취소, 완료 등 주문을 응답으로 내보내는 모든 경로가 `assembler.toModel`을 거치므로 링크 규칙이 한 곳에 모인다.
- 클라이언트가 HAL을 이해해서 일반 JSON 값 대신 링크를 읽는다면 주문 시스템에 대한 지식이 필요 없어지고, 클라이언트를 깨뜨리지 않고 주문 처리 흐름을 바꿀 수 있다.
- 주의 : 어셈블러는 링크를 **보여줄지**를, 컨트롤러는 동작을 **실행해도 되는지**를 각각 판단한다. 링크 없이 주소를 직접 호출할 수도 있어서 컨트롤러에서도 검사해야 하므로 규칙이 두 곳에 있게 된다. (거슬리면 `Order`에 `canCancel()` 같은 메서드를 두는 방법도 있다.)

### 취소와 완료
> [! cancel]- 
> ```java
> @DeleteMapping("/orders/{id}/cancel")
> ResponseEntity<?> cancel(@PathVariable Long id) {
>
>   Order order = orderRepository.findById(id) //
>       .orElseThrow(() -> new OrderNotFoundException(id));
>
>   if (order.getStatus() == Status.IN_PROGRESS) {
>     order.setStatus(Status.CANCELLED);
>     return ResponseEntity.ok(assembler.toModel(orderRepository.save(order)));
>   }
>
>   return ResponseEntity //
>       .status(HttpStatus.METHOD_NOT_ALLOWED) //
>       .header(HttpHeaders.CONTENT_TYPE, MediaTypes.HTTP_PROBLEM_DETAILS_JSON_VALUE) //
>       .body(Problem.create() //
>           .withTitle("Method not allowed") //
>           .withDetail("You can't cancel an order that is in the " + order.getStatus() + " status"));
> }
> ```

> [! complete]- 
> ```java
> @PutMapping("/orders/{id}/complete")
> ResponseEntity<?> complete(@PathVariable Long id) {
>
>   Order order = orderRepository.findById(id) //
>       .orElseThrow(() -> new OrderNotFoundException(id));
>
>   if (order.getStatus() == Status.IN_PROGRESS) {
>     order.setStatus(Status.COMPLETED);
>     return ResponseEntity.ok(assembler.toModel(orderRepository.save(order)));
>   }
>
>   return ResponseEntity //
>       .status(HttpStatus.METHOD_NOT_ALLOWED) //
>       .header(HttpHeaders.CONTENT_TYPE, MediaTypes.HTTP_PROBLEM_DETAILS_JSON_VALUE) //
>       .body(Problem.create() //
>           .withTitle("Method not allowed") //
>           .withDetail("You can't complete an order that is in the " + order.getStatus() + " status"));
> }
> ```


- 취소는 `DELETE /orders/{id}/cancel`, 완료는 `PUT /orders/{id}/complete`
- `findById`로 기존 주문을 가져와서 상태가 `IN_PROGRESS`이면 상태를 바꾸고 저장한 뒤 **200 OK**와 모델을 돌려준다.
- 유효한 상태가 아니면 **405 Method Not Allowed**와 `Problem`을 돌려준다. `Problem`은 하이퍼미디어를 지원하는 오류 컨테이너(RFC 7807)이고 `Content-Type`은 `application/problem+json`이다.
- ==`save`를 하는 이유== : `setStatus`는 메모리의 객체만 바꾸므로 DB에 반영하려면 `save`가 필요하다. 읽어온 객체라 id가 있어서 INSERT가 아니라 ==같은 행의 UPDATE==가 된다. (이 메서드에는 `@Transactional`이 없어서 더티 체킹에 기대지 않고 명시적으로 `save`)
- 새 `Order`를 만들어서 `save`하면 id가 없어서 새 행이 생기므로 먼저 `findById`로 기존 주문을 가져오는 것이 중요하다.

> [! LoadDatabase]- 
> ```java
> package payroll;
>
> import org.slf4j.Logger;
> import org.slf4j.LoggerFactory;
> import org.springframework.boot.CommandLineRunner;
> import org.springframework.context.annotation.Bean;
> import org.springframework.context.annotation.Configuration;
>
> @Configuration
> class LoadDatabase {
>
>   private static final Logger LOG = LoggerFactory.getLogger(LoadDatabase.class);
>
>   @Bean
>   CommandLineRunner initDatabase(EmployeeRepository employeeRepository, OrderRepository orderRepository) {
>
>     return args -> {
>       employeeRepository.save(new Employee("Bilbo", "Baggins", "burglar"));
>       employeeRepository.save(new Employee("Frodo", "Baggins", "thief"));
>
>       employeeRepository.findAll().forEach(employee -> LOG.info("Preloaded " + employee));
>
>       orderRepository.save(new Order("MacBook Pro", Status.COMPLETED));
>       orderRepository.save(new Order("iPhone", Status.IN_PROGRESS));
>
>       orderRepository.findAll().forEach(order -> {
>         LOG.info("Preloaded " + order);
>       });
>
>     };
>   }
> }
> ```

- `Employee`와 함께 `Order`도 미리 저장한다. (`COMPLETED`인 주문 1개, `IN_PROGRESS`인 주문 1개)

## 결과
%% 직접 실행한 결과를 여기에 추가하기. URL의 id(4)는 DB에 따라 다르므로 /orders 결과에서 확인 %%

`curl -v http://localhost:8080/orders | json_pp`

`curl -v -X DELETE http://localhost:8080/orders/4/cancel | json_pp`

`curl -v -X DELETE http://localhost:8080/orders/4/cancel | json_pp` (이미 취소된 주문에 한 번 더)

`curl -v -X PUT localhost:8080/orders/4/complete | json_pp`

### 요약
REST는 보기 좋은 URI를 쓰거나 XML 대신 JSON을 반환하는 것만이 아니다. 아래 전략은 내가 직접 관리하지 않을 수도 있는 기존 클라이언트와의 관계가 깨질 가능성을 줄여준다.
- ==기존 필드를 삭제하지 않고 지원을 추가==한다.
- 클라이언트가 URI를 직접 입력하지 않도록 ==관계(rel)가 있는 링크==를 쓴다.
- 기존 링크는 가능한 한 오래 유지하고, URI를 바꿔야 해도 ==rel은 그대로 유지==해서 옛 클라이언트가 새 기능에 접근하게 한다.
- 상태 제어 동작이 가능한 때를 알릴 때는 페이로드 데이터가 아니라 ==링크==를 쓴다.
- 리소스마다 `RepresentationModelAssembler`를 만들고 컨트롤러에서 쓰는 것이 번거로워 보여도, 이 서버 쪽 설정이 내가 관리하는 클라이언트와 관리하지 않는 클라이언트 모두 API가 발전해도 쉽게 따라오도록 보장해준다.

### 결론
- ==규칙(동작이 가능한 조건)은 서버만 알고==, 클라이언트는 응답의 링크를 따라간다.
- 서버와 클라이언트가 약속하는 것은 링크 이름의 의미와 응답 형식이다.
- 어셈블러는 HATEOAS를 쓸 때의 변환 도구이고 필수 요소는 아니다. HATEOAS 없이 일반 JSON을 쓴다면 DTO와 변환 메서드(또는 매퍼)가 같은 자리를 맡는다.

