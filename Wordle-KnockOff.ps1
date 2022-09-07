<#
Author: Stan Crider
Date:   6 September 2022
Crap:   Just playing around to see if I can do it. And I really like Wordle.
Dictionary file used: http://www.math.sjsu.edu/~foster/dictionary.txt
#>

## Variables
# Dictionary file
$DictionaryFile = "C:\Temp\dictionary_file.txt"
# length of words to use (1 through 10)
[int32]$GameWordLength = 5
# maximum number of attempts
[int32]$Attempts = 6

## Functions
Function Compare-Words{
    <#
    .SYNOPSIS
    Compares 2 string values for matching letters

    .DESCRIPTION
    Compares 2 string values for matching letters and word length
    Input: this, that, 4
    Output: "th" match

    .PARAMETER FirstWord
    String value

    .PARAMETER SecondWord
    String value

    .PARAMETER WordLength
    Integer (positive number) to verify strings are the same length

    .EXAMPLE
    Compare-Words -FirstWord "this" -SecondWord "that" -WordLength 4

    .INPUTS
    String,String,Integer(positive)

    .OUTPUTS
    Matching letters

    .NOTES
    Author: Stan Crider
    Date:   6Sept2022
    Crap:   Compare 2 string values for matching letters
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,
        HelpMessage = 'What is the first word to compare?')]
        [String]$FirstWord,

        [Parameter(Mandatory,
        HelpMessage = 'What is the second word to compare?')]
        [String]$SecondWord,

        [Parameter(Mandatory,
        HelpMessage = 'What is the length of the words?')]
        [ValidateRange(1,10)]
        [Int32]$WordLength
    )

    [int]$CharacterCounter = 0
    $MatchWord = @()

    If(($FirstWord.Length -eq $WordLength) -and ($SecondWord.Length -eq $WordLength)){
        Do{
            # If letter is in correct location, capitalize letter
            If($FirstWord.Substring($CharacterCounter,1) -eq $SecondWord.Substring($CharacterCounter,1)){
                $MatchWord += ($SecondWord.Substring($CharacterCounter,1)).ToUpper()
            }
            # If letter is in the word, but not in correct location, set letter to lower case
            ElseIf($FirstWord.Contains($SecondWord.Substring($CharacterCounter,1))){
                $MatchWord += ($SecondWord.Substring($CharacterCounter,1)).ToLower()
            }
            # If letter is not in the word, replace with blank
            Else{
                $MatchWord += "_"
            }
            # Increment counter to next letter in word
            $CharacterCounter++
        }
        Until($CharacterCounter -eq $WordLength)

        $MatchWord -join ""
    }
}

## Script
If(Test-Path -Path $DictionaryFile){
    $DictionaryWordLength = Get-Content -Path $DictionaryFile | Where-Object{$_.length -eq $GameWordLength}

    If($DictionaryWordLength){
        $PlayGame = Read-Host -Prompt "Would you like to play a game? Type 'yes' to continue"
        If(($PlayGame -eq "yes") -or ($PlayGame -eq "y")){
            $TheWord = $DictionaryWordLength | Get-Random
            $AttemptCounter = 0
            $CompleteMatch = $false

            Write-Host "The word of the day is: $TheWord"
            Do{
                $AttemptCounter++
                Do{
                    $GuestGuess = Read-Host -Prompt "Enter your $GameWordLength-letter word guess for attempt $AttemptCounter"
                    If($GuestGuess.Length -ne $GameWordLength){
                        Write-Warning "The word $GuestGuess does not equal $GameWordLength characters. Try again."
                    }
                    If($DictionaryWordLength -contains $GuestGuess){
                        $DictionaryWord = $true
                    }
                    Else{
                        $DictionaryWord = $false
                        Write-Warning "The word $GuestGuess is not in the dictionary. Try again."
                    }
                }
                Until(($GuestGuess.Length -eq $GameWordLength) -and ($DictionaryWord))

                $MatchWordString = Compare-Words -FirstWord $TheWord -SecondWord $GuestGuess -WordLength $GameWordLength
                Write-Host ("Attempt " + $AttemptCounter + ": " + $MatchWordString)
                If($TheWord -eq $GuestGuess){
                    $CompleteMatch = $true
                }
            }
            Until(($AttemptCounter -eq $Attempts) -or ($CompleteMatch -eq $true))
            If($CompleteMatch -eq $false){
                Write-Host "The word was $TheWord"
            }
        }
        Else{
            Write-Host "No fun for you today."
        }
    }
    Else{
        Write-Warning "No $GameWordLength character words were found."
    }
}
Else{
    Write-Warning "The dictionary file $DictionaryFile does not exist. Game over, man! Game over!"
}
