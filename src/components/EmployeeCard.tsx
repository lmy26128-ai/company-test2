import type { Employee } from '../types/employee'

interface Props {
  employee: Employee
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex gap-2">
      <span className="text-gray-500 text-sm w-20 shrink-0">{label}</span>
      <span className="text-gray-900 text-sm font-medium">{value || '—'}</span>
    </div>
  )
}

function TargetBadge({ label, value }: { label: string; value: string }) {
  const isTarget = value === 'O'
  return (
    <span
      className={`px-2 py-0.5 rounded text-xs font-semibold border ${
        isTarget
          ? 'bg-indigo-100 text-indigo-800 border-indigo-300'
          : 'bg-gray-100 text-gray-400 border-gray-200 line-through'
      }`}
    >
      {label}
    </span>
  )
}

export function EmployeeCard({ employee: e }: Props) {
  const cardBg = e.isOnLeave ? 'bg-pink-50 border-pink-300' : 'bg-white border-gray-200'

  return (
    <div className={`rounded-xl border-2 p-5 shadow-sm ${cardBg}`}>
      <div className="flex items-start justify-between mb-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">{e.성명}</h2>
          <p className="text-gray-500 text-sm mt-0.5">
            {e.부서} · {e.직군} · {e.직무}
          </p>
        </div>
        <div className="flex flex-col items-end gap-1">
          <span className="text-lg font-mono font-bold text-indigo-600">{e.사번}</span>
          {e.isOnLeave && (
            <span className="px-2 py-0.5 rounded bg-pink-200 text-pink-800 text-xs font-bold border border-pink-400">
              휴직자
            </span>
          )}
        </div>
      </div>

      <div className="grid grid-cols-2 gap-x-8 gap-y-1.5 mb-4">
        <Field label="입사일" value={e.입사일} />
        <Field label="성별" value={e.성별} />
        <Field label="부서" value={e.부서} />
        <Field label="직군" value={e.직군} />
        <Field label="직무" value={e.직무} />
      </div>

      <div className="mb-3">
        <p className="text-gray-500 text-xs mb-1.5">검진 대상</p>
        <div className="flex gap-2 flex-wrap">
          <TargetBadge label="보건증" value={e.보건증대상} />
          <TargetBadge label="일반검진" value={e.일반대상} />
          <TargetBadge label="야간검진" value={e.야간대상} />
          <TargetBadge label="특수검진" value={e.특수대상} />
        </div>
      </div>

      {e.유해인자 && e.유해인자 !== 'X' && e.유해인자 !== '' && (
        <div>
          <p className="text-gray-500 text-xs mb-1">유해인자</p>
          <p className="text-sm text-orange-700 bg-orange-50 border border-orange-200 rounded px-3 py-1.5 leading-relaxed">
            {e.유해인자}
          </p>
        </div>
      )}
    </div>
  )
}
