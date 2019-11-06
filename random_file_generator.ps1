function New-RandomFiles {
    param (
        $Path = 'C:\testfiles\',
        $NumberOfFiles = 10,
        $SizeOfFiles = 12000
    )
    
    if(-not (Test-Path($Path)){
        New-Item -ItemType Directory -Path $Path -Force
    }

    $Random = New-Object -TypeName Random

    while($NumberOfFiles -gt 0){
        $FileName = "$Path\$NumberOfFiles"
        $NumberOfFiles = $NumberOfFiles - 1
    
        # Makes a new file with fixed length
        $NewFile = New-Object -TypeName byte[] -ArgumentList $SizeOfFiles
        # random.nextbytes fills a given array with random content
        $Random.NextBytes($NewFile)
        [IO.File]::WriteAllBytes($FileName, $NewFile)
    }
}
