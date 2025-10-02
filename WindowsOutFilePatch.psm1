param ([Switch]$Force)
if (-not $Force -and (get-command out-file).Version -gt [Version]'3.1.0.0') { return }
$null = New-Item -Path Function:\Global:Out-File -Force -Value {
    [CmdletBinding(DefaultParameterSetName='ByPath', SupportsShouldProcess=$true, ConfirmImpact='Medium', HelpUri='https://go.microsoft.com/fwlink/?LinkID=113363')]
    param(
        [Parameter(ParameterSetName='ByPath', Mandatory=$true, Position=0)]
        [string]
        ${FilePath},

        [Parameter(ParameterSetName='ByLiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string]
        ${LiteralPath},

        [Parameter(Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('unknown','string','unicode','bigendianunicode','utf8','utf8BOM','utf8NoBOM','utf7','utf32','ascii','default','oem')]
        [string]
        ${Encoding},

        [switch]
        ${Append},

        [switch]
        ${Force},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber},

        [ValidateRange(2, 2147483647)]
        [int]
        ${Width},

        [switch]
        ${NoNewline},

        [Parameter(ValueFromPipeline=$true)]
        [psobject]
        ${InputObject})

    begin {
        $NewUtf8NoBomFile, $steppablePipeline = $null
        $ValueFromPipeline = -not $PSBoundParameters.ContainsKey('InputObject')
    }

    process {
        $NewItem = $Null
        if ($null -eq $NewUtf8NoBomFile) {
            if ($PSBoundParameters.ContainsKey('FilePath')) { $LiteralPath = $FilePath }
            $NewUtf8NoBomFile = $Encoding -eq 'utf8NoBOM' -and
                                (-not $Append -or -not (Test-Path -LiteralPath $LiteralPath -PathType Leaf ))
            if ($NewUtf8NoBomFile) {
                $OutStringParam = @{ InputObject = $InputObject }
                if ($PSBoundParameters.ContainsKey('Width'))     { $OutStringParam['Width']     = $Width }
                $Value = Out-String @OutStringParam
                if ($PSBoundParameters.ContainsKey('NoNewLine')) { $Value = $Value -replace '\r\n$' }
                $NewItem = New-Item -Path $LiteralPath -ItemType File -Value $Value -Force
                $PSBoundParameters['Append'] = $true
            }
        }
        if (-not $steppablePipeline -and -not $NewItem) {
                $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Out-File', [System.Management.Automation.CommandTypes]::Cmdlet)
                if ($Encoding -eq 'utf8BOM')   { $PSBoundParameters['Encoding'] = 'utf8' }
                if ($Encoding -eq 'utf8NoBOM') { $PSBoundParameters['Encoding'] = 'Default' }
                if ($ValueFromPipeline -and $PSBoundParameters.ContainsKey('InputObject')) {
                    $null = $PSBoundParameters.Remove('InputObject')
                }
                $scriptCmd = {& $wrappedCmd @PSBoundParameters } # Start the pipeline
                $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
                $steppablePipeline.Begin($ValueFromPipeline)
        }
        if ($steppablePipeline) {
            if ($ValueFromPipeline) { $steppablePipeline.Process($_) } else { $steppablePipeline.Process() }
        }
    }

    end {
        if ($null -ne $steppablePipeline) { $steppablePipeline.End() }
    }
}

Export-ModuleMember -Function Out-File