# Windows Out-File Patch

Add `-Encoding Utf8Bom` and `-Encoding Utf8NoBom` values to the Windows `Out-File` cmdlet

### Use case

Your company is in a transition phase from Windows PowerShell to PowerShell Core.
You have a lot of scripts that use the [`Out-File`][1] cmdlet to create text files.
Most of the `Out-File` commands do not have any encoding specified, so they use the default encoding.
In Windows PowerShell, the default encoding is `Unicode` (UTF-16LE), while in PowerShell Core,
the default encoding is `Utf8NoBom` (UTF-8 without BOM).
Besides, the `Utf8` encoding has changed from `Utf8Bom` (UTF-8 with BOM) in Windows PowerShell to
`Utf8` (UTF-8 without BOM) in PowerShell Core.

You want the same behavior in both Windows PowerShell and PowerShell Core preferably using UTF-8 encoding.
Therefore, you want to use `-Encoding Utf8NoBom` in all `Out-File` commands.
However, Windows PowerShell does not support `Utf8NoBom` as a value for the `-Encoding` parameter of the `Out-File` cmdlet:

```PowerShell
PS C:\> Get-Command Out-File

CommandType     Name         Version    Source
-----------     ----         -------    ------
Cmdlet          Out-File     3.1.0.0    Microsoft.PowerShell.Utility

PS C:\> Out-File Test.txt -InputObject 'Hello World' -Encoding utf8NoBOM -NoNewLine
Out-File : Cannot validate argument on parameter 'Encoding'. The argument "utf8NoBOM" does not belong to the set "unknown,string,unicode,bigendianunicode,utf8,utf7,utf32,ascii,default,oem" specified
by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.
At line:1 char:56
+ ... -File Test.txt -InputObject 'Hello World' -Encoding utf8NoBOM -NoNewL ...
+                                                         ~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Out-File], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.PowerShell.Commands.OutFileCommand
```

This module adds  and implements the `Utf8NoBom` and `Utf8Bom` values to the `-Encoding` parameter of the
`Out-File` cmdlet in Windows PowerShell.

### Installation

```PowerShell
Install-Module WindowsOutFilePatch -AllowClobber
```

After the patch is installation `Out-File` version should be than `3.2.0.0` or higher for Windows PowerShell
and the new encoding values should be available.

> [!NOTE]
> The `Out-File` cmdlet is not replaced in PowerShell Core, so the version remains.

For more details see the helpful answers from [mklement0](https://stackoverflow.com/users/101152/mklement0)
on Stack Overflow:

* [Write-Output with no BOM][2]
* [How to make Out-File use UTF8 without BOM in Windows PowerShell][3]

[1]: https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/out-file "Out-File"
[2]: https://stackoverflow.com/a/65192064/1701026 "Write-Output with no BOM"
[3]: https://stackoverflow.com/a/34969243/1701026 "How to make Out-File use UTF8 without BOM in Windows PowerShell"
