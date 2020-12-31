#!/usr/bin/env bash
curl -o dotnet-sdk-5.0.102-win-x64.exe \
    -z dotnet-sdk-5.0.102-win-x64.exe \
    https://download.visualstudio.microsoft.com/download/pr/75483251-b77a-41a9-9ea2-05fb1668e148/2c27ea12ec2c93434c447f4009f2c2d2/dotnet-sdk-5.0.102-win-x64.exe
curl -o windowsdesktop-runtime-3.1.11-win-x64.exe \
    -z windowsdesktop-runtime-3.1.11-win-x64.exe \
    https://download.visualstudio.microsoft.com/download/pr/3f1cc4f7-0c1a-48ca-9551-a8447fa55892/ed9809822448f55b649858920afb35cb/windowsdesktop-runtime-3.1.11-win-x64.exe
sha256sum --check <<EOF
6443ce718208584497d4c7958ddbfb8cfec11c3b21b95b5d0a75c7c9649e9056  dotnet-sdk-5.0.102-win-x64.exe
07e39daa367feb89139fbadbd56b820f27f691a0441a077a5aca423339109ffd  windowsdesktop-runtime-3.1.11-win-x64.exe
EOF
if [ -f dotnet-sdk-5.0.102-win-x64.exe ]; then
    wine dotnet-sdk-5.0.102-win-x64.exe /install /quiet
fi
if [ -f windowsdesktop-runtime-3.1.11-win-x64.exe ]; then
    wine windowsdesktop-runtime-3.1.11-win-x64.exe /install /quiet
fi
