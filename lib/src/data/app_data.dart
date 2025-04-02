import 'package:hitch/src/models/coach_experience_model.dart';
import 'package:hitch/src/models/player_level_model.dart';

class AppData{
  static List<PlayerLevelModel> get getPickleBallPlayerLevels {
    return [
      PlayerLevelModel(levelRank: '2.0', levelTitle: "Novice Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '3.0', levelTitle: "Intermediate Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '4.0', levelTitle: "Advanced Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '5.0', levelTitle: "Pro Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '6.0', levelTitle: "Pro Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '7.0', levelTitle: "Pro Pickleball (DUPR)"),
      PlayerLevelModel(levelRank: '8.0', levelTitle: "Pro Pickleball (DUPR)"),
    ];
  }

  static List<PlayerLevelModel> get getTennisBallPlayerLevels {
    return [
      PlayerLevelModel(levelRank: '2.0 - 3.5', levelTitle: "Beginner Tennis (UTR)"),
      PlayerLevelModel(levelRank: '2.5 - 4.0', levelTitle: "Beginner Tennis (UTR)"),
      PlayerLevelModel(levelRank: '3.5 - 5.0', levelTitle: "Intermediate Tennis (UTR)"),
      PlayerLevelModel(levelRank: '4.5 - 6.5', levelTitle: "Intermediate Tennis (UTR)"),
      PlayerLevelModel(levelRank: '6.5 - 9.0', levelTitle: "Advanced Tennis (UTR)"),
      PlayerLevelModel(levelRank: '9.5 - 11.5', levelTitle: "Advanced Tennis (UTR)"),
      PlayerLevelModel(levelRank: '11.5 - 13.5', levelTitle: "Pro Tennis (UTR)"),
    ];
  }

  static List<CoachExperienceModel> get getCoachPickleBallExperienceList {
    return [
      CoachExperienceModel(experienceInYears: '1-2 Years', gameTitle: "Pickleball"),
      CoachExperienceModel(experienceInYears: '3-4 Years', gameTitle: "Pickleball"),
      CoachExperienceModel(experienceInYears: '5-6 Years', gameTitle: "Pickleball"),
      CoachExperienceModel(experienceInYears: '7-8 Years', gameTitle: "Pickleball"),
      CoachExperienceModel(experienceInYears: '10+ Years', gameTitle: "Pickleball"),
    ];
  }

  static List<CoachExperienceModel> get getCoachTennisBallExperienceList {
    return [
      CoachExperienceModel(experienceInYears: '1-2 Years', gameTitle: "Tennis"),
      CoachExperienceModel(experienceInYears: '3-4 Years', gameTitle: "Tennis"),
      CoachExperienceModel(experienceInYears: '5-6 Years', gameTitle: "Tennis"),
      CoachExperienceModel(experienceInYears: '7-8 Years', gameTitle: "Tennis"),
      CoachExperienceModel(experienceInYears: '10+ Years', gameTitle: "Tennis"),
    ];
  }

  static List<String> get genders {
   return [
     "Male",
     "Female"
   ];
  }

  static List<Map<String, dynamic>> get daysAvailable {
    return [
      {
        'day' : 'Monday',
        'isSelected' : false
      },
      {
        'day' : 'Tuesday',
        'isSelected' : false
      },
      {
        'day' : 'Wednesday',
        'isSelected' : false
      },
      {
        'day' : 'Thursday',
        'isSelected' : false
      },
      {
        'day' : 'Friday',
        'isSelected' : false
      },
      {
        'day' : 'Saturday',
        'isSelected' : false
      },
      {
        'day' : 'Sunday',
        'isSelected' : false
      },
    ];
  }
}