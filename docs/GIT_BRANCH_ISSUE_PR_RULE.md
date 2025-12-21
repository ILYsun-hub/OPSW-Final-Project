## Git Branch / Issue / PR 규칙 문서 작성

# 🌿 Branch Naming Convention

---

본 프로젝트는 안정적인 협업을 위해 다음과 같은 브랜치 규칙을 사용합니다.

## 🏷 브랜치 기본 규칙

브랜치는 다음 패턴을 반드시 따른다:

```
type/part-description-#issueNumber
```

## ✔ 브랜치 이름 예시

feat/FE-login-ui-#12
feat/BE-ocr-api-#8
bugfix/FE-calendar-crash-#45
docs/CM-api-spec-update-#7
refactor/BE-schedule-service-#32

### ✔ type 목록

| type | 설명 |
| --- | --- |
| `feat` | 새로운 기능 개발 |
| `bugfix` | 버그 수정 |
| `hotfix` | 긴급 수정 |
| `docs` | 문서 작업 |
| `test` | 테스트 코드 추가 |

### ✔ part 목록

| part | 의미 |
| --- | --- |
| `FE` | 프론트엔드 |
| `BE` | 백엔드 |
| `DB` | 데이터베이스 |
| `CM` | 공통(common |

---

## ✔ 브랜치 생성 규칙

1. 반드시 **Issue가 존재해야 함**
2. 브랜치 이름에는 이슈 번호 `#번호` 포함
3. main, dev에 **직접 push 금지**
4. 개발은 반드시 `feat/*` 브랜치에서 진행
5. 여러 기능을 한번에 구현해서  PR하는 게 아니라 기능 하나 당 브랜치 하나, 개발 순서대로 진행
6. 완료 후 PR 생성 → 리뷰 → merge

---

## ✔ 브랜치 흐름 구조

main ← dev ← feature/*
                ↳ bugfix/*

- `main` : 배포 또는 최종 안정 버전
- `dev` : 개발 브랜치(모든 feature merge)
- `feat/*` : 개별 기능 개발

---

# 📝 Issue 작성 템플릿

## 제목

ex) [feat][BE] FastAPI 프로젝트 초기화

(아래 내용 복붙해서 사용)

```markdown
## 작업 목적
- 

## 해야 할 일
- 
```

### ✔ type 목록

| type | 설명 |
| --- | --- |
| `feat` | 새로운 기능 개발 |
| `bugfix` | 버그 수정 |
| `hotfix` | 긴급 수정 |
| `docs` | 문서 작업 |
| `test` | 테스트 코드 추가 |

### ✔ part 목록

| part | 의미 |
| --- | --- |
| `FE` | 프론트엔드 |
| `BE` | 백엔드 |
| `DB` | 데이터베이스 |
| `CM` | 공통(common |

---

# 📝 Pull Request

## 제목

ex) [feat][FE] 로그인 UI 구현 (#12)

(아래 내용 복붙 해서 사용)

```
## 개요

<!-- 이 PR이 무엇을 해결하는지, 왜 필요한지 간단 설명 -->

---

## 변경 사항

## <!-- 주요 변경 사항 정리 -->

---

## 관련 이슈

<!-- 예: closes #12 -->
closes #1

---

## 👀 리뷰어 참고 사항

<!-- 리뷰어가 집중해서 보면 좋을 부분, 알려야 할 사항 -->
<!-- 없어도 됨 -->
```

### ✔ type 목록

| type | 설명 |
| --- | --- |
| `feat` | 새로운 기능 개발 |
| `bugfix` | 버그 수정 |
| `hotfix` | 긴급 수정 |
| `docs` | 문서 작업 |
| `test` | 테스트 코드 추가 |

### ✔ part 목록

| part | 의미 |
| --- | --- |
| `FE` | 프론트엔드 |
| `BE` | 백엔드 |
| `DB` | 데이터베이스 |
| `CM` | 공통(common |

---

# 📝 Commit

```
type/PART 작업 요약 (#이슈번호)
```

ex) setup/CM Flutter, Fast API 개발환경 세팅, Firebase 연동 (#4, #5, #36, #37) 

### ✔ type 목록

| type | 설명 |
| --- | --- |
| `feat` | 새로운 기능 개발 |
| `bugfix` | 버그 수정 |
| `hotfix` | 긴급 수정 |
| `docs` | 문서 작업 |
| `test` | 테스트 코드 추가 |

### ✔ part 목록

| part | 의미 |
| --- | --- |
| `FE` | 프론트엔드 |
| `BE` | 백엔드 |
| `DB` | 데이터베이스 |
| `CM` | 공통(common) |