import type { CheckupEntry } from '../types/employee'

interface Props {
  entry: CheckupEntry
}

const styles: Record<string, string> = {
  completed: 'bg-green-100 text-green-800 border border-green-300',
  scheduled: 'bg-blue-100 text-blue-800 border border-blue-300',
  overdue: 'bg-red-100 text-red-800 border border-red-300',
  empty: 'bg-gray-100 text-gray-400 border border-gray-200',
  not_applicable: 'bg-gray-50 text-gray-300 border border-gray-100',
}

const labels: Record<string, string> = {
  completed: '완료',
  scheduled: '예정',
  overdue: '초과',
  empty: '—',
  not_applicable: '-',
}

export function StatusBadge({ entry }: Props) {
  const cls = styles[entry.status] ?? styles.empty
  const label = entry.value || labels[entry.status]
  return (
    <span className={`inline-block px-2 py-0.5 rounded text-xs font-medium ${cls}`}>
      {label}
    </span>
  )
}
