$chosen=Get-Disk | ForEach-Object {
    $diskprt = Get-Partition -DiskNumber $_.DiskNumber | Select-Object -Property PartitionNumber,Size,Type,DriveLetter
    $diskprt | Add-Member -Name 'DiskName' -MemberType NoteProperty -Value $_.FriendlyName
    $diskprt | Add-Member -Name 'DiskNumber' -MemberType NoteProperty -Value $_.DiskNumber
    $diskprt | Add-Member -Name 'DiskSize' -MemberType NoteProperty -Value $_.Size
    $diskprt | Add-Member -Name 'PartitionTable' -MemberType NoteProperty -Value $_.PartitionStyle

    echo $diskprt

} | Select-Object -Property DiskNumber,DiskName,DiskSize,PartitionNumber,DriveLetter,Type,Size,PartitionTable | 
    Out-GridView -OutputMode "Single"

# Safeguard
if ($chosen -Eq $null) {exit}
if ($chosen.DriveLetter) { echo "Hey! This partition is already mounted."; exit}
if ($chosen.Type -contains "Unknown") { echo "Sorry, This partition has an unknown type."; exit}

# Shoose available mounting drive letter
$mnt=echo "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" | 
    Where-Object -FilterScript { ( $_ -NotIn ((Get-PSDrive).Name -match '^[a-z]$')) } | 
    Out-GridView -OutputMode "Single"


# Safeguard
if ($mnt -Eq $null) {exit}

# mount the selected partition to the selected drive letter
Get-Partition -DiskNumber $chosen.DiskNumber | Where-Object -FilterScript { ($_.PartitionNumber -Eq $chosen.PartitionNumber) } | Set-Partition -NewDriveLetter $mnt