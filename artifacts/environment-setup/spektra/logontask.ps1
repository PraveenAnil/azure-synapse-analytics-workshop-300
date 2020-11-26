Start-Transcript -Path C:\WindowsAzure\Logs\logontasklogs.txt -Append
cd 'C:\LabFiles\synapse-ws-L400\artifacts\environment-setup\automation'

./01-environment-setup.ps1
./03-environment-validate.ps1

Unregister-ScheduledTask -TaskName "Setup" -Confirm:$false
Stop-Transcript
