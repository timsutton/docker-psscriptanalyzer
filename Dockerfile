FROM mcr.microsoft.com/powershell:6.2.2-debian-stretch-slim

LABEL maintainer="Tim Sutton"

RUN ["/usr/bin/pwsh", "-c", "Install-Module -Name PSScriptAnalyzer -Force"]
