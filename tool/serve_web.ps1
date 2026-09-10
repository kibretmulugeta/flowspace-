param(
    [int]$Port = 8080,
    [string]$WebRoot = "$PSScriptRoot\..\build\web"
)

$resolvedRoot = [System.IO.Path]::GetFullPath($WebRoot)
if (-not (Test-Path $resolvedRoot)) {
    Write-Error "Web root directory not found: $resolvedRoot"
    exit 1
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Error "Failed to start HTTP listener on $prefix : $_"
    exit 1
}

Write-Host "FlowSpace Web server running at $prefix serving $resolvedRoot"
Write-Host "Press Ctrl+C to stop."

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".mjs"  = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".wasm" = "application/wasm"
    ".ttf"  = "font/ttf"
    ".otf"  = "font/otf"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
    ".ico"  = "image/x-icon"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawUrl = $request.RawUrl.Split('?')[0].TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($rawUrl)) {
            $rawUrl = "index.html"
        }

        $filePath = [System.IO.Path]::Combine($resolvedRoot, $rawUrl.Replace('/', '\'))

        # SPA fallback: If file does not exist, return index.html
        if (-not (Test-Path $filePath -PathType Leaf)) {
            $filePath = [System.IO.Path]::Combine($resolvedRoot, "index.html")
        }

        $ext = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
        $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.StatusCode = 200
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.OutputStream.Close()
    } catch {
        # Continue listening
    }
}
