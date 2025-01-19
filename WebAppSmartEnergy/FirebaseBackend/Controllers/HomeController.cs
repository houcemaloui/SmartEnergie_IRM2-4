using FirebaseBackend.Services;
using Microsoft.AspNetCore.Mvc;

namespace FirebaseBackend.Controllers
{
    public class HomeController : Controller
    {
        private readonly FirebaseService _firebaseService;

        public HomeController(FirebaseService firebaseService)
        {
            _firebaseService = firebaseService;
        }

        public async Task<IActionResult> Index()
        {
            try
            {
                // Récupérer les données initiales depuis Firebase
                var entry = await _firebaseService.GetDataAsync("Smart_Energie");

                // Ajouter les données dans ViewBag pour l'affichage initial
                ViewBag.FirebaseData = entry;

                return View();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erreur : {ex.Message}");
                return View();
            }
        }

        [Route("api/Home/MobileData")]
        [HttpGet]
        public async Task<IActionResult> GetMobileData()
        {
            try
            {
                var entry = await _firebaseService.GetDataAsync("Smart_Energie");

                if (entry == null)
                {
                    return NotFound(new { Message = "Aucune donnée disponible." });
                }

                // Retourner un format JSON adapté pour le mobile
                return Ok(new
                {
                    Voltage = entry.Voltage,
                    Current = entry.Current,
                    kWh = entry.kWh,
                    Temps = entry.Temps
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = $"Erreur : {ex.Message}" });
            }
        }


    }

}
