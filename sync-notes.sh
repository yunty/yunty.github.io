#!/bin/bash
# 옵시디언 노트에서 공개할 폴더만 content/ 로 복사한다. (원본은 수정하지 않음)
# 폴더를 추가하려면 아래 SYNC 목록에 "원본경로|content 안의 경로" 한 줄을 추가하면 된다.

VAULT="${NOTES_VAULT:-$HOME/Documents/Study/Obsidian}"
DEST="$(cd "$(dirname "$0")" && pwd)/content"

SYNC=(
  "$VAULT/Java/01_Java|01_Java"
  "$VAULT/Java/03_디자인 패턴|03_디자인 패턴"
  "$VAULT/Java/05_Git|05_Git"
  "$VAULT/Java/9999_첨부파일|9999_첨부파일"
  "$VAULT/회고/01_회고|회고"
)

for entry in "${SYNC[@]}"; do
  src="${entry%%|*}"
  dst="$DEST/${entry##*|}"
  if [ ! -d "$src" ]; then
    echo "건너뜀 (원본 없음): $src"
    continue
  fi
  mkdir -p "$dst"
  rsync -a --delete --exclude ".obsidian" --exclude ".DS_Store" "$src/" "$dst/"
  echo "복사: ${entry##*|}"
done

# 사이트에서는 번호 접두사(01_, 03_ ...)가 보이지 않도록, 복사본에만 제목을 넣어 준다. (원본은 그대로)
python3 - "$DEST" <<'PY'
import datetime, os, re, sys

dest = sys.argv[1]
TITLED_DIRS = ["01_Java", "03_디자인 패턴", "05_Git"]
DATED_ONLY_DIRS = ["회고"]
FOLDER_TITLES = {
    "01_Java": "자바",
    "03_디자인 패턴": "디자인 패턴",
    "05_Git": "깃",
    "03_디자인 패턴/01_GoF_생성": "GoF 생성",
    "03_디자인 패턴/02_GoF_구조": "GoF 구조",
    "03_디자인 패턴/03_GoF 행동": "GoF 행동",
}

def clean(name):
    return re.sub(r"^\d+_", "", name).replace("_", " ")

def prepare(path, title):
    # 복사본의 머리말에 title(번호 제거)과 modified(원본 수정일)를 넣는다.
    # 서버(GitHub Actions)에서 빌드하면 파일 시각이 배포한 날로 바뀌므로, 날짜를 글 안에 적어 둔다.
    # 파일 수정 시각은 원본 그대로 유지한다. (홈의 "최근 업데이트" 정렬에 쓰임)
    st = os.stat(path)
    with open(path, encoding="utf-8") as f:
        text = f.read()
    head, body, joiner = "", text, "\n"
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            head, body, joiner = text[4:end], text[end + 4:], ""
    add = []
    if title and not re.search(r"^title:", head, re.M):
        add.append("title: " + title)
    if not re.search(r"^modified:", head, re.M):
        add.append("modified: " + datetime.date.fromtimestamp(st.st_mtime).isoformat())
    if not add:
        return
    new_head = "\n".join(add) + ("\n" + head if head else "")
    with open(path, "w", encoding="utf-8") as f:
        f.write("---\n" + new_head + "\n---" + joiner + body)
    os.utime(path, (st.st_atime, st.st_mtime))

for d in TITLED_DIRS + DATED_ONLY_DIRS:
    for root, _, files in os.walk(os.path.join(dest, d)):
        for name in files:
            if name.endswith(".md") and name != "index.md":
                title = clean(name[:-3]) if d in TITLED_DIRS else None
                prepare(os.path.join(root, name), title)

for rel, title in FOLDER_TITLES.items():
    folder = os.path.join(dest, rel)
    index = os.path.join(folder, "index.md")
    if os.path.isdir(folder) and not os.path.exists(index):
        with open(index, "w", encoding="utf-8") as f:
            f.write("---\ntitle: " + title + "\n---\n")
PY
echo "제목 정리 완료"

# 홈 화면(content/index.md)은 이 스크립트가 노트 내용으로 매번 새로 만든다.
# (통계, 카테고리별 노트 수, 최근 업데이트, 가장 최근 회고, 태그 모음)
python3 - "$DEST" <<'PY'
import collections, datetime, html, os, re, sys

dest = sys.argv[1]

CATS = [  # (tone, 폴더, 이름, 설명)
    ("1", "01_Java", "자바", "자바 기본과 동시성"),
    ("2", "03_디자인 패턴", "디자인 패턴", "GoF 생성, 구조, 행동 패턴"),
    ("3", "05_Git", "깃", "기본 개념과 사용법, 커밋 메시지"),
    ("4", "회고", "회고", "하루하루 공부한 내용과 헷갈렸던 점"),
]
DAILY = re.compile(r"^(\d+)\.(\d+)$")
HASHTAG = re.compile(r"#[\w가-힣][\w가-힣/_-]*")


def slug(text):
    return re.sub(r"\s+", "-", text.strip().lower())


def esc(text):
    return html.escape(text, quote=True)


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def frontmatter(text):
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            return text[4:end], text[end + 4:]
    return "", text


def fm_value(head, key):
    m = re.search(r"^" + key + r":\s*(.+)$", head, re.M)
    return m.group(1).strip().strip("\"'") if m else None


