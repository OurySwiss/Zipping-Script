function GetUniqueFileName($filePath) {
    $fileDirectory = [System.IO.Path]::GetDirectoryName($filePath)
    $fileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $fileExtension = [System.IO.Path]::GetExtension($filePath)
    $counter = 1

    while (Test-Path $filePath) {
        $filePath = Join-Path $fileDirectory ($fileBaseName + "_" + $counter + $fileExtension)
        $counter++
    }

    return $filePath
}

# Frage nach dem Pfad zum Ordner, der komprimiert werden soll
Write-Host "Bitte geben Sie den Pfad zum Ordner ein, der komprimiert werden soll:"
$folderPath = Read-Host

# Überprüfe, ob der angegebene Pfad existiert
if (Test-Path $folderPath) {
    # Frage Speicherort der ZIP-Datei
    Write-Host "Bitte geben Sie den Pfad zum Speicherort der ZIP-Datei ein:"
    $destinationPath = Read-Host

    # Überprüfen Sie, ob der angegebene Speicherort existiert
    if (Test-Path $destinationPath) {
        # Erstellen Sie den Namen der ZIP-Datei basierend auf dem Ordnernamen
        $zipFileName = [System.IO.Path]::GetFileNameWithoutExtension($folderPath) + ".zip"
        $zipFilePath = Join-Path $destinationPath $zipFileName

        # Überprüfen, ob eine Datei mit demselben Namen bereits existiert
        if (Test-Path $zipFilePath) {
            Write-Host "Eine Datei mit demselben Namen existiert bereits. Möchten Sie die Datei umbenennen? (j/n)"
            $userInput = Read-Host

            if ($userInput -eq "j" -or $userInput -eq "J") {
                $zipFilePath = GetUniqueFileName($zipFilePath)
            }
            else {
                Write-Host "Vorgang abgebrochen."
                return
            }
        }

        # Komprimiere den Ordner in eine ZIP-Datei
        Compress-Archive -Path $folderPath -DestinationPath $zipFilePath
        Write-Host "Ordner wurde erfolgreich komprimiert und als $zipFilePath gespeichert."

        # Frage nach der E-Mail-Adresse des Benutzers
        Write-Host "Bitte geben Sie Ihre E-Mail-Adresse ein:"
        $userEmail = Read-Host

        #E-Mail-Adresse und App-Passwort
        $yourEmail = "yannick.smurft@gmail.com"
        $yourPassword = "gfec fbri qcni bybi"

        # Senden der Bestätigungsnachricht per E-Mail
        $subject = "Bestaetigung: Ordner wurde erfolgreich komprimiert"
        $body = "Der Ordner '$folderPath' wurde erfolgreich komprimiert und als '$zipFilePath' gespeichert."

        $securePassword = ConvertTo-SecureString $yourPassword -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $yourEmail, $securePassword

        Send-MailMessage -From $yourEmail -To $userEmail -Subject $subject -Body $body -SmtpServer "smtp.gmail.com" -Port 587 -Credential $credential -UseSsl

        Write-Host "Bestätigungsnachricht wurde erfolgreich an $userEmail gesendet."
    }
    else {
        # Wenn der angegebene Speicherort nicht existiert = Fehlermeldung
        Write-Host "Der angegebene Speicherort ist ungültig oder existiert nicht. Bitte überprüfen Sie den Pfad und versuchen Sie es erneut."
    }
}
else {
    # Wenn der angegebene Pfad nicht existiert = Fehlermeldung
    Write-Host "Der angegebene Pfad ist ungültig oder existiert nicht. Bitte überprüfen Sie den Pfad und versuchen Sie es erneut."
}
