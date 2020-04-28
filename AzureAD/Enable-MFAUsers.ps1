if (Get-Module -ListAvailable -Name MSOnline) { 
    Import-Module MSOnline
} else { 
    Install-Module -Name MSOnline
}
Connect-MsolService
Set-Location $PSScriptRoot
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enforced"
$sta = @($st)

Import-Csv -Path .\..\DataFiles\MFAUsers.csv -Header "UserPrincipalName" | ForEach-Object {
    Write-Host -NoNewline "Enabling MFA for $($_.UserPrincipalName)"
    Try{
        Set-MsolUser -UserPrincipalName $_.UserPrincipalName -StrongAuthenticationRequirements $sta -PasswordNeverExpires $true
        Write-Host -f "Green" " .....Done!"
    } Catch {
        Write-Host -f "Red" " .....Error!"
    }
}


