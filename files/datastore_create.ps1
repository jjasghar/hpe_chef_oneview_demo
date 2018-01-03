# First thing we need to do is connect to our vCenter server
Connect-VIServer -Server 192.168.10.55 -User root -Password P@rtn3r1

# Get the CanonicalName of our storage LUN
$lun = (Get-SCSILun -VMhost 192.168.10.55 -LunType Disk | ? { $_.RuntimeName.StartsWith("vmhba1") }).CanonicalName

# Create a new datastore
New-Datastore -VMHost 192.168.10.55 -Name 'VMFS_Datastore_1' -Path $lun -vmfs