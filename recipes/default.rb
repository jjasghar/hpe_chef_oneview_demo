require 'oneview-sdk'
my_client = { url: 'https://192.168.20.20', user: 'Administrator', password: '***REMOVED***', api_version: 500 }
# r_client = OneviewSDK::Client.new(user: 'Administrator', password: '***REMOVED***',  url: 'https://192.168.20.20', api_version: 500)

# Create a new fiber channel network
oneview_fc_network 'FCNetwork1' do
  data(
    autoLoginRedistribution: true,
    fabricType: 'FabricAttach'
  )
  client my_client
  action :create
end

# Create a new fiber channel over ethernet network
oneview_fcoe_network 'FCoENetwork1' do
  data(
    vlanId: 2101,
    bandwidth: {
      typicalBandwidth: 2000,
      maximumBandwidth: 9000,
    }
  )
  associated_san 'VSAN2101'
  client my_client
  action :create
end

# Create a new ethernet network
oneview_ethernet_network 'EthernetNetwork1' do
  client my_client
  data(
    vlanId: 1001,
    purpose: 'General',
    smartLink: false,
    privateNetwork: false
  )
end

# Create an enclosure group
oneview_enclosure_group 'EnclosureGroup1' do
  data(
    stackingMode: 'Enclosure',
    portMappingCount: 8,
    portMappings: [
      { midplanePort: 1, interconnectBay: 1 },
      { midplanePort: 2, interconnectBay: 2 },
      { midplanePort: 3, interconnectBay: 3 },
      { midplanePort: 4, interconnectBay: 4 },
      { midplanePort: 5, interconnectBay: 5 },
      { midplanePort: 6, interconnectBay: 6 },
      { midplanePort: 7, interconnectBay: 7 },
      { midplanePort: 8, interconnectBay: 8 },
    ],
    interconnectBayMappingCount: 2,
    interconnectBayMappings: [
      { interconnectBay: 3, logicalInterconnectGroupUri: '/rest/logical-interconnect-groups/02c6d1b0-e081-4da4-beb4-1991451ec5d4' },
      { interconnectBay: 6, logicalInterconnectGroupUri: '/rest/logical-interconnect-groups/02c6d1b0-e081-4da4-beb4-1991451ec5d4' },
    ],
    ipAddressingMode: 'IpPool',
    ipRangeUris: ['/rest/id-pools/ipv4/ranges/c8f08983-f55f-4894-99e5-497e57ff2081'],
    powerMode: 'RedundantPowerFeed',
    description: nil,
    enclosureCount: 3,
    associatedLogicalInterconnectGroups: ['/rest/logical-interconnect-groups/02c6d1b0-e081-4da4-beb4-1991451ec5d4']
  )
  logical_interconnect_groups ['MLAG-ImageStreamer']
  client my_client
  action :create
end

oneview_server_profile 'RHEL7_Chef_Test_2' do
  client my_client
  server_hardware 'BOT-CN75150107, bay 11'
  server_hardware_type 'SY 480 Gen9 CNA Only'
  enclosure_group 'EnclosureGroup1'
  ethernet_network_connections [
    {
      Deploy: {
        name: 'Connection1',
        boot: {
          priority: "Primary",
        }
      },
    },
    {
      Deploy: {
        name: 'Connection2',
        boot: {
          priority: "Secondary",
        }
      },
    },
    {
      Mgmt: {
        name: 'Connection3',
      },
    },
    {
      Mgmt: {
        name: 'Connection4',
      },
    },
    {
      Production: {
        name: 'Connection5',
      },
    },
    {
      Production: {
        name: 'Connection6',
      },
    },
  ]
  data(
    bootMode: {
      manageMode: true,
      mode: 'BIOS'
    },
    boot: {
      manageBoot: true
    },
    description: 'RHEL 7.3 Demo Server Profile'
  )
  server_profile_template 'RedHat 7.3'
end
