# Ruby Zabbix Api Module

Simple and lightweight ruby module for working with [Zabbix][Zabbix] via the [Zabbix API][Zabbix API]

## Installation

```ruby
# Gemfile
gem 'zabbixapi', github: 'connorgallopo/zabbixapi'
```

## Quick Start

```ruby
require 'zabbixapi'

zabbix = ZabbixApi.connect(
  url: 'https://zabbix.example.com/api_jsonrpc.php',
  user: 'Admin',
  password: 'zabbix'
)

# Get all hosts
zabbix.hosts.all

# Get a host ID
zabbix.hosts.get_id(host: 'myhost.example.com')

# Create a host
zabbix.hosts.create(
  host: 'myhost.example.com',
  interfaces: [{
    type: 1,
    main: 1,
    ip: '192.168.1.1',
    dns: '',
    port: '10050',
    useip: 1
  }],
  groups: [{ groupid: '2' }]
)
```

## History

Retrieve historical metric data from Zabbix:

```ruby
# History value types
ZabbixApi::History::NUMERIC_FLOAT    # 0
ZabbixApi::History::CHARACTER        # 1
ZabbixApi::History::LOG              # 2
ZabbixApi::History::NUMERIC_UNSIGNED # 3
ZabbixApi::History::TEXT             # 4
ZabbixApi::History::BINARY           # 5

# Get history for an item
zabbix.history.get(itemids: '12345', history: ZabbixApi::History::NUMERIC_UNSIGNED)

# Get the latest value
zabbix.history.get_latest(item_id, ZabbixApi::History::NUMERIC_UNSIGNED)

# Get the latest value as a number
nvps = zabbix.history.get_latest_value(item_id, ZabbixApi::History::NUMERIC_UNSIGNED)

# Get history within a time range
zabbix.history.get_range(item_id, time_from, time_till, ZabbixApi::History::NUMERIC_UNSIGNED)

# Count history records
zabbix.history.count(item_id, ZabbixApi::History::NUMERIC_UNSIGNED)
```

### Example: Get NVPS (New Values Per Second)

```ruby
# Find the NVPS item on the Zabbix server
items = zabbix.items.get_full_data(key_: 'zabbix[wcache,values]')
item_id = items.first['itemid']

# Get current NVPS
nvps = zabbix.history.get_latest_value(item_id, ZabbixApi::History::NUMERIC_UNSIGNED)
puts "Current NVPS: #{nvps}"
```

## Available Resources

- `actions` - Trigger actions
- `applications` - Applications (deprecated in Zabbix 5.4+)
- `configurations` - Import/export configurations
- `drules` - Discovery rules
- `events` - Events
- `graphs` - Graphs
- `history` - Historical data
- `hostgroups` - Host groups
- `hosts` - Hosts
- `httptests` - Web scenarios
- `items` - Items
- `maintenance` - Maintenance periods
- `mediatypes` - Media types
- `problems` - Problems
- `proxies` - Proxies
- `proxygroup` - Proxy groups (Zabbix 7+)
- `roles` - User roles
- `screens` - Screens (deprecated)
- `scripts` - Scripts
- `server` - Server info
- `templates` - Templates
- `triggers` - Triggers
- `usergroups` - User groups
- `usermacros` - User macros
- `users` - Users
- `valuemaps` - Value maps

## Raw API Queries

```ruby
zabbix.query(
  method: 'host.get',
  params: {
    output: 'extend',
    filter: { host: 'myhost' }
  }
)
```

## Logout

```ruby
zabbix.logout
```

## Version Support

This fork supports:
- Zabbix 5.x, 6.x, 7.x
- Ruby 3.1+

## Dependencies

- net/http (stdlib)
- json

## Zabbix Documentation

- [Zabbix Project Homepage][Zabbix]
- [Zabbix API docs][Zabbix API]

[Zabbix]: https://www.zabbix.com
[Zabbix API]: https://www.zabbix.com/documentation/current/en/manual/api
