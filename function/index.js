const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.predictMaintenance = functions.database.ref('/sensors/data/{pushId}')
    .onCreate((snapshot, context) => {
      const data = snapshot.val();
      const { temperature, vibration, timestamp } = data;

      // Logique IA simple (seuils)
      let status = 'Normal';
      let probability = 0.1;
      let message = 'No action needed';

      if (temperature > 80 || vibration > 5) {
        status = 'Warning';
        probability = 0.6;
        message = 'Monitor closely';
      }
      if (temperature > 100 || vibration > 8) {
        status = 'Critical';
        probability = 0.9;
        message = 'Immediate maintenance required';
      }

      // Stocker la prédiction
      return admin.database().ref('/sensors/prediction').set({
        status,
        probability,
        message,
        timestamp
      });
    });