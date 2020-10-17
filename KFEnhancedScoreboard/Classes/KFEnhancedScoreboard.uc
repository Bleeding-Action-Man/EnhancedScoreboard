// TODO: Credits to FPP & SP Goes here
// TODO: Change directory parent to KFEnhancedScoreboard

class KFEnhancedScoreboard extends Mutator;

var ESGameRules ESGR;

function PostBeginPlay()
{
    Level.Game.ScoreBoardType = "KFEnhancedScoreboard.EnhancedScoreboard";
    ESGR = Spawn(class'ESGameRules');
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if(PlayerController(Other) != none)
    {
        PlayerController(Other).PlayerReplicationInfoClass = class'ESPlayerReplicationInfo';
    }
    return true;
}

defaultproperties
{
    bAddToServerPackages=true
    GroupName="KF-EnhancedScoreboard"
    FriendlyName="EnhancedScoreboard - v1.1"
    Description="Based on ServerPerks Scoreboard, this is an enhanced version with Headshots, Husks, Scrakes & Fleshpound kills counters!; Modified by Vel-San"
}