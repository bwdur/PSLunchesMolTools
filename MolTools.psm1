function Set-TMServiceLogon {
    [cmdletBinding(SupportsShouldProcess)]
    
    param(
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string] $ServiceName,
        [parameter(ValueFromPipelineByPropertyName)]
        [string] $NewUser,
        [parameter(ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string] $NewPassword,
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory = $True)]
        [string[]] $ComputerName,
        [string] $ErrorLogFilePath
    )

    BEGIN { }
    PROCESS {
        $query = "Select * from win32_service where name = '$ServiceName'"

        foreach ($computer in $ComputerName) {

            $option = New-CimSessionOption -protocol Wsman
            $session = New-CimSession -SessionOption $option -ComputerName $computer

            if ($PSBoundParameters.ContainsKey('NewUser')) {
                $args = @{'StartName' = $NewUser; 'StartPassword' = $NewPassword } 
            }
            else {
                $args = @{'StartPassword' = $NewPassword }
            }

            # SPLATTING example
            
            $params = @{'CimSession' = $session
                        'MethodName' = 'Change'
                        'Query' = "Select * from win32_service where name = '$ServiceName'"
                        'Arguments' = $args}

            $status = Invoke-CimMethod @params
            
            switch ($status.ReturnValue){
                0 {$result = "Success"}
                22 {$result = "Invalid Account"}
                Default{
                    $result = "Failed: " + $status.ReturnValue
                }
            }

            $obj = [PSCustomObject]@{
                ComputerName = $computer
                Result = $result
            }

            $obj

            $session | Remove-CimSession
        } 
    } #process
    END { }
}