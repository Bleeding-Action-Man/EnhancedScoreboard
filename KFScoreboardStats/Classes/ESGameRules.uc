// Class originally credited for FPP
// Slightly modified by Vel-San to remove Patriach kills counter

class ESGameRules extends GameRules;

function PostBeginPlay()
{
    if(Level.Game.GameRulesModifiers == none)
    {
        Level.Game.GameRulesModifiers = self;
    }
    else
    {
        Level.Game.GameRulesModifiers.AddGameRules(self);
    }
}

function AddGameRules(GameRules GR)
{
    if(GR != self)
    {
        super.AddGameRules(GR);
    }
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, Vector HitLocation)
{
    if(((DamageType == none) || Killer == none) || Killed == none)
    {
        if(NextGameRules != none)
        {
            return NextGameRules.PreventDeath(Killed, Killer, DamageType, HitLocation);
        }
        return false;
    }
    if((Killed.IsA('ZombieFleshPound') && Killer != none) && ESPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none)
    {
        ++ ESPlayerReplicationInfo(Killer.PlayerReplicationInfo).FPKills;
    }
    if((Killed.IsA('ZombieScrake') && Killer != none) && ESPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none)
    {
        ++ ESPlayerReplicationInfo(Killer.PlayerReplicationInfo).SCKills;
    }
    if((Killed.IsA('ZombieHusk') && Killer != none) && ESPlayerReplicationInfo(Killer.PlayerReplicationInfo) != none)
    {
        ++ ESPlayerReplicationInfo(Killer.PlayerReplicationInfo).HSKills;
    }
    if(NextGameRules != none)
    {
        return NextGameRules.PreventDeath(Killed, Killer, DamageType, HitLocation);
    }
    return false;
}

function int NetDamage(int OriginalDamage, int Damage, Pawn injured, Pawn instigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    if(NextGameRules != none)
    {
        return NextGameRules.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
    }
    return Damage;
}