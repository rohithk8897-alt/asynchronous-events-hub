# asynchronous-events-hub — ac-loy-eventhub (portfolio showcase)

A self-contained Mule 4 app demonstrating **asynchronous event processing with
API-led connectivity**. Events land on a queue, get **dynamically routed** to
the right processing flow based on a JSON registry (no hardcoded branching),
and flow down through Experience → Process → System layers to a downstream
"system of record".

**Zero infrastructure to run** — no external message broker and no database.
The queue is Mule's in-JVM **VM connector**, and the downstream system is a
**local mock flow** inside the same app. Clone it, open it in Anypoint Studio,
run it.

## Architecture

```
                POST /events (injector)
                        │
                        ▼
              VM queue  eventhub.inbound
                        │
                        ▼
        ac-loy-eventhub-consumer  (VM listener)
                        │
        reads notificationTypeToFlow.json  ──►  dynamic flow-ref
                        │
          ┌─────────────┴──────────────┐
          │ mapped                      │ unmapped / error
          ▼                             ▼
  x-loy-events-account-created  eventhub-dead-letter
     (x: route/validate)            → VM queue eventhub.dlq
          │
          ▼
  p-loy-events-profile-update
     (p: orchestrate, map to system contract, retry)
          │
          ▼
  s-system-record-upsert
     (s: single outbound HTTP call)
          │
          ▼
  mock-system-of-record  (local HTTP 200 — swap for a real API in properties)
```

### Layers (API-led)
| Layer | Flow | Responsibility |
|-------|------|----------------|
| Experience / Router (`x-`) | `x-profile-created` | Thin: validate + delegate to `p-` |
| Process (`p-`) | `p-profile-created` | Orchestrate: map to system contract, retry |
| System (`s-`) | `s-system-record-upsert` | Exactly one outbound HTTP call |
| Consumer | `ac-loy-eventhub-consumer` | VM listener + dynamic routing, no per-type logic |
| Test harness | `x-eventhub-inject`, `mock-system-of-record` | Inject events / stand in for the downstream | helps to inject event through postman and http listener for local mock testing.

### Dynamic routing
`src/main/resources/notificationTypeToFlow.json` maps `eventType → x-flow`:

```json
{ "accountCreated": "x-profile-created" }
```

The consumer reads this at runtime and dispatches with `<flow-ref name="#[vars.targetFlow]"/>`.
**Adding a new event type = one JSON entry + one new `x-` flow. The consumer
never changes.** Unmapped types are parked on the VM dead-letter queue.

## Run it in 3 steps

1. **Import** into Anypoint Studio: *File → Import → Anypoint Studio project
   from File System* → select this folder. Studio resolves `pom.xml` and its
   connectors (needs your Anypoint Exchange credentials in `~/.m2/settings.xml`
   — see `settings.xml.example`).
2. **Run** the project (Run As → Mule Application). It starts on port `8081`;
   no queue, broker, or database setup required.
3. **Fire an event** (below) and watch the console log the full chain.

### Sample calls

Routed event (happy path):
```bash
curl -X POST http://localhost:8081/events \
  -H "Content-Type: application/json" \
  -d '{"eventType":"accountCreated","memberId":"M1","payload":{"balance":5000,"currency":"POINTS"}}'
```
Returns `202 Accepted`. Console shows: consumer received → routed to
`x-profile-created` → `p-` → `s-` → mock system `200`.

Unmapped event (dead-letter path):
```bash
curl -X POST http://localhost:8081/events \
  -H "Content-Type: application/json" \
  -d '{"eventType":"UNKNOWN_EVENT","memberId":"M9","payload":{}}'
```
Returns `202`; the consumer finds no route and parks it on `eventhub.dlq`.

Health:
```bash
curl http://localhost:8081/health
```

## Project layout

```
pom.xml
mule-artifact.json
src/main/mule/
  global.xml                              # VM, HTTP listener, downstream requester, Object Store
  util/mock-downstream.xml                # local mock system of record (HTTP 200)
  x/x-eventhub-inject.xml                 # POST /events injector + /health
  x/ac-loy-eventhub-consumer.xml          # VM consumer + dynamic routing + DLQ
  x/x-loy-eventhub-balance-updates.xml    # experience/router layer
  p/p-loy-eventhub-balance-update.xml     # process layer
  s/s-system-record-upsert.xml            # system layer (one HTTP call)
src/main/resources/
  ac-loy-eventhub.properties              # all config (no secrets)
  notificationTypeToFlow.json             # eventType -> x-flow routing registry
```

## Production alternatives (called out deliberately)

This POC favors zero-setup reproducibility. In a real deployment:

- **Transport** — replace the VM connector with **IBM MQ** or **Anypoint MQ**
  for durable, cross-application messaging. The consumer logic is unchanged;
  only the listener/config swaps.
- **Downstream / persistence** — point `ac.loy.eventhub.downstream.*` at a real
  system API, or replace the s-layer with a Database/DynamoDB connector.
- **Registry caching** — the consumer reads `notificationTypeToFlow.json` per
  message via `readUrl`. For higher throughput, cache it in the provided
  `Registry_Store` object store or load it once at startup.

## Status

Working POC skeleton: one end-to-end event type (`accountCreated`) exercising
all layers plus dynamic routing and a dead-letter path. Extend by adding
registry entries and new `x-`/`p-`/`s-` flows.
