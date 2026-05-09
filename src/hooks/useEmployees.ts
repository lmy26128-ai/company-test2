import { useEffect, useState } from 'react'
import type { Employee } from '../types/employee'
import { parseEmployee } from '../utils/parseEmployee'

export function useEmployees() {
  const [employees, setEmployees] = useState<Employee[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetch('/employees.json')
      .then((r) => r.json())
      .then((data) => {
        setEmployees(data.map(parseEmployee))
        setLoading(false)
      })
      .catch(() => {
        setError('데이터를 불러올 수 없습니다.')
        setLoading(false)
      })
  }, [])

  function search(query: string): Employee | undefined {
    const q = query.trim()
    if (!q) return undefined
    return employees.find((e) => e.사번 === q || e.성명 === q)
  }

  return { employees, loading, error, search }
}
