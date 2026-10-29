---
title: 자바의 JVM
modified: 2026-09-21
---
#  자바의 실행 순서
.java파일을 JDK에서 .class파일로 (JVM바이트코드로) 변환
&rarr; JVM에서 JVM인터프리터, JIT(Just-In Time Compiler)로 CPU에서 읽는, 각 운영체제에 맞는 바이트코드로 변환(이진 코드)

JVM이 필요한 이유는 JVM이 없다면 개발자들은 각 개발환경별 배포파일을 다 만들어야함
즉 JVM은 어떤 환경에서 내가 코드를 작성하고 사용하든 결국 JVM을 거쳐서 사용되기 때문에 어떤 운영체제인지를 신경 쓸 필요가 없음

하지만 ==JVM이 없다면== MacOS + ARM64 따로 MacOS + x86-64 따로
각각 운영체제 + CPU 환경에서 해석할 수 있는 각==각의 실행파일을 다 만들어서 배포해야함==
하지만 JVM을 통해서 ==본인들의 환경에 맞는 JVM이 설치== 되어있기 때문에 ==JVM에서 해석할 수 있는 JVM바이트 코드로만 변환되면 끝인거다==

### 순서
컴파일 &rarr; 인터프리터 + 컴파일
JDK 컴파일러 &rarr; JVM인터프리터 + JIT 컴파일러
.java &rarr; .class &rarr; 각  CPU별 기계어

이때 JIT는 JVM 인터프리터에서 자주 사용되는것을 code cache라는 JVM 프로세스 즉 실행파일을 실행 하면 메모리에서 JVM에 할당해주는 메모리 내부에 Java Heap + Metaspace + Code Cache + stack + JVM, GC 등의 네이티브 데이터
이렇게 구성되어있는 곳 중 Code Cache에 저장해두고 사용함
Java Heap : new 키워드로 생성된 객체들과 배열들
Metaspace : 클래스의 메타데이터 즉 클래스의 기본 구성들의 정보들이 담겨있음
Code Cache : JIT가 만든 CPU 기계어
스레드 별 STACK : 실행 메서드들이 스택프레임으로 들어가있음


