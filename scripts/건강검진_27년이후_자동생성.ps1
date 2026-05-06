param(
    [string]$InputFile  = "F:\dev\실습\data\정기특검+보건증.xlsx",
    [string]$OutputFile = "F:\dev\실습\data\정기특검+보건증_27년이후.xlsx",
    [int]   $StartYear  = 27
)

$HAZARD_MAP = @(
    [PSCustomObject]@{ Dept="설비파트";     Job="생산기술직"; Task="*";    Hazard="망간, 니켈, 알루미늄, 구리, 크롬, 텅스텐, 코발트, 산화철, 용접흄, 광물성분진, 자외선, 적외선, 오존"; HasNight=$true }
    [PSCustomObject]@{ Dept="생산1파트";    Job="생산기술직"; Task="*";    Hazard="용접, 소음, 메탄올, 메틸에틸케톤"; HasNight=$true }
    [PSCustomObject]@{ Dept="생산2파트";    Job="생산기술직"; Task="*";    Hazard="용접, 소음, 메탄올, 메틸에틸케톤"; HasNight=$true }
    [PSCustomObject]@{ Dept="생산3파트";    Job="생산기술직"; Task="*";    Hazard="소음, 메탄올, 메틸에틸케톤";       HasNight=$true }
    [PSCustomObject]@{ Dept="생산1파트";    Job="생산직";     Task="*QC*"; Hazard="디에틸에테르, 메탄올, 클로로포름, 에틸렌글리콜, 요오드화칼륨"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산2파트";    Job="생산직";     Task="*QC*"; Hazard="디에틸에테르, 메탄올, 클로로포름, 에틸렌글리콜, 요오드화칼륨"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산3파트";    Job="생산직";     Task="*QC*"; Hazard="디에틸에테르, 메탄올, 클로로포름, 에틸렌글리콜, 요오드화칼륨"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산1파트";    Job="생산직";     Task="*";    Hazard="소음, 곡물분진"; HasNight=$true }
    [PSCustomObject]@{ Dept="생산2파트";    Job="생산직";     Task="*";    Hazard="소음, 곡물분진"; HasNight=$true }
    [PSCustomObject]@{ Dept="생산3파트";    Job="생산직";     Task="*";    Hazard="소음, 곡물분진"; HasNight=$true }
    [PSCustomObject]@{ Dept="품질안전파트"; Job="*";          Task="*";    Hazard="디에틸에테르, 메탄올, 클로로포름, 에틸렌글리콜, 요오드화칼륨"; HasNight=$false }
    [PSCustomObject]@{ Dept="안전보건환경"; Job="생산직";     Task="*";    Hazard="알루미늄 및 그 화합물, 황화수소"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산1파트";    Job="사무전문직"; Task="*파트장*"; Hazard="용접, 소음, 메탄올, 메틸에틸케톤"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산2파트";    Job="사무전문직"; Task="*파트장*"; Hazard="용접, 소음, 메탄올, 메틸에틸케톤"; HasNight=$false }
    [PSCustomObject]@{ Dept="생산3파트";    Job="사무전문직"; Task="*파트장*"; Hazard="소음, 메탄올, 메틸에틸케톤"; HasNight=$false }
)

function Get-YM { param($text)
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    if ($text -match '(\d{2})\.(\d{2})') { return @{ Y=[int]$Matches[1]; M=[int]$Matches[2] } }
    return $null
}
function Format-YM { param($y,$m); return ("{0:D2}.{1:D2}" -f [int]$y,[int]$m) }
function Add-Months { param($ym,$n)
    if ($ym -eq $null) { return "" }
    $t = ($ym.Y*12+$ym.M-1)+$n
    return Format-YM ([int][Math]::Floor($t/12)) ([int](($t%12)+1))
}
function Get-HireYM { param($val)
    if ($val -eq $null) { return $null }
    # .Value2가 숫자인 경우 → Excel 날짜 시리얼 → DateTime 변환
    if ($val -is [double] -or $val -is [int]) {
        $dt = [DateTime]::FromOADate($val)
        return @{ Y = $dt.Year % 100; FullY = $dt.Year; M = $dt.Month }
    }
    # 문자열 폴백: YYYY-MM-DD
    if ($val -match '(\d{4})-(\d{2})-(\d{2})') {
        $y4 = [int]$Matches[1]
        return @{ Y = $y4 % 100; FullY = $y4; M = [int]$Matches[2] }
    }
    return $null
}
function Get-SameMonthNextYear { param($text,$targetYear)
    $ym=Get-YM $text; if ($ym -ne $null) { return Format-YM $targetYear $ym.M }; return ""
}
function Find-DateAndShift { param([string[]]$candidates,[int]$targetYear)
    foreach ($c in $candidates) { $r=Get-SameMonthNextYear $c $targetYear; if ($r -ne "") { return $r } }
    return ""
}
function Lookup-Hazard { param($dept,$job,$task)
    foreach ($e in $HAZARD_MAP) {
        if (($dept -like ("*"+$e.Dept+"*")) -and ($job -like $e.Job) -and ($task -like $e.Task)) { return $e }
    }
    return $null
}

Write-Host "=== 건강검진 자동생성 시작 ===" -ForegroundColor Cyan
Copy-Item $InputFile $OutputFile -Force
Write-Host ("파일 복사: " + $OutputFile) -ForegroundColor Green

$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false; $excel.DisplayAlerts = $false

try {
    $wb    = $excel.Workbooks.Open($OutputFile)
    $sheet = $wb.Sheets.Item("24.7기준최종")
    $lastRow = $sheet.UsedRange.Rows.Count + $sheet.UsedRange.Row - 1
    $lastCol = $sheet.UsedRange.Columns.Count + $sheet.UsedRange.Column - 1
    Write-Host ("대상: 4~" + $lastRow + "행 / 기존 마지막 열: " + $lastCol) -ForegroundColor Yellow

    $COL_부서=3; $COL_직군=4; $COL_직무=5; $COL_성명=6; $COL_입사일=7
    $COL_일반=10; $COL_야간=11; $COL_특수=12; $COL_유해=13
    $COL_Y24일=15; $COL_Y24배전=16; $COL_Y24배후=17; $COL_Y24정=18
    $COL_Y25일=19; $COL_Y25배전=20; $COL_Y25배후=21; $COL_Y25정=22
    $COL_Y26일=23; $COL_Y26배전=24; $COL_Y26배후=25; $COL_Y26정=26; $COL_Y26ext=27

    $C27일=$lastCol+1; $C27배전=$lastCol+2; $C27배후=$lastCol+3; $C27정=$lastCol+4

    # 헤더
    $sheet.Cells.Item(2,$C27일).Value2="27년"; $sheet.Cells.Item(2,$C27일).Font.Bold=$true
    $hdrLabels = @("보건증+일검","배치전","특수검진 6개월이내;배치후","정기특검")
    $hdrCols   = @($C27일,$C27배전,$C27배후,$C27정)
    for ($i=0;$i -lt 4;$i++) {
        $hc=$sheet.Cells.Item(3,$hdrCols[$i])
        $hc.Value2=$hdrLabels[$i]; $hc.Font.Bold=$true
        $hc.HorizontalAlignment=-4108; $hc.Interior.Color=0xD9E1F2
    }

    $cntDate=0; $cntHazard=0; $cntSpec=0

    for ($row=4; $row -le $lastRow; $row++) {
        $dept =$sheet.Cells.Item($row,$COL_부서).Text
        $job  =$sheet.Cells.Item($row,$COL_직군).Text
        $task =$sheet.Cells.Item($row,$COL_직무).Text
        $name =$sheet.Cells.Item($row,$COL_성명).Text
        $night=$sheet.Cells.Item($row,$COL_야간).Text
        $spec =$sheet.Cells.Item($row,$COL_특수).Text
        $haz  =$sheet.Cells.Item($row,$COL_유해).Text
        $hireT=$sheet.Cells.Item($row,$COL_입사일).Value2
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        # 유해인자 자동채움 (유해인자·특수항목 둘 다 빈칸일 때만 적용, X는 보존)
        if ([string]::IsNullOrWhiteSpace($haz) -and [string]::IsNullOrWhiteSpace($spec)) {
            $m=Lookup-Hazard $dept $job $task
            if ($m -ne $null -and $m.Hazard -ne "") {
                $base=$m.Hazard
                $sheet.Cells.Item($row,$COL_특수).Value2=$base
                $full=$base
                if ($m.HasNight -and $night -eq "O") { $full="야간, "+$base }
                $sheet.Cells.Item($row,$COL_유해).Value2=$full
                $haz=$full; $spec=$base; $cntHazard++
            }
        }
        $isSpec=($spec -ne "" -and $spec -ne "X")

        # 27년 일반검진
        $d26일=$sheet.Cells.Item($row,$COL_Y26일).Text
        $d25일=$sheet.Cells.Item($row,$COL_Y25일).Text
        $d24일=$sheet.Cells.Item($row,$COL_Y24일).Text
        $d27일=Find-DateAndShift @($d26일,$d25일,$d24일) $StartYear
        if ($d27일 -eq "") {
            if ($sheet.Cells.Item($row,$COL_일반).Text -eq "O") { $d27일=Format-YM $StartYear 4 }
        }
        if ($d27일 -ne "") { $sheet.Cells.Item($row,$C27일).Value2=$d27일; $cntDate++ }

        # 27년 배치전 (이전 기록 없는 특수대상 26년+ 신입)
        $prevBJ=@(
            $sheet.Cells.Item($row,$COL_Y26배전).Text
            $sheet.Cells.Item($row,$COL_Y25배전).Text
            $sheet.Cells.Item($row,$COL_Y24배전).Text
        )
        $hasPrev=(($prevBJ|Where-Object{$_ -ne ""}).Count -gt 0)
        $d27배전=""
        if ($isSpec -and -not $hasPrev) {
            $hYM=Get-HireYM $hireT
            if ($hYM -ne $null -and $hYM.FullY -ge (2000 + $StartYear)) {
                $d27배전=Format-YM $StartYear $hYM.M
            }
        }
        if ($d27배전 -ne "") { $sheet.Cells.Item($row,$C27배전).Value2=$d27배전 }

        # 27년 배치후
        $d27배후=""
        if ($d27배전 -ne "") {
            $d27배후=Add-Months (Get-YM $d27배전) 6
        }
        if ($d27배후 -ne "") { $sheet.Cells.Item($row,$C27배후).Value2=$d27배후 }

        # 27년 정기특검
        if ($isSpec) {
            $d27정=""
            $ext=$sheet.Cells.Item($row,$COL_Y26ext).Text
            $ymE=Get-YM $ext
            if ($ymE -ne $null -and $ymE.Y -eq $StartYear) { $d27정=$ext }
            else {
                $d26정=$sheet.Cells.Item($row,$COL_Y26정).Text
                $d25정=$sheet.Cells.Item($row,$COL_Y25정).Text
                $d24정=$sheet.Cells.Item($row,$COL_Y24정).Text
                $d27정=Find-DateAndShift @($d26정,$d25정,$d24정) $StartYear
            }
            if ($d27정 -eq "") { $d27정=Format-YM $StartYear 4 }
            $sheet.Cells.Item($row,$C27정).Value2=$d27정; $cntSpec++
        }
        if ($row % 100 -eq 0) { Write-Host ("  " + $row + "/" + $lastRow) -ForegroundColor DarkGray }
    }

    $rng=$sheet.Range($sheet.Cells.Item(2,$C27일),$sheet.Cells.Item($lastRow,$C27정))
    $rng.EntireColumn.AutoFit() | Out-Null
    $rng.Borders.LineStyle=1; $rng.Borders.Weight=2

    $wb.Save()
    Write-Host "=== 완료 ===" -ForegroundColor Cyan
    Write-Host ("일반검진: "+$cntDate+"건 / 정기특검: "+$cntSpec+"건 / 유해인자: "+$cntHazard+"건") -ForegroundColor Green
    Write-Host ("저장: " + $OutputFile) -ForegroundColor Cyan

} catch { Write-Host ("오류: " + $_) -ForegroundColor Red
} finally {
    if ($wb)    { $wb.Close($false) }
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
    [System.GC]::Collect()
}