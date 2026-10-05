$ErrorActionPreference = "Stop"

Set-Location C:\work

# package-lock.json contains a git+ssh GitHub dependency.
# Use HTTPS so the build does not require an SSH key.
git config --global url."https://github.com/".insteadOf "ssh://git@github.com/"
git config --global --add url."https://github.com/".insteadOf "git@github.com:"

$talkPath = "C:\work\out\.temp\spreed"

if (Test-Path $talkPath) {
    Remove-Item -Recurse -Force $talkPath
}

New-Item -ItemType Directory -Force "C:\work\out\.temp" | Out-Null

git clone --branch=v25.0.0 --depth=1 -- https://github.com/nextcloud/spreed $talkPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

npm ci
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

npm ci --prefix=$talkPath
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$env:TALK_PATH = $talkPath

npm run build:windows
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

npm run package:windows:x64:msi
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$msi = Get-ChildItem "C:\work\out" -Recurse -Filter *.msi
if (-not $msi) { throw "MSI was not generated." }
$msi | Select-Object FullName, Length
