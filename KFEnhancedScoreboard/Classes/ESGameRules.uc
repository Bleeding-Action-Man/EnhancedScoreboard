// Class originally credited for FPP
// Credits for MaxyLos's I <3 Stats Mut for HeadShots!
// Slightly modified by Vel-San to remove Patriach kills counter and merge FPP with I <3 Stats

class ESGameRules extends GameRules;

struct MonsterInfo
{
    var KFMonster Monster;

    // variables below are set after NetDamage() call
	var bool bHeadshot;
    var int HeadHealth; // track head health to check headshots
    var bool bWasDecapitated; // was the monster decapitated before last damage? If bWasDecapitated=true then bHeadshot=false
};
var array<MonsterInfo> MonsterInfos;
var private transient KFMonster LastSeachedMonster; //used to optimize GetMonsterIndex()
var private transient int       LastFoundMonsterIndex;

function PostBeginPlay()
{
    MonsterInfos.Length = KFGameType(Level.Game).MaxMonsters; //reserve a space that will be required anyway
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

///////////////////////// CREDITS FOR FPP /////////////////////////
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
///////////////////////////////////////////////////////////////////////////

///////////////////////// CREDITS FOR I <3 STATS /////////////////////////
// Creates a new record, if monster not found
function int GetMonsterIndex(KFMonster Monster)
{
    local int i, count, free_index;

    if ( LastSeachedMonster == Monster )
        return LastFoundMonsterIndex;

    count = MonsterInfos.length;
    free_index = count;
    LastSeachedMonster = Monster;
    for ( i = 0; i < count; ++i ) {
        if ( MonsterInfos[i].Monster == Monster ) {
            LastFoundMonsterIndex = i;
            return i;
        }
        if ( free_index == count && MonsterInfos[i].Monster == none )
            free_index = i;
    }
    // if reached here - no monster is found, so init a first free record
    if ( free_index >= MonsterInfos.length ) {
        // if free_index out of bounds, maybe MaxZombiesOnce is changed during the game
        if ( MonsterInfos.length < KFGameType(Level.Game).MaxMonsters )
            MonsterInfos.insert(free_index, KFGameType(Level.Game).MaxMonsters - MonsterInfos.length);
        // MaxZombiesOnce was ok, just added extra monsters
        if ( free_index >= MonsterInfos.length )
            MonsterInfos.insert(free_index, 1);
    }
    ClearMonsterInfo(free_index);
    MonsterInfos[free_index].Monster = Monster;
    //MonsterInfos[free_index].HeadHealth = Monster.HeadHealth * Monster.DifficultyHeadHealthModifer() * Monster.NumPlayersHeadHealthModifer();
    MonsterInfos[free_index].HeadHealth = Monster.HeadHealth;
    LastFoundMonsterIndex = free_index;
    return free_index;
}

function ClearMonsterInfo(int index)
{
    MonsterInfos[index].Monster = none;
    MonsterInfos[index].HeadHealth = 0;
    MonsterInfos[index].bWasDecapitated = false;
}

function int NetDamage(int OriginalDamage, int Damage, Pawn injured, Pawn instigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    local int idx;
	local KFHumanPawn Player;
	local KFMonster ZedVictim;
	local class<KFWeaponDamageType> KFDamType;
	local bool bP2M;

	local PlayerController PC;
	local ESPlayerReplicationInfo ESPRI;

	KFDamType = class<KFWeaponDamageType>(DamageType);
	Player = KFHumanPawn(instigatedBy);//get attacker
	ZedVictim = KFMonster(injured);    //get attacked

    if(NextGameRules != none)
    {
        bP2M = ZedVictim != none && KFDamType != none && instigatedBy != none && PlayerController(instigatedBy.Controller) != none;
	    if ( bP2M )
	    {
	    	if(Player != None)
	    	{
	    		idx = GetMonsterIndex(ZedVictim);
            	MonsterInfos[idx].bHeadshot = !MonsterInfos[idx].bWasDecapitated && KFDamType.default.bCheckForHeadShots
                && (ZedVictim.bDecapitated || int(ZedVictim.HeadHealth) < MonsterInfos[idx].HeadHealth);

	    		PC = PlayerController(Player.Controller);

	    		ESPRI = ESPlayerReplicationInfo(PC.PlayerReplicationInfo);

            	if ( MonsterInfos[idx].bHeadshot )
	    		{
                    ESPRI.HDSKills++;
            	}
	    	}
        }
	    if ( bP2M )
	    {
            MonsterInfos[idx].HeadHealth = ZedVictim.HeadHealth;
            MonsterInfos[idx].bWasDecapitated = ZedVictim.bDecapitated;
        }
        return NextGameRules.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
    }
    return Damage;
}
///////////////////////////////////////////////////////////////////////////