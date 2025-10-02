#Requires -Modules @{ModuleName="Pester"; ModuleVersion="5.5.0"}

[Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'False positive')]
param()

Describe 'Test-Object' {

    BeforeAll {
        Set-StrictMode -Version Latest

        $TempFile = New-TemporaryFile
    }

    AfterEach {
        Remove-Item $TempFile -ErrorAction SilentlyContinue
    }

    Context 'Version check' {

        It 'PowerShell Core' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
            $OutFileCommand = Get-Command Out-File
            $OutFileCommand.Source  | Should -Be 'Microsoft.PowerShell.Utility'
            $OutFileCommand.Version | Should -BeGreaterOrEqual ([version]'6.0.0.0')
        }

        It 'Windows PowerShell' -Skip:($PSVersionTable.PSEdition -ne 'Desktop') {
            $OutFileCommand = Get-Command Out-File
            $OutFileCommand.Source  | Should -Be 'WindowsOutFilePatch'
            $OutFileCommand.Version | Should -BeGreaterOrEqual ([version]'3.2.0.0')
        }
    }

    Context 'Per InputObject Parameter (no encoding)' {

        It 'PowerShell Core' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
            Out-File $TempFile -InputObject 'Test'
            (Get-Item $TempFile).Length | Should -Be 6
        }

        It 'Windows PowerShell' -Skip:($PSVersionTable.PSEdition -ne 'Desktop') {
            Out-File $TempFile -InputObject 'Test'
            (Get-Item $TempFile).Length | Should -Be 14
        }
    }

    Context 'Via pipeline (no encoding)' {

        It 'PowerShell Core' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
            'Test' | Out-File $TempFile
            (Get-Item $TempFile).Length | Should -Be 6
        }

        It 'Windows PowerShell' -Skip:($PSVersionTable.PSEdition -ne 'Desktop') {
            'Test' | Out-File $TempFile
            (Get-Item $TempFile).Length | Should -Be 14
        }
    }

    Context 'Multiple items via pipeline (no encoding)' {

        It 'PowerShell Core' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
            'Test1', 'Test2' | Out-File $TempFile
            (Get-Item $TempFile).Length | Should -Be 14
        }

        It 'Windows PowerShell' -Skip:($PSVersionTable.PSEdition -ne 'Desktop') {
            'Test1', 'Test2' | Out-File $TempFile
            (Get-Item $TempFile).Length | Should -Be 30
        }
    }

    Context '-Encoding utf8BOM' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test' -Encoding utf8BOM
            (Get-Item $TempFile).Length | Should -Be 9
        }

        It 'Via pipeline' {
            'Test' | Out-File $TempFile -Encoding utf8BOM
            (Get-Item $TempFile).Length | Should -Be 9
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8BOM
            (Get-Item $TempFile).Length | Should -Be 17
        }
    }

    Context '-Encoding utf8BOM -NoNewLine' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test' -Encoding utf8BOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 7
        }

        It 'Via pipeline' {
            'Test' | Out-File $TempFile -Encoding utf8BOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 7
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8BOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 13
        }
    }

    Context '-Encoding utf8BOM -Append' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test1' -Encoding utf8BOM
            Out-File $TempFile -InputObject 'Test2' -Encoding utf8BOM -Append
            (Get-Item $TempFile).Length | Should -Be 17
        }

        It 'Via pipeline' {
            'Test1' | Out-File $TempFile -Encoding utf8BOM
            'Test2' | Out-File $TempFile -Encoding utf8BOM -Append
            (Get-Item $TempFile).Length | Should -Be 17
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8BOM
            'Test3', 'Test4' | Out-File $TempFile -Encoding utf8BOM -Append
            (Get-Item $TempFile).Length | Should -Be 31
        }
    }

    Context '-Encoding utf8BOM -NoNewLine -Append' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test1' -Encoding utf8BOM -NoNewLine
            Out-File $TempFile -InputObject 'Test2' -Encoding utf8BOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 13
        }

        It 'Via pipeline' {
            'Test1' | Out-File $TempFile -Encoding utf8BOM -NoNewLine
            'Test2' | Out-File $TempFile -Encoding utf8BOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 13
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8BOM -NoNewLine
            'Test3', 'Test4' | Out-File $TempFile -Encoding utf8BOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 23
        }
    }

    Context '-Encoding utf8NoBOM' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test' -Encoding utf8NoBOM
            (Get-Item $TempFile).Length | Should -Be 6
        }

        It 'Via pipeline' {
            'Test' | Out-File $TempFile -Encoding utf8NoBOM
            (Get-Item $TempFile).Length | Should -Be 6
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8NoBOM
            (Get-Item $TempFile).Length | Should -Be 14
        }
    }

    Context '-Encoding utf8NoBOM -NoNewLine' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test' -Encoding utf8NoBOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 4
        }

        It 'Via pipeline' {
            'Test' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 4
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine
            (Get-Item $TempFile).Length | Should -Be 10
        }
    }

    Context '-Encoding utf8NoBOM -Append' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test1' -Encoding utf8NoBOM
            Out-File $TempFile -InputObject 'Test2' -Encoding utf8NoBOM -Append
            (Get-Item $TempFile).Length | Should -Be 14
        }

        It 'Via pipeline' {
            'Test1' | Out-File $TempFile -Encoding utf8NoBOM
            'Test2' | Out-File $TempFile -Encoding utf8NoBOM -Append
            (Get-Item $TempFile).Length | Should -Be 14
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8NoBOM
            'Test3', 'Test4' | Out-File $TempFile -Encoding utf8NoBOM -Append
            (Get-Item $TempFile).Length | Should -Be 28
        }
    }

    Context '-Encoding utf8NoBOM -NoNewLine -Append' {

        It 'Per InputObject Parameter' {
            Out-File $TempFile -InputObject 'Test1' -Encoding utf8NoBOM -NoNewLine
            Out-File $TempFile -InputObject 'Test2' -Encoding utf8NoBOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 10
        }

        It 'Via pipeline' {
            'Test1' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine
            'Test2' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 10
        }

        It 'Multiple items via pipeline' {
            'Test1', 'Test2' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine
            'Test3', 'Test4' | Out-File $TempFile -Encoding utf8NoBOM -NoNewLine -Append
            (Get-Item $TempFile).Length | Should -Be 20
        }
    }
}