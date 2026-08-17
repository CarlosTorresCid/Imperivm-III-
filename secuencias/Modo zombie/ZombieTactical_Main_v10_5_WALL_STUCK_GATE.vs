// ZombieTactical_Main_v10_5_WALL_STUCK_GATE
// AUTORUN
//
// Fases:
// 0 MARCHA + DETECCION DE ATASCO EN MURALLA
// 1 SIEGE
// 2 BREACH_ADVANCE
// 3 CAPTURE
//
// En CAPTURE el Foro tiene prioridad absoluta.
// Sólo se vuelve a SIEGE si hay atasco real lejos del Foro y una Gate
// intacta está por delante de la horda respecto al Foro.
//
// No usa RunAIHelper ni enter.
// Siege se reintenta automáticamente si la Gate no pierde health y no aparece
// ningún holder durante la ventana de construcción.
//
// La captura final de loyalty es determinista desde Sequence:
// zombies a <=850 del Foro -> cada 2 s baja 1..10 puntos de loyalty.
// Al llegar a 1 -> Settlement pasa a Player 12 y loyalty queda en 11.
//
// Gate rota se aproxima mediante health<=1000, porque IsBroken no es
// accesible desde Sequence y en runtime se observó la Gate abierta a 1000/5000.
//
// V10.5:
// además de activar Siege por proximidad al Foro, detecta si la marcha deja
// de progresar y busca una Gate cerca de la propia horda. Esto cubre ciudades
// grandes donde la muralla/puerta queda lejos del Foro.
//

ObjList h;
ObjList q;
ObjList allTownhalls;
ObjList stateList;

Building state;
Building target;
Building cand;
Building gate;

Unit u;
point breachPoint;

IntArray phase;
IntArray marchTicks;
IntArray phaseTicks;
IntArray gateX;
IntArray gateY;
IntArray siegeHadHolder;
IntArray lastGateHealth;
IntArray siegeNoProgress;
IntArray lastForumDist;
IntArray captureStuck;
IntArray marchLastDist;
IntArray marchStuck;

int HP;
int H;
int i;
int j;
int pp;
int active;
int tx;
int ty;
int owner;
int rr;
int foundTarget;
int bestD;
int d;
int sampleCount;
int nearCount;
int nearestD;
int ga;
int gx;
int gy;
int nCat;
int bCat;
int nearbyGate;
int zombiesIn;
int drop;
int actualLoyalty;
int nearForumReady;
int stuckMarch;

HP=12;

stateList=Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();

if(stateList.count!=1)
{
    return;
}

state=stateList[0].AsBuilding();

