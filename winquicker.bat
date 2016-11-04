cd ..
IF EXIST "%PROGRAMFILES(x86)%" (GOTO 64BIT) ELSE (GOTO 32BIT)

:64BIT
fteqwsv64.exe -game cspree +exec ports/port1.cfg
GOTO END

:32BIT
fteqwsv32.exe -game cspree +exec ports/port1.cfg
GOTO END

:END