def fm_tags(head):
    m = re.search(r"^tags:\s*\[(.*)\]\s*$", head, re.M)
    if m:
        return [t.strip().strip("\"'") for t in m.group(1).split(",") if t.strip()]
    m = re.search(r"^tags:\s*\n((?:\s+-\s*.+\n?)+)", head + "\n", re.M)
    if m:
        return [t.strip().lstrip("-").strip().strip("\"'") for t in m.group(1).splitlines() if t.strip()]
    return []


def section(body, heading):
    m = re.search(r"^##\s*" + heading + r"[^\n]*\n(.*?)(?=^##\s|\Z)", body, re.M | re.S)
    return m.group(1) if m else ""


notes = []
tags = collections.Counter()
daily = []
for tone, folder, cat_title, _ in CATS:
    base = os.path.join(dest, folder)
    for root, _, files in os.walk(base):
        for name in files:
            if not name.endswith(".md") or name == "index.md":
                continue
            path = os.path.join(root, name)
            rel = os.path.relpath(path, dest)[:-3]
            head, body = frontmatter(read(path))
            stem = name[:-3]
            title = fm_value(head, "title") or stem
            display = title + " 회고" if folder == "회고" else title
            notes.append({
                "rel": rel, "display": display, "cat": cat_title, "folder": folder,
                "mtime": os.path.getmtime(path),
            })
            for t in fm_tags(head):
                tags[t.lower()] += 1
            m = DAILY.match(stem)
            if folder == "회고" and m:
                studied = section(body, "오늘 공부한 것")
                topics = []
                for line in studied.splitlines():
                    if line.lstrip().startswith("%%"):
                        continue
                    for t in HASHTAG.findall(line):
                        topics.append(t[1:].lower())
                for t in topics:
                    tags[t] += 1
                todos = []
                for line in section(body, "내일").splitlines():
                    mt = re.match(r"\s*-\s*\[ \]\s*(\S.*)$", line)
                    if mt:
                        todos.append(mt.group(1).strip())
                daily.append({
                    "key": (int(m.group(1)), int(m.group(2))), "stem": stem, "rel": rel,
                    "hours": fm_value(head, "공부시간"), "topics": topics, "todos": todos,
                })

total = len(notes)
latest_mtime = max((n["mtime"] for n in notes), default=0)
latest_dt = datetime.datetime.fromtimestamp(latest_mtime)
counts = collections.Counter(n["folder"] for n in notes)


def mmdd(ts):
    d = datetime.datetime.fromtimestamp(ts)
    return f"{d.month}.{d.day}"


out = []
out.append("---\ntitle: 동태의 공부방\n---\n")
out.append(
    '<section class="hero">\n<div class="hero-body">\n'
    '<span class="hero-badge">TREE STUDY</span>\n'
    '<div class="hero-title">동태의 공부방</div>\n'
    '<p class="hero-sub">AI와 백엔드를 깊게 탐구하는 사이보그 개발자(희망)</p>\n'
    "</div>\n</section>\n"
)

out.append('<div class="section-heading">카테고리</div>\n')
cards = ['<div class="card-grid">']
for i, (tone, folder, cat_title, desc) in enumerate(CATS, 1):
    href = slug(folder) + "/"
    cards.append(
        f'<a class="cat-card" data-tone="{tone}" href="{esc(href)}">'
        f'<span class="cat-no">#{i}</span><strong class="cat-title">{esc(cat_title)}</strong>'
        f'<span class="cat-desc">{esc(desc)}</span>'
        f'<span class="cat-count">노트 {counts.get(folder, 0)}개</span></a>'
    )
cards.append("</div>\n")
out.append("\n".join(cards))

recent = sorted(notes, key=lambda n: n["mtime"], reverse=True)[:6]
out.append('<div class="section-heading">최근 업데이트<small>최근에 고친 노트 순</small></div>\n')
out.append('<div class="recent-list">\n')
for n in recent:
    link = f"[[{n['rel']}|{n['display']}]]"
    out.append(f'- {link} <span class="recent-meta">{esc(n["cat"])} · {mmdd(n["mtime"])}</span>')
out.append("\n</div>\n")

if daily:
    last = max(daily, key=lambda d: d["key"])
    seg = "/".join(slug(p) for p in last["rel"].split("/"))
    meta = f'{last["stem"]}'
    if last["hours"]:
        meta += f' · 공부 시간 {esc(last["hours"])}시간'
    box = ['<div class="section-heading">가장 최근 회고</div>\n', '<div class="recap">']
    box.append(f'<div class="recap-label">{meta}</div>')
    box.append(f'<div class="recap-title"><a href="{esc(seg)}">{esc(last["stem"])} 회고 보러 가기</a></div>')
    if last["topics"]:
        chips = "".join(f'<span class="recap-topic">#{esc(t)}</span>' for t in last["topics"][:8])
        box.append(f'<div class="recap-topics">{chips}</div>')
    if last["todos"]:
        items = "".join(f"<li>{esc(t)}</li>" for t in last["todos"][:4])
        box.append(f'<ul class="recap-todo">{items}</ul>')
    box.append("</div>\n")
    out.append("\n".join(box))

if tags:
    out.append('<div class="section-heading">태그 모음<small>많이 쓴 순</small></div>\n')
    cloud = ['<div class="tag-cloud">']
    for t, c in sorted(tags.items(), key=lambda kv: (-kv[1], kv[0]))[:24]:
        cloud.append(f'<a class="tag-chip" href="tags/{esc(slug(t))}">#{esc(t)}<i>{c}</i></a>')
    cloud.append("</div>\n")
    out.append("\n".join(cloud))

with open(os.path.join(dest, "index.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(out))
PY
echo "홈 화면 생성 완료"
