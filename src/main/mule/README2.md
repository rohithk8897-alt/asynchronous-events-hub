#Consumer layer(Process)

Main consuming flow lives here: where a message would be replayed based on checkPoint level system, where each message would be replayed with increment level
where attributes or payload details can be used based on type of message queue we choose(ibm mq or vm mq).

-< In the below we have used vm queue for POC< however with other message queue we have an option to utilize attributes using user properties during publish>


- **Sub-process** `x-<name>-<step>.xml` — one dynamic business-logic step, where message can be routed based on eventType
  delegates its actual system call(s) to one or more s-layer flows.
- **Parent process** `p-<name>.xml` — orchestrates the sub-process steps for
  one event type end-to-end, owns checkpointing (`checkPoint`, `deliveryDelay`,
  `deliveryDelayUnit`) and exception/error handling.

Naming to follow:  `p-<name>.xml` (parent) / `p-<name>-<step>.xml` (sub-process) 
flow name matches file name minus extension.
