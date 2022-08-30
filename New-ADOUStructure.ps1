Function New-ADOUStructure {
    <#
    .SYNOPSIS
    Checks existence of specified Organizational Unit (OU) tree and creates if necessary. Can
    create multilayer OU structure.

    .DESCRIPTION
    For creating multiple embedded OU layers
    Input: OU=TestOU3,OU=TestOU2,OU=TestOU1,OU=ParentTest,DC=acme,DC=com
    Output: A string variable with any error messages or successful creations will be output; message 
            will not appear if no OU creation attempt is made.
    Result: Creates Active Directory OU OU=TestOU3,OU=TestOU2,OU=TestOU1,OU=ParentTest,DC=acme,DC=com

    .PARAMETER OUDistinguishedName
    An Active Directory distinguished name of an OU to create

    .EXAMPLE
    New-ADOU-Structure -OUDistinguishedName "OU=TestOU2,OU=TestOU1,OU=ParentTest,DC=acme,DC=com"

    .INPUTS
    String

    .OUTPUTS
    Creation of Active Directory OU object(s)
    String message of results including error messages

    .NOTES
    Author: Stan Crider
    Date:   8Aug2022
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,
        HelpMessage='What is the distinguished name of the Active Directory Organization Unit you would like to create?')]

        [string]
        $OUDistinguishedName
    )

    Process{
        # Validate distinguished name format
        If($OUDistinguishedName -match "^(?:(?:OU|DC)\=\w+,)*DC\=\w+$"){
            # Check existence of OU and create if OU doesn't exist
            $OUExists = [adsi]::Exists("LDAP://" + $OUDistinguishedName)
            If(!$OUExists){
                # Stage variable arrays
                $OUCreationOutputMessage = @()
                $DCNameArray = @()
                $OUSplitArray = @()
                $OUDistinguishedNameSplit = $OUDistinguishedName -split ","
                
                # Separate domain name from distinguished name
                ForEach($DN in $OUDistinguishedNameSplit){
                    If($DN -match "^DC="){
                        $DCNameArray += $DN
                    }
                }
                $IncrementSplit = $DCNameArray -join ","

                # Separate OU segment from distinguished name
                ForEach($OUSegment in $OUDistinguishedNameSplit){
                    If($OUSegment -match "^OU="){
                        $OUSplitArray += $OUSegment
                    }
                }

                # Create counter for number of OU splits in distinguished name
                $SplitCounter = (($OUSplitArray | Measure-Object).Count) -1

                # Begin building each OU layer in distinguished name starting with highest number in array (parent)
                Do{
                    $NewOUError = $null
                    If(!([adsi]::Exists("LDAP://" + ($OUSplitArray[$SplitCounter] + "," + $IncrementSplit)))){
                        $OUName = ($OUSplitArray[$SplitCounter]).TrimStart("OU=")
                        Try{
                            New-ADOrganizationalUnit -Name $OUName -Path $IncrementSplit -ErrorAction Stop
                        }
                        Catch{
                            $NewOUError = ("Creation of the OU " + ($OUSplitArray[$SplitCounter] + "," + $IncrementSplit) + " failed miserably.")
                        }
                        If($NewOUError){
                            $OUCreationOutputMessage += $NewOUError
                            $SplitCounter = (-1)
                        }
                    }
                    $IncrementSplit = ($OUSplitArray[$SplitCounter] + "," + $IncrementSplit)
                    $SplitCounter --
                }
                Until($SplitCounter -eq -1)
                $OUCreationOutputMessage += "The OU $OUDistinguishedName was successfully created."
                # Results message; remark out if no message is desired.
                $OUCreationOutputMessage
            }
        }
    }
}
