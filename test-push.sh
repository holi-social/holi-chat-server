# simple script to test pushing a message to Sygnal locally

#export URL=http://localhost:8050/_matrix/push/v1/notify
export URL=https://staging-push.chat.holi.social/_matrix/push/v1/notify

curl -i -H "Content-Type: application/json" --request POST -d '@-' $URL <<EOF
{
	"notification": {
		"event_id": "\$3957tyerfgewrf384",
			"room_id": "!OCJHQnWSFaSRPFBejq:local.chat.holi.social",
			"type": "m.room.message",
			"sender": "@danielinoio:local.chat.holi.social",
			"sender_display_name": "Daniel Holi",
			"room_name": "Mission Control",
			"room_alias": "#mission-control:local.chat.holi.social",
			"prio": "high",
			"content": {
				"msgtype": "m.text",
				"body": "I'm floating in a most peculiar way."
			},
			"counts": {
				"unread": 2,
				"missed_calls": 1
			},
			"devices": [
			{
        "app_id": "social.holi.ios",
        "pushkey": "fd3ef01c3a49c80d8e09a92c197585db9121e53e162ec1dfc09a050473d91198",
        "pushkey_ts": 12345678,
        "data": {"url":"http://chat-push-gateway:5000/_matrix/push/v1/notify","default_payload":{"title":"holi Chat","message":"You have a new message or invitation.","experienceId":"@holistic-foundation/projectholi","scopeKey":"@holistic-foundation/projectholi"}}
      }
    ]
  }
}
