from firebase_admin import messaging

def send_guardian_notification(token: str, title: str, body: str):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=token
    )
    messaging.send(message)
