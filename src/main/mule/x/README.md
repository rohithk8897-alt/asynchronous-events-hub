# x-layer (Experience / Router)

Thin routing only. Each `x-<name>.xml` flow is triggered by the MQ consumer
flow, looks up the target parent process via `notificationTypeToFlow.json`,
and delegates to the matching `p-<name>` flow. No business logic here.

Naming: `x-<name>.xml`, flow `x-<name>`, referenced by value in
`src/main/resources/notificationTypeToFlow.json`.
