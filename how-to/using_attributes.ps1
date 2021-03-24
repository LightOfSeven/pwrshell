# declarative
[ValidateRange(0, 10)]
[int]$n = Read-Host

# imperative
[int]$n = Read-Host
if ($n -lt 0 -or $n -gt 10) {
  throw [IndexOutOfRangeException]::new()
}

# Most importantly, you can use ValidateSet and other Attribute paramters outside of functions and classes.

<#
This allows Declarative programming vs Imperative.
The declarative implementation is clearly more concise, telling the interpreter to simply validate that
$n is between 0 and 10. In contrast, the imperative solution requires more code and contains implementation details — 
boolean operations and error instantiation — that can otherwise be avoided with a declarative solution. 
Validation attributes are declarative because they define when a value is valid.
#>

<#
Declaring an attribute

Attribute declarations require:

    Square brackets
    The attribute name
    The attribute parameters — sometimes empty, but always present
    The value that the attribute affects
#>

[ValidateSet("ca", "eu", "us")]
$region = Read-Host

# A more advanced, common scenario
function Deploy-Cluster {
    Param(
      [Parameter(Mandatory)]
      [ValidatePattern("^[a-z]+-[a-z]+-[a-z]+-[0-9]+$")]
      [string] $ClusterId
  )
  #do
}
