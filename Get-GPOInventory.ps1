#############################################################################
# Author  : Tyler Cox
#
# Version : 1.0
# Created : 11/2/2021
# Modified : 
#
# Purpose : This script will build an inventory of all GPOs and their links.
#
# Requirements: A computer with Active Directory Admin Center (ADAC) installed and a 
#               user account with enough privileges 
#             
# Change Log: Ver 1.0 - Initial release
#
#############################################################################

#Set our variables
$OutputFile = "C:\GPOList.txt" #Output file. Note: It's easiest to just import this into Excel 
$DomainName = $env:USERDNSDOMAIN #Set the domain to search for GPOs 

#Pull a list of all our GPOs
$GPOs = Get-GPO -All -Domain $DomainName

#Add our file headers
"Name;Description;CreatedTime;ModifiedTime;WmiFilter;GPOstatus;LinkPath" | Out-File $OutputFile 

#Cycle through each GPO
ForEach ($GPO in $GPOs)
    {
        If ($GPO.WmiFilter) {$WMIFilter = $GPO.WmiFilter.Name } Else {$WMIFilter = "NONE"} #Get the WMIFilter Name or put "False" if no filter
        If ($GPO.Description) {$Description = $GPO.Description.replace("`r`n",", ")} Else {$Description = $null} #Parse out and replace new lines with a comma
        $Output = $GPO.DisplayName + ";" + $Description + ";" + $GPO.CreationTime + ";" + $GPO.ModificationTime + ";" + $WMIFilter + ";" + $GPO.GPOStatus #Build out each GPO information
        $Output | Out-File $OutputFile -Append #Add it to the file
        [xml]$Report = $GPO | Get-GPOReport -ReportType XML #Dive deeper into the GPO to get the Links
        $Links = $Report.GPO.LinksTo 
        ForEach($Link In $Links) #Cycle through each Link
        {
            $Output = ";;;;;;" + $Link.SOMPath #We put blanks for all the columns except for the Link Path
            $Output | Out-File $OutputFile -Append #Append the Links under the GPO
        }
    }