from datadog import initialize, api

options = {
    'api_key': '',
    'app_key': ''
}

initialize(**options)

title = "Hiring Engineer Timeboard"
description = "An informative timeboard."
graphs = [{
    "definition": {
        "events": [],
        "requests": [
            {"q": "avg:my_metric{host:default-ubuntu-1604}"}
        ],
        "viz": "timeseries"
    },
    "title": "Avg of my_metric over host:default-ubuntu-1604"
},
{
    "definition": {
        "events": [],
        "requests": [
            {"q": "avg:my_metric{host:default-ubuntu-1604}.rollup(sum, 3600)"}
        ],
        "viz": "query_value"
    },
    "title": "custom metric with the rollup function applied, 1 hour"
},
{
    "definition": {
        "events": [],
        "requests": [
            {"q": "anomalies(avg:mysql.net.connections{host:default-ubuntu-1604}, 'basic', 2)"}
        ],
        "viz": "timeseries"
    },
    "title": "Avg of mysql.net.connections, with anomaly detection applied"
}]

template_variables = [{
    "name": "host1",
    "prefix": "host",
    "default": "host:my-host"
}]

read_only = True
api.Timeboard.create(title=title,
                     description=description,
                     graphs=graphs,
                     template_variables=template_variables,
                     read_only=read_only)