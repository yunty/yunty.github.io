---
title: collect()
modified: 2026-10-06
---
# .collect()

- 리스트로 모으기
stream.collect(Collectors.toList());
- Set으로 모으기
stream.collect(Collectors.toSet());
- Map으로 모으기
stream.collect(Collectors.toMap(
        Menu::getName, // key: 메뉴 이름
        menu -> menu  // value: Menu 객체
));

- Map
Map<키타입, 값타입> result = list.stream()
        .collect(Collectors.toMap(
                element -> 키를_만드는_표현식,
                element -> 값을_만드는_표현식,
                (previous, next) -> next, // 키 중복 시 새 값 사용
                () -> new HashMap<>()    // 결과를 담을 Map 생성
        ));
toMap()은 총 4가지 인자를 받을 수 있음