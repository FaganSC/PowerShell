param (
    [switch] $IsEnabled,
    [switch] $IsDisabled
)
if (-not $IsEnabled -and -not $IsDisabled) { $All = $true } else { $All = $false }
if (Get-Module -ListAvailable -Name MSOnline) { Import-Module MSOnline } else { Install-Module -Name MSOnline }
#Connect-MsolService
$output = @()
Get-MsolUser | Where-Object { $_.IsLicensed } | ForEach-Object {
    if (($IsEnabled -and $_.StrongAuthenticationRequirements[0].State) -or
        ($IsDisabled -and -not $_.StrongAuthenticationRequirements[0].State) -or
        ($All)) {
        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $_.UserPrincipalName
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $_.DisplayName
        $obj | Add-Member -MemberType NoteProperty -Name isLicensed -Value $_.isLicensed
        $obj | Add-Member -MemberType NoteProperty -Name MFAStatus -Value (& { If ($_.StrongAuthenticationRequirements[0].State) { $_.StrongAuthenticationRequirements[0].State } Else { "Disable" } })
        $output += $obj
    }
}
$output | Format-Table -AutoSize
