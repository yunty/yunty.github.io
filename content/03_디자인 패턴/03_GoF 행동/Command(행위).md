---
title: Command(행위)
modified: 2026-09-22
---
#디자인패턴 #디자인패턴/행위 #객체지향
# Command

#### 

---
## 개념
명령(메서드)를 객체로 만들어서 사용하는 패턴

- 명령을 객체로 만들면 변수나 컬렉션에 저장이 가능
- 이를 통해 얻을 수 있는 이점
	- 명령 실행 예약
	- 작업 대기열
	- 실행 기록 보관
	- 실행 취소
	- 명령 재실행
	- 여러 명령을 묶어서 실행
- 작업을 그냥 한 번 호출하고 끝내면 직접 메서드를 호출하고, 작업 자체를 저장·전달·교체·취소·예약해야 한다면 커맨드 패턴을 고려하면 됨

####  구조
- Command
	- 명령의 공통 형식 / 공통으로 사용할 메서드를 지정해서 모두가 이 틀에 맞추도록 함
- Concrete Command
	- 어떤 작업을 실행할지 정의 / 원본 객체의 메서드를 공통 형식에 맞춰서 위임시킴
- Receiver
	- 실제 작업 수행 / 원본 객체
- Invoker
	- 명령 실행 / 제품이라고 생각하면 됨
	- 어떠한 제품에 나 이 기능 쓸거야 라고 명령구현객체를 넣고 사용
- Client
	- 객체를 만들고 연결 / 사용하는 곳임

## 장·단점
#### 장점

#### 단점

## 사용 방법 
#### Command
```java
public interface Command {
    public void run();
}
```
#### Concrete Command
```java
public class HeaterOnCommand implements Command {
	private Heater heater;
    
	public HeaterOnCommand(Heater heater) {
    	this.heater = heater;
    }
    
    @Override
    public void run() {
    	heater.heaterOn();
    }
}

public class LightOnCommand implements Command {
	private Light light;
    
	public LightOnCommand(Light light) {
    	this.light = light;
    }
    
    @Override
    public void run() {
    	light.lightOn();
    }
}
```
#### Receiver
```java
public class Heater {
	public void heaterOn() {
    	System.out.println("Heater on");
    }
}

public class Light {
	public void lightOn() {
    	System.out.println("Light on");
    }
}
```
#### Invoker
```java
public class AISpeaker {
	private Command command;
    
    public void setCommand(Command command) {
    	this.command = command;
    }// 어떤 기능을 쓸지
    
    public void talk() {
    	command.run();
    }// 기능 실행
} 
```
#### Client
```java
public class Client {
    public static void main(String args[]){
    	Light light = new Light();
        Heater heater = new Heater();
        
        Command heaterOnCommand = new HeaterOnCommand(heater);
        Command lightOnCommnad = new LightOnCommand(light);
        
        AISpeaker aiSpeaker = new AISpeaker();
        
        aiSpeaker.setCommand(heaterOnCommand);
        aiSpeaker.talk();
        
        aiSpeaker.setCommand(lightOnCommnad);
        aiSpeaker.talk();
    }
}
```


#### 
