$env:path += ";$home/documents/github/comp2101/powershell"

function welcome{

# Lab 2 COMP2101 welcome script for profile
#

write-output "Welcome to planet $env:computername Overlord $env:username"
$now = get-date -format 'HH:MM tt on dddd'
write-output "It is $now."

}

function get-cpuinfo{

Get-CimInstance CIM_Processor | Select-Object Manufacturer, Name, MaxClockSpeed, CurrentClockSpeed, NumberOfCores | Format-List

}


function get-mydisks{

Get-CimInstance CIM_DiskDrive | Select-Object Manufacturer, Model, SerialNumber, FirmwareRevision, Size | Format-Table -AutoSize

}

#@@@!!
###! All functions
    

# Getting Hardware system details
function hardware{
$objectHardware = WmiObject -Class Win32_ComputerSystem
$objectResult = [ordered]@{
"Hardware-Manufacturer" = $objectHardware.Manufacturer
"Hardware-Model" = $objectHardware.Model
"Total Physical-Memory" = "{0:N2}" -f ($objectHardware.TotalPhysicalMemory / 1GB)
"Hardware Description" = $objectHardware.Description
"System-Type" = $objectHardware.SystemType
}
return $objectResult 
}

# Getting Operating system details
Function os{
    $objectOperating = WmiObject -Class Win32_OperatingSystem
    $objectResult =[PSCustomObject]@{
   "System-Name " = $objectOperating.Caption
   "Version" =  $objectOperating.Version

}
    return $objectResult 
}

# Getting processor information
function processor {
    $objectProcessor = WmiObject -Class Win32_Processor
    $objectResult= [PSCustomObject] @{
    "Name" = $objectProcessor.Name
    "Number-of-Cores" = $objectProcessor.NumberOfCores
    "Speed" = $objectProcessor.MaxClockSpeed
    "L1-Cache-Size" = if ($objectProcessor.L1CacheSize) { "{0:N2}" -f ($objectProcessor.L1CacheSize[0] / 1KB) } else { "N/A" }
    "L2-Cache-Size" = if ($objectProcessor.L2CacheSize) { "{0:N2}" -f ($objectProcessor.L2CacheSize[0] / 1KB) } else { "N/A" }
    "L3-Cache-Size" = if ($objectProcessor.L3CacheSize) { "{0:N2}" -f ($objectProcessor.L3CacheSize[0] / 1KB) } else { "N/A" }
    }
    return $objectResult 
}


# Getting Ram memory 
Function memory {
   $objectMemory = WmiObject -Class Win32_PhysicalMemory
    $totalRAM = 0
       
    $objectResult = foreach ($objMem in $objectMemory) {
         [PSCustomObject] @{
            "Vendor" = $objMem.Manufacturer
            "Description" = $objMem.Description
            "Capacity" = "{0:N2} GB" -f ($objMem.Capacity / 1GB)
            "Bank/Slot" = $objMem.DeviceLocator
            "Memory-Type" = $objMem.MemoryType
            "Speed" = $objMem.Speed
        }
          $totalRAM += $objMem.Capacity
            
    }  $objectResult   | format-table -autosize
   
    Write-Output "Total $(('{0:N2}' -f ($totalRAM / 1GB))) GB"
 }


# getting Disk drive 
function disk{
 $diskdrives = CIMInstance CIM_diskdrive

  foreach ($disk in $diskdrives) {
      $partitions = $disk|cimassociatedinstance -resultclassname CIM_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | cimassociatedinstance -resultclassname CIM_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
    $freeSpace = [math]::Round(($logicaldisk.FreeSpace / $logicaldisk.Size) * 100, 2)
        $objectResult = [PSCustomObject]@{

            Manufacturer=$disk.Manufacturer
            Model=$disk.Model     
            Size = "{0:N2} GB" -f ($logicaldisk.Size / 1GB)
            "Free-Space" = "{0:N2} GB" -f ($logicaldisk.FreeSpace / 1GB)
            "Free-space(%)" = "$freeSpace%"
                                                     }
         $objectResult
           }
      }
  }

}

#getting network details
function network{
$networks= CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}
$count = 0
$objectResult = @()
    while ($count -lt $networks.Count) {
        $objectAdapter = $networks[$count]
        $netsdisplay = [PSCustomObject]@{

            "Adapter Description" = if ($objectAdapter.Description){$objectAdapter.Description} else { "N/A"}
            "Index" = if($objectAdapter.Index){$objectAdapter.Index} else { "N/A"}
            "IP-Address" = if($objectAdapter.IPAddress){$objectAdapter.IPAddress} else { "N/A"}
            "Subnet-Mask" = if($objectAdapter.IPSubnet){$objectAdapter.IPSubnet} else { "N/A"}
            "DNS Domain-Name" = if($objectAdapter.DNSDomain){$objectAdapter.DNSDomain} else { "N/A"}
            "DNS-Server" = if($objectAdapter.DNSServerSearchOrder){$objectAdapter.IPSubnet} else { "N/A"}
            "MAC-Address" = if($objectAdapter.MACAddress){$objectAdapter.MACAddress} else { "N/A"}
            "DHCP-Servers" = if($objectAdapter.DHCPServer){$objectAdapter.DHCPServer} else { "N/A"}
            

    }

        $objectResult += $netsdisplay
        $count++

}
$objectResult | Format-Table -AutoSize 
}
                                                         
#getting video informations
function controller {
    $objectVideo = WmiObject -Class Win32_VideoController
    $objectResult= foreach ($objvideo in $objectVideo) {
        [PSCustomObject]@{
            Vendor = $objvideo.VideoProcessor
            Description = $objvideo.Description
            Resolution = $objvideo.CurrentHorizontalResolution.ToString() + "x" + $objvideo.CurrentVerticalResolution.ToString()
        }
    }
    $objectResult
}

#this three line will check the width of laptop and print the line
$width = $Host.UI.RawUI.BufferSize.Width
$line = "*" * $width

#display formated output
Write-Output " "
Write-Output "`"The System information Report`" "
Write-Output $line
Write-Output "System detail of Hardware "
hardware | Format-List
Write-Output "      "
Write-Output $line
Write-Output "      "

Write-Output "System detail of Operating "
os | Format-List
Write-Output "      "
Write-Output $line
Write-Output "      "


Write-Output "System detail of Processor "
processor | Format-List
Write-Output $line


Write-Output "System detail of RAM "
memory 
Write-Output "      "
Write-Output $line
Write-Output "      "


Write-Output "System detail of Disk "
disk  | format-table -autosize
Write-Output $line
Write-Output "      "



Write-Output "System detail of Network "
network
Write-Output $line
Write-Output "      "


Write-Output "System detail of Video Controller "
controller | Format-List
Write-Output $line
Write-Output "      "