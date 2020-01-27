Import-Module ActiveDirectory

function Pass {
function Scramble-String([string]$inputString){
$characterArray = $inputString.ToCharArray()
$scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length
$outputString = -join $scrambledStringArray
return $outputString
}
function Get-RandomCharacters($length, $characters) {
$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
$private:ofs=""
return [String]$characters[$random]
}
$password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnprstuvwxyz'
$password += Get-RandomCharacters -length 3 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
$password += Get-RandomCharacters -length 3 -characters '123456789'
$password += Get-RandomCharacters -length 1 -characters '!$%&?@#'
$password = Scramble-String $password
return $password
}

# ===============
# CREATE ACCOUNT:

Write-Host "--------------------------------------------------"
Write-Host "HELLO! DO YOU WANT CREATE (1) OR DELETE (2) ACCOUNT?"
$YON = Read-Host " "
If ($YON -eq '1') { 
Write-Host " "
Write-Host "PROVIDE USER'S FIRST NAME IN ENGLISH"
Write-Host "Example: Bear"
$givenName = Read-Host " "
$num=$givenName.length #count for 

Write-Host " "
Write-Host "PROVIDE USER'S LAST NAME IN ENGLISH"
Write-Host "Example: Grylls"
$surName = Read-Host " "
$name = $givenName + " " + $surName

Write-Host " "
Write-Host "PROVIDE USER'S FIRST AND LAST NAME IN RUSSIAN"
Write-Host "Example: Беар Гриллз"
[string]$info = Read-Host " "

$samAccName = ($surName + "_" + $givenName.Substring(0,1)).ToLower()
$mail= ($givenName.Chars(0) + "." + $surName).ToLower()

#=============
#COUNT NUMBER SIMILAR USERS
$l=(Get-ADUser -SearchBase "OU=user objects, DC=belitgroup, DC=lan" -Filter {SamAccountName -eq $samAccName}).count

foreach ($i in 1..$num){
if ($l -eq 0) 
{
$samAccName = ($surName + "_" + $givenName.Substring(0,$i)).ToLower()
break}

else {
if ($i=$num){ 
Write-Error "ERROR! CAN'T CREATE USER BECAUSE USER WITH THE SAME NAME EXIST!"
exit
} 
else {
$samAccName = ($surName + "_" + $givenName.Substring(0,$i+1)).ToLower()
$l=(Get-ADUser -SearchBase "OU=user objects, DC=belitgroup, DC=lan" -Filter {SamAccountName -eq $samAccName}).count
}
}
}

Write-Host " "
Write-Host "PROVIDE USER'S SEX, MALE (M) OR FEMALE (F)"
$YON = Read-Host " "
If ($YON -eq 'M') { $sex="male" }
If ($YON -eq 'F') { $sex="female" }

Write-Host " "
Write-Host "CREATE THE DEFAULT (1) OR RANDOM (2) PASSWORD FOR USER?"
$YON = Read-Host " "
$passCPAL = $false #ChangePasswordAtLogon
$passPNE = $true #PasswordNeverExpires
If ($YON -eq "1") {
    $password = "123qweASDzxc"
    $passCPAL = $true 
    $passPNE = $false 
}
else {
$password =Pass
}

Write-Host " "
Write-Host "PROVIDE THE OU'S DISTINGUISHE DNAME"
Write-Host "Example: OU=belitsoft"
Write-Host " "
$ous = Get-ADOrganizationalUnit -SearchBase "ou=user objects,dc=belitgroup,dc=lan" -Filter * -SearchScope OneLevel
foreach ($ou in $ous) {
    Write-Host " " $ou.DistinguishedName.Replace(",OU=user objects,DC=belitgroup,DC=lan", "")
    $subOus = Get-ADOrganizationalUnit -SearchBase $ou.distinguishedName -Filter * -SearchScope OneLevel
    if ($subOus) {
        foreach ($subOu in $subOus) {
            Write-Host "    " $subOu.DistinguishedName.Replace(",OU=user objects,DC=belitgroup,DC=lan", "")
        }
    }
}

$orgUnit = Read-Host " "
Write-Host " "
$orgUnit = $orgUnit + ",ou=user objects,dc=belitgroup,dc=lan"

Write-Host "PROVIDE USER'S MANAGER ACCOUNT"
Write-Host "Example: ivanov_i"
$manager = Read-Host " "

Write-Host " "
Write-Host "PROVIDE USER'S LOCATION"
Write-Host "Example: 11A-WP13"
$office = Read-Host " "

Write-Host " "

Write-Host "PROVIDE USER'S JOB"
Write-Host "Example: QA manual"
$jobTitle = Read-Host " "

$UPN = $samAccName + "@belitgroup.lan"
if ($jobTitle -like "*-*") {
    $displayName = $name
} else {
    $displayName = $name
}
$dept = (Get-ADOrganizationalUnit $orgUnit -Properties displayName).displayName

$encrPassword = ConvertTo-SecureString $password -AsPlainText -Force
Write-Host " "
Write-Host "FINAL CHECK: "
Write-Host "User: ", $name
Write-Host "Login: ", $samAccName
Write-Host "Password: ", $Password
Write-Host ""
write-host 'ALL IS OK? CREATE? (Y/N)'
$YON = Read-Host " "
If ($YON -ne 'Y') {exit}

try{
New-ADUser `
-GivenName $givenName `
-Surname $surname `
-OtherAttributes @{info=$info} <# $name in russian #> `
-Name $name <# composed of givenName + surname #> `
-AccountPassword $encrPassword  <# if blank specified -> use 123qweASDzxc, else -> use $password #> `
-ChangePasswordAtLogon $passCPAL <# if password is set to default -> $true, else -> $false #> `
-PasswordNeverExpires $passPNE <# if blank specified -> $false, else -> $true #> `
-SamAccountName $samAccName `
-UserPrincipalName $UPN `
-Path $orgUnit <# "belitgroup.lan/user objects/" + target OU #> `
-Department $dept <# obtained from OU.displayName #> `
-DisplayName $displayname <# $name #> `
-Manager $manager `
-Office $office `
-Title $jobTitle `
-Enabled $true `
-PassThru `
| Set-ADObject -ProtectedFromAccidentalDeletion $true
}
catch {
Write-Host "ERROR! CAN'T CREATE USER BECAUSE USER WITH THE SAME NAME EXIST!"
exit}

$maildept=(Get-ADOrganizationalUnit $orgUnit -Properties Name).Name
$ougroup= "group_"+(Get-ADOrganizationalUnit $orgUnit -Properties Name).Name #CHANGE "OU=" IN "group_" AFTER NAME
Write-Host " "
Write-Host "MAKE USER A MEMBER OF HIS GROUP? (Y/N)"
$ougroup
$YON = Read-Host " "
If ($YON -eq 'Y') {
Add-ADGroupMember $ougroup $samAccName}

Write-Host " "
Write-Host "CREATE USER'S MAILBOX? (Y/N)"
$YON = Read-Host " "
Write-Host ""
Write-Host "User: ", $name
Write-Host "Login: ", $samAccName
Write-Host "Password: ", $Password
If ($YON -eq 'Y') {
python ./create_new_user_yandex.py $givenname $surName $mail $maildept.toupper() $sex #CREATE USERS MAIL
Set-ADUser  $samAccName -EmailAddress $mail"@belitsoft.com" #ADD MAIL TO USER ACCOUNT
}
Write-Host ""
Write-Host "Пожалуйста, проверяйте написание логина и пароля. В случае пяти попыток неправильного ввода аккаунт будет заблокирован на 30 минут."
Write-Host "Владельцам ноутбуков перед входом в систему необходимо подключиться к Wi-Fi."
Write-Host "Для подключения к Wi-Fi используйте SSID Belitsoft и Login и Password, указанные выше."
Write-Host "Для использования почты необходимо перейти на http://mail.belitsoft.com и произвести регистрацию почтового аккаунта."
Write-Host "Ознакомиться с инструкциями по настройке почты, VPN, принтеров можно и нужно на нашем портале https://wiki.yandex.ru"
}

# ===============
# DELETE ACCOUNT:

If ($YON -eq '2') { 
$YON = 'N'
Do
{
$userObject = 'False'
$usersComputersBase = "OU=user objects,DC=belitgroup,DC=lan"
$archiveBase = "OU=user objects - archived,DC=belitgroup,DC=lan"
$userGroupsLeft = "CN=SP_ProjectServer-Users,OU=sp,OU=internal core,DC=belitgroup,DC=lan"
$userComputersGroupsLeft = "CN=Domain Computers,OU=Groups,OU=Others System Accounts,DC=belitgroup,DC=lan"

$OU = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=user objects,DC=belitgroup,DC=lan" | Where-Object {$_.DistinguishedName -ne 'OU=user objects,DC=belitgroup,DC=lan'} | Select-Object -Property Name | Sort-object -Property Name
[int]$a=1
Write-Host " "
foreach ($OUname in $OU) { #SEARCH ALL OU'S
$OUWriteName = $OUname.Name
Write-Host "$a - $OUWriteName"
$a=$a+1
}
Write-Host " "
$Num = Read-Host "SELECT NUMBER OU"
$userOUnameFull = $OU[$Num-1]
$userOUname = $userOUnameFull.name
$U = Get-ADUser -SearchBase "OU=$userOUname,OU=user objects,DC=belitgroup,DC=lan" -LDAPFilter '(&(objectCategory=person)(objectClass=user))' | Select-Object -Property SamAccountName,Name,UserPrincipalName | Sort-object -Property SamAccountName

$a=1
Write-Host " "
foreach ($Uname in $U) {
$UserWriteName = $Uname.SamAccountName
$UserWriteName2 = $Uname.Name
$UserWriteName3 = $Uname.UserPrincipalName
Write-Host "$a - $UserWriteName - $UserWriteName2 ($UserWriteName3)"
$a=$a+1
}
Write-Host " "
$Num = Read-Host "SELECT NUMBER"
$userInputFull = $U[$Num-1]
$userInput = $userInputFull.SamAccountName #USER SamAccountName
$userObject = (Get-ADUser -Identity $userInput  -Properties memberof)
$userDN = $userObject.DistinguishedName
If ($userObject  -ne 'False')
{

#REMOVE USER'S MAIL BLEAT
Write-Host " "
$findmail=(Get-ADUser -SearchBase "OU=user objects, DC=belitgroup, DC=lan" -Filter {SamAccountName -eq $userInput} -Properties mail).mail
if ($findmail -ne $NULL) {
write-host 'DO YOU WANT DISABLE USER MAILBOX? (Y/N)'
$findmail
$YON = Read-Host " "
If ($YON -eq 'Y'){
python disable_user_yandex.py $findmail.Replace("@belitsoft.com","")
}
}

#Processing users computers
Write-Host " "
write-host 'DO YOU WANT DISABLE USER COMPUTERS? (Y/N)'
$YON = Read-Host " "
If ($YON -eq 'Y')
{
Write-Host("Processing user computers:")
$userComputersObjects = (Get-ADComputer -searchbase $usersComputersBase -properties managedby,memberof -filter * | where {$_.ManagedBy -eq $userDN})
if ($userComputersObjects.Count -lt 1) {
    Write-Host("   No computers found")
}
else {
    Write-Host("   Disabling user computers:")
    foreach($computer in $userComputersObjects) {
        $userComputerDN = $computer.DistinguishedName

        Set-ADComputer -Identity $computer -Enabled $false
        Set-ADObject -Identity $computer.ObjectGUID -ProtectedFromAccidentalDeletion $false
        Move-ADObject -Identity $computer.ObjectGUID -targetpath $archiveBase
        Set-ADObject -Identity $computer.ObjectGUID -ProtectedFromAccidentalDeletion $true

        Write-Host("   " + $userComputerDN)
        $userComputersGroups = $computer.memberof
        if ($userComputersGroups.count -lt 1) {
            Write-Host("      No computer groups for removal")
        }
        else {
            Write-Host("      Removing computer groups:")
            foreach($group in $userComputersGroups) {
                if($group -ne $userComputersGroupsLeft) {
                    Remove-ADGroupMember -identity $group -Members $computer -Confirm:$false
                    Write-Host("      " + $group)
                }
                else {
                    Write-host("      Skipping: " + $group)
                }
            }
        }     
    }
}
}

#Processing users account
Write-Host " "
write-host 'DO YOU WANT REMOVE USER FROM ALL AD_GROUPS? (Y/N)'
$YON = Read-Host " "
If ($YON -eq 'Y')
{
Write-Host("Processing user account:")
$userGroups = $userObject.memberof
if ($userGroups.count -lt 1) {
    write-host("   No user groups for removal")
}
else {
    Write-Host("   Removing user groups:")
    foreach($group in $userGroups) {
        if($group -ne $userGroupsLeft) {
            Remove-ADGroupMember -identity $group -Members $userDN -Confirm:$false
            write-host("   " + $group)             
        }
        else {
            write-host("   Skipping: " + $group)
        }
    }
}
}
set-ADUser -Identity $userObject.ObjectGUID -Enabled $false
Set-ADobject -Identity $userObject.ObjectGUID -ProtectedFromAccidentalDeletion $false
Move-ADObject -Identity $userObject.ObjectGUID -targetpath $archiveBase
Set-ADObject -Identity $userObject.ObjectGUID -ProtectedFromAccidentalDeletion $true
}

#Return to start
Write-Host " "
write-host 'DO YOU WANT REMOVE ANOTHER USER? (Y/N)'
$YON = Read-Host " "
}
while ($YON -eq 'Y')
}