Function Get-ADDomainDistinguishedName{
    <#
    .SYNOPSIS
    Converts fully qualified domain name into Active Directory DC format

    .DESCRIPTION
    For use when both accessing Active Directory root structure and
    working with a domain fully qualified domain name is necessary.
    Especially useful when using an entire domain as a search base.
    Input: resource.acme.com
    Output: DC=resource,DC=acme,DC=com

    .PARAMETER DomainFQDN 
    A fully qualified domain name in the DOT format; example: resource.acme.com

    .EXAMPLE
    Get-ADDomainDistinguishedName -DomainFQDN 'resource.acme.com'

    .EXAMPLE
    'resource.acme.com','development.acme.com' | Get-ADDomainDistinguishedName

    .INPUTS
    String

    .OUTPUTS
    String

    .NOTES
    Author: Stan Crider
    Date:   5May2022
    Crap:   Yes, I wrote a function for 6 lines of code. Sue me.
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What is the root fully qualified domain name you would like to convert?')]

        [string]
        $DomainFQDN
    )

    Process{
        $DomainDistinguishedName = @()
        $DomainNameSplit = $DomainFQDN -split '\.'
        ForEach($DC in $DomainNameSplit){
            $DomainDistinguishedName += "DC=$DC"
        }
        $DomainDistinguishedName -join ","
    }
}
