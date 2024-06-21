
daemonSet: [ID=_]: _spec & {
    apiVersion: "apps/v1"
    kind:       "DaemonSet"
    _name:      ID
}

statefulSet: [ID=_]: _spec & {
    apiVersion: "apps/v1"
    kind:       "StatefulSet"
    _name:      ID
}

deployment: [ID=_]: _spec & {
    apiVersion: "apps/v1"
    kind:       "Deployment"
    _name:      ID
    spec: replicas: *1 | int
}

configMap: [ID=_]: {
    metadata: name: ID
    metadata: labels: component: #Component
}

_spec: {
    _name: string

    metadata: name: _name
    metadata: labels: component: #Component
    spec: selector: {}
    spec: template: {
        metadata: labels: {
            app:       _name
            component: #Component
            domain:    "prod"
        }
        spec: containers: [{name: _name}]
    }
}
