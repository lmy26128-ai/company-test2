$file = "F:\dev\실습\data\정기특검+보건증_27년이후.xlsx"
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false; $excel.DisplayAlerts = $false

try {
    $wb    = $excel.Workbooks.Open($file)
    $sheet = $wb.Sheets.Item("24.7기준최종")
    $lastRow = $sheet.UsedRange.Rows.Count + $sheet.UsedRange.Row - 1

    $rows = New-Object System.Collections.ArrayList

    for ($r = 4; $r -le $lastRow; $r++) {
        $name = $sheet.Cells.Item($r,6).Text
        if ([string]::IsNullOrWhiteSpace($name)) { continue }

        # 셀값+상태 추출 (auto=true이면 무조건 예정)
        function ReadCell { param([int]$col, [bool]$auto=$false)
            $c = $sheet.Cells.Item($r, $col)
            $v = ($c.Text).Trim()
            if ($v -eq "") { return @{val="";status=""} }
            if ($auto)     { return @{val=$v;status="scheduled"} }
            $st = if ($c.Font.Color -eq 0) { "done" } else { "scheduled" }
            return @{val=$v;status=$st}
        }

        $obj = [ordered]@{
            no      = $sheet.Cells.Item($r,1).Text
            id      = $sheet.Cells.Item($r,2).Text
            name    = $name
            dept    = $sheet.Cells.Item($r,3).Text
            job     = $sheet.Cells.Item($r,4).Text
            role    = $sheet.Cells.Item($r,5).Text
            hire    = $sheet.Cells.Item($r,7).Text
            gender  = $sheet.Cells.Item($r,8).Text
            health  = $sheet.Cells.Item($r,9).Text
            general = $sheet.Cells.Item($r,10).Text
            night   = $sheet.Cells.Item($r,11).Text
            hazard  = ($sheet.Cells.Item($r,13).Text -replace "`n"," " -replace "\s+"," ").Trim()
            y23     = @{ ilgeom=(ReadCell 14) }
            y24     = @{ ilgeom=(ReadCell 15); baejijeon=(ReadCell 16); baejihoo=(ReadCell 17); jeonggi=(ReadCell 18) }
            y25     = @{ ilgeom=(ReadCell 19); baejijeon=(ReadCell 20); baejihoo=(ReadCell 21); jeonggi=(ReadCell 22) }
            y26     = @{ ilgeom=(ReadCell 23); baejijeon=(ReadCell 24); baejihoo=(ReadCell 25); jeonggi=(ReadCell 26) }
            y27     = @{ ilgeom=(ReadCell 28 $true); baejijeon=(ReadCell 29 $true); baejihoo=(ReadCell 30 $true); jeonggi=(ReadCell 31 $true) }
        }
        [void]$rows.Add($obj)

        if ($r % 100 -eq 0) { Write-Host ("  " + $r + "/" + $lastRow) }
    }

    $json = $rows | ConvertTo-Json -Depth 5 -Compress
    [System.IO.File]::WriteAllText("F:\dev\실습\webapp\data.json", $json, [System.Text.Encoding]::UTF8)
    Write-Host ("완료: " + $rows.Count + "명 추출")

} finally {
    if ($wb)    { $wb.Close($false) }
    if ($excel) { $excel.Quit(); [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null }
    [System.GC]::Collect()
}