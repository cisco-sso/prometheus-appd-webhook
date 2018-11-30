# Prometheus AlertManager to AppD APM Webhook

## Work in Progress

### Theory of Operation

This effort aims to take configured alert flow from Prometheus AlertManager and forward it on to Application Dynamics (AppD) APM for further processing.

On the Prometheus side, this will be done through the [webhook method](https://prometheus.io/docs/alerting/configuration/#webhook_config).  Specifically:

Whether or not to notify about resolved alerts.  

```
[ send_resolved: <boolean> | default = true ]
```
The endpoint to send HTTP POST requests to.  

```
url: <string>
```

The HTTP client's configuration.  

```
[ http_config: <http_config> | default = global.http_config ]
```

The Alertmanager will send HTTP POST requests in the following JSON format to the configured endpoint:  

```
{
  "version": "4",
  "groupKey": <string>,    // key identifying the group of alerts (e.g. to deduplicate)
  "status": "<resolved|firing>",
  "receiver": <string>,
  "groupLabels": <object>,
  "commonLabels": <object>,
  "commonAnnotations": <object>,
  "externalURL": <string>,  // backlink to the Alertmanager.
  "alerts": [
    {
      "status": "<resolved|firing>",
      "labels": <object>,
      "annotations": <object>,
      "startsAt": "<rfc3339>",
      "endsAt": "<rfc3339>",
      "generatorURL": <string> // identifies the entity that caused the alert
    },
    ...
  ]
}
```

On the APM side, alerts will be received by the APM controller.  Since APM does not expose a cloud API, the only way to get alerts into APM is via the [Standalone Machine Agent HTTP Listener](https://docs.appdynamics.com/display/PRO44/Standalone+Machine+Agent+HTTP+Listener) "Create Events" API.  Specifically:

###Create Events

Use to post custom events to the Machine Agent for uploading to the Controller. Define one or more events in the body of the request as JSON data. Example:

```
POST /api/v1/events  
[
  {
    "eventSeverity": <event_severity>,
    "type": "<event_type>",
    "summaryMessage": "<event_summary>",
    "properties": {
      "<key>": {
        <user-specified_object>
      },...
    },
    "details": {
      "<key>": "<value>"
    }
  },
  {
    "eventSeverity": <event_severity>,
    "type": "<event_type>",
    "summaryMessage": "event_summary>",
    "properties": {
      "<key>": {
        <user-specified_object>
      },...
    },
    "details": {
      "<key>": "<value>"
    }
  },...
]
```

## Deployment Model

This is intented to bridge Alerts from a Prometheus running in k8s into an AppD APM running outside k8s.  We need to host a relatively heavy AppD Machine Agent as well as a means to translate the POST from Prometheus into a POST to the Machine Agent.

This solution is a small custom golang module to receive the Prometeus POST, transform the format, and then POST the solution to APM.  This will be packaged as a k8s service.  The pod definition for this service will include the AppD Machine Agent as well as this module.  When deployed into k8s it will be a highly available service to bridge Prometheus Alerts into AppD.




