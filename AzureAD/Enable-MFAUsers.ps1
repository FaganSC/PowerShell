if (Get-Module -ListAvailable -Name MSOnline) { 
    Import-Module MSOnline
} else { 
    Install-Module -Name MSOnline
}
Connect-MsolService

$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)

Import-Csv -Path .\SampleDataFiles\MFAUsers.csv -Header "UserPrincipalName" | ForEach-Object {
    Write-Host -NoNewline "Enabling MFA for $($_.UserPrincipalName)"
    Try{
        Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
        Write-Host -f "Green" " .....Done!"
    } Catch {
        Write-Host -f "Red" " .....Error!"
    }
}


