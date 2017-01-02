###############################################################################
# PS Script tox2                                                              #
###############################################################################
#
# Ein kleines Vorf�hrbeispiel wie man 7Zip und RAR bzw RAR5 Archive,
# mit den freien Archiv Cracker Tools von:
# http://www.crark.net/
# http://www.crark.net/crark-7zip.html
# in Sekunden schnelle pr�fen kann, ob ein PW n�tig ist 
# und falls ja k�nnen auch PW's getestet werden 
# (Dictonary Check via 'password.def' File) 
#
# Der Vorteil der �berpfr�ung auf diese Weise ist. 
# Ein Archiv oder Teilarchiv kann in sehr geringer Zeit getestet
# werden im Vergleich zu den 7zip oder WinRar Archiv Test Methoden.
#
# Anmerkung die 'crark-7z.exe' ist neu und hat zb. keinen Multi Archiv Support
# Wohin gegen die 'cRARk.exe' f�r RAR Archive dies sehr wohl unterst�tzt.
###############################################################################
#
# Ich wollte das ganze zun�chst in C++ machen, aber es wurde mir zu Umst�ndlich
# da es auch hier in Powershell einfacher geht und ich irgendwo gelesen habe, 
# das man diesen Code fast 1:1 in .net weiter verwenden kann. 
#
#

## Hier Sind die Testarchive
$7zipfiles = get-childitem ($PSScriptRoot + "\7ZIP") 
$rarfiles  = get-childitem ($PSScriptRoot + "\RAR")
$rar5files = get-childitem ($PSScriptRoot + "\RAR5")

## Leider gibt es von diesem Software Author kein Tool f�r Zip Files.
## Aber daf�r habe ich .Net Libs f�r Zip Archive gesehen welche �nhliche Funktionen zur Verf�gung stellen sollten.

# $zipfiles  = get-childitem ($PSScriptRoot + "\ZIP") 

$7zipcrack = $PSScriptRoot + "\crark-7z.exe"
$rarcrack  = $PSScriptRoot + "\cRARk.exe"

## Kann auch weggelassen werden, sollte man sogar, ist nur vordefiniert um ein wenig mehr Performance herauszuholen.
$7zipfunc  = "-f355"
$rarfunc   = "-f244"
$rar5func  = "-f355"

<# So oder einfach als Parameter unten l�schen.
$7zipfunc  = ""
$rarfunc   = ""
$rar5func  = ""
#>



foreach ($file in $7zipfiles){
   
    Write-Host $file.Name `t -NoNewline
    
    ## Hier wird der Cracker f�r 7zip Archiv ausgef�hrt.
    ## Je Nach IF bedingung kann man hier ExitCodes setzten wenn man das f�r 1 Archiv macht 
    ## bzw. wie hier eine kurze Meldung an die Konsole f�r mehrere Archive.  

    ## Anmerkung: Die 'crark-7z.exe' stellt auch Exit Codes zur Verf�gung diese sind aber 
    ## nicht vom Author der Software dokumentiert. Deshalb hier das Output Scanning.
    $stdout= &$7zipcrack $7zipfunc $file.fullname 2>&1

    if( (echo $stdout | select-string -pattern 'No encrypted' -Quiet ) -eq "True") 
    {
        write-host " NO PW" -foreground "yellow" 
    }
    if( (echo $stdout | select-string -pattern 'CRC OK' -Quiet ) -eq "True") 
    {
        
        $line = echo $stdout  | select-string -pattern 'CRC OK' -CaseSensitive
        $splitline = $line.tostring().split(" ")
        write-host " " $splitline[0] -NoNewline
        write-host " Correct PW" -foreground "green"  
    }

    if( (echo $stdout | select-string -pattern 'Password not found' -Quiet ) -eq "True") 
    {
        write-host " Wrong PW" -foreground "red" 
    }
    
    if( (echo $stdout | select-string -pattern 'is not the' -Quiet ) -eq "True") 
    {
        write-host " invalid Archiv or not 1st Archivepart" -background "red" 
    }
}

Write-Host "########################"
foreach ($file in $rarfiles){

    Write-Host $file.Name `t -NoNewline

    ## Hier wird der Cracker f�r RAR Archiv ausgef�hrt.
    ## Je Nach IF bedingung kann man hier ExitCodes setzten wenn man das f�r 1 Archiv macht 
    ## bzw. wie hier eine kurze Meldung an die Konsole f�r mehrere Archive.  

    ## Anmerkung: Die 'cRARk.exe' stellt auch Exit Codes zur Verf�gung diese sind aber 
    ## nicht vom Author der Software dokumentiert. Deshalb hier das Output Scanning.
    ## Zudem ist leider dieser ExitCode bei 'NO PW', 'Correct PW' und 'Wrong PW' immer gleich.
    $stdout= &$rarcrack $rarfunc $file.fullname 

    if( (echo $stdout | select-string -pattern 'not encrypted' -Quiet ) -eq "True") 
    {
        write-host " NO PW" -foreground "yellow" 
    }

    if( (echo $stdout | select-string -pattern 'CRC OK' -Quiet ) -eq "True") 
    {
        $line = echo $stdout  | select-string -pattern 'CRC OK' -CaseSensitive
        $splitline = $line.tostring().split(" ")
        write-host " " $splitline[0] -NoNewline
        write-host " Correct PW" -foreground "green"  
    }

    if( (echo $stdout | select-string -pattern 'Password not found' -Quiet ) -eq "True") 
    {
        write-host " Wrong PW" -foreground "red" 
    }
   
    if( (echo $stdout | select-string -pattern 'is not RAR' -Quiet ) -eq "True") 
    {
        write-host " invalid Archiv" -background "red" 
    }
}


Write-Host "########################"
foreach ($file in $rar5files){

    Write-Host $file.Name `t -NoNewline

    ## Hier wird der Cracker f�r RAR5 Archiv ausgef�hrt. Sehr �nhlich zum oberen RAR Code. 
    ## Je Nach IF bedingung kann man hier ExitCodes setzten wenn man das f�r 1 Archiv macht 
    ## bzw. wie hier eine kurze Meldung an die Konsole f�r mehrere Archive.  

    ## Anmerkung: Die 'cRARk.exe' stellt auch Exit Codes zur Verf�gung diese sind aber 
    ## nicht vom Author der Software dokumentiert. Deshalb hier das Output Scanning.
    ## Zudem ist leider dieser ExitCode bei 'NO PW', 'Correct PW' und 'Wrong PW' immer gleich.
    $stdout= &$rarcrack $rar5func $file.fullname 

    if( (echo $stdout | select-string -pattern 'not encrypted' -Quiet ) -eq "True") 
    {
        write-host " NO PW" -foreground "yellow"  
    }

    if( (echo $stdout | select-string -pattern 'CRC OK' -Quiet ) -eq "True") 
    {
        $line = echo $stdout  | select-string -pattern 'CRC OK' -CaseSensitive
        $splitline = $line.tostring().split(" ")
        write-host " " $splitline[0] -NoNewline
        write-host " Correct PW" -foreground "green"  
    }

    if( (echo $stdout | select-string -pattern 'Password not found' -Quiet ) -eq "True") 
    { 
        write-host " Wrong PW" -foreground "red" 
    }
     
    if( (echo $stdout | select-string -pattern 'is not RAR' -Quiet ) -eq "True") 
    {
        write-host " invalid Archiv" -background "red" 
    }
}