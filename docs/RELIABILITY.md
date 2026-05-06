# RELIABILITY.md — 안정성 및 오류 처리

## 스크립트 안전장치

- `try/finally` 블록으로 Excel 프로세스 항상 종료 (좀비 프로세스 방지)
- 원본 파일 복사 후 작업 (원본 훼손 불가)
- 빈 행 자동 스킵 (`IsNullOrWhiteSpace($name)`)

## 알려진 엣지케이스

| 상황 | 처리 방식 |
|------|-----------|
| 날짜 셀에 텍스트 혼재 (예: "용/소-26.04") | 정규식으로 YY.MM만 추출 |
| 배치후 날짜에 복수 날짜 (예: "25.02/26.05") | 첫 번째 YY.MM만 사용 |
| C27열에 이미 27.xx 값 있음 | 해당 값을 정기특검으로 우선 사용 |
| 특수항목 = "X" | 정기특검 날짜 생성 안 함 |

## 실행 전 확인 사항

1. Excel이 이미 열려있지 않은지 확인
2. `data/정기특검+보건증.xlsx` 파일이 존재하는지 확인
3. PowerShell ExecutionPolicy 설정:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```
