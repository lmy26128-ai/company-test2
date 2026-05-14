import type { Employee, CheckupEntry, YearKey } from '../types/employee'

const YEARS: YearKey[] = ['y24', 'y25', 'y26', 'y27']
const NA: CheckupEntry = { value: '', status: 'not_applicable' }

function parseYM(v: string): { year: number; month: number } | null {
  const m = v.match(/^(\d{2})\.(\d{2})/)
  if (!m) return null
  return { year: 2000 + parseInt(m[1], 10), month: parseInt(m[2], 10) }
}

function nextYearValue(v: string): string {
  const p = parseYM(v)
  if (!p) return v
  return `${String(p.year + 1).slice(2)}.${String(p.month).padStart(2, '0')}`
}

function futureOrOverdue(v: string): CheckupEntry {
  const p = parseYM(v)
  const isScheduled = p ? new Date(p.year, p.month - 1) > new Date() : false
  return { value: v, status: isScheduled ? 'scheduled' : 'overdue' }
}

function findLastCompleted(emp: Employee, key: keyof Employee['y24']): string | null {
  for (const y of [...YEARS].reverse()) {
    const entry = emp[y][key]
    if (entry.status === 'completed' && entry.value) return entry.value
  }
  return null
}

export function deriveEmployee(emp: Employee): Employee {
  // 특수대상: 'X' 이거나 빈값이 아니면 특수검진 대상
  const isSpecial = emp.특수대상 !== '' && emp.특수대상 !== 'X'

  // 정기특검이 이미 진행 중인지 확인 (배치전→배치후→정기특검 사이클 완료)
  const hasJeonggiEver = isSpecial && YEARS.some(y => emp[y].정기특검.status === 'completed')

  // 추적 기간 내에 배치전이 완료된 첫 해
  const baejijeonYear = YEARS.find(y => emp[y].배치전.status === 'completed')

  const result = { ...emp }

  for (const year of YEARS) {
    const d = { ...emp[year] }

    if (!isSpecial) {
      // 특수검진 비대상자: 배치전/배치후/정기특검 모두 해당없음
      d.배치전 = NA
      d.배치후 = NA
      d.정기특검 = NA
    } else {
      // 배치전: 정기특검이 이미 진행 중이거나, 배치전이 다른 연도에 완료됐으면 해당없음
      if (d.배치전.status === 'empty') {
        if (hasJeonggiEver || (baejijeonYear && baejijeonYear !== year)) {
          d.배치전 = NA
        }
      }

      // 배치후: 정기특검이 이미 진행 중이거나, 배치전이 더 이른 연도에 완료됐으면 해당없음
      // (배치후는 배치전 후 6개월 이내 1회만)
      if (d.배치후.status === 'empty') {
        if (hasJeonggiEver || (baejijeonYear && baejijeonYear < year)) {
          d.배치후 = NA
        }
      }
    }

    result[year] = d
  }

  // y27 빈 항목 자동 예측 (가장 최근 완료일 + 1년)
  const y27 = { ...result.y27 }

  const needsBogeun = emp.보건증대상 === 'O' || emp.일반대상 === 'O'
  if (needsBogeun && y27.보건증일검.status === 'empty') {
    const last = findLastCompleted(emp, '보건증일검')
    if (last) y27.보건증일검 = futureOrOverdue(nextYearValue(last))
  }

  if (isSpecial && y27.정기특검.status === 'empty') {
    const last = findLastCompleted(emp, '정기특검')
    if (last) y27.정기특검 = futureOrOverdue(nextYearValue(last))
  }

  result.y27 = y27

  return result
}
