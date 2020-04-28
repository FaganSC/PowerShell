if (Get-Module -ListAvailable -Name AzureAD) { 
    Import-Module AzureAD
} else { 
    Install-Module -Name AzureAD 
}
Connect-AzureAD

$output = @()
Get-AzureADDirectoryRole | Foreach-Object {
    $roleName = $_.DisplayName
    $role = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq $roleName }
    $roleMember = Get-AzureADDirectoryRoleMember -ObjectId $role.ObjectId 
    if ($roleMember.count -gt 0){
        if ($roleMember[0].UserPrincipalName){
            $roleMember | Get-AzureADUser | Foreach-Object {
                $obj = New-Object -TypeName psobject
                $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $_.DisplayName
                $obj | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $_.UserPrincipalName
                $obj | Add-Member -MemberType NoteProperty -Name AzureADDirectoryRole -Value $roleName
                $obj | Add-Member -MemberType NoteProperty -Name Type -Value "User"
                $output += $obj
            }
        }
    }
}
$output

