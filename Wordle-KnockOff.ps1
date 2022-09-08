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
# select a special character to represent an invalid guess
$WrongCharacter = "_"

## Functions
# Compare each character in corresponding locations in same-length words
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
                $MatchWord += $WrongCharacter
            }
            # Increment counter to next letter in word
            $CharacterCounter++
        }
        Until($CharacterCounter -eq $WordLength)

        $MatchWord -join ""
    }
}

# Get count of duplicate letters
Function Get-LetterCount ([string]$string){
    $CharArray = $string.ToLower().ToCharArray()
    $HashTable = @{}
    ForEach($char in $CharArray){ 
        If(-not $HashTable.ContainsKey($char)){ 
            $HashTable.Add($char,1)
        }
        Else{
            $HashTable[$char]++
        }
    }
    $HashTable
}

## Script
# Verify existence of dictionary file
If(Test-Path -Path $DictionaryFile){
    # Pull words that equal desired length for word pool
    $DictionaryWordLength = Get-Content -Path $DictionaryFile | Where-Object{$_.length -eq $GameWordLength}
    # Verify words of desired length exist; continue if true
    If($DictionaryWordLength){
        # Prompt for user verification
        $PlayGame = Read-Host -Prompt "Would you like to play a game? Type 'yes' to continue"
        If(($PlayGame -eq "yes") -or ($PlayGame -eq "y")){
            # Pull random word from word pool
            $TheWord = $DictionaryWordLength | Get-Random
            # Set counter for attempts
            $AttemptCounter = 0
            # Set variable for winning guess
            $CompleteMatch = $false

            # Provide user instructions
            Write-Host "A CAPITAL LETTER indicates that the letter is in the correct spot."
            Write-Host "A lower case letter indicates that the letter is in the word, but not in the correct spot."
            Write-Host "A `"$WrongCharacter`" indicates that the letter is not in the word."
            Write-Host "You will have $Attempts attempts to guess the correct word. Good luck."

            #Write-Host "The word of the day is: $TheWord" #For troubleshooting or cheating
            Do{
                # Increment attempt counter
                $AttemptCounter++
                # Check word for validity (length, valid characters, etc.); retry if invalid
                Do{
                    $WordCriteria = $false
                    $GuestGuess = Read-Host -Prompt "Enter your $GameWordLength-letter word guess for attempt $AttemptCounter"
                    If($GuestGuess.Length -ne $GameWordLength){
                        Write-Warning "The word $GuestGuess does not equal $GameWordLength characters. Try again."
                    }
                    ElseIf($GuestGuess -notmatch "^[a-zA-Z]+$"){
                        Write-Warning "The word $GuestGuess contains invalid characters. Try again."
                    }
                    ElseIf(!($DictionaryWordLength -contains $GuestGuess)){
                        Write-Warning "The word $GuestGuess is not in the dictionary. Try again."
                    }
                    Else{
                        $WordCriteria = $true
                    }
                }
                Until($WordCriteria)

                # Run function for word comparison
                $MatchWordString = Compare-Words -FirstWord $TheWord -SecondWord $GuestGuess -WordLength $GameWordLength
                Write-Host ("Attempt " + $AttemptCounter + " of " + $Attempts + ": " + $MatchWordString)
                If($TheWord -eq $GuestGuess){
                    $CompleteMatch = $true
                }
            }
            # End if word matches or attempts exceeded
            Until(($AttemptCounter -eq $Attempts) -or ($CompleteMatch -eq $true))
            If($CompleteMatch){
                Write-Host "Congratulations! You guessed correctly!"
            }
            # Provide solution if game is lost
            Else{
                Write-Host "Sorry! The word was $TheWord"
            }
        }
        # Cancel upon invalid user verification
        Else{
            Write-Host "No fun for you today."
        }
    }
    # Cancel if no words of desired length are found in the dictionary
    Else{
        Write-Warning "No $GameWordLength character words were found."
    }
}
# Cancel because of stupidity inputting the dictionary file
Else{
    Write-Warning "The dictionary file $DictionaryFile does not exist. Game over, man! Game over!"
}
