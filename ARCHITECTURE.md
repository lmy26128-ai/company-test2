# ARCHITECTURE.md — 건강검진 자동화 시스템 구조

## 시스템 개요

익산2공장 임직원의 **산업안전보건법 기반 건강검진 일정 및 유해인자를 자동으로 관리**하는 도구입니다.

```
[원본 Excel]  →  [PS1 자동생성 스크립트]  →  [결과 Excel]
 data/           scripts/                      data/
 원본.xlsx        자동생성.ps1                  27년이후.xlsx
```

---

## 디렉토리 구조

```
F:\dev\실습\
├── AGENTS.md                   # 에이전트 작업 규칙 및 로직 명세
├── ARCHITECTURE.md             # 이 파일 - 시스템 구조 설명
│
├── data\                       # 데이터 파일 (원본 보존)
│   ├── 정기특검+보건증.xlsx      # 원본 (읽기 전용으로 취급)
│   └── 정기특검+보건증_27년이후.xlsx  # 자동생성 결과
│
├── scripts\                    # 실행 스크립트
│   └── 건강검진_27년이후_자동생성.ps1
│
└── docs\
    ├── DESIGN.md               # 설계 원칙
    ├── PLANS.md                # 로드맵
    ├── PRODUCT_SENSE.md        # 도구의 목적과 사용자 관점
    ├── QUALITY_SCORE.md        # 데이터 품질 기준
    ├── RELIABILITY.md          # 안정성 및 오류 처리
    ├── SECURITY.md             # 개인정보 보안 정책
    │
    ├── design-docs\            # 설계 상세 문서
    │   ├── index.md
    │   └── core-beliefs.md
    │
    ├── exec-plans\             # 실행 계획
    │   ├── active\             # 진행 중인 작업
    │   ├── completed\          # 완료된 작업
    │   └── tech-debt-tracker.md
    │
    ├── generated\              # 자동 생성된 참고 문서
    │   └── 데이터구조.md
    │
    ├── product-specs\          # 기능 명세
    │   ├── index.md
    │   └── 건강검진_자동화.md
    │
    └── references\             # 법령·기준 참고자료
        ├── 유해인자_기준표.md
        └── 검진주기_법령기준.md
```

---

## 데이터 흐름

```
정기특검+보건증.xlsx (원본)
    │
    │  Excel COM Object (PowerShell)
    ▼
[Row 분석]
    ├── 부서 + 직군 + 직무 → 유해인자 매핑 조회
    ├── 특수항목(L열) == "X" → 일반검진만
    └── 특수항목 있음 → 일반검진 + 정기특검 날짜 생성
    │
    │  날짜 계산 (YY.MM 파싱)
    ▼
[27년 컬럼 생성 - 열 28~31]
    ├── 28열: 일반검진(보건증+일검) 날짜
    ├── 29열: 배치전 날짜
    ├── 30열: 배치후 날짜 (배치전 + 6개월)
    └── 31열: 정기특검 날짜
    │
    ▼
정기특검+보건증_27년이후.xlsx (결과)
```

---

## 핵심 컴포넌트

### `$HAZARD_MAP` (유해인자 매핑 테이블)
- 위치: `scripts/건강검진_27년이후_자동생성.ps1` 상단
- 구조: `Dept(부서패턴) + Job(직군) + Task(직무패턴) → Hazard + HasNight`
- 우선순위: 배열 순서대로 첫 매칭 적용 (더 구체적인 규칙을 앞에 배치)

### 날짜 처리 함수
| 함수 | 역할 |
|------|------|
| `Get-YM` | 셀 텍스트에서 YY.MM 추출 |
| `Format-YM` | YY.MM 형식 문자열 생성 |
| `Add-Months` | YY.MM + N개월 계산 |
| `Get-SameMonthNextYear` | 전년도 날짜 → 목표연도 동월 변환 |
| `Find-DateAndShift` | 여러 후보 셀 중 첫 유효 날짜 탐색 |

---

## 확장 방법

### 새 연도 추가 (예: 28년)
```powershell
& .\scripts\건강검진_27년이후_자동생성.ps1 `
    -InputFile  ".\data\정기특검+보건증_27년이후.xlsx" `
    -OutputFile ".\data\정기특검+보건증_28년이후.xlsx" `
    -StartYear  28
```

### 새 파트/유해인자 추가
`scripts/건강검진_27년이후_자동생성.ps1`의 `$HAZARD_MAP`에 항목 추가:
```powershell
[PSCustomObject]@{ Dept="새파트"; Job="생산직"; Task="*"; Hazard="새유해인자"; HasNight=$true }
```

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 런타임 | PowerShell 5.1 (Windows) |
| Excel 제어 | Excel COM Object (`New-Object -ComObject Excel.Application`) |
| 데이터 형식 | .xlsx (Office Open XML) |
| 인코딩 | UTF-8 |
