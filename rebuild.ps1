# =====================================================
#  건강검진 관리 시스템 — 데이터 재추출 및 HTML 재생성
#  사용법: 엑셀 수정 후 이 스크립트 실행
#  .\rebuild.ps1
# =====================================================

$BASE      = $PSScriptRoot
$XLSX      = Join-Path $BASE "실습용.xlsx"
$JSON_OUT  = Join-Path $BASE "employees.json"
$TEMPLATE  = Join-Path $BASE "검진조회_template.html"
$HTML_OUT  = Join-Path $BASE "검진조회.html"

Write-Host "`n[1/3] Excel 열기..." -ForegroundColor Cyan

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false
$workbook = $excel.Workbooks.Open($XLSX)
$sheet    = $workbook.Sheets.Item(1)

# ── 색상 상수 ──
$WHITE_BG  = 16777215   # 흰색 (일반)
$NO_FILL   = -4142      # 채우기 없음
$PINK_BG   = 16764159   # 핑크 = 휴직자
$BLUE_FC   = 15773696   # 파란글씨 = 수검예정
$RED_FC    = 255        # 빨간글씨 = 미수검 명시

# 회색 판별 함수: R≈G≈B 이고 너무 밝지/어둡지 않은 색
function Is-Gray($color) {
    if ($color -eq $WHITE_BG -or $color -eq $NO_FILL -or $color -eq $PINK_BG) { return $false }
    $r = $color -band 0xFF
    $g = ($color -shr 8)  -band 0xFF
    $b = ($color -shr 16) -band 0xFF
    $maxDiff = [Math]::Max([Math]::Abs($r-$g), [Math]::Max([Math]::Abs($g-$b), [Math]::Abs($r-$b)))
    return ($maxDiff -le 30) -and ($r -gt 40) -and ($r -lt 220)
}

$colMap = @{
    1="no"; 2="사번"; 3="부서"; 4="직군"; 5="직무"; 6="성명"; 7="입사일"; 8="성별"
    9="보건증대상"; 10="일반대상"; 11="야간대상"; 12="특수대상"; 13="유해인자"
    14="y23_요약"
    15="y24_보건증일검"; 16="y24_배치전"; 17="y24_배치후"; 18="y24_정기특검"
    19="y25_보건증일검"; 20="y25_배치전"; 21="y25_배치후"; 22="y25_정기특검"
    23="y26_보건증일검"; 24="y26_배치전"; 25="y26_배치후"; 26="y26_정기특검"
    27="y27_보건증일검"; 28="y27_배치전"; 29="y27_배치후"; 30="y27_정기특검"
}

Write-Host "[2/3] 데이터 추출 중..." -ForegroundColor Cyan

$employees = [System.Collections.Generic.List[object]]::new()

for ($r = 4; $r -le 700; $r++) {
    $noVal = $sheet.Cells.Item($r, 1).Text
    if (-not ($noVal -match '^\d+$')) { continue }

    $emp = [ordered]@{}

    # 행 배경색으로 직원 상태 판별 (2번 사번 컬럼 기준)
    $bg = $sheet.Cells.Item($r, 2).Interior.Color
    $emp["isOnLeave"]  = ($bg -eq $PINK_BG)
    $emp["isResigned"] = (Is-Gray $bg)

    for ($c = 1; $c -le 30; $c++) {
        $cell = $sheet.Cells.Item($r, $c)
        $txt  = $cell.Text
        $colName = $colMap[$c]

        if ($c -le 13) {
            $emp[$colName] = $txt
        } else {
            $fc  = $cell.Font.Color
            $cbg = $cell.Interior.Color

            $status = if ($txt -eq "") { "empty" }
                      elseif ($fc -eq $RED_FC)  { "overdue" }
                      elseif ($fc -eq $BLUE_FC) { "scheduled" }
                      else { "completed" }

            $emp[$colName] = "${txt}|${status}"
        }
    }
    $employees.Add($emp)
}

$workbook.Close($false)
$excel.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

$resigned = ($employees | Where-Object { $_.isResigned }).Count
$onLeave  = ($employees | Where-Object { $_.isOnLeave }).Count
$active   = $employees.Count - $resigned - $onLeave
Write-Host "   → 총 $($employees.Count)명 (재직 $active · 휴직 $onLeave · 퇴사 $resigned)" -ForegroundColor Green

# JSON 저장
$json = $employees | ConvertTo-Json -Depth 3
[System.IO.File]::WriteAllText($JSON_OUT, $json, [System.Text.Encoding]::UTF8)

Write-Host "[3/3] HTML 재생성 중..." -ForegroundColor Cyan

if (-not (Test-Path $TEMPLATE)) {
    Write-Host "오류: 템플릿 파일을 찾을 수 없습니다: $TEMPLATE" -ForegroundColor Red
    exit 1
}

$template = [System.IO.File]::ReadAllText($TEMPLATE, [System.Text.Encoding]::UTF8)
$final    = $template.Replace('__EMPLOYEE_DATA__', $json)
[System.IO.File]::WriteAllText($HTML_OUT, $final, [System.Text.Encoding]::UTF8)

$kb = [math]::Round(([System.IO.FileInfo]::new($HTML_OUT).Length)/1KB, 0)
Write-Host "`n완료! $HTML_OUT ($kb KB)" -ForegroundColor Green
Write-Host "브라우저에서 검진조회.html 을 열어 확인하세요.`n" -ForegroundColor Yellow
