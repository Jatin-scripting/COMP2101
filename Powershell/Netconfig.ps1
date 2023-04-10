## Getting the enabled network adapters.
$adapterFound= Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled}

#the report tittle
Write-Output "`"The System Network information`""
$width = $Host.UI.RawUI.BufferSize.Width
$line = "-" * $width
Write-Host $line

#function to retrieve IP configuration information of the system network adapters currently available
$count = 0
$adapterResult = @() #initialize the counter variable to store adapter data to display in table form.

    while ($count -lt $adapterFound.Count) {
        $AptFoundObj = $adapterFound[$count]
        $adapter = [PSCustomObject]@{

            "Adapter Description" = if ($AptFoundObj.Description){$AptFoundObj.Description} else { "N/A"}
            "Index" = if($AptFoundObj.Index){$AptFoundObj.Index} else { "N/A"}
            "IP Addresses" = if($AptFoundObj.IPAddress){$AptFoundObj.IPAddress} else { "N/A"}
            "Subnet Masks" = if($AptFoundObj.IPSubnet){$AptFoundObj.IPSubnet} else { "N/A"}
            "DNS Domain Name" = if($AptFoundObj.DNSDomain){$AptFoundObj.DNSDomain} else { "N/A"}
            "DNS Servers" = if($AptFoundObj.DNSServerSearchOrder){$AptFoundObj.IPSubnet} else { "N/A"}
           }

        $adapterResult += $adapter
        $count++

}

$adapterResult | Format-Table -AutoSize