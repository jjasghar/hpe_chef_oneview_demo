require 'oneview-sdk'
my_client = { url: 'https://TME-Synergy-R1.tme.lab', user: 'PartnerAccess_1', password: 'P@rtn3r1', api_version: 500 }
# r_client = OneviewSDK::Client.new(user: 'Administrator', password: '*******',  url: 'https://192.168.20.20', api_version: 500)

oneview_server_profile 'chef_demo_esxi' do
  client my_client
  server_hardware 'CN759000AC, bay 1'
  server_hardware_type 'SY 480 Gen9 1'
  enclosure_group 'TME_Synergy_R1'
  server_profile_template 'chef-demo-esxi'
end

oneview_server_hardware 'CN759000AC, bay 1' do
  client my_client
  power_state 'on'
  action :set_power_state
end

powershell_script 'Create Datastore' do
  code <<-EOH
    # First thing we need to do is connect to our vCenter server
    Connect-VIServer -Server 192.168.10.59 -User root -Password P@rtn3r1
      
    # Get the CanonicalName of our storage LUN
    $lun = (Get-SCSILun -VMhost 192.168.10.59 -LunType Disk | ? { $_.RuntimeName.StartsWith("vmhba1") }).CanonicalName
      
    # Create a new datastore
    New-Datastore -VMHost 192.168.10.59 -Name 'VMFS_Datastore_1' -Path $lun -vmfs
  EOH
  retries 5
  retry_delay 60
end

cookbook_file "#{Chef::Config['file_cache_path']}/vcenter_config.json" do
  source 'vcenter_config.json'
end

execute 'inject the vcenter instance' do
  command "C:\\VMware-VCSA\\vcsa-cli-installer\\win32\\vcsa-deploy.exe install --accept-eula --no-esx-ssl-verify --acknowledge-ceip #{Chef::Config['file_cache_path']}/vcenter_config.json"
end

powershell_script 'Creating inital Datacenter' do

  code <<-EOH
  # Connect to the vCenter Instance
  Connect-VIServer -Server 192.168.10.100 -User administrator@vsphere.local -Password P@rtn3r1

  # Name of the Datacenter
  $datacenter = "Chef-Demo"

  # Root level location
  $location = Get-Folder -NoRecursion

  # Create the Datacenter object
  New-Datacenter -Location $location -Name $datacenter
  EOH
end

powershell_script 'Adding ESXi host to Datacenter' do

  code <<-EOH
    # Connect to the vCenter Instance
    Connect-VIServer -Server 192.168.10.100 -User administrator@vsphere.local -Password P@rtn3r1

    # Name of the Datacenter
    $datacenter = "Chef-Demo"

    # ESXi host
    $esx = "192.168.10.59"

    Add-VMHost -Name $esx -Location (Get-Datacenter $datacenter) -Force -RunAsync -Confirm:$false -User "root" -Password "P@rtn3r1"  EOH
end

powershell_script 'Pull down a CentOS OVA to start off with' do

    code <<-EOH
      # Pull down a premade OVA for CentOS
      Invoke-WebRequest http://s3.asgharlabs.io/vmware/centos7.ova -Outfile Chef::Config['file_cache_path']/centos7.ova
      
      # Connect to the vCenter Instance
      Connect-VIServer -Server 192.168.10.100 -User administrator@vsphere.local -Password P@rtn3r1

      # Enject the OVA in to the vCenter instance
      Get-VMHost -Name '192.168.10.59' | Import-vApp -Source 'Chef::Config['file_cache_path']/centos7.ova'

    EOH
end