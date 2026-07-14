%dw 2.0
output application/json
---
{
	"event": {
		"source": Mule::p('asynchronous.events.ibm.mq.message.republish.event.source.default'),
		"eventType": Mule::p('asynchronous.events.ibm.mq.destination.message.type.invalidate.member.context'),
		"eventId": vars.eip_correlation_id,
		"timestamp": now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"},
		"saga": {
			"source": Mule::p('asynchronous.events.ibm.mq.message.republish.event.source.default'),
			"sagaName": Mule::p('asynchronous.events.ibm.mq.message.republish.event.saga.name.default'),
			"sagaId": vars.eip_correlation_id,
		}
	},
	"message": [vars.iamRequestPayload]
}