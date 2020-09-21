#######################################
# By: Zubair Khan                     #
#     YMA-SA - DSMA                   #
#     21/9/2020                       #
#######################################

# Note:
# The Script needs to be run on Windows Domain controllers


# We will first collect all DHCP instances in your domain
$dhcpServers = Get-DhcpServerInDC | Select DnsName

 
# Now we are going to scan all scopes per DHCP detected. This may throw a few errors depending on DHCP server reachability and permissions
# The specified queries are all Get commands and will not make changes on your Domain controller

foreach($ser in $dhcpServers){
    if(Test-Connection -ComputerName $ser.DnsName -Count 2 -Quiet -ErrorAction SilentlyContinue){
        $scope = Get-DhcpServerv4Scope -ComputerName $ser.DnsName
        #$scope
        foreach($s in $scope.ScopeId){
        $SID += Get-DhcpServerv4Lease -ComputerName $ser.DnsName -ScopeId $s | select AddressState, ClientID, IPAddress, ScopeID, Hostname, LeaseExpiryTime, ServerIP, @{Name="Server";Expression={$ser.DnsName}}
        }


    }
}

# The result can be exported in a CSV format to be processed in Excel. 
$SID | Export-Csv -Path C:\temp\DHCPOutput.csv

# The result can be presented in a tableview which can be expeorted to an excel or CSV file
$SID | Out-GridView