Function Get-DataSize{
    <#
    .SYNOPSIS
    Converts data size to legible output

    .DESCRIPTION
    Convert raw file, folder, drive or RAM number sizes to legible string values 
    with two decimal places and highest exceeded denomination up to a pebibyte.
    Output format: NNN.NN BB
    Input: 1024
    Output: 1.00 KB
    Do any necessary math before calling function! Function converts number to string.

    .PARAMETER DataSize
    Numeric value of raw size to convert

    .EXAMPLE
    Get-DataSize -DataSize <numeric value>

    .EXAMPLE
    <numeric value> | Get-DataSize

    .INPUTS
    Integer

    .OUTPUTS
    String

    .NOTES
    Author: Stan Crider
    Date: 4Dec2017
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What is the number you would like to convert?')]
        [double]$DataSize
    )
    Process{
        Switch($DataSize){
            {$_ -lt 1KB}{
                $DataValue =  "$DataSize B"
            }
            {($_ -ge 1KB) -and ($_ -lt 1MB)}{
                $DataValue = "{0:N2}" -f ($DataSize/1KB) + " KiB"
            }
            {($_ -ge 1MB) -and ($_ -lt 1GB)}{
                $DataValue = "{0:N2}" -f ($DataSize/1MB) + " MiB"
            }
            {($_ -ge 1GB) -and ($_ -lt 1TB)}{
                $DataValue = "{0:N2}" -f ($DataSize/1GB) + " GiB"
            }
            {($_ -ge 1TB) -and ($_ -lt 1PB)}{
                $DataValue = "{0:N2}" -f ($DataSize/1TB) + " TiB"
            }
            Default{
                $DataValue = "{0:N2}" -f ($DataSize/1PB) + " PiB"
            }
        }
        $DataValue
    }
}
