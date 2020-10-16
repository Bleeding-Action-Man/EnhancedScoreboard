class ESPlayerReplicationInfo extends KFPlayerReplicationInfo;

var int FPKills;
var int SCKills;
var int HSKills;

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        FPKills,
        HSKills,
        SCKills
}