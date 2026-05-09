# ARCHITECTURE.md

## 시스템 구조

```
실습용.xlsx
    │
    └── employees.json  (Excel → PowerShell 추출)
            │
            └── React App (Vite)
                    ├── useEmployees hook  (JSON 로딩)
                    ├── SearchPage         (사번 검색 UI)
                    ├── EmployeeCard       (인적사항 표시)
                    ├── CheckupStatus      (검진 현황 표시)
                    └── YearlySchedule     (연도별 일정 뷰)
```

## 데이터 모델

### Employee
- 인적사항: no, 사번, 부서, 직군, 직무, 성명, 입사일, 성별
- 대상여부: 보건증대상, 일반대상, 야간대상, 특수대상
- 유해인자: string
- isOnLeave: boolean (핑크 배경 = 휴직자)
- 연도별 검진: y24~y27 각각 { 보건증일검, 배치전, 배치후, 정기특검 }
  - 각 항목: { value: string, status: 'completed' | 'scheduled' | 'empty' }

## 검진 종류
| 코드 | 설명 |
|------|------|
| 보건증일검 | 보건증 + 일반검진 |
| 배치전 | 배치전 특수검진 |
| 배치후 | 배치후 특수검진 (6~7개월 이내) |
| 정기특검 | 정기 특수검진 |
