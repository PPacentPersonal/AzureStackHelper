# Create Cert Durectiry fir Secret Rotation
Function MakeSecretRotationDirectory {

mkdir "Certificates"
mkdir ".\Certificates\AAD"
mkdir ".\Certificates\ADFS"

$MandatoryCerts = New-Object 'Collections.Generic.List[Tuple[string,string]]'
$MandatoryCerts.Add([System.Tuple]::Create("Admin Portal","adminportal"))
$MandatoryCerts.Add([System.Tuple]::Create("Public Portal","publicportal"))
$MandatoryCerts.Add([System.Tuple]::Create("KeyVault","*.vault"))
$MandatoryCerts.Add([System.Tuple]::Create("KeyVaultInternal","*.adminvault"))
$MandatoryCerts.Add([System.Tuple]::Create("ARM Admin","adminmanagement"))
$MandatoryCerts.Add([System.Tuple]::Create("ARM Public","management"))
$MandatoryCerts.Add([System.Tuple]::Create("ACSBlob","*.blob"))
$MandatoryCerts.Add([System.Tuple]::Create("ACSTable","*.table"))
$MandatoryCerts.Add([System.Tuple]::Create("ACSQueue","*.queue"))


$ADFSCerts = New-Object 'Collections.Generic.List[Tuple[string,string]]'
$ADFSCerts.Add([System.Tuple]::Create("ADFS","ADFS"))
$ADFSCerts.Add([System.Tuple]::Create("Graph","Graph"))

Get-ChildItem .\Certificates -Directory | ForEach-Object {
    ForEach ($Cert in $MandatoryCerts) { 
        MakeCertDirectory -Cert $Cert -Path $_.FullName.ToString()
        }
}
ForEach ($cert in $ADFSCerts) {
    MakeCertDirectory -Cert $cert -Path ".\Certificates\ADFS"
    }
}


Function MakeCertDirectory {
[cmdletbinding()]
Param(
[tuple[string,string][]]$Cert,
[String]$Path )
$DirectoryName = $cert.Item1
$RecordName = $cert.Item2

New-Item -Path $Path -Name $DirectoryName -ItemType "Directory"

If ($RecordName.contains("*")) {
    New-Item -Path $Path\$DirectoryName -Name "CertificateHelp.txt" -ItemType "file" -Value "Put PFX File here. 
    The Certificate's Subject or Subject Alternative Name must contain: `"$RecordName.[RegionName].[ExternalDomainFQDN]`""
    }

else {
    New-Item -Path $Path\$DirectoryName -Name "CertificateHelp.txt" -ItemType "file" -Value "Put PFX File here. The Certificate's Subject or Subject Alternative Name must contain: 
    `"$RecordName.[RegionName].[ExternalDomainFQDN]`" 
    OR 
    `"*.[RegionName].[ExternalDomainFQDN]`""
}

}

MakeSecretRotationDirectory
