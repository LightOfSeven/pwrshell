<#
.SYNOPSIS 
- This example explains how to use a switch (aka case) instead of nested ifs / foreach loops
.DESCRIPTION 
- Switches save time, space, and are easier to read!
#>

# Bad - don't do this

if($Example -like "foo"){
    do foo
}
elseif($Example -like "bar){
    do bar
}
elseif($Example -like "foobar){
    do foobar
}
else{
    do defaultaction
}

# Good - do this

switch($example){
    "foo" {do foo}
    "bar" {do bar}
    "foobar" {do foobar}
    Default {do defaultaction}
}
