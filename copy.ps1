Clear-Host;
Write-Output("Copy started");

function Add-TimeStamp-IfNotAdded {
    param (
        $file
    )    

    $fileName = $file.FullName;
    $ext = $file.Extension;

    $fileEnd = $file.CreationTime.ToString("yyyyMMddHHmmss") + $ext;

    $isStamped = $fileName -like '*_' + $fileTimestamp + $fileEnd;

    if ($isStamped -eq $false) {
        $newName = $fileName.Substring(0, $fileName.Length - $ext.Length); #Join-Path -Path $newName -ChildPath $_.Name.Substring(0, $_.Name.Length - $_.Extension.Length); 
        $newName = $newName + "_" + $fileEnd;
        Rename-Item -Path $fileName -NewName $newName;
        return $newName;
    }   

    return $fileName;
}

function Get-RelativePath {
    param (
        $startPath, $path
    )
    
    $relativePath = "";
    $startIndex = $startPath.Length;
    $subLength = $path.Length - $startPath.Length;   
    if ($subLength -gt 0) {
        $relativePath = $path.Substring($startIndex, $subLength);
    }

    return $relativePath;
}

function Copy-Files {

    param(
        $from, $toList, $remove
    )

    Get-ChildItem -Path $from -Recurse -File | ForEach-Object {

        # копируемый каталог
        $from = Join-Path -Path $from -ChildPath "";

        # копируемый файл
        $fromFile = Add-TimeStamp-IfNotAdded -file $_;
        $fromFileName = Split-Path $fromFile -leaf;

        # относительный путь
        $relativePath = Get-RelativePath -startPath $from  -path $_.Directory.FullName;

        for ($i = 0; $i -lt $toList.Length; $i++) {            
            $to = Join-Path -Path $toList[$i] -ChildPath "";
            $toPath = Join-Path -Path $to -ChildPath $relativePath;
            $toFile = Join-Path -Path $toPath -ChildPath $fromFileName;
    
            # создать каталог, если нету
            if (!(Test-Path $toPath -PathType Container)) {
                New-Item -ItemType Directory -Force -Path $toPath
            }
    
            # прервать, если файл есть, и размер совпадает
            if ((Test-Path $toFile -PathType Any)) {            
                $checkSize = (Get-Item $fromFile).Length -eq (Get-Item $toFile).Length;
                if ($checkSize -eq $true) {
                    continue;
                }
            }
            
            Write-Output($fromFile + " > " + $toFile);
            Copy-Item -Path $fromFile -Destination $toFile -Force
        }

        if ($remove -eq $true) {
            Remove-item $fromFile;
        }
    }
}

function Remove-OldItems {
    param (
        $path, $days
    )

    $refDate = (Get-Date).AddDays(-$days);
    Get-ChildItem -Path $path -Recurse -File | 
    Where-Object { $_.LastWriteTime -lt $refDate } | 
    Remove-Item -Force
}

Copy-Files -from "F:\ChatBB" -toList @("F:\test1", "F:\test2") -remove $true;


