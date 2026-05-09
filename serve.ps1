# 간단한 HTTP 서버 (Node.js 없이 실행 가능)
# 실행: .\serve.ps1
# 브라우저에서 http://localhost:5173 접속

$port = 5173
$root = $PSScriptRoot
$prefix = "http://localhost:$port/"

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)
$listener.Start()

Write-Host "서버 시작: $prefix" -ForegroundColor Green
Write-Host "브라우저에서 http://localhost:$port 을 열어주세요" -ForegroundColor Cyan
Write-Host "종료: Ctrl+C" -ForegroundColor Yellow

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.js'   = 'application/javascript'
    '.css'  = 'text/css'
    '.json' = 'application/json; charset=utf-8'
    '.ico'  = 'image/x-icon'
    '.png'  = 'image/png'
    '.svg'  = 'image/svg+xml'
}

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response

        $urlPath = $req.Url.LocalPath
        if ($urlPath -eq '/') { $urlPath = '/standalone.html' }

        # standalone.html 서빙
        $filePath = Join-Path $root $urlPath.TrimStart('/')

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath)
            $mime = $mimeTypes[$ext] ?? 'application/octet-stream'
            $res.ContentType = $mime
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $res.StatusCode = 404
        }
        $res.OutputStream.Close()
    } catch { break }
}

$listener.Stop()
