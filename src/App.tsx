import { useState } from 'react'
import { useEmployees } from './hooks/useEmployees'
import { EmployeeCard } from './components/EmployeeCard'
import { CheckupTable } from './components/CheckupTable'
import type { Employee } from './types/employee'

export function App() {
  const { loading, error, search } = useEmployees()
  const [query, setQuery] = useState('')
  const [result, setResult] = useState<Employee | null | undefined>(undefined)

  function handleSearch(e: React.FormEvent) {
    e.preventDefault()
    const found = search(query)
    setResult(found ?? null)
  }

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-indigo-700 text-white py-5 px-6 shadow-md">
        <h1 className="text-xl font-bold tracking-tight">건강검진 관리 시스템</h1>
        <p className="text-indigo-200 text-sm mt-0.5">익산2공장 검진 현황 조회</p>
      </header>

      <main className="max-w-2xl mx-auto px-4 py-8">
        <form onSubmit={handleSearch} className="flex gap-2 mb-8">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="사번 또는 성명 입력"
            className="flex-1 px-4 py-3 rounded-lg border border-gray-300 shadow-sm text-base focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
          <button
            type="submit"
            disabled={loading}
            className="px-6 py-3 bg-indigo-600 text-white rounded-lg font-semibold hover:bg-indigo-700 disabled:opacity-50 transition-colors"
          >
            {loading ? '로딩 중…' : '검색'}
          </button>
        </form>

        {error && (
          <div className="bg-red-50 border border-red-300 text-red-700 rounded-lg px-4 py-3 text-sm mb-4">
            {error}
          </div>
        )}

        {result === null && (
          <div className="text-center text-gray-500 py-10">
            <p className="text-lg">검색 결과가 없습니다.</p>
            <p className="text-sm mt-1">사번 또는 성명을 정확히 입력해주세요.</p>
          </div>
        )}

        {result && (
          <div className="space-y-4">
            <EmployeeCard employee={result} />
            <CheckupTable employee={result} />
          </div>
        )}

        {result === undefined && !loading && (
          <div className="text-center text-gray-400 py-16">
            <p className="text-4xl mb-3">🔍</p>
            <p className="text-gray-500 font-medium">사번 또는 성명으로 검색하세요</p>
            <p className="text-sm text-gray-400 mt-1">예: 2150570 또는 이우상</p>
          </div>
        )}
      </main>
    </div>
  )
}
