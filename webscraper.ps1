#Link to you want to download the HTML files from
$Uri = "https://sleuthkit.org/autopsy/docs/user-docs/4.19.3"

#Folder where you want the files stored
$DestinationFolder = "C:\"

#HREF GATHERING
##Gets a list of hrefs and puts them in a hreflist.txt.  Sets contents of hreflist.txt to $hreflistcontent
(Invoke-WebRequest -Uri $Uri).links.href | where{$_ -notmatch "http|^#"} >> "$DestinationFolder\hreflist.txt"
$hreflistcontent = Get-Content "$DestinationFolder\hreflist.txt"

##Creates new file to store searched hrefs in.
##Searches each href in hreflist and adds the name of searched hrefs to a file.  Appends new hrefs to hreflist.
New-Item -Path $DestinationFolder -Name "searchedhrefs.txt"
"index.html" >> "$DestinationFolder/searchedhrefs.txt"


function Search-href() {
$hreflistcontent = Get-Content "$DestinationFolder\hreflist.txt"
$hreflistcontent | %{
$searchedhrefscontent = Get-Content "$DestinationFolder\searchedhrefs.txt"
if($searchedhrefscontent.Contains($_) -eq $false){$_ >> "$DestinationFolder/searchedhrefs.txt"
$searchedhrefscontent = Get-Content "$DestinationFolder\searchedhrefs.txt"
(Invoke-WebRequest -Uri "$Uri/$_").links.href | %{if($hreflistcontent.Contains($_) -eq $false){$_ | where{$_ -notmatch "^#|http"} >> "$DestinationFolder/hreflist.txt"}}}}
}
$preemptivesearch = ""
Search-href
$postsearch = Get-Content "$DestinationFolder\searchedhrefs.txt"

while($preemptivesearch.Value.count -ne $postsearch.count){
$preemptivesearch = Get-Content "$DestinationFolder\searchedhrefs.txt"
Search-href
$postsearch = Get-Content "$DestinationFolder\searchedhrefs.txt"}


#Downloading files
$WebClient = New-Object System.Net.WebClient
Get-Content "$DestinationFolder\hreflist.txt" | %{$webrequest = (Invoke-WebRequest -Uri "$Uri/$_"); foreach($image in ($webrequest.Images | select -expandproperty src)){$wc.DownloadFile("$Uri/$image", "$DestinationFolder\$image")}; $webrequest.RawContent >> "$DestinationFolder\$_"}
