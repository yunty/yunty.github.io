# 동태의 옵시디언 모음집

백엔드를 깊게 탐구하는 사이보그 개발자(희망)의 공부 노트입니다.
[Quartz](https://quartz.jzhao.xyz/)로 만들었고 GitHub Pages로 배포합니다.

## 노트를 고친 뒤 반영하는 방법

```bash
./sync-notes.sh                 # 옵시디언 노트를 content/ 로 복사하고 홈 화면을 새로 만든다
npx quartz build --serve        # http://localhost:8080 에서 미리 보기
git add -A && git commit -m "노트 업데이트" && git push
```

`main` 브랜치에 push하면 GitHub Actions가 사이트를 다시 만들어 올립니다.

- 공개할 폴더는 `sync-notes.sh`의 `SYNC` 목록으로 정합니다.
- 옵시디언 보관함 위치가 다르면 `NOTES_VAULT=/경로 ./sync-notes.sh` 로 지정합니다.
- 색과 글꼴은 `quartz.config.yaml`, 모양은 `quartz/styles/custom.scss` 에서 고칩니다.

## 라이선스

사이트 엔진 Quartz는 MIT 라이선스입니다. (`LICENSE.txt`)
