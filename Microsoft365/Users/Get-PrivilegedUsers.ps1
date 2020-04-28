if (Get-Module -ListAvailable -Name AzureAD) { 
    Import-Module AzureAD
} else { 
    Install-Module -Name AzureAD 
}
Connect-AzureAD
Connect-MsolService

$output = @()
Get-AzureADDirectoryRole | Foreach-Object {
    $roleName = $_.DisplayName
    $role = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq $roleName }
    $roleMember = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId 
    if ($roleMember.count -gt 0){
        if ($roleMember[0].UserPrincipalName){
            $roleMember| Foreach-Object {
                $obj = New-Object -TypeName psobject
                $obj | Add-Member -MemberType NoteProperty -Name Type -Value $_.ObjectType
                $obj | Add-Member -MemberType NoteProperty -Name ADDirectoryRole -Value $roleName
                if ($_.UserPrincipalName){
                    $userMFA = Get-MsolUser -UserPrincipalName $_.UserPrincipalName
                    $obj | Add-Member -MemberType NoteProperty -Name User -Value "$($_.DisplayName) ($($_.UserPrincipalName))"
                } elseif ($_.ServicePrincipalType){
                    $obj | Add-Member -MemberType NoteProperty -Name User -Value "$($_.DisplayName) ($($_.UserPrincipalName))"
                    
                }
                if ($userMFA.StrongAuthenticationRequirements[0].State){
                    $obj | Add-Member -MemberType NoteProperty -Name MFA -Value $userMFA.StrongAuthenticationRequirements[0].State
                } else {
                    $obj | Add-Member -MemberType NoteProperty -Name MFA -Value "Disabled"
                }
                $output += $obj
            }
        }
    }
}
$output | Select-Object User, ADDirectoryRole, Type, MFA | Format-Table -AutoSize

