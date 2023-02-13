Function Get-ADDomainFQDN{
    <#
    .SYNOPSIS
    Retrieves domain name from AD distinguished name and converts to FQDN

    .DESCRIPTION
    For use when it is necessary to access different domains in the same script.
    Input: OU=Test,OU=Computers,DC=acme,DC=com
    Output: acme.com

    .PARAMETER ADObjectDistinguishedName
    An Active Directory object in distinguished name format; example: OU=Test,OU=Computers,DC=acme,DC=com

    .EXAMPLE
    Get-ADDomainFQDN -ADObjectDistinguishedName 'OU=Test,OU=Computers,DC=acme,DC=com'

    .EXAMPLE
    'OU=Test,OU=Computers,DC=resource,DC=acme,DC=com','OU=Test,OU=Computers,DC=development,DC=acme,DC=com' | Get-ADDomainFQDN

    .INPUTS
    String

    .OUTPUTS
    String

    .NOTES
    Author: Stan Crider
    Date: 13Feb2023
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'What is the distinguished name of the AD object you would like the fully qualified domain name for?')]

        [string]
        $ADObjectDistinguishedName
    )

    Process{
        $FQDNString = @()
        $FQDNOutput = @()
        $DCElements = $null

        $FQDNString = $ADObjectDistinguishedName -split '\,'
        ForEach($FQDNElement in $FQDNString){
            If($FQDNElement -match 'DC='){
                $DCElements = $FQDNElement -split '='
                $FQDNOutput += $DCElements[1]
            }
        }
        $FQDNOutput -join '.'
    }
}
