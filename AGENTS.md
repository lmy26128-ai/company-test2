# AGENTS.md

## Project Overview
건강검진 관리 웹앱 — 직원 사번 기반으로 보건증, 일반검진, 배치전/후 검진, 정기특검 수검 현황 및 유해인자를 조회하고 연도별 검진 일정을 관리한다.

## Stack
- Frontend: React 18 + TypeScript + Vite
- Styling: Tailwind CSS
- Data: employees.json (Excel에서 추출)

## Agent Guidelines
- 컴포넌트는 `src/components/` 아래에 위치한다
- 타입은 `src/types/employee.ts`에 정의한다
- 데이터 로딩은 `src/hooks/useEmployees.ts`에서 담당한다
- 유틸 함수는 `src/utils/`에 위치한다

## Status Color Rules (Excel 원본 기준)
- `completed` — 검정 글씨, 수검 완료
- `scheduled` — 파란 글씨, 수검 예정
- `empty` — 값 없음
- `on_leave` — 핑크 배경, 휴직자
