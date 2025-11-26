# Hardlopen met Virgil - iOS App API

## Overzicht
Deze API biedt toegang tot trainingsdata voor de iOS app. Alle endpoints vereisen authenticatie via sessie cookies (zoals de website gebruikt).

## Base URL
```
https://hardlopen.metvirgil.nl
```

## Authenticatie
Alle API calls moeten worden gedaan met dezelfde sessie cookies als de website. Gebruikers moeten eerst inloggen via de website om toegang te krijgen.

## Endpoints

### 1. Training van vandaag
**GET** `/api/training_sessions/today`

Retourneert de training voor vandaag.

**Response:**
```json
{
  "success": true,
  "training": {
    "id": 123,
    "date": "2025-10-03",
    "description": "Duurloop 5km",
    "loopscholing": "Core stabiliteit en lichte mobiliteitsoefeningen",
    "fase": "Opbouw",
    "wedstrijd": "Singelloop Utrecht (5 oktober)",
    "dag": "donderdag",
    "location": "GAC Clubhuis",
    "trainer": "Virgil Smit",
    "trainer_id": 5,
    "structured_core": [...],
    "kern": "10km rustig tempo uit schema",
    "tempozones": {
      "extensief": "5:30",
      "intensief": "4:45",
      "interval": "4:00",
      "sprint": "3:30"
    },
    "human_core": "Warming-up: 10 minuten...",
    "attendance": "aanwezig",
    "attendance_note": null
  }
}
```

### 2. Trainingen deze week
**GET** `/api/training_sessions/week`

Retourneert alle trainingen van deze week (maandag t/m zondag).

**Response:**
```json
{
  "success": true,
  "week_start": "2025-09-30",
  "week_end": "2025-10-06",
  "trainings": [
    {
      "id": 123,
      "date": "2025-10-02",
      "description": "Duurloop 5km",
      // ... andere velden zoals hierboven
    },
    // ... meer trainingen
  ]
}
```

### 3. Aankomende trainingen
**GET** `/api/training_sessions/upcoming`

Retourneert trainingen voor de komende 2 weken.

**Response:**
```json
{
  "success": true,
  "start_date": "2025-10-04",
  "end_date": "2025-10-17",
  "trainings": [
    // ... array van trainingen
  ]
}
```

### 4. Volledige trainingsschema
**GET** `/api/training_sessions/schedule`

Retourneert alle aankomende trainingen (maximaal 30).

**Response:**
```json
{
  "success": true,
  "trainings": [
    // ... array van trainingen
  ]
}
```

## Data Structuur

### Training Object
```json
{
  "id": 123,                    // Unieke ID
  "date": "2025-10-03",         // Datum (YYYY-MM-DD)
  "description": "Duurloop 5km", // Hoofdbeschrijving
  "loopscholing": "...",        // Loopscholing details
  "fase": "Opbouw",             // Trainingsfase
  "wedstrijd": "...",           // Gerelateerde wedstrijd
  "dag": "donderdag",           // Dag van de week
  "location": "GAC Clubhuis",   // Locatie
  "trainer": "Virgil Smit",     // Trainer naam
  "trainer_id": 5,              // Trainer ID
  "structured_core": [...],     // Gestructureerde kern data
  "kern": "10km rustig tempo",  // Samenvatting van kern
  "tempozones": {               // Tempo zones van gebruiker
    "extensief": "5:30",
    "intensief": "4:45", 
    "interval": "4:00",
    "sprint": "3:30"
  },
  "human_core": "...",          // Menselijke leesbare kern
  "attendance": "aanwezig",     // Aanwezigheid status
  "attendance_note": null       // Opmerking bij aanwezigheid
}
```

## Error Responses

### Geen training gevonden
```json
{
  "success": false,
  "message": "Geen training voor vandaag"
}
```

### Niet geauthenticeerd
```json
{
  "error": "not allowed"
}
```

## iOS App Implementatie

### Swift voorbeeld
```swift
import Foundation

class TrainingAPI {
    private let baseURL = "https://hardlopen.metvirgil.nl"
    
    func getTodayTraining() async throws -> Training? {
        let url = URL(string: "\(baseURL)/api/training_sessions/today")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TodayTrainingResponse.self, from: data)
        
        return response.success ? response.training : nil
    }
    
    func getWeekTrainings() async throws -> [Training] {
        let url = URL(string: "\(baseURL)/api/training_sessions/week")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeekTrainingResponse.self, from: data)
        
        return response.trainings
    }
}

struct TodayTrainingResponse: Codable {
    let success: Bool
    let training: Training?
    let message: String?
}

struct WeekTrainingResponse: Codable {
    let success: Bool
    let trainings: [Training]
}

struct Training: Codable {
    let id: Int
    let date: String
    let description: String
    let loopscholing: String?
    let fase: String?
    let wedstrijd: String?
    let dag: String
    let location: String
    let trainer: String?
    let trainerId: Int?
    let kern: String?
    let tempozones: TempoZones?
    let humanCore: String?
    let attendance: String?
    let attendanceNote: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, description, loopscholing, fase, wedstrijd, dag, location, trainer
        case trainerId = "trainer_id"
        case kern, tempozones
        case humanCore = "human_core"
        case attendance
        case attendanceNote = "attendance_note"
    }
}

struct TempoZones: Codable {
    let extensief: String?
    let intensief: String?
    let interval: String?
    let sprint: String?
}
```

## Gebruik in iOS App

1. **Authenticatie**: Gebruikers moeten eerst inloggen via Safari/WebView om sessie cookies te krijgen
2. **Data ophalen**: Gebruik de API endpoints om trainingsdata op te halen
3. **Caching**: Cache de data lokaal voor offline gebruik
4. **Updates**: Poll regelmatig voor nieuwe trainingen

## Rate Limiting
Er zijn momenteel geen rate limits, maar gebruik de API verantwoordelijk. Voor productie gebruik wordt aangeraden om caching te implementeren.

## Support
Voor vragen over de API, neem contact op met de ontwikkelaar.

