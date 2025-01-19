using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Firebase.Database;
using Firebase.Database.Query;
using Google.Apis.Auth.OAuth2;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FirebaseBackend.Controllers;
using Newtonsoft.Json;

namespace FirebaseBackend.Services
{
    public class FirebaseService
    {
        private readonly FirebaseClient _firebaseClient;

        public FirebaseService()
        {
            // Initialiser Firebase Admin SDK
            FirebaseApp.Create(new AppOptions 
            {
                Credential = GoogleCredential.FromFile("smart-energie-irm2-4-firebase-adminsdk-pox97-f18f7008a6.json") // Chemin vers le fichier JSON
            });

            // Initialiser le client pour Firebase Realtime Database
            string firebaseDatabaseUrl = "https://smart-energie-irm2-4-default-rtdb.firebaseio.com/"; // Remplacez par l'URL de votre base de données
            _firebaseClient = new FirebaseClient(firebaseDatabaseUrl);
        }

        // Récupérer les données depuis Firebase
        // Service Firebase
        public async Task<Entry> GetDataAsync(string path)
        {
            try
            {
                // Récupérer le nœud principal "Smart_Energie"
                var smartEnergieData = await _firebaseClient
                    .Child(path) // Par exemple "Smart_Energie"
                    .OnceSingleAsync<dynamic>(); // Récupération brute des données

                // Vérifiez si les données existent
                if (smartEnergieData == null)
                {
                    Console.WriteLine("Aucune donnée trouvée pour le chemin spécifié.");
                    return null; // Retourne null si aucune donnée
                }

                // Désérialisation manuelle en raison de la structure spécifique
                var entry = new Entry
                {
                    Current = smartEnergieData["data"]["Current"],
                    Voltage = smartEnergieData["data"]["Voltage"],
                    kWh = smartEnergieData["data"]["kWh"],
                    Temps = smartEnergieData["temps"]
                };

                return entry;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erreur lors de la récupération des données Firebase : {ex.Message}");
                throw;
            }
        }











        // Envoyer une notification via Firebase Cloud Messaging
        public async Task SendNotificationAsync(string title, string body)
        {
            var message = new Message
            {
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                },
                Topic = "notifications"
            };
            await FirebaseMessaging.DefaultInstance.SendAsync(message);
        }
    }
}
