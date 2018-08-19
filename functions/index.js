
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

let functions = require('firebase-functions');

let admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendNotification = functions.database.ref('/ACTIVE RIDES/{email}/notify').onWrite((change, context) => {
	
	//get the email of the person receiving the notification because we need to get their token
    const receiverEmail = change.after.child('email').val();
    console.log("receiverId: ", receiverEmail);
	
	//get the token of the user receiving the message
	return admin.database().ref("/ACTIVE RIDES/" + receiverEmail).once('value').then(snap => {
		const token = snap.child("token").val();
		console.log("token: ", token);
		
		//we have everything we need
		//Build the message payload and send the message
		console.log("Construction the notification message.");
		const payload = {
			data: {
				data_type: "direct_message",
				title: "Your ride is here!",
				message: "message",
				message_id: "messageId",
			}
		};
		
		return admin.messaging().sendToDevice(token, payload)
					.then(function(response) {
						console.log("Successfully sent message:", response);
					  })
					  .catch(function(error) {
						console.log("Error sending message:", error);
					  });
	});
});