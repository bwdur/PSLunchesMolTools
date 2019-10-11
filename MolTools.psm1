function Set-TMServiceLogon {
    [cmdletBinding(SupportsShouldProcess)]
    
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string] $ServiceName,
        [parameter(ValueFromPipelineByPropertyName)]
        [string] $NewUser,
        [parameter(ValueFromPipelineByPropertyName)]
        [string] $NewPassword,
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string[]] $ComputerName,
        [string] $ErrorLogFilePath
    )

    BEGIN {
        Write-Verbose "[BEGIN ] Starting $($MyInvocation.MyCommand)..."
     }
    PROCESS {
        foreach ($computer in $ComputerName) {
            
            $option = New-CimSessionOption -protocol Wsman
            Write-Verbose "[PROCESS ] Connecting to $computer on WS-MAN protocol"
            $session = New-CimSession -SessionOption $option -ComputerName $computer

            if ($PSBoundParameters.ContainsKey('NewUser')) {
                $args = @{'StartName' = $NewUser; 'StartPassword' = $NewPassword } 
            }
            else {
                $args = @{'StartPassword' = $NewPassword }
                Write-Warning "Not setting a new user name"
            }

            # SPLATTING example
            
            $params = @{'CimSession' = $session
                        'MethodName' = 'Change'
                        'Query' = "Select * from win32_service where name = '$ServiceName'"
                        'Arguments' = $args}

             Write-Verbose "[PROCESS ] Setting $servicename on $computer"
            $status = Invoke-CimMethod @params
            
            switch ($status.ReturnValue){
                0 {$result = "Success"}
                22 {$result = "Invalid Account"}
                Default{
                    $result = "Failed: " + $status.ReturnValue
                }
            }

            Write-Verbose "[PROCESS ] Result for $computer - $result"
            $obj = [PSCustomObject]@{
                ComputerName = $computer
                Result = $result
            }

            $obj
            write-verbose "Closing connection to $computer"
            $session | Remove-CimSession
        } 
    } #process
    END { }
}