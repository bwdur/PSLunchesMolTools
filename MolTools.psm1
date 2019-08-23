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

    begin { }
    process {
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

            Invoke-CimMethod -ComputerName $computer -MethodName Change -Query "SELECT * FROM Win32_Service WHERE Name = '$ServiceName'" -Arguments $args | 
            Select-Object -Property @{n = 'ComputerName'; e = { $computer } }, @{n = 'Result'; e = { $_.ReturnValue } }

            $session | Remove-CimSession
        }
        end { }
    }
}