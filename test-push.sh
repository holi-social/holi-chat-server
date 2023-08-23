# simple script to test pushing a message to Sygnal locally

#export URL=http://localhost:8050/_matrix/push/v1/notify
#export SERVERNAME=local.chat.holi.social

export URL=https://development-chat-push.holi.social/_matrix/push/v1/notify
export SERVERNAME=development-chat.holi.social

curl -i -H "Content-Type: application/json" --request POST -d '@-' $URL <<EOF
{
	"notification": {
		"event_id": "\$3957tyerfgewrf384",
			"room_id": "!OCJHQnWSFaSRPFBejq:$SERVERNAME",
			"type": "m.room.message",
			"sender": "@danielinoio:$SERVERNAME",
			"sender_display_name": "Daniel Holi",
			"room_name": "Mission Control",
			"room_alias": "#mission-control:$SERVERNAME",
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
        "pushkey": "76c2d0d9525d163d43ef00b2555a516144c8ffc6edd1eb10e2c5e1839c10f7dc",
        "pushkey_ts": 12345678,
        "data": {
          "url":"$URL",
          "default_payload": {
            "title": "holi Chat",
            "message": "You have a new message or invitation.",
            "experienceId": "@holistic-foundation/projectholi",
            "scopeKey": "@holistic-foundation/projectholi"
          }
        }
      }
    ]
  }
}
