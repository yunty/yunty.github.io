---
title: Git 기본 사용법
modified: 2026-09-28
tags: [Git, 기초]
aliases: [Git 기본 사용법]
---

# Git 기본 사용법

이전 페이지: [[05_Git/00_Git 기본 개념|Git 기본 개념]]

다음 페이지: [[05_Git/02_커밋 메시지 작성법과 예시|커밋 메시지 작성법과 예시]]

**기본 흐름: 수정 → 확인 → add → commit → push**

아래는 터미널 기준이다. `사용자명`, `저장소명`, 파일 경로는 자신의 것으로 바꾼다.

## 1. 처음 한 번 설정하기

```bash
git --version                              # Git 설치 여부 확인
git config --global user.name "내 이름"      # 커밋 작성자 이름
git config --global user.email "me@example.com" # 커밋 작성자 이메일
```

`--global`은 이 컴퓨터의 내 계정에 기본값으로 적용한다는 뜻이다. 이름·이메일 설정은 GitHub 로그인과는 별개다.

## 2. 저장소 시작하기 — 둘 중 하나 선택

### A. 내 프로젝트를 처음 Git으로 관리할 때

**아직 Git으로 관리하지 않는 프로젝트 폴더**에서 실행한다. 첫 `add` 전에 아래의 `.gitignore`도 준비한다.

```bash
git init -b main                 # Git 저장소 생성, 첫 브랜치 이름은 main
git add .                        # 현재 폴더 아래 변경 내용을 스테이지에 담기
git commit -m "프로젝트 초기 설정" # 첫 버전 기록
```

GitHub에 **README 등을 추가하지 않은 빈 저장소**를 만든 뒤 연결한다.

```bash
git remote add origin https://github.com/사용자명/저장소명.git
git push -u origin main          # 첫 업로드 + 앞으로 사용할 원격 브랜치 연결
```

이후 같은 브랜치에서는 `git push`만 입력하면 된다. GitHub에 올리려면 별도 인증이 필요하다. [init](https://git-scm.com/docs/git-init), [push](https://git-scm.com/docs/git-push)

### B. GitHub에 이미 있는 저장소를 가져올 때

프로젝트를 보관할 **상위 폴더**에서 실행한다.

```bash
git clone https://github.com/사용자명/저장소명.git
cd 저장소명                     # 만들어진 프로젝트 폴더로 이동
```

`clone`하면 보통 `origin`과 기본 브랜치의 원격 연결도 설정된다. `init`이나 `remote add origin`을 다시 할 필요는 없다. [clone](https://git-scm.com/docs/git-clone)

## 3. 평소 작업할 때

아래 명령은 **프로젝트 폴더 안에서** 실행한다. 원격 연결을 마친 상태를 기준으로 한다.

```bash
# 작업 시작 전: 미커밋 변경이 없는 상태에서 원격 변경 반영
git pull --ff-only

# 파일 수정·저장 및 테스트 후
git status                      # 변경된 파일과 스테이지 상태 확인
git diff                        # 추적 중인 파일의 아직 add하지 않은 변경 확인
git add src/Main.java           # 이번 커밋에 넣을 파일 선택
git diff --staged               # 이번 커밋에 들어갈 변경 확인
git commit -m "입력값 검증 추가"  # 선택한 내용을 내 컴퓨터에 기록
git push                        # 커밋을 원격 저장소에 업로드
```

- `git add .`은 현재 폴더 아래 변경을 한꺼번에 담는다. 관련 파일만 담으려면 파일 경로를 지정한다.
- 커밋은 **의미 있는 변경 단위**로 한다. 예: 기능 하나 구현, 오류 하나 수정.
- `pull --ff-only`는 내 이력과 원격 이력이 서로 갈라졌다면 반영을 중단한다. 이때는 이력을 확인하고 병합 등의 방법을 선택한다. [pull](https://git-scm.com/docs/git-pull)

## 4. 필요할 때 찾아 쓰는 명령어

| 명령어 | 언제 사용하는가? |
| --- | --- |
| `git log --oneline` | 커밋 기록을 한 줄씩 보고 싶을 때 |
| `git remote -v` | 연결된 원격 저장소 주소를 확인할 때 |
| `git branch` | 로컬 브랜치 목록과 현재 브랜치를 확인할 때 |
| `git switch -c feature/login` | 현재 위치에서 새 브랜치를 만들고 이동할 때 |
| `git switch main` | main 브랜치로 돌아갈 때 |
| `git merge feature/login` | **현재 브랜치에** feature/login의 이력을 합칠 때 |

브랜치를 전환하기 전에는 작업을 커밋해둔다. 로그인 기능을 `main`에 합치려면 `main`으로 이동한 뒤 병합한다. 충돌이 나면 충돌 파일을 수정하고 `add` → `commit`으로 병합을 마친다. [브랜치 전환](https://git-scm.com/docs/git-switch), [병합 안내](https://git-scm.com/docs/gittutorial#_managing_branches)

## 5. 기록에서 제외할 파일 — .gitignore

프로젝트 최상위에 `.gitignore` 파일을 만들고, Git이 새로 추적하지 않을 파일·폴더를 적는다. Java·Gradle 프로젝트라면 다음처럼 시작할 수 있다.

```gitignore
# macOS가 만드는 파일
.DS_Store
# 빌드 결과
build/
# Gradle 캐시
.gradle/
```

`.gitignore` 자체는 함께 커밋한다. **이미 Git이 추적 중인 파일은 여기에 추가해도 자동으로 추적이 해제되지 않는다.** [gitignore](https://git-scm.com/docs/gitignore)
