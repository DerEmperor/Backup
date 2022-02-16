@ECHO OFF
CLS
chcp 1252>nul
TITLE Datensicherung

::******************************************************************************
:: Hier Zielpfad, Quellen & Namen eingeben!
:: Wichtig: Der Pfad darf keine Leerzeichen enthalten!

Set ziel=\\SERVER\Backup_Desktop\2022

set quellen[0]="C:\Users\%USERNAME%\AppData\Roaming\Mozilla\Firefox\Profiles" 
set quellen[1]="C:\Users\%USERNAME%\AppData\Roaming\Thunderbird\Profiles" 
set quellen[2]="C:\Users\%USERNAME%\Pictures" 
set quellen[3]="C:\Users\%USERNAME%\Videos"
set quellen[4]="C:\Users\%USERNAME%\Documents" 
set quellen[5]="C:\Users\%USERNAME%\Music" 
set quellen[6]="C:\Users\%USERNAME%\Downloads" 


set namen[0]=Firefox_Profil
set namen[1]=Thunderbird_Profil
set namen[2]=Bilder
set namen[3]=Videos
set namen[4]=Dokumente
set namen[5]=Musik
set namen[6]=Downloads


::*******************************************************************************

:: https://docs.microsoft.com/de-de/windows-server/administration/windows-commands/robocopy

:: robocopy <Quelle> <Ziel> /MIR /R:10 /W:5
::  /E     					:: Kopiert Unterverzeichnisse, einschließlich leerer Unterverzeichnisse.
::  /PURGE 					:: Löscht Zieldateien/-verzeichnisse, die in der Quelle nicht mehr vorhanden sind.
::  /MIR   					:: Spiegelt eine Verzeichnisstruktur(Entspricht "/E" mit "/PURGE").
::  /R:100 					:: Wiederholungen 
::  /W:3   					:: Zeit zwischen Wiederholungen
::	/MT[:n]					:: Erstellt multithreadkopien mit n Threads. n muss eine ganze Zahl zwischen 1 und 128 sein.
::								Der Standardwert für n ist 8.
::								Um eine bessere Leistung zu erzielen, leiten Sie die Ausgabe mit der Option /Log um
::								Der /MT -Parameter kann nicht mit den Parametern /IPG und /EFSRAW verwendet werden.
::	/xd <directory>[ ...] 	:: Schließt Verzeichnisse aus, die den angegebenen Namen und Pfaden entsprechen.
::	/sl 					:: Verwenden Sie symbolische Verknüpfungen nicht, und erstellen Sie stattdessen eine Kopie der Verknüpfung.

::*******************************************************************************


:EchoTitel
ECHO ++++++++++++++++++++++
ECHO +++ DATENSICHERUNG +++
ECHO ++++++++++++++++++++++
ECHO.
ECHO.

:CheckDest
ECHO Ziel checken.
ECHO.
ECHO Ihr Zielordner ist: %ziel%
CHOICE /M "Stimmt das Verzeichnis? Ja: J  Nein: N"
if errorlevel 2 GOTO ERREND
IF not exist %ziel% GOTO ERRDEST

:SICHERUNG
ECHO.
ECHO Zum Starten der Synchronisation eine beliebige Taste druecken.
COLOR 9F
PAUSE > NUL
ECHO Bitte alle Programme und Fenster schliessen, die das Programm beeinflussen. Zum Fortfahren eine beliebige Taste druecken.
PAUSE > NUL
COLOR 0F
ECHO SYNCHRONISIERUNG STARTEN
ECHO.


set "i=0" 
:LOOP
if not defined quellen[%i%] goto :endLoop
::if not %i%==4 goto :Skip
call set quelle=%%quellen[%i%]%%
call set name=%%namen[%i%]%%

ECHO %name%
ECHO.
IF not exist %quelle% ECHO Das Quellverzeichnis %quelle% existiert nicht & GOTO ERREND
ROBOCOPY %quelle% "%ziel%\%name%" /MIR /R:10 /W:5 /sl /MT:4 /xd "D:\Unwichtig\Auslagerung SSD" "C:\Users\Tobias\Music\Spotify"
if %ERRORLEVEL% EQU 8 COLOR 4F & ECHO Fehler: Mindestend eine Datei konnte nicht kopiert bzw. geloescht werden Fehlercode: %ERRORLEVEL% & CHOICE /M "Trotzdem fortfahren?" & if errorlevel 2 (goto ERREND) else (COLOR 0F)
if %ERRORLEVEL% EQU 0 if not %ERRORLEVEL% EQU 1 ECHO Seit dem letzten Backup hat sich nichts geaendert.
ECHO "%name% Fertig"
ECHO.
:Skip
set /a "i+=1"
GOTO :LOOP

:endLoop

:END
ECHO.
ECHO.
COLOR 2F
ECHO Sicherung beendet
ECHO Eine beliebige Taste druecken zum Schliessen
PAUSE > NUL
EXIT

:ERRDEST
ECHO.
ECHO Der angegebene Pfad existiert nicht!
CHOICE /M "Soll der Pfad ertellt werden? Ja: J  Nein:N"
if errorlevel 2 GOTO ERREND
mkdir %ziel%
GOTO SICHERUNG

:ERREND
COLOR 4F
ECHO.
ECHO Das Programm wurde abgebrochen
ECHO Eine beliebige Taste druecken zum Schliessen
PAUSE > NUL
EXIT