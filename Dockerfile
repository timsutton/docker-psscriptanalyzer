FROM mcr.microsoft.com/powershell:6.2.3-debian-stretch-slim

LABEL maintainer="Tim Sutton"

COPY docker-build /tmp

RUN ["/usr/bin/pwsh", "-File", "/tmp/InstallPSScriptAnalyzer.ps1"]
