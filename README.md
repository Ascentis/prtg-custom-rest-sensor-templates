# prtg-custom-rest-sensor-templates
PRTG custom REST sensor templates

This repository contains a collection of .template files used within the PRTG monitoring platform that allow to parse REST calls and map to PRTG sensor-channels.

Current collections:

TrueNAS monitoring for:

* Pool health
* Pool disks health
* Pool free space (percentage)
* Replication health

PRTG custom sensor documentation at: https://www.paessler.com/manuals/prtg/custom_sensors#advanced_sensors

JSONPath online evaluator: https://jsonpath.com

Example usage of rest.exe utility contained within PRTG to test REST custom sensors:

Within PowerShell or Windows cmd, cd until you get to C:\Program Files (x86)\PRTG Network Monitor\Sensor System
Use the rest.exe contined within that folder in the following way:

.\rest.exe http://<IP Address of TrueNAS>/api/v2.0/pool "..\Custom Sensors\rest\truenas.generic.pool.freespace.template" -customheaders "Authorization:<Your TrueNAS Authorhization token>"

You should see a response like this in the console:

```json
{
  "prtg": {
    "result": [
      {
        "channelid": 0,
        "Value": 169,
        "Unit": "TimeResponse",
        "ShowChart": 0,
        "ShowTable": 0
      },
      {
        "channel": "USMacProRAIDZ",
        "Value": 39.1587156010425,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "default",
        "Value": 98.34172341131395,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "FileSharePool",
        "Value": 99.99491070944165,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "mvdmacproraidzpool",
        "Value": 42.04015769357756,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "MVDRAIDZS2DPOOL",
        "Value": 96.6840416973174,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "MVDSQLBackups",
        "Value": 99.99959606150682,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "USRaidZPool",
        "Value": 77.42501135271881,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      },
      {
        "channel": "DFSStorageTest",
        "Value": 99.77613879788306,
        "Unit": "Percent",
        "Float": 1,
        "LimitMinWarning": 10,
        "LimitMinError": 5,
        "LimitMode": 1
      }
    ]
  }
}
```