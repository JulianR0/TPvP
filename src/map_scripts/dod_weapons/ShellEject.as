/**
* NO MATTER WHAT YOU DO
* DO NOT DELETE THIS FILE
* IT IS USED BY ALL WEAPONS
* Author: KernCore & Solokiller
* Contact: Sven Co-op Forums
*
*
* ACTUALLY, YES. DELETE THIS FILE
* BECAUSE ONLY AN IDIOT CREATES ANOTHER FILE
* WITH THE SAME FUNCTION ON EVERY WEAPON PACK.
* YES I'M MAD. -Giegue
*
**/

void WW2DynamicTracer( Vector start, Vector end, NetworkMessageDest msgType = MSG_BROADCAST, edict_t@ dest = null )
{
	NetworkMessage WW2DT( msgType, NetworkMessages::SVC_TEMPENTITY, dest );
	WW2DT.WriteByte( TE_TRACER );
	WW2DT.WriteCoord( start.x );
	WW2DT.WriteCoord( start.y );
	WW2DT.WriteCoord( start.z );
	WW2DT.WriteCoord( end.x );
	WW2DT.WriteCoord( end.y );
	WW2DT.WriteCoord( end.z );
	WW2DT.End();
}

void WW2DynamicLight( Vector vecPos, int radius, int r, int g, int b, int8 life, int decay )
{
	NetworkMessage WW2DL( MSG_PVS, NetworkMessages::SVC_TEMPENTITY );
		WW2DL.WriteByte( TE_DLIGHT );
		WW2DL.WriteCoord( vecPos.x );
		WW2DL.WriteCoord( vecPos.y );
		WW2DL.WriteCoord( vecPos.z );
		WW2DL.WriteByte( radius );
		WW2DL.WriteByte( int(r) );
		WW2DL.WriteByte( int(g) );
		WW2DL.WriteByte( int(b) );
		WW2DL.WriteByte( life );
		WW2DL.WriteByte( decay );
	WW2DL.End();
}

enum WW2InShoulder_e
{
	NotInShoulder = 0,
	InShoulder
};

enum WW2Bipod_e
{
	BIPOD_UNDEPLOY = 0,
	BIPOD_DEPLOY
};

enum WW2ScopedSniper_e
{
	MODE_NOSCOPE = 0,
	MODE_SCOPED
};

enum WW2ScopedRifle_e
{
	MODE_UNSCOPE = 0,
	MODE_SCOPE
};

/*
* Modify those strings below to
* Translate the messages to your language
*/

const string MGToDeploy = "Agachate antes de apuntar\n";
const string MGWaterDeploy = "No puedes apuntar en el agua\n";
const string MGReloadDeploy = "Debes apuntar antes de recargar\n";
const string ROCKETDeploy = "Apunta antes de disparar\n";
const string ROCKETCantOnAir = "No puedes disparar esta arma en el aire\n";
