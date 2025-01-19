using Microsoft.AspNetCore.Mvc;
using FirebaseBackend.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;

namespace FirebaseBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FirebaseController : Controller
    {
        private readonly FirebaseService _firebaseService;

        public FirebaseController(FirebaseService firebaseService)
        {
            _firebaseService = firebaseService;
        }

        [HttpGet("data")]
        public async Task<IActionResult> GetData()
        {
            try
            {
                Console.WriteLine("Appel de la méthode GetData.");

                // Spécifiez le chemin correct, ici "Smart_Energie"
                var entry = await _firebaseService.GetDataAsync("Smart_Energie");

                // Vérifiez si les données existent
                if (entry == null)
                {
                    Console.WriteLine("Aucune donnée disponible.");
                    return Ok(new { Message = "Aucune donnée disponible." });
                }

                Console.WriteLine($"Données récupérées : Current={entry.Current}, Voltage={entry.Voltage}, kWh={entry.kWh}, Temps={entry.Temps}");
                return Ok(entry); // Retourne l'objet Entry
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erreur : {ex.Message}");
                return StatusCode(500, $"Erreur lors de la récupération des données : {ex.Message}");
            }
        }











        [HttpGet("view-data")]
        public IActionResult ViewData()
        {
            Console.WriteLine("Méthode ViewData appelée.");
            return View();
        }


        [HttpPost("notify")]
        public async Task<IActionResult> SendNotification([FromBody] NotificationRequest request)
        {
            await _firebaseService.SendNotificationAsync(request.Title, request.Body);
            return Ok("Notification envoyée.");
        }
    }

    public class Entry
    {
        public string Current { get; set; } // Exemple : "0.00A"
        public string Voltage { get; set; } // Exemple : "8.37V"
        public string kWh { get; set; }     // Exemple : "0.06436kWh"
        public string Temps { get; set; }  // Exemple : "0 Days, 00:31:38"
    }







    public class NotificationRequest
    {
        public string Title { get; set; }
        public string Body { get; set; }
    }
}
