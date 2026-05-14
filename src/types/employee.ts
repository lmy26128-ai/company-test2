export type CheckupStatus = 'completed' | 'scheduled' | 'overdue' | 'empty' | 'not_applicable'

export interface CheckupEntry {
  value: string
  status: CheckupStatus
}

export interface YearlyCheckup {
  보건증일검: CheckupEntry
  배치전: CheckupEntry
  배치후: CheckupEntry
  정기특검: CheckupEntry
}

export interface Employee {
  no: string
  사번: string
  부서: string
  직군: string
  직무: string
  성명: string
  입사일: string
  성별: string
  보건증대상: string
  일반대상: string
  야간대상: string
  특수대상: string
  유해인자: string
  isOnLeave: boolean
  y23: { 요약: CheckupEntry }
  y24: YearlyCheckup
  y25: YearlyCheckup
  y26: YearlyCheckup
  y27: YearlyCheckup
}

export type YearKey = 'y24' | 'y25' | 'y26' | 'y27'
