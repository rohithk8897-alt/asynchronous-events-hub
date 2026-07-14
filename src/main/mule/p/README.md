# p-layer (Process)

Two kinds of flows live here:

- **Sub-process** `p-<name>-<step>.xml` — one discrete business-logic step,
  delegates its actual system call(s) to one or more s-layer flows.
- **Parent process** `p-<name>.xml` — orchestrates the sub-process steps for
  one event type end-to-end, owns checkpointing (`checkPoint`, `deliveryDelay`,
  `deliveryDelayUnit`) and compensation/error handling.

Naming: `p-<name>-<step>.xml` (sub-process) / `p-<name>.xml` (parent),
flow name matches file name minus extension.
