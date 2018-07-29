function Get-DomainSummary {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$Paragraph,
        $ActiveDirectorySnapshot,
        $Domain
    )

    $ForestName = $($ActiveDirectorySnapshot.ForestInformation.Name)
    $ForestNameDN = $($ActiveDirectorySnapshot.RootDSE.defaultNamingContext)
    $DomainNetBios = $ActiveDirectorySnapshot.DomainInformation.NetBIOSName
    $DomainName = $ActiveDirectorySnapshot.DomainInformation.DNSRoot
    $DomainDistinguishedName = $ActiveDirectorySnapshot.DomainInformation.DistinguishedName

    $Text = "Following domains exists within forest $ForestName"
    $Text0 = "Domain $DomainDistinguishedName"
    $Text1 = "Name for fully qualified domain name (FQDN): $DomainName"
    $Text2 = "Name for NetBIOS: $DomainNetBios"

    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text

    $ListDomainInformation = $null
    $ListDomainInformation = $ListDomainInformation | New-WordListItem -WordDocument $WordDocument -ListLevel 0 -ListItemType Bulleted -ListValue $Text0
    $ListDomainInformation = $ListDomainInformation | New-WordListItem -WordDocument $WordDocument -ListLevel 1 -ListItemType Bulleted -ListValue $Text1
    $ListDomainInformation = $ListDomainInformation | New-WordListItem -WordDocument $WordDocument -ListLevel 1 -ListItemType Bulleted -ListValue $Text2
    Add-WordListItem -WordDocument $WordDocument -Paragraph $Paragraph -List $ListDomainInformation -Supress $true
}


function Get-DocumentScope {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$Paragraph,
        $CompanyName
    )

    $Text = "This document provides a low-level design of roles and permissions for the IT infrastructure team at $CompanyName organization. This document utilizes knowledge from AD General Concept document that should be delivered with this document. Having all the information described in attached document one can start designing Active Directory with those principles in mind. It's important to know while best practices that were described are important in decision making they should not be treated as final and only solution. Most important aspect is to make sure company has full usability of Active Directory and is happy with how it works. Making things harder just for the sake of implementation of best practices isn't always the best way to go."
    #$Section1 = Add-WordParagraph -WordDocument $WordDocument -Paragraph $Section1 -AfterSelf -Supress $false
    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text -Alignment both
    return $Paragraph
}

function New-WordBuildingBlock {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$WordDocument,
       # [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]$Paragraph,
        [bool] $TocEnable,
        [string] $TocText,
        [int] $TocListLevel,
        $TocListItemType,
        $TocHeadingType,

        $EmptyParagraphs = 0,
        [string] $Text,

        [Object] $TableData,
        $TableDesign,
        [bool] $TableTitleMerge = $false,
        [string] $TableTitleText,
        $TableTitleAlignment = 'center',
        $TableTitleColor = 'Black'
    )
    if ($TocEnable) {
        $TOC = $WordDocument | Add-WordTocItem -Text $TocText -ListLevel $TocListLevel -ListItemType $TocListItemType -HeadingType $TocHeadingType
    }
    $i = 0
    While ($i -lt $EmptyParagraphs) {
        Write-Verbose 'New-Test - $Breaks'
        $Paragraph = Add-WordParagraph -WordDocument $WordDocument
        $i++
    }
    $Paragraph = Add-WordText -WordDocument $WordDocument -Paragraph $Paragraph -Text $Text
    $Table = Add-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -DataTable $TableData -AutoFit Window -Design $TableDesign -DoNotAddTitle:$TableTitleMerge

    if ($TableTitleMerge) {
        $Table = Set-WordTableRowMergeCells -Table $Table -RowNr 0 -ColumnNrStart 0 -ColumnNrEnd 1
        if ($TableTitleText -ne $null) {
            $TableParagraph = Get-WordTableRow -Table $Table -RowNr 0 -ColumnNr 0
            $TableParagraph = Add-WordText -WordDocument $WordDocument -Paragraph $TableParagraph -Text $TableTitleText -Alignment $TableTitleAlignment -Color $TableTitleColor -AppendToExistingParagraph
        }
    }
}