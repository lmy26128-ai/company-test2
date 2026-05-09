import { useState } from 'react'
import type { Employee, YearKey } from '../types/employee'
import { StatusBadge } from './StatusBadge'

interface Props {
  employee: Employee
}

const YEARS: { key: YearKey; label: string }[] = [
  { key: 'y24', label: '24년' },
  { key: 'y25', label: '25년' },
  { key: 'y26', label: '26년' },
  { key: 'y27', label: '27년' },
]

const CHECKUP_ITEMS: { key: keyof Employee['y24']; label: string }[] = [
  { key: '보건증일검', label: '보건증 + 일반검진' },
  { key: '배치전', label: '배치전 특수검진' },
  { key: '배치후', label: '배치후 특수검진' },
  { key: '정기특검', label: '정기 특수검진' },
]

export function CheckupTable({ employee: e }: Props) {
  const [activeYear, setActiveYear] = useState<YearKey>('y26')

  const yearData = e[activeYear]

  return (
    <div className="rounded-xl border border-gray-200 bg-white shadow-sm overflow-hidden">
      <div className="flex border-b border-gray-200">
        {YEARS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setActiveYear(key)}
            className={`flex-1 py-2.5 text-sm font-semibold transition-colors ${
              activeYear === key
                ? 'bg-indigo-600 text-white'
                : 'text-gray-600 hover:bg-gray-50'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      <div className="p-4">
        {activeYear === 'y24' && e.y23.요약.value && (
          <div className="mb-3 text-xs text-gray-500 bg-gray-50 rounded px-3 py-1.5 border border-gray-200">
            23년 기록: {e.y23.요약.value}
          </div>
        )}

        <div className="space-y-3">
          {CHECKUP_ITEMS.map(({ key, label }) => {
            const entry = yearData[key]
            const isTarget = getTarget(e, key)
            return (
              <div
                key={key}
                className={`flex items-center justify-between py-2 px-3 rounded-lg ${
                  !isTarget ? 'opacity-40' : 'bg-gray-50'
                }`}
              >
                <div>
                  <span className="text-sm font-medium text-gray-800">{label}</span>
                  {!isTarget && (
                    <span className="ml-2 text-xs text-gray-400">(해당없음)</span>
                  )}
                </div>
                <StatusBadge entry={entry} />
              </div>
            )
          })}
        </div>
      </div>

      <div className="px-4 pb-4">
        <div className="flex gap-3 text-xs text-gray-500 border-t border-gray-100 pt-3 flex-wrap">
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-green-400 inline-block" />
            완료
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-blue-400 inline-block" />
            예정
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-red-400 inline-block" />
            초과
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded-full bg-gray-300 inline-block" />
            미입력
          </span>
        </div>
      </div>
    </div>
  )
}

function getTarget(e: Employee, key: keyof Employee['y24']): boolean {
  if (key === '보건증일검') return e.보건증대상 === 'O' || e.일반대상 === 'O'
  if (key === '배치전' || key === '배치후' || key === '정기특검') return e.특수대상 === 'O'
  return true
}
