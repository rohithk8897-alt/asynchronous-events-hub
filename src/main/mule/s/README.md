# s-layer (System)

Each flow here (`s-<system>-<action>.xml`) makes exactly **one** outbound call
to a single external system and returns a normalized response. No
orchestration, no business logic — just protocol translation and error mapping
for one downstream dependency.

In this POC the only s-flow is `s-sor-create-profile`, which makes one HTTP
call to the downstream "system of record" (a local mock by default — see
`Downstream_Request_config` in `global.xml`).

Naming: `s-<system>-<action>.xml`, flow `s-<system>-<action>`.

Add flows here as new event types require calls to new downstream systems.
