import type { CheckupEntry, CheckupStatus, Employee } from '../types/employee'
import { deriveEmployee } from './deriveCheckups'

function parseEntry(raw: string): CheckupEntry {
  const [value, status] = raw.split('|')
  return { value: value ?? '', status: (status ?? 'empty') as CheckupStatus }
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function parseEmployee(raw: any): Employee {
  return deriveEmployee({
    no: raw['no'] ?? '',
    사번: raw['사번'] ?? '',
    부서: raw['부서'] ?? '',
    직군: raw['직군'] ?? '',
    직무: raw['직무'] ?? '',
    성명: raw['성명'] ?? '',
    입사일: raw['입사일'] ?? '',
    성별: raw['성별'] ?? '',
    보건증대상: raw['보건증대상'] ?? '',
    일반대상: raw['일반대상'] ?? '',
    야간대상: raw['야간대상'] ?? '',
    특수대상: raw['특수대상'] ?? '',
    유해인자: raw['유해인자'] ?? '',
    isOnLeave: !!raw['isOnLeave'],
    y23: {
      요약: parseEntry(raw['y23_요약'] ?? '|empty'),
    },
    y24: {
      보건증일검: parseEntry(raw['y24_보건증일검'] ?? '|empty'),
      배치전: parseEntry(raw['y24_배치전'] ?? '|empty'),
      배치후: parseEntry(raw['y24_배치후'] ?? '|empty'),
      정기특검: parseEntry(raw['y24_정기특검'] ?? '|empty'),
    },
    y25: {
      보건증일검: parseEntry(raw['y25_보건증일검'] ?? '|empty'),
      배치전: parseEntry(raw['y25_배치전'] ?? '|empty'),
      배치후: parseEntry(raw['y25_배치후'] ?? '|empty'),
      정기특검: parseEntry(raw['y25_정기특검'] ?? '|empty'),
    },
    y26: {
      보건증일검: parseEntry(raw['y26_보건증일검'] ?? '|empty'),
      배치전: parseEntry(raw['y26_배치전'] ?? '|empty'),
      배치후: parseEntry(raw['y26_배치후'] ?? '|empty'),
      정기특검: parseEntry(raw['y26_정기특검'] ?? '|empty'),
    },
    y27: {
      보건증일검: parseEntry(raw['y27_보건증일검'] ?? '|empty'),
      배치전: parseEntry(raw['y27_배치전'] ?? '|empty'),
      배치후: parseEntry(raw['y27_배치후'] ?? '|empty'),
      정기특검: parseEntry(raw['y27_정기특검'] ?? '|empty'),
    },
  })
}
