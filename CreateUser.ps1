Import-Module ActiveDirectory

$SMTPServer = "smtp.gmail.com"
$SMTPUsername = "helpdesk@domain.net"
$SMTPPassword = ConvertTo-SecureString "passwordhere" -AsPlainText -Force
$EmailCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SMTPUsername,$SMTPPassword
$MailFrom = "Companyname IT <helpdesk@domain.com>"
$MailSubject = "Account Has Been Created"
$MailBody = "Hello, the user $givenname $surname has been created. Email Address and Login: $upn Password: $Password"

$reseller = "Company Name"
$givenname = Read-Host "Given Name (firstname)"
$surname = Read-Host "Surname"
$upn = Read-Host "UPN (full email address)"
$description = Read-Host "Ticket Number Here"
$password = Read-Host "Password"

$hostingdn = [string]"OU=Companies,DC=domain,DC=com"
$hostingdomain = [string]"domain.com"

#the following objects create a random samaccountname based on users name and some random numbers - this is usually best used when naming conventions exceed 20 characters.
$rand = New-Object System.Random
$uid = $rand.next(100,999)

$index = $upn.IndexOf("@")
$upnsuffix = $upn.SubString($index+1)
$upnprefix = $upn.SubString(0,$index)
$name = $givenname + " " + $surname

$sam = $upnprefix.substring(0, [System.Math]::Min(7, $upnprefix.Length)) + $uid
   
New-ADUser -SamAccountName $sam -DisplayName $name -GivenName $givenname -Surname $surname -UserPrincipalName $upn -Name $name -Description $description -EmailAddress $upn -AccountPassword (ConvertTo-SecureString "$password" -AsPlainText -Force) -ChangePasswordAtLogon $true -Enabled $true -path "OU=Users,OU=SubCompany,OU=Companies,DC=Domain,DC=com"

Write-Host "***************************"
Write-Host "User created successfully"
Write-Host "***************************"

Send-MailMessage -From $MailFrom -To helpdesk.team@domain.com -Subject $MailSubject -Body $MailBody -BodyAsHtml -SmtpServer $SMTPServer -UseSsl -Credential $EmailCredential  -Encoding UTF8