while(1)
{
    Sleep(1000);

    allTownhalls.Clear();

    for(pp=1;pp<=8;pp+=1)
    {
        allTownhalls.AddList(ClassPlayerObjs("BaseTownhall",pp).GetObjList());
    }

    allTownhalls.ClearDead();

    for(H=1;H<=32;H+=1)
    {
        active=0;
if(H==1)active=EnvReadInt(state,"HW_ACTIVE1");
if(H==2)active=EnvReadInt(state,"HW_ACTIVE2");
if(H==3)active=EnvReadInt(state,"HW_ACTIVE3");
if(H==4)active=EnvReadInt(state,"HW_ACTIVE4");
if(H==5)active=EnvReadInt(state,"HW_ACTIVE5");
if(H==6)active=EnvReadInt(state,"HW_ACTIVE6");
if(H==7)active=EnvReadInt(state,"HW_ACTIVE7");
if(H==8)active=EnvReadInt(state,"HW_ACTIVE8");
if(H==9)active=EnvReadInt(state,"HW_ACTIVE9");
if(H==10)active=EnvReadInt(state,"HW_ACTIVE10");
if(H==11)active=EnvReadInt(state,"HW_ACTIVE11");
if(H==12)active=EnvReadInt(state,"HW_ACTIVE12");
if(H==13)active=EnvReadInt(state,"HW_ACTIVE13");
if(H==14)active=EnvReadInt(state,"HW_ACTIVE14");
if(H==15)active=EnvReadInt(state,"HW_ACTIVE15");
if(H==16)active=EnvReadInt(state,"HW_ACTIVE16");
if(H==17)active=EnvReadInt(state,"HW_ACTIVE17");
if(H==18)active=EnvReadInt(state,"HW_ACTIVE18");
if(H==19)active=EnvReadInt(state,"HW_ACTIVE19");
if(H==20)active=EnvReadInt(state,"HW_ACTIVE20");
if(H==21)active=EnvReadInt(state,"HW_ACTIVE21");
if(H==22)active=EnvReadInt(state,"HW_ACTIVE22");
if(H==23)active=EnvReadInt(state,"HW_ACTIVE23");
if(H==24)active=EnvReadInt(state,"HW_ACTIVE24");
if(H==25)active=EnvReadInt(state,"HW_ACTIVE25");
if(H==26)active=EnvReadInt(state,"HW_ACTIVE26");
if(H==27)active=EnvReadInt(state,"HW_ACTIVE27");
if(H==28)active=EnvReadInt(state,"HW_ACTIVE28");
if(H==29)active=EnvReadInt(state,"HW_ACTIVE29");
if(H==30)active=EnvReadInt(state,"HW_ACTIVE30");
if(H==31)active=EnvReadInt(state,"HW_ACTIVE31");
if(H==32)active=EnvReadInt(state,"HW_ACTIVE32");

        if(active!=1)
        {
            phase[H]=0;
            marchTicks[H]=4;
            phaseTicks[H]=0;
            gateX[H]=0;
            gateY[H]=0;
            siegeHadHolder[H]=0;
            lastGateHealth[H]=0;
            siegeNoProgress[H]=0;
            lastForumDist[H]=0;
            captureStuck[H]=0;
            marchLastDist[H]=0;
            marchStuck[H]=0;
            continue;
        }

        h.Clear();
if(H==1)h=Group("HW_H1").GetObjList();
if(H==2)h=Group("HW_H2").GetObjList();
if(H==3)h=Group("HW_H3").GetObjList();
if(H==4)h=Group("HW_H4").GetObjList();
if(H==5)h=Group("HW_H5").GetObjList();
if(H==6)h=Group("HW_H6").GetObjList();
if(H==7)h=Group("HW_H7").GetObjList();
if(H==8)h=Group("HW_H8").GetObjList();
if(H==9)h=Group("HW_H9").GetObjList();
if(H==10)h=Group("HW_H10").GetObjList();
if(H==11)h=Group("HW_H11").GetObjList();
if(H==12)h=Group("HW_H12").GetObjList();
if(H==13)h=Group("HW_H13").GetObjList();
if(H==14)h=Group("HW_H14").GetObjList();
if(H==15)h=Group("HW_H15").GetObjList();
if(H==16)h=Group("HW_H16").GetObjList();
if(H==17)h=Group("HW_H17").GetObjList();
if(H==18)h=Group("HW_H18").GetObjList();
if(H==19)h=Group("HW_H19").GetObjList();
if(H==20)h=Group("HW_H20").GetObjList();
if(H==21)h=Group("HW_H21").GetObjList();
if(H==22)h=Group("HW_H22").GetObjList();
if(H==23)h=Group("HW_H23").GetObjList();
if(H==24)h=Group("HW_H24").GetObjList();
if(H==25)h=Group("HW_H25").GetObjList();
if(H==26)h=Group("HW_H26").GetObjList();
if(H==27)h=Group("HW_H27").GetObjList();
if(H==28)h=Group("HW_H28").GetObjList();
if(H==29)h=Group("HW_H29").GetObjList();
if(H==30)h=Group("HW_H30").GetObjList();
if(H==31)h=Group("HW_H31").GetObjList();
if(H==32)h=Group("HW_H32").GetObjList();
        h.ClearDead();

        // ============================================================
        // HORDA DESTRUIDA
        // ============================================================
        if(h.count==0)
        {
            tx=0;
            ty=0;
if(H==1)tx=EnvReadInt(state,"HW_TX1");
if(H==2)tx=EnvReadInt(state,"HW_TX2");
if(H==3)tx=EnvReadInt(state,"HW_TX3");
if(H==4)tx=EnvReadInt(state,"HW_TX4");
if(H==5)tx=EnvReadInt(state,"HW_TX5");
if(H==6)tx=EnvReadInt(state,"HW_TX6");
if(H==7)tx=EnvReadInt(state,"HW_TX7");
if(H==8)tx=EnvReadInt(state,"HW_TX8");
if(H==9)tx=EnvReadInt(state,"HW_TX9");
if(H==10)tx=EnvReadInt(state,"HW_TX10");
if(H==11)tx=EnvReadInt(state,"HW_TX11");
if(H==12)tx=EnvReadInt(state,"HW_TX12");
if(H==13)tx=EnvReadInt(state,"HW_TX13");
if(H==14)tx=EnvReadInt(state,"HW_TX14");
if(H==15)tx=EnvReadInt(state,"HW_TX15");
if(H==16)tx=EnvReadInt(state,"HW_TX16");
if(H==17)tx=EnvReadInt(state,"HW_TX17");
if(H==18)tx=EnvReadInt(state,"HW_TX18");
if(H==19)tx=EnvReadInt(state,"HW_TX19");
if(H==20)tx=EnvReadInt(state,"HW_TX20");
if(H==21)tx=EnvReadInt(state,"HW_TX21");
if(H==22)tx=EnvReadInt(state,"HW_TX22");
if(H==23)tx=EnvReadInt(state,"HW_TX23");
if(H==24)tx=EnvReadInt(state,"HW_TX24");
if(H==25)tx=EnvReadInt(state,"HW_TX25");
if(H==26)tx=EnvReadInt(state,"HW_TX26");
if(H==27)tx=EnvReadInt(state,"HW_TX27");
if(H==28)tx=EnvReadInt(state,"HW_TX28");
if(H==29)tx=EnvReadInt(state,"HW_TX29");
if(H==30)tx=EnvReadInt(state,"HW_TX30");
if(H==31)tx=EnvReadInt(state,"HW_TX31");
if(H==32)tx=EnvReadInt(state,"HW_TX32");
if(H==1)ty=EnvReadInt(state,"HW_TY1");
if(H==2)ty=EnvReadInt(state,"HW_TY2");
if(H==3)ty=EnvReadInt(state,"HW_TY3");
if(H==4)ty=EnvReadInt(state,"HW_TY4");
if(H==5)ty=EnvReadInt(state,"HW_TY5");
if(H==6)ty=EnvReadInt(state,"HW_TY6");
if(H==7)ty=EnvReadInt(state,"HW_TY7");
if(H==8)ty=EnvReadInt(state,"HW_TY8");
if(H==9)ty=EnvReadInt(state,"HW_TY9");
if(H==10)ty=EnvReadInt(state,"HW_TY10");
if(H==11)ty=EnvReadInt(state,"HW_TY11");
if(H==12)ty=EnvReadInt(state,"HW_TY12");
if(H==13)ty=EnvReadInt(state,"HW_TY13");
if(H==14)ty=EnvReadInt(state,"HW_TY14");
if(H==15)ty=EnvReadInt(state,"HW_TY15");
if(H==16)ty=EnvReadInt(state,"HW_TY16");
if(H==17)ty=EnvReadInt(state,"HW_TY17");
if(H==18)ty=EnvReadInt(state,"HW_TY18");
if(H==19)ty=EnvReadInt(state,"HW_TY19");
if(H==20)ty=EnvReadInt(state,"HW_TY20");
if(H==21)ty=EnvReadInt(state,"HW_TY21");
if(H==22)ty=EnvReadInt(state,"HW_TY22");
if(H==23)ty=EnvReadInt(state,"HW_TY23");
if(H==24)ty=EnvReadInt(state,"HW_TY24");
if(H==25)ty=EnvReadInt(state,"HW_TY25");
if(H==26)ty=EnvReadInt(state,"HW_TY26");
if(H==27)ty=EnvReadInt(state,"HW_TY27");
if(H==28)ty=EnvReadInt(state,"HW_TY28");
if(H==29)ty=EnvReadInt(state,"HW_TY29");
if(H==30)ty=EnvReadInt(state,"HW_TY30");
if(H==31)ty=EnvReadInt(state,"HW_TY31");
if(H==32)ty=EnvReadInt(state,"HW_TY32");

            foundTarget=0;

            if(tx!=0||ty!=0)
            {
                for(i=0;i<allTownhalls.count;i+=1)
                {
                    cand=allTownhalls[i].AsBuilding();

                    if(cand.pos.x==tx&&cand.pos.y==ty)
                    {
                        target=cand;
                        foundTarget=1;
                        i=allTownhalls.count;
                    }
                }
            }

            rr=0;
if(H==1)rr=EnvReadInt(state,"HW_REWARDED1");
if(H==2)rr=EnvReadInt(state,"HW_REWARDED2");
if(H==3)rr=EnvReadInt(state,"HW_REWARDED3");
if(H==4)rr=EnvReadInt(state,"HW_REWARDED4");
if(H==5)rr=EnvReadInt(state,"HW_REWARDED5");
if(H==6)rr=EnvReadInt(state,"HW_REWARDED6");
if(H==7)rr=EnvReadInt(state,"HW_REWARDED7");
if(H==8)rr=EnvReadInt(state,"HW_REWARDED8");
if(H==9)rr=EnvReadInt(state,"HW_REWARDED9");
if(H==10)rr=EnvReadInt(state,"HW_REWARDED10");
if(H==11)rr=EnvReadInt(state,"HW_REWARDED11");
if(H==12)rr=EnvReadInt(state,"HW_REWARDED12");
if(H==13)rr=EnvReadInt(state,"HW_REWARDED13");
if(H==14)rr=EnvReadInt(state,"HW_REWARDED14");
if(H==15)rr=EnvReadInt(state,"HW_REWARDED15");
if(H==16)rr=EnvReadInt(state,"HW_REWARDED16");
if(H==17)rr=EnvReadInt(state,"HW_REWARDED17");
if(H==18)rr=EnvReadInt(state,"HW_REWARDED18");
if(H==19)rr=EnvReadInt(state,"HW_REWARDED19");
if(H==20)rr=EnvReadInt(state,"HW_REWARDED20");
if(H==21)rr=EnvReadInt(state,"HW_REWARDED21");
if(H==22)rr=EnvReadInt(state,"HW_REWARDED22");
if(H==23)rr=EnvReadInt(state,"HW_REWARDED23");
if(H==24)rr=EnvReadInt(state,"HW_REWARDED24");
if(H==25)rr=EnvReadInt(state,"HW_REWARDED25");
if(H==26)rr=EnvReadInt(state,"HW_REWARDED26");
if(H==27)rr=EnvReadInt(state,"HW_REWARDED27");
if(H==28)rr=EnvReadInt(state,"HW_REWARDED28");
if(H==29)rr=EnvReadInt(state,"HW_REWARDED29");
if(H==30)rr=EnvReadInt(state,"HW_REWARDED30");
if(H==31)rr=EnvReadInt(state,"HW_REWARDED31");
if(H==32)rr=EnvReadInt(state,"HW_REWARDED32");

            if(foundTarget==1&&target.player>=1&&target.player<=8&&rr==0)
            {
                owner=target.player;
                rr=0;
if(H==1)rr=EnvReadInt(state,"HW_ROUND1");
if(H==2)rr=EnvReadInt(state,"HW_ROUND2");
if(H==3)rr=EnvReadInt(state,"HW_ROUND3");
if(H==4)rr=EnvReadInt(state,"HW_ROUND4");
if(H==5)rr=EnvReadInt(state,"HW_ROUND5");
if(H==6)rr=EnvReadInt(state,"HW_ROUND6");
if(H==7)rr=EnvReadInt(state,"HW_ROUND7");
if(H==8)rr=EnvReadInt(state,"HW_ROUND8");
if(H==9)rr=EnvReadInt(state,"HW_ROUND9");
if(H==10)rr=EnvReadInt(state,"HW_ROUND10");
if(H==11)rr=EnvReadInt(state,"HW_ROUND11");
if(H==12)rr=EnvReadInt(state,"HW_ROUND12");
if(H==13)rr=EnvReadInt(state,"HW_ROUND13");
if(H==14)rr=EnvReadInt(state,"HW_ROUND14");
if(H==15)rr=EnvReadInt(state,"HW_ROUND15");
if(H==16)rr=EnvReadInt(state,"HW_ROUND16");
if(H==17)rr=EnvReadInt(state,"HW_ROUND17");
if(H==18)rr=EnvReadInt(state,"HW_ROUND18");
if(H==19)rr=EnvReadInt(state,"HW_ROUND19");
if(H==20)rr=EnvReadInt(state,"HW_ROUND20");
if(H==21)rr=EnvReadInt(state,"HW_ROUND21");
if(H==22)rr=EnvReadInt(state,"HW_ROUND22");
if(H==23)rr=EnvReadInt(state,"HW_ROUND23");
if(H==24)rr=EnvReadInt(state,"HW_ROUND24");
if(H==25)rr=EnvReadInt(state,"HW_ROUND25");
if(H==26)rr=EnvReadInt(state,"HW_ROUND26");
if(H==27)rr=EnvReadInt(state,"HW_ROUND27");
if(H==28)rr=EnvReadInt(state,"HW_ROUND28");
if(H==29)rr=EnvReadInt(state,"HW_ROUND29");
if(H==30)rr=EnvReadInt(state,"HW_ROUND30");
if(H==31)rr=EnvReadInt(state,"HW_ROUND31");
if(H==32)rr=EnvReadInt(state,"HW_ROUND32");
if(H==1)EnvWriteInt(state,"ZR_OWNER1",owner);
if(H==2)EnvWriteInt(state,"ZR_OWNER2",owner);
if(H==3)EnvWriteInt(state,"ZR_OWNER3",owner);
if(H==4)EnvWriteInt(state,"ZR_OWNER4",owner);
if(H==5)EnvWriteInt(state,"ZR_OWNER5",owner);
if(H==6)EnvWriteInt(state,"ZR_OWNER6",owner);
if(H==7)EnvWriteInt(state,"ZR_OWNER7",owner);
if(H==8)EnvWriteInt(state,"ZR_OWNER8",owner);
if(H==9)EnvWriteInt(state,"ZR_OWNER9",owner);
if(H==10)EnvWriteInt(state,"ZR_OWNER10",owner);
if(H==11)EnvWriteInt(state,"ZR_OWNER11",owner);
if(H==12)EnvWriteInt(state,"ZR_OWNER12",owner);
if(H==13)EnvWriteInt(state,"ZR_OWNER13",owner);
if(H==14)EnvWriteInt(state,"ZR_OWNER14",owner);
if(H==15)EnvWriteInt(state,"ZR_OWNER15",owner);
if(H==16)EnvWriteInt(state,"ZR_OWNER16",owner);
if(H==17)EnvWriteInt(state,"ZR_OWNER17",owner);
if(H==18)EnvWriteInt(state,"ZR_OWNER18",owner);
if(H==19)EnvWriteInt(state,"ZR_OWNER19",owner);
if(H==20)EnvWriteInt(state,"ZR_OWNER20",owner);
if(H==21)EnvWriteInt(state,"ZR_OWNER21",owner);
if(H==22)EnvWriteInt(state,"ZR_OWNER22",owner);
if(H==23)EnvWriteInt(state,"ZR_OWNER23",owner);
if(H==24)EnvWriteInt(state,"ZR_OWNER24",owner);
if(H==25)EnvWriteInt(state,"ZR_OWNER25",owner);
if(H==26)EnvWriteInt(state,"ZR_OWNER26",owner);
if(H==27)EnvWriteInt(state,"ZR_OWNER27",owner);
if(H==28)EnvWriteInt(state,"ZR_OWNER28",owner);
if(H==29)EnvWriteInt(state,"ZR_OWNER29",owner);
if(H==30)EnvWriteInt(state,"ZR_OWNER30",owner);
if(H==31)EnvWriteInt(state,"ZR_OWNER31",owner);
if(H==32)EnvWriteInt(state,"ZR_OWNER32",owner);
if(H==1)EnvWriteInt(state,"ZR_ROUND1",rr);
if(H==2)EnvWriteInt(state,"ZR_ROUND2",rr);
if(H==3)EnvWriteInt(state,"ZR_ROUND3",rr);
if(H==4)EnvWriteInt(state,"ZR_ROUND4",rr);
if(H==5)EnvWriteInt(state,"ZR_ROUND5",rr);
if(H==6)EnvWriteInt(state,"ZR_ROUND6",rr);
if(H==7)EnvWriteInt(state,"ZR_ROUND7",rr);
if(H==8)EnvWriteInt(state,"ZR_ROUND8",rr);
if(H==9)EnvWriteInt(state,"ZR_ROUND9",rr);
if(H==10)EnvWriteInt(state,"ZR_ROUND10",rr);
if(H==11)EnvWriteInt(state,"ZR_ROUND11",rr);
if(H==12)EnvWriteInt(state,"ZR_ROUND12",rr);
if(H==13)EnvWriteInt(state,"ZR_ROUND13",rr);
if(H==14)EnvWriteInt(state,"ZR_ROUND14",rr);
if(H==15)EnvWriteInt(state,"ZR_ROUND15",rr);
if(H==16)EnvWriteInt(state,"ZR_ROUND16",rr);
if(H==17)EnvWriteInt(state,"ZR_ROUND17",rr);
if(H==18)EnvWriteInt(state,"ZR_ROUND18",rr);
if(H==19)EnvWriteInt(state,"ZR_ROUND19",rr);
if(H==20)EnvWriteInt(state,"ZR_ROUND20",rr);
if(H==21)EnvWriteInt(state,"ZR_ROUND21",rr);
if(H==22)EnvWriteInt(state,"ZR_ROUND22",rr);
if(H==23)EnvWriteInt(state,"ZR_ROUND23",rr);
if(H==24)EnvWriteInt(state,"ZR_ROUND24",rr);
if(H==25)EnvWriteInt(state,"ZR_ROUND25",rr);
if(H==26)EnvWriteInt(state,"ZR_ROUND26",rr);
if(H==27)EnvWriteInt(state,"ZR_ROUND27",rr);
if(H==28)EnvWriteInt(state,"ZR_ROUND28",rr);
if(H==29)EnvWriteInt(state,"ZR_ROUND29",rr);
if(H==30)EnvWriteInt(state,"ZR_ROUND30",rr);
if(H==31)EnvWriteInt(state,"ZR_ROUND31",rr);
if(H==32)EnvWriteInt(state,"ZR_ROUND32",rr);
if(H==1)EnvWriteInt(state,"ZR_X1",target.pos.x);
if(H==2)EnvWriteInt(state,"ZR_X2",target.pos.x);
if(H==3)EnvWriteInt(state,"ZR_X3",target.pos.x);
if(H==4)EnvWriteInt(state,"ZR_X4",target.pos.x);
if(H==5)EnvWriteInt(state,"ZR_X5",target.pos.x);
if(H==6)EnvWriteInt(state,"ZR_X6",target.pos.x);
if(H==7)EnvWriteInt(state,"ZR_X7",target.pos.x);
if(H==8)EnvWriteInt(state,"ZR_X8",target.pos.x);
if(H==9)EnvWriteInt(state,"ZR_X9",target.pos.x);
if(H==10)EnvWriteInt(state,"ZR_X10",target.pos.x);
if(H==11)EnvWriteInt(state,"ZR_X11",target.pos.x);
if(H==12)EnvWriteInt(state,"ZR_X12",target.pos.x);
if(H==13)EnvWriteInt(state,"ZR_X13",target.pos.x);
if(H==14)EnvWriteInt(state,"ZR_X14",target.pos.x);
if(H==15)EnvWriteInt(state,"ZR_X15",target.pos.x);
if(H==16)EnvWriteInt(state,"ZR_X16",target.pos.x);
if(H==17)EnvWriteInt(state,"ZR_X17",target.pos.x);
if(H==18)EnvWriteInt(state,"ZR_X18",target.pos.x);
if(H==19)EnvWriteInt(state,"ZR_X19",target.pos.x);
if(H==20)EnvWriteInt(state,"ZR_X20",target.pos.x);
if(H==21)EnvWriteInt(state,"ZR_X21",target.pos.x);
if(H==22)EnvWriteInt(state,"ZR_X22",target.pos.x);
if(H==23)EnvWriteInt(state,"ZR_X23",target.pos.x);
if(H==24)EnvWriteInt(state,"ZR_X24",target.pos.x);
if(H==25)EnvWriteInt(state,"ZR_X25",target.pos.x);
if(H==26)EnvWriteInt(state,"ZR_X26",target.pos.x);
if(H==27)EnvWriteInt(state,"ZR_X27",target.pos.x);
if(H==28)EnvWriteInt(state,"ZR_X28",target.pos.x);
if(H==29)EnvWriteInt(state,"ZR_X29",target.pos.x);
if(H==30)EnvWriteInt(state,"ZR_X30",target.pos.x);
if(H==31)EnvWriteInt(state,"ZR_X31",target.pos.x);
if(H==32)EnvWriteInt(state,"ZR_X32",target.pos.x);
if(H==1)EnvWriteInt(state,"ZR_Y1",target.pos.y);
if(H==2)EnvWriteInt(state,"ZR_Y2",target.pos.y);
if(H==3)EnvWriteInt(state,"ZR_Y3",target.pos.y);
if(H==4)EnvWriteInt(state,"ZR_Y4",target.pos.y);
if(H==5)EnvWriteInt(state,"ZR_Y5",target.pos.y);
if(H==6)EnvWriteInt(state,"ZR_Y6",target.pos.y);
if(H==7)EnvWriteInt(state,"ZR_Y7",target.pos.y);
if(H==8)EnvWriteInt(state,"ZR_Y8",target.pos.y);
if(H==9)EnvWriteInt(state,"ZR_Y9",target.pos.y);
if(H==10)EnvWriteInt(state,"ZR_Y10",target.pos.y);
if(H==11)EnvWriteInt(state,"ZR_Y11",target.pos.y);
if(H==12)EnvWriteInt(state,"ZR_Y12",target.pos.y);
if(H==13)EnvWriteInt(state,"ZR_Y13",target.pos.y);
if(H==14)EnvWriteInt(state,"ZR_Y14",target.pos.y);
if(H==15)EnvWriteInt(state,"ZR_Y15",target.pos.y);
if(H==16)EnvWriteInt(state,"ZR_Y16",target.pos.y);
if(H==17)EnvWriteInt(state,"ZR_Y17",target.pos.y);
if(H==18)EnvWriteInt(state,"ZR_Y18",target.pos.y);
if(H==19)EnvWriteInt(state,"ZR_Y19",target.pos.y);
if(H==20)EnvWriteInt(state,"ZR_Y20",target.pos.y);
if(H==21)EnvWriteInt(state,"ZR_Y21",target.pos.y);
if(H==22)EnvWriteInt(state,"ZR_Y22",target.pos.y);
if(H==23)EnvWriteInt(state,"ZR_Y23",target.pos.y);
if(H==24)EnvWriteInt(state,"ZR_Y24",target.pos.y);
if(H==25)EnvWriteInt(state,"ZR_Y25",target.pos.y);
if(H==26)EnvWriteInt(state,"ZR_Y26",target.pos.y);
if(H==27)EnvWriteInt(state,"ZR_Y27",target.pos.y);
if(H==28)EnvWriteInt(state,"ZR_Y28",target.pos.y);
if(H==29)EnvWriteInt(state,"ZR_Y29",target.pos.y);
if(H==30)EnvWriteInt(state,"ZR_Y30",target.pos.y);
if(H==31)EnvWriteInt(state,"ZR_Y31",target.pos.y);
if(H==32)EnvWriteInt(state,"ZR_Y32",target.pos.y);
if(H==1)EnvWriteInt(state,"ZR_PENDING1",1);
if(H==2)EnvWriteInt(state,"ZR_PENDING2",1);
if(H==3)EnvWriteInt(state,"ZR_PENDING3",1);
if(H==4)EnvWriteInt(state,"ZR_PENDING4",1);
if(H==5)EnvWriteInt(state,"ZR_PENDING5",1);
if(H==6)EnvWriteInt(state,"ZR_PENDING6",1);
if(H==7)EnvWriteInt(state,"ZR_PENDING7",1);
if(H==8)EnvWriteInt(state,"ZR_PENDING8",1);
if(H==9)EnvWriteInt(state,"ZR_PENDING9",1);
if(H==10)EnvWriteInt(state,"ZR_PENDING10",1);
if(H==11)EnvWriteInt(state,"ZR_PENDING11",1);
if(H==12)EnvWriteInt(state,"ZR_PENDING12",1);
if(H==13)EnvWriteInt(state,"ZR_PENDING13",1);
if(H==14)EnvWriteInt(state,"ZR_PENDING14",1);
if(H==15)EnvWriteInt(state,"ZR_PENDING15",1);
if(H==16)EnvWriteInt(state,"ZR_PENDING16",1);
if(H==17)EnvWriteInt(state,"ZR_PENDING17",1);
if(H==18)EnvWriteInt(state,"ZR_PENDING18",1);
if(H==19)EnvWriteInt(state,"ZR_PENDING19",1);
if(H==20)EnvWriteInt(state,"ZR_PENDING20",1);
if(H==21)EnvWriteInt(state,"ZR_PENDING21",1);
if(H==22)EnvWriteInt(state,"ZR_PENDING22",1);
if(H==23)EnvWriteInt(state,"ZR_PENDING23",1);
if(H==24)EnvWriteInt(state,"ZR_PENDING24",1);
if(H==25)EnvWriteInt(state,"ZR_PENDING25",1);
if(H==26)EnvWriteInt(state,"ZR_PENDING26",1);
if(H==27)EnvWriteInt(state,"ZR_PENDING27",1);
if(H==28)EnvWriteInt(state,"ZR_PENDING28",1);
if(H==29)EnvWriteInt(state,"ZR_PENDING29",1);
if(H==30)EnvWriteInt(state,"ZR_PENDING30",1);
if(H==31)EnvWriteInt(state,"ZR_PENDING31",1);
if(H==32)EnvWriteInt(state,"ZR_PENDING32",1);
if(H==1)EnvWriteInt(state,"HW_REWARDED1",1);
if(H==2)EnvWriteInt(state,"HW_REWARDED2",1);
if(H==3)EnvWriteInt(state,"HW_REWARDED3",1);
if(H==4)EnvWriteInt(state,"HW_REWARDED4",1);
if(H==5)EnvWriteInt(state,"HW_REWARDED5",1);
if(H==6)EnvWriteInt(state,"HW_REWARDED6",1);
if(H==7)EnvWriteInt(state,"HW_REWARDED7",1);
if(H==8)EnvWriteInt(state,"HW_REWARDED8",1);
if(H==9)EnvWriteInt(state,"HW_REWARDED9",1);
if(H==10)EnvWriteInt(state,"HW_REWARDED10",1);
if(H==11)EnvWriteInt(state,"HW_REWARDED11",1);
if(H==12)EnvWriteInt(state,"HW_REWARDED12",1);
if(H==13)EnvWriteInt(state,"HW_REWARDED13",1);
if(H==14)EnvWriteInt(state,"HW_REWARDED14",1);
if(H==15)EnvWriteInt(state,"HW_REWARDED15",1);
if(H==16)EnvWriteInt(state,"HW_REWARDED16",1);
if(H==17)EnvWriteInt(state,"HW_REWARDED17",1);
if(H==18)EnvWriteInt(state,"HW_REWARDED18",1);
if(H==19)EnvWriteInt(state,"HW_REWARDED19",1);
if(H==20)EnvWriteInt(state,"HW_REWARDED20",1);
if(H==21)EnvWriteInt(state,"HW_REWARDED21",1);
if(H==22)EnvWriteInt(state,"HW_REWARDED22",1);
if(H==23)EnvWriteInt(state,"HW_REWARDED23",1);
if(H==24)EnvWriteInt(state,"HW_REWARDED24",1);
if(H==25)EnvWriteInt(state,"HW_REWARDED25",1);
if(H==26)EnvWriteInt(state,"HW_REWARDED26",1);
if(H==27)EnvWriteInt(state,"HW_REWARDED27",1);
if(H==28)EnvWriteInt(state,"HW_REWARDED28",1);
if(H==29)EnvWriteInt(state,"HW_REWARDED29",1);
if(H==30)EnvWriteInt(state,"HW_REWARDED30",1);
if(H==31)EnvWriteInt(state,"HW_REWARDED31",1);
if(H==32)EnvWriteInt(state,"HW_REWARDED32",1);
            }

            phase[H]=0;
            marchTicks[H]=4;
            phaseTicks[H]=0;
            gateX[H]=0;
            gateY[H]=0;
            siegeHadHolder[H]=0;
if(H==1)EnvWriteInt(state,"HW_ACTIVE1",0);
if(H==2)EnvWriteInt(state,"HW_ACTIVE2",0);
if(H==3)EnvWriteInt(state,"HW_ACTIVE3",0);
if(H==4)EnvWriteInt(state,"HW_ACTIVE4",0);
if(H==5)EnvWriteInt(state,"HW_ACTIVE5",0);
if(H==6)EnvWriteInt(state,"HW_ACTIVE6",0);
if(H==7)EnvWriteInt(state,"HW_ACTIVE7",0);
if(H==8)EnvWriteInt(state,"HW_ACTIVE8",0);
if(H==9)EnvWriteInt(state,"HW_ACTIVE9",0);
if(H==10)EnvWriteInt(state,"HW_ACTIVE10",0);
if(H==11)EnvWriteInt(state,"HW_ACTIVE11",0);
if(H==12)EnvWriteInt(state,"HW_ACTIVE12",0);
if(H==13)EnvWriteInt(state,"HW_ACTIVE13",0);
if(H==14)EnvWriteInt(state,"HW_ACTIVE14",0);
if(H==15)EnvWriteInt(state,"HW_ACTIVE15",0);
if(H==16)EnvWriteInt(state,"HW_ACTIVE16",0);
if(H==17)EnvWriteInt(state,"HW_ACTIVE17",0);
if(H==18)EnvWriteInt(state,"HW_ACTIVE18",0);
if(H==19)EnvWriteInt(state,"HW_ACTIVE19",0);
if(H==20)EnvWriteInt(state,"HW_ACTIVE20",0);
if(H==21)EnvWriteInt(state,"HW_ACTIVE21",0);
if(H==22)EnvWriteInt(state,"HW_ACTIVE22",0);
if(H==23)EnvWriteInt(state,"HW_ACTIVE23",0);
if(H==24)EnvWriteInt(state,"HW_ACTIVE24",0);
if(H==25)EnvWriteInt(state,"HW_ACTIVE25",0);
if(H==26)EnvWriteInt(state,"HW_ACTIVE26",0);
if(H==27)EnvWriteInt(state,"HW_ACTIVE27",0);
if(H==28)EnvWriteInt(state,"HW_ACTIVE28",0);
if(H==29)EnvWriteInt(state,"HW_ACTIVE29",0);
if(H==30)EnvWriteInt(state,"HW_ACTIVE30",0);
if(H==31)EnvWriteInt(state,"HW_ACTIVE31",0);
if(H==32)EnvWriteInt(state,"HW_ACTIVE32",0);
            continue;
        }

        // ============================================================
        // RECUPERAR TARGET ACTUAL
        // ============================================================
        tx=0;
        ty=0;
if(H==1)tx=EnvReadInt(state,"HW_TX1");
if(H==2)tx=EnvReadInt(state,"HW_TX2");
if(H==3)tx=EnvReadInt(state,"HW_TX3");
if(H==4)tx=EnvReadInt(state,"HW_TX4");
if(H==5)tx=EnvReadInt(state,"HW_TX5");
if(H==6)tx=EnvReadInt(state,"HW_TX6");
if(H==7)tx=EnvReadInt(state,"HW_TX7");
if(H==8)tx=EnvReadInt(state,"HW_TX8");
if(H==9)tx=EnvReadInt(state,"HW_TX9");
if(H==10)tx=EnvReadInt(state,"HW_TX10");
if(H==11)tx=EnvReadInt(state,"HW_TX11");
if(H==12)tx=EnvReadInt(state,"HW_TX12");
if(H==13)tx=EnvReadInt(state,"HW_TX13");
if(H==14)tx=EnvReadInt(state,"HW_TX14");
if(H==15)tx=EnvReadInt(state,"HW_TX15");
if(H==16)tx=EnvReadInt(state,"HW_TX16");
if(H==17)tx=EnvReadInt(state,"HW_TX17");
if(H==18)tx=EnvReadInt(state,"HW_TX18");
if(H==19)tx=EnvReadInt(state,"HW_TX19");
if(H==20)tx=EnvReadInt(state,"HW_TX20");
if(H==21)tx=EnvReadInt(state,"HW_TX21");
if(H==22)tx=EnvReadInt(state,"HW_TX22");
if(H==23)tx=EnvReadInt(state,"HW_TX23");
if(H==24)tx=EnvReadInt(state,"HW_TX24");
if(H==25)tx=EnvReadInt(state,"HW_TX25");
if(H==26)tx=EnvReadInt(state,"HW_TX26");
if(H==27)tx=EnvReadInt(state,"HW_TX27");
if(H==28)tx=EnvReadInt(state,"HW_TX28");
if(H==29)tx=EnvReadInt(state,"HW_TX29");
if(H==30)tx=EnvReadInt(state,"HW_TX30");
if(H==31)tx=EnvReadInt(state,"HW_TX31");
if(H==32)tx=EnvReadInt(state,"HW_TX32");
if(H==1)ty=EnvReadInt(state,"HW_TY1");
if(H==2)ty=EnvReadInt(state,"HW_TY2");
if(H==3)ty=EnvReadInt(state,"HW_TY3");
if(H==4)ty=EnvReadInt(state,"HW_TY4");
if(H==5)ty=EnvReadInt(state,"HW_TY5");
if(H==6)ty=EnvReadInt(state,"HW_TY6");
if(H==7)ty=EnvReadInt(state,"HW_TY7");
if(H==8)ty=EnvReadInt(state,"HW_TY8");
if(H==9)ty=EnvReadInt(state,"HW_TY9");
if(H==10)ty=EnvReadInt(state,"HW_TY10");
if(H==11)ty=EnvReadInt(state,"HW_TY11");
if(H==12)ty=EnvReadInt(state,"HW_TY12");
if(H==13)ty=EnvReadInt(state,"HW_TY13");
if(H==14)ty=EnvReadInt(state,"HW_TY14");
if(H==15)ty=EnvReadInt(state,"HW_TY15");
if(H==16)ty=EnvReadInt(state,"HW_TY16");
if(H==17)ty=EnvReadInt(state,"HW_TY17");
if(H==18)ty=EnvReadInt(state,"HW_TY18");
if(H==19)ty=EnvReadInt(state,"HW_TY19");
if(H==20)ty=EnvReadInt(state,"HW_TY20");
if(H==21)ty=EnvReadInt(state,"HW_TY21");
if(H==22)ty=EnvReadInt(state,"HW_TY22");
if(H==23)ty=EnvReadInt(state,"HW_TY23");
if(H==24)ty=EnvReadInt(state,"HW_TY24");
if(H==25)ty=EnvReadInt(state,"HW_TY25");
if(H==26)ty=EnvReadInt(state,"HW_TY26");
if(H==27)ty=EnvReadInt(state,"HW_TY27");
if(H==28)ty=EnvReadInt(state,"HW_TY28");
if(H==29)ty=EnvReadInt(state,"HW_TY29");
if(H==30)ty=EnvReadInt(state,"HW_TY30");
if(H==31)ty=EnvReadInt(state,"HW_TY31");
if(H==32)ty=EnvReadInt(state,"HW_TY32");

        foundTarget=0;

        if(tx!=0||ty!=0)
        {
            for(i=0;i<allTownhalls.count;i+=1)
            {
                cand=allTownhalls[i].AsBuilding();

                if(cand.pos.x==tx&&cand.pos.y==ty)
                {
                    target=cand;
                    foundTarget=1;
                    i=allTownhalls.count;
                }
            }
        }

        // ============================================================
        // NUEVO TARGET
        // ============================================================
        // Si el anterior ya es P12, ya no aparece en allTownhalls.
        if(foundTarget==0)
        {
            phase[H]=0;
            marchTicks[H]=4;
            phaseTicks[H]=0;
            gateX[H]=0;
            gateY[H]=0;
            siegeHadHolder[H]=0;
            lastGateHealth[H]=0;
            siegeNoProgress[H]=0;
            lastForumDist[H]=0;
            captureStuck[H]=0;
            marchLastDist[H]=0;
            marchStuck[H]=0;
            bestD=-1;

            for(i=0;i<allTownhalls.count;i+=1)
            {
                cand=allTownhalls[i].AsBuilding();
                d=cand.DistTo(h[0].AsUnit());

                if(bestD==-1||d<bestD)
                {
                    bestD=d;
                    target=cand;
                }
            }

            if(bestD<0)
            {
if(H==1)EnvWriteInt(state,"HW_TX1",0);
if(H==2)EnvWriteInt(state,"HW_TX2",0);
if(H==3)EnvWriteInt(state,"HW_TX3",0);
if(H==4)EnvWriteInt(state,"HW_TX4",0);
if(H==5)EnvWriteInt(state,"HW_TX5",0);
if(H==6)EnvWriteInt(state,"HW_TX6",0);
if(H==7)EnvWriteInt(state,"HW_TX7",0);
if(H==8)EnvWriteInt(state,"HW_TX8",0);
if(H==9)EnvWriteInt(state,"HW_TX9",0);
if(H==10)EnvWriteInt(state,"HW_TX10",0);
if(H==11)EnvWriteInt(state,"HW_TX11",0);
if(H==12)EnvWriteInt(state,"HW_TX12",0);
if(H==13)EnvWriteInt(state,"HW_TX13",0);
if(H==14)EnvWriteInt(state,"HW_TX14",0);
if(H==15)EnvWriteInt(state,"HW_TX15",0);
if(H==16)EnvWriteInt(state,"HW_TX16",0);
if(H==17)EnvWriteInt(state,"HW_TX17",0);
if(H==18)EnvWriteInt(state,"HW_TX18",0);
if(H==19)EnvWriteInt(state,"HW_TX19",0);
if(H==20)EnvWriteInt(state,"HW_TX20",0);
if(H==21)EnvWriteInt(state,"HW_TX21",0);
if(H==22)EnvWriteInt(state,"HW_TX22",0);
if(H==23)EnvWriteInt(state,"HW_TX23",0);
if(H==24)EnvWriteInt(state,"HW_TX24",0);
if(H==25)EnvWriteInt(state,"HW_TX25",0);
if(H==26)EnvWriteInt(state,"HW_TX26",0);
if(H==27)EnvWriteInt(state,"HW_TX27",0);
if(H==28)EnvWriteInt(state,"HW_TX28",0);
if(H==29)EnvWriteInt(state,"HW_TX29",0);
if(H==30)EnvWriteInt(state,"HW_TX30",0);
if(H==31)EnvWriteInt(state,"HW_TX31",0);
if(H==32)EnvWriteInt(state,"HW_TX32",0);
if(H==1)EnvWriteInt(state,"HW_TY1",0);
if(H==2)EnvWriteInt(state,"HW_TY2",0);
if(H==3)EnvWriteInt(state,"HW_TY3",0);
if(H==4)EnvWriteInt(state,"HW_TY4",0);
if(H==5)EnvWriteInt(state,"HW_TY5",0);
if(H==6)EnvWriteInt(state,"HW_TY6",0);
if(H==7)EnvWriteInt(state,"HW_TY7",0);
if(H==8)EnvWriteInt(state,"HW_TY8",0);
if(H==9)EnvWriteInt(state,"HW_TY9",0);
if(H==10)EnvWriteInt(state,"HW_TY10",0);
if(H==11)EnvWriteInt(state,"HW_TY11",0);
if(H==12)EnvWriteInt(state,"HW_TY12",0);
if(H==13)EnvWriteInt(state,"HW_TY13",0);
if(H==14)EnvWriteInt(state,"HW_TY14",0);
if(H==15)EnvWriteInt(state,"HW_TY15",0);
if(H==16)EnvWriteInt(state,"HW_TY16",0);
if(H==17)EnvWriteInt(state,"HW_TY17",0);
if(H==18)EnvWriteInt(state,"HW_TY18",0);
if(H==19)EnvWriteInt(state,"HW_TY19",0);
if(H==20)EnvWriteInt(state,"HW_TY20",0);
if(H==21)EnvWriteInt(state,"HW_TY21",0);
if(H==22)EnvWriteInt(state,"HW_TY22",0);
if(H==23)EnvWriteInt(state,"HW_TY23",0);
if(H==24)EnvWriteInt(state,"HW_TY24",0);
if(H==25)EnvWriteInt(state,"HW_TY25",0);
if(H==26)EnvWriteInt(state,"HW_TY26",0);
if(H==27)EnvWriteInt(state,"HW_TY27",0);
if(H==28)EnvWriteInt(state,"HW_TY28",0);
if(H==29)EnvWriteInt(state,"HW_TY29",0);
if(H==30)EnvWriteInt(state,"HW_TY30",0);
if(H==31)EnvWriteInt(state,"HW_TY31",0);
if(H==32)EnvWriteInt(state,"HW_TY32",0);
if(H==1)EnvWriteInt(state,"HW_OWNER1",0);
if(H==2)EnvWriteInt(state,"HW_OWNER2",0);
if(H==3)EnvWriteInt(state,"HW_OWNER3",0);
if(H==4)EnvWriteInt(state,"HW_OWNER4",0);
if(H==5)EnvWriteInt(state,"HW_OWNER5",0);
if(H==6)EnvWriteInt(state,"HW_OWNER6",0);
if(H==7)EnvWriteInt(state,"HW_OWNER7",0);
if(H==8)EnvWriteInt(state,"HW_OWNER8",0);
if(H==9)EnvWriteInt(state,"HW_OWNER9",0);
if(H==10)EnvWriteInt(state,"HW_OWNER10",0);
if(H==11)EnvWriteInt(state,"HW_OWNER11",0);
if(H==12)EnvWriteInt(state,"HW_OWNER12",0);
if(H==13)EnvWriteInt(state,"HW_OWNER13",0);
if(H==14)EnvWriteInt(state,"HW_OWNER14",0);
if(H==15)EnvWriteInt(state,"HW_OWNER15",0);
if(H==16)EnvWriteInt(state,"HW_OWNER16",0);
if(H==17)EnvWriteInt(state,"HW_OWNER17",0);
if(H==18)EnvWriteInt(state,"HW_OWNER18",0);
if(H==19)EnvWriteInt(state,"HW_OWNER19",0);
if(H==20)EnvWriteInt(state,"HW_OWNER20",0);
if(H==21)EnvWriteInt(state,"HW_OWNER21",0);
if(H==22)EnvWriteInt(state,"HW_OWNER22",0);
if(H==23)EnvWriteInt(state,"HW_OWNER23",0);
if(H==24)EnvWriteInt(state,"HW_OWNER24",0);
if(H==25)EnvWriteInt(state,"HW_OWNER25",0);
if(H==26)EnvWriteInt(state,"HW_OWNER26",0);
if(H==27)EnvWriteInt(state,"HW_OWNER27",0);
if(H==28)EnvWriteInt(state,"HW_OWNER28",0);
if(H==29)EnvWriteInt(state,"HW_OWNER29",0);
if(H==30)EnvWriteInt(state,"HW_OWNER30",0);
if(H==31)EnvWriteInt(state,"HW_OWNER31",0);
if(H==32)EnvWriteInt(state,"HW_OWNER32",0);
                continue;
            }

            tx=target.pos.x;
            ty=target.pos.y;
            owner=target.player;
if(H==1)EnvWriteInt(state,"HW_TX1",tx);
if(H==2)EnvWriteInt(state,"HW_TX2",tx);
if(H==3)EnvWriteInt(state,"HW_TX3",tx);
if(H==4)EnvWriteInt(state,"HW_TX4",tx);
if(H==5)EnvWriteInt(state,"HW_TX5",tx);
if(H==6)EnvWriteInt(state,"HW_TX6",tx);
if(H==7)EnvWriteInt(state,"HW_TX7",tx);
if(H==8)EnvWriteInt(state,"HW_TX8",tx);
if(H==9)EnvWriteInt(state,"HW_TX9",tx);
if(H==10)EnvWriteInt(state,"HW_TX10",tx);
if(H==11)EnvWriteInt(state,"HW_TX11",tx);
if(H==12)EnvWriteInt(state,"HW_TX12",tx);
if(H==13)EnvWriteInt(state,"HW_TX13",tx);
if(H==14)EnvWriteInt(state,"HW_TX14",tx);
if(H==15)EnvWriteInt(state,"HW_TX15",tx);
if(H==16)EnvWriteInt(state,"HW_TX16",tx);
if(H==17)EnvWriteInt(state,"HW_TX17",tx);
if(H==18)EnvWriteInt(state,"HW_TX18",tx);
if(H==19)EnvWriteInt(state,"HW_TX19",tx);
if(H==20)EnvWriteInt(state,"HW_TX20",tx);
if(H==21)EnvWriteInt(state,"HW_TX21",tx);
if(H==22)EnvWriteInt(state,"HW_TX22",tx);
if(H==23)EnvWriteInt(state,"HW_TX23",tx);
if(H==24)EnvWriteInt(state,"HW_TX24",tx);
if(H==25)EnvWriteInt(state,"HW_TX25",tx);
if(H==26)EnvWriteInt(state,"HW_TX26",tx);
if(H==27)EnvWriteInt(state,"HW_TX27",tx);
if(H==28)EnvWriteInt(state,"HW_TX28",tx);
if(H==29)EnvWriteInt(state,"HW_TX29",tx);
if(H==30)EnvWriteInt(state,"HW_TX30",tx);
if(H==31)EnvWriteInt(state,"HW_TX31",tx);
if(H==32)EnvWriteInt(state,"HW_TX32",tx);
if(H==1)EnvWriteInt(state,"HW_TY1",ty);
if(H==2)EnvWriteInt(state,"HW_TY2",ty);
if(H==3)EnvWriteInt(state,"HW_TY3",ty);
if(H==4)EnvWriteInt(state,"HW_TY4",ty);
if(H==5)EnvWriteInt(state,"HW_TY5",ty);
if(H==6)EnvWriteInt(state,"HW_TY6",ty);
if(H==7)EnvWriteInt(state,"HW_TY7",ty);
if(H==8)EnvWriteInt(state,"HW_TY8",ty);
if(H==9)EnvWriteInt(state,"HW_TY9",ty);
if(H==10)EnvWriteInt(state,"HW_TY10",ty);
if(H==11)EnvWriteInt(state,"HW_TY11",ty);
if(H==12)EnvWriteInt(state,"HW_TY12",ty);
if(H==13)EnvWriteInt(state,"HW_TY13",ty);
if(H==14)EnvWriteInt(state,"HW_TY14",ty);
if(H==15)EnvWriteInt(state,"HW_TY15",ty);
if(H==16)EnvWriteInt(state,"HW_TY16",ty);
if(H==17)EnvWriteInt(state,"HW_TY17",ty);
if(H==18)EnvWriteInt(state,"HW_TY18",ty);
if(H==19)EnvWriteInt(state,"HW_TY19",ty);
if(H==20)EnvWriteInt(state,"HW_TY20",ty);
if(H==21)EnvWriteInt(state,"HW_TY21",ty);
if(H==22)EnvWriteInt(state,"HW_TY22",ty);
if(H==23)EnvWriteInt(state,"HW_TY23",ty);
if(H==24)EnvWriteInt(state,"HW_TY24",ty);
if(H==25)EnvWriteInt(state,"HW_TY25",ty);
if(H==26)EnvWriteInt(state,"HW_TY26",ty);
if(H==27)EnvWriteInt(state,"HW_TY27",ty);
if(H==28)EnvWriteInt(state,"HW_TY28",ty);
if(H==29)EnvWriteInt(state,"HW_TY29",ty);
if(H==30)EnvWriteInt(state,"HW_TY30",ty);
if(H==31)EnvWriteInt(state,"HW_TY31",ty);
if(H==32)EnvWriteInt(state,"HW_TY32",ty);
if(H==1)EnvWriteInt(state,"HW_OWNER1",owner);
if(H==2)EnvWriteInt(state,"HW_OWNER2",owner);
if(H==3)EnvWriteInt(state,"HW_OWNER3",owner);
if(H==4)EnvWriteInt(state,"HW_OWNER4",owner);
if(H==5)EnvWriteInt(state,"HW_OWNER5",owner);
if(H==6)EnvWriteInt(state,"HW_OWNER6",owner);
if(H==7)EnvWriteInt(state,"HW_OWNER7",owner);
if(H==8)EnvWriteInt(state,"HW_OWNER8",owner);
if(H==9)EnvWriteInt(state,"HW_OWNER9",owner);
if(H==10)EnvWriteInt(state,"HW_OWNER10",owner);
if(H==11)EnvWriteInt(state,"HW_OWNER11",owner);
if(H==12)EnvWriteInt(state,"HW_OWNER12",owner);
if(H==13)EnvWriteInt(state,"HW_OWNER13",owner);
if(H==14)EnvWriteInt(state,"HW_OWNER14",owner);
if(H==15)EnvWriteInt(state,"HW_OWNER15",owner);
if(H==16)EnvWriteInt(state,"HW_OWNER16",owner);
if(H==17)EnvWriteInt(state,"HW_OWNER17",owner);
if(H==18)EnvWriteInt(state,"HW_OWNER18",owner);
if(H==19)EnvWriteInt(state,"HW_OWNER19",owner);
if(H==20)EnvWriteInt(state,"HW_OWNER20",owner);
if(H==21)EnvWriteInt(state,"HW_OWNER21",owner);
if(H==22)EnvWriteInt(state,"HW_OWNER22",owner);
if(H==23)EnvWriteInt(state,"HW_OWNER23",owner);
if(H==24)EnvWriteInt(state,"HW_OWNER24",owner);
if(H==25)EnvWriteInt(state,"HW_OWNER25",owner);
if(H==26)EnvWriteInt(state,"HW_OWNER26",owner);
if(H==27)EnvWriteInt(state,"HW_OWNER27",owner);
if(H==28)EnvWriteInt(state,"HW_OWNER28",owner);
if(H==29)EnvWriteInt(state,"HW_OWNER29",owner);
if(H==30)EnvWriteInt(state,"HW_OWNER30",owner);
if(H==31)EnvWriteInt(state,"HW_OWNER31",owner);
if(H==32)EnvWriteInt(state,"HW_OWNER32",owner);
        }
        else
        {
            owner=target.player;
if(H==1)EnvWriteInt(state,"HW_OWNER1",owner);
if(H==2)EnvWriteInt(state,"HW_OWNER2",owner);
if(H==3)EnvWriteInt(state,"HW_OWNER3",owner);
if(H==4)EnvWriteInt(state,"HW_OWNER4",owner);
if(H==5)EnvWriteInt(state,"HW_OWNER5",owner);
if(H==6)EnvWriteInt(state,"HW_OWNER6",owner);
if(H==7)EnvWriteInt(state,"HW_OWNER7",owner);
if(H==8)EnvWriteInt(state,"HW_OWNER8",owner);
if(H==9)EnvWriteInt(state,"HW_OWNER9",owner);
if(H==10)EnvWriteInt(state,"HW_OWNER10",owner);
if(H==11)EnvWriteInt(state,"HW_OWNER11",owner);
if(H==12)EnvWriteInt(state,"HW_OWNER12",owner);
if(H==13)EnvWriteInt(state,"HW_OWNER13",owner);
if(H==14)EnvWriteInt(state,"HW_OWNER14",owner);
if(H==15)EnvWriteInt(state,"HW_OWNER15",owner);
if(H==16)EnvWriteInt(state,"HW_OWNER16",owner);
if(H==17)EnvWriteInt(state,"HW_OWNER17",owner);
if(H==18)EnvWriteInt(state,"HW_OWNER18",owner);
if(H==19)EnvWriteInt(state,"HW_OWNER19",owner);
if(H==20)EnvWriteInt(state,"HW_OWNER20",owner);
if(H==21)EnvWriteInt(state,"HW_OWNER21",owner);
if(H==22)EnvWriteInt(state,"HW_OWNER22",owner);
if(H==23)EnvWriteInt(state,"HW_OWNER23",owner);
if(H==24)EnvWriteInt(state,"HW_OWNER24",owner);
if(H==25)EnvWriteInt(state,"HW_OWNER25",owner);
if(H==26)EnvWriteInt(state,"HW_OWNER26",owner);
if(H==27)EnvWriteInt(state,"HW_OWNER27",owner);
if(H==28)EnvWriteInt(state,"HW_OWNER28",owner);
if(H==29)EnvWriteInt(state,"HW_OWNER29",owner);
if(H==30)EnvWriteInt(state,"HW_OWNER30",owner);
if(H==31)EnvWriteInt(state,"HW_OWNER31",owner);
if(H==32)EnvWriteInt(state,"HW_OWNER32",owner);
        }

        // ============================================================
        // PHASE 0 = MARCHA + DETECCION DE ATASCO EN MURALLA
        // ============================================================
        if(phase[H]==0)
        {
            phaseTicks[H]+=1;

            sampleCount=0;
            nearCount=0;
            nearestD=-1;

            // --------------------------------------------------------
            // Distancia actual de una muestra de la horda al Foro.
            // --------------------------------------------------------
            for(j=0;j<h.count;j+=5)
            {
                u=h[j].AsUnit();
                d=target.DistTo(u);

                sampleCount+=1;

                if(nearestD==-1||d<nearestD)
                    nearestD=d;

                if(d<=2500)
                    nearCount+=1;
            }

            // --------------------------------------------------------
            // CONDICION A — la antigua, que ya funciona:
            // una parte suficiente de la horda está cerca del Foro.
            // --------------------------------------------------------
            nearForumReady=0;

            if(
                (sampleCount>0&&nearCount*3>=sampleCount)
                ||
                (nearestD>=0&&nearestD<=1500)
            )
            {
                nearForumReady=1;
            }

            // --------------------------------------------------------
            // CONDICION B — nueva:
            // detectar que la horda ha dejado de acercarse al Foro.
            //
            // Medimos cada 3 s.
            // Si mejora al menos 100 unidades -> hay progreso.
            // Si no mejora durante 4 mediciones -> ~12 s atascada.
            //
            // No significa automáticamente "hay muralla":
            // sólo habilita una búsqueda LOCAL de Gate.
            // --------------------------------------------------------
            stuckMarch=0;

            if(phaseTicks[H]%3==0&&nearestD>=0)
            {
                if(marchLastDist[H]==0)
                {
                    marchLastDist[H]=nearestD;
                    marchStuck[H]=0;
                }
                else
                {
                    if(nearestD+100<marchLastDist[H])
                    {
                        // Progreso claro hacia el Foro.
                        marchLastDist[H]=nearestD;
                        marchStuck[H]=0;
                    }
                    else
                    {
                        marchStuck[H]+=1;

                        // Si hubo una pequeña mejora, conservar la mejor
                        // referencia sin considerarla todavía progreso claro.
                        if(nearestD<marchLastDist[H])
                            marchLastDist[H]=nearestD;
                    }
                }

                if(marchStuck[H]>=4)
                    stuckMarch=1;
            }

            // --------------------------------------------------------
            // ACTIVAR BUSQUEDA DE GATE si:
            // A) estamos cerca del Foro (lógica antigua)
            // O
            // B) llevamos ~12 s sin progresar (lógica nueva)
            // --------------------------------------------------------
            if(nearForumReady==1||stuckMarch==1)
            {
                ga=0;
                bestD=-1;

                // ====================================================
                // PRIMERA BUSQUEDA: GATE CERCA DE LA PROPIA HORDA
                //
                // Esta es la corrección para ciudades grandes.
                // No importa cuánto se encuentre la Gate del Foro.
                // ====================================================
                for(j=0;j<h.count;j+=5)
                {
                    u=h[j].AsUnit();

                    q=ObjsInRange(u,"Building",1600).GetObjList();

                    for(i=0;i<q.count;i+=1)
                    {
                        if(q[i].IsHeirOf("Gate")&&
                           q[i].player==target.player&&
                           q[i].health>1000)
                        {
                            cand=q[i].AsBuilding();

                            // La Gate debe estar hacia delante respecto
                            // al objetivo final, no detrás de la tropa.
                            if(cand.DistTo(target)<u.DistTo(target))
                            {
                                d=cand.DistTo(u);

                                if(bestD==-1||d<bestD)
                                {
                                    bestD=d;
                                    gate=cand;
                                    ga=1;
                                }
                            }
                        }
                    }
                }

                // ====================================================
                // FALLBACK ANTIGUO:
                //
                // Si estamos cerca del Foro pero no encontramos una Gate
                // local, conservar exactamente la detección anterior por
                // radio de 7000 alrededor del Foro.
                //
                // Así no rompemos las ciudades que ya funcionaban.
                // ====================================================
                if(ga==0&&nearForumReady==1)
                {
                    q=ObjsInRange(target,"Building",7000).GetObjList();

                    for(i=0;i<q.count;i+=1)
                    {
                        if(q[i].IsHeirOf("Gate")&&
                           q[i].player==target.player&&
                           q[i].health>1000)
                        {
                            cand=q[i].AsBuilding();

                            for(j=0;j<h.count;j+=5)
                            {
                                d=cand.DistTo(h[j].AsUnit());

                                if(bestD==-1||d<bestD)
                                {
                                    bestD=d;
                                    gate=cand;
                                    ga=1;
                                }
                            }
                        }
                    }
                }

                // ====================================================
                // GATE ENCONTRADA -> SIEGE
                // ====================================================
                if(ga==1)
                {
                    nCat=h.count/15;
                    if(nCat<=0)nCat=1;
                    if(nCat>4)nCat=4;

                    gateX[H]=gate.pos.x;
                    gateY[H]=gate.pos.y;
                    siegeHadHolder[H]=0;
                    lastGateHealth[H]=gate.health;
                    siegeNoProgress[H]=0;

                    // Reset de diagnóstico de marcha:
                    // ya sabemos que el obstáculo era una Gate.
                    marchLastDist[H]=0;
                    marchStuck[H]=0;

                    h.Siege(gate,nCat,4);

                    phase[H]=1;
                    phaseTicks[H]=0;
                    marchTicks[H]=0;
                    continue;
                }

                // ====================================================
                // NO HAY GATE
                //
                // CASO 1:
                // estábamos cerca del Foro -> conservar comportamiento
                // antiguo: asumir que existe paso y avanzar al interior.
                //
                // CASO 2:
                // sólo saltó el detector de atasco lejos del Foro ->
                // NO entrar en BREACH. Simplemente rearmar la medición y
                // continuar marchando.
                // ====================================================
                if(nearForumReady==1)
                {
                    for(j=0;j<h.count;j+=1)
                    {
                        u=h[j].AsUnit();

                        if(u.command!="attack"&&u.command!="engage")
                        {
                            breachPoint=Point(
                                target.pos.x+((j%7)-3)*60,
                                target.pos.y+(((j/7)%7)-3)*60
                            );

                            u.SetCommand("advance",breachPoint);
                        }
                    }

                    marchLastDist[H]=0;
                    marchStuck[H]=0;

                    phase[H]=2;
                    phaseTicks[H]=0;
                    continue;
                }
                else
                {
                    // Falso atasco (combate, giro de camino, etc.).
                    // Esperar otra ventana de progreso antes de buscar otra vez.
                    marchLastDist[H]=nearestD;
                    marchStuck[H]=0;
                }
            }

            // --------------------------------------------------------
            // Marcha lejana original.
            // Refresco cada 5 s sin pisar attack/engage.
            // --------------------------------------------------------
            marchTicks[H]+=1;

            if(marchTicks[H]>=5)
            {
                marchTicks[H]=0;

                for(j=0;j<h.count;j+=1)
                {
                    u=h[j].AsUnit();

                    if(u.command!="attack"&&u.command!="engage")
                    {
                        u.SetCommand("advance",target.pos);
                    }
                }
            }

            continue;
        }

        // ============================================================
        // PHASE 1 = SIEGE
        // ============================================================
        if(phase[H]==1)
        {
            phaseTicks[H]+=1;

            gx=gateX[H];
            gy=gateY[H];
            ga=0;

            q=ObjsInRange(target,"Building",7000).GetObjList();

            for(i=0;i<q.count&&ga==0;i+=1)
            {
                if(q[i].IsHeirOf("Gate")&&
                   q[i].pos.x==gx&&
                   q[i].pos.y==gy)
                {
                    gate=q[i].AsBuilding();
                    ga=1;
                }
            }

            // Gate desaparecida o ya en estado visual/transitable.
            if(ga==0||gate.health<=1000)
            {
                gateX[H]=0;
                gateY[H]=0;
                siegeHadHolder[H]=0;
                lastGateHealth[H]=0;
                siegeNoProgress[H]=0;

                for(j=0;j<h.count;j+=1)
                {
                    u=h[j].AsUnit();

                    if(u.command!="attack"&&u.command!="engage")
                    {
                        breachPoint=Point(
                            target.pos.x+((j%7)-3)*60,
                            target.pos.y+(((j/7)%7)-3)*60
                        );

                        u.SetCommand("advance",breachPoint);
                    }
                }

                phase[H]=2;
                phaseTicks[H]=0;
                continue;
            }

            // --------------------------------------------------------
            // ASEDIO AUTORREPARABLE
            //
            // Problema observado:
            // a veces la Gate se detecta, Siege() se llama, pero no llega
            // a aparecer el ariete y el grupo queda esperando.
            //
            // Cada 2 s comprobamos DOS señales de que el asedio está vivo:
            //
            //   A) alguna unidad está InHolder()
            //   B) la Gate ha perdido health
            //
            // Mientras ocurra A o B, NO reemitimos órdenes.
            //
            // Si durante 12 s no hay holder Y la Gate no pierde ni 1 HP,
            // volvemos a lanzar Siege() contra LA MISMA Gate.
            //
            // Si ya había holder y desaparece, sólo esperamos 4 s sin
            // progreso antes de reconstruir, porque ahí sí sabemos que el
            // arma probablemente fue destruida.
            // --------------------------------------------------------
            if(phaseTicks[H]%2==0)
            {
                bCat=0;

                for(j=0;j<h.count;j+=1)
                {
                    u=h[j].AsUnit();

                    if(u.InHolder())
                        bCat=1;
                }

                // Hay máquina/tripulación activa.
                if(bCat==1)
                {
                    siegeHadHolder[H]=1;
                    siegeNoProgress[H]=0;
                }

                // La Gate está recibiendo daño: el asedio funciona.
                if(gate.health<lastGateHealth[H])
                {
                    lastGateHealth[H]=gate.health;
                    siegeNoProgress[H]=0;
                }
                else
                {
                    // Sólo contar falta de progreso cuando tampoco hay holder.
                    if(bCat==0)
                        siegeNoProgress[H]+=2;
                }

                // Si nunca hubo holder: dar hasta 12 s al primer intento.
                // Si ya hubo holder y desapareció: 4 s bastan para reintentar.
                if(
                    (siegeHadHolder[H]==0&&siegeNoProgress[H]>=12)
                    ||
                    (siegeHadHolder[H]==1&&bCat==0&&siegeNoProgress[H]>=4)
                )
                {
                    nCat=h.count/15;
                    if(nCat<=0)nCat=1;
                    if(nCat>4)nCat=4;

                    h.Siege(gate,nCat,4);

                    // No reseteamos phaseTicks: seguimos vigilando la Gate.
                    // Sí reiniciamos la ventana de progreso del nuevo intento.
                    siegeHadHolder[H]=0;
                    siegeNoProgress[H]=0;
                    lastGateHealth[H]=gate.health;
                }
            }

            continue;
        }

        // ============================================================
        // PHASE 2 = BREACH_ADVANCE
        // ============================================================
        if(phase[H]==2)
        {
            phaseTicks[H]+=1;

            // Durante unos segundos NO pisamos el advance que ya está llevando
            // las tropas a través de la brecha hacia el Foro.
            //
            // Después pasamos a CAPTURE sin emitir una orden masiva nueva aquí.
            // Las unidades que terminen su advance quedarán idle y PHASE 3
            // les dará capture.
            if(phaseTicks[H]>=8)
            {
                phase[H]=3;
                phaseTicks[H]=0;
                lastForumDist[H]=0;
                captureStuck[H]=0;
            }

            continue;
        }

        // ============================================================
        // PHASE 3 = CAPTURE + LOYALTY — EL FORO ES EL OBJETIVO ABSOLUTO
        // ============================================================
        if(phase[H]==3)
        {
            phaseTicks[H]+=1;

            // --------------------------------------------------------
            // 0) CAPTURA DE LOYALTY DETERMINISTA
            //
            // Datos confirmados del motor:
            // LoyaltyRadiusTownhall = 850
            // LoyaltyInterval       = 2000 ms
            // LoyaltyChangeCap      = 10 por intervalo
            //
            // El main loop duerme 1000 ms, así que phaseTicks%2==0
            // reproduce un intervalo aproximado de 2 segundos.
            //
            // Sólo cuenta zombies físicamente a <=850 del Foro.
            // Si no ha entrado nadie de verdad, NO baja loyalty.
            // --------------------------------------------------------
            if(phaseTicks[H]%2==0)
            {
                zombiesIn=0;

                for(j=0;j<h.count;j+=1)
                {
                    u=h[j].AsUnit();

                    if(target.DistTo(u)<=850)
                        zombiesIn+=1;
                }

                if(zombiesIn>0)
                {
                    actualLoyalty=target.settlement.loyalty;

                    // Máximo nativo confirmado: 10 puntos / intervalo.
                    drop=zombiesIn;
                    if(drop>10)drop=10;
                    if(drop<1)drop=1;

                    actualLoyalty-=drop;

                    // No escribir 0 y esperar otro tick.
                    // En el MISMO tick:
                    //   loyalty -> 1
                    //   owner   -> Player 12
                    //   loyalty -> 11
                    //
                    // 11 es el valor que usa unit_capture.vs después de
                    // una captura nativa.
                    if(actualLoyalty<=1)
                    {
                        target.settlement.SetLoyalty(1);
                        target.settlement.SetPlayer(HP);
                        target.settlement.SetLoyalty(11);

                        phase[H]=0;
                        marchTicks[H]=4;
                        phaseTicks[H]=0;
                        gateX[H]=0;
                        gateY[H]=0;
                        siegeHadHolder[H]=0;
                        lastGateHealth[H]=0;
                        siegeNoProgress[H]=0;
                        lastForumDist[H]=0;
                        captureStuck[H]=0;
                        marchLastDist[H]=0;
                        marchStuck[H]=0;

                        continue;
                    }
                    else
                    {
                        target.settlement.SetLoyalty(actualLoyalty);
                    }
                }
            }

            // --------------------------------------------------------
            // 1) CAPTURE estilo helper nativo.
            //
            // Sólo tocar unidades idle/capture.
            // NO sustituir:
            //   advance todavía en curso
            //   attack
            //   engage
            // ni ninguna otra acción.
            //
            // Así las unidades que ya están entrando terminan su trayecto,
            // y cuando quedan idle reciben capture.
            // --------------------------------------------------------
            if(phaseTicks[H]%2==0)
            {
                for(j=0;j<h.count;j+=1)
                {
                    u=h[j].AsUnit();

                    if(u.command=="idle"||u.command=="capture")
                    {
                        u.SetCommand("capture",target);
                    }
                }
            }

            // --------------------------------------------------------
            // 2) MEDIR PROGRESO REAL HACIA EL FORO.
            //
            // Esto sustituye el viejo comportamiento:
            // "si veo cualquier Gate a 1800 -> destruirla".
            //
            // Cada 3 s calculamos la unidad muestreada más cercana al Foro.
            // Si se acerca, NO existe atasco.
            // --------------------------------------------------------
            if(phaseTicks[H]%3==0)
            {
                nearestD=-1;

                for(j=0;j<h.count;j+=5)
                {
                    d=target.DistTo(h[j].AsUnit());

                    if(nearestD==-1||d<nearestD)
                        nearestD=d;
                }

                if(lastForumDist[H]==0)
                {
                    lastForumDist[H]=nearestD;
                    captureStuck[H]=0;
                }
                else
                {
                    // Progreso apreciable: al menos 80 unidades más cerca.
                    if(nearestD+80<lastForumDist[H])
                    {
                        lastForumDist[H]=nearestD;
                        captureStuck[H]=0;
                    }
                    else
                    {
                        captureStuck[H]+=1;

                        // Actualizar referencia lentamente para no conservar
                        // una distancia antigua durante toda la batalla.
                        if(nearestD<lastForumDist[H])
                            lastForumDist[H]=nearestD;
                    }
                }

                // ----------------------------------------------------
                // Si alguien ya está muy cerca del Foro, JAMÁS buscar
                // otra Gate. El acceso está resuelto.
                // ----------------------------------------------------
                if(nearestD<=900)
                {
                    captureStuck[H]=0;
                }
            }

            // --------------------------------------------------------
            // 3) SEGUNDA GATE SÓLO SI REALMENTE BLOQUEA EL CAMINO.
            //
            // Condiciones simultáneas:
            // - mínimo ~15 s en CAPTURE;
            // - 5 mediciones consecutivas sin progreso (~15 s);
            // - ningún zombie muestreado ha llegado cerca del Foro
            //   (nearestD > 900).
            //
            // Además, una Gate candidata sólo vale si está "por delante"
            // del zombie respecto al Foro:
            //
            //    distancia Gate->Foro < distancia Zombie->Foro
            //
            // Así una puerta exterior o lateral detrás de las tropas NO
            // provoca que salgan de la ciudad para destruirla.
            // --------------------------------------------------------
            if(
                phaseTicks[H]>=15
                &&
                captureStuck[H]>=5
                &&
                nearestD>900
                &&
                phaseTicks[H]%3==0
            )
            {
                nearbyGate=0;
                bestD=-1;

                for(j=0;j<h.count;j+=5)
                {
                    u=h[j].AsUnit();

                    q=ObjsInRange(u,"Building",1200).GetObjList();

                    for(i=0;i<q.count;i+=1)
                    {
                        if(q[i].IsHeirOf("Gate")&&
                           q[i].player==target.player&&
                           q[i].health>1000)
                        {
                            cand=q[i].AsBuilding();

                            // Gate debe estar más cerca del Foro que la unidad:
                            // obstáculo hacia delante, no una puerta detrás.
                            if(cand.DistTo(target)<u.DistTo(target))
                            {
                                d=cand.DistTo(u);

                                if(bestD==-1||d<bestD)
                                {
                                    bestD=d;
                                    gate=cand;
                                    nearbyGate=1;
                                }
                            }
                        }
                    }
                }

                if(nearbyGate==1)
                {
                    nCat=h.count/15;
                    if(nCat<=0)nCat=1;
                    if(nCat>4)nCat=4;

                    gateX[H]=gate.pos.x;
                    gateY[H]=gate.pos.y;
                    siegeHadHolder[H]=0;
                    lastGateHealth[H]=gate.health;
                    siegeNoProgress[H]=0;

                    h.Siege(gate,nCat,4);

                    phase[H]=1;
                    phaseTicks[H]=0;
                    lastForumDist[H]=0;
                    captureStuck[H]=0;

                    continue;
                }

                // No había Gate realmente bloqueante.
                // No inventar otro objetivo: mantener capture al Foro.
                captureStuck[H]=0;
                lastForumDist[H]=nearestD;
            }

            continue;
        }

        // Estado inesperado -> volver a marcha.
        phase[H]=0;
        marchTicks[H]=4;
        phaseTicks[H]=0;
        gateX[H]=0;
        gateY[H]=0;
        siegeHadHolder[H]=0;
        lastGateHealth[H]=0;
        siegeNoProgress[H]=0;
        lastForumDist[H]=0;
        captureStuck[H]=0;
        marchLastDist[H]=0;
        marchStuck[H]=0;
    }
}
