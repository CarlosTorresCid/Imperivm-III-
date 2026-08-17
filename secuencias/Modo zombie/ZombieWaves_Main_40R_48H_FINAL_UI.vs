// ZombieWaves_Main_40R_48H_FINAL_UI - Autorun
//
// DISEÑO FINAL DE ESTA PRUEBA
// - 40 rondas.
// - Delay inicial: 30 minutos.
// - Intervalo: 2 minutos.
// - R1..R32: 1 horda por ronda.
// - R33..R40: 2 hordas por ronda, en spawns distintos.
// - Total interno máximo: 48 hordas (HW_H1..HW_H48).
// - Spawn aleatorio entre HordeSpawn_01..08.
// - HordeSpawn_07 se usa como punto visual de las notificaciones.
// - Aviso a 30 s.
// - Cuenta atrás: 3, 2, 1.
// - Al aparecer: RONDA X/40.
// - Dificultad ligeramente superior a HARD.
// - R33..R40 incluyen CWarElephant.
// - Sin héroes zombies.

ObjList q;ObjList stateList;
Building state;
Unit u;

point s1;point s2;point s3;point s4;point s5;point s6;point s7;point s8;point p;

str c1;str c2;str c3;str c4;str c5;str c6;str c7;str c8;str c9;str c10;str c11;str c12;str c13;str cls;
int n1;int n2;int n3;int n4;int n5;int n6;int n7;int n8;int n9;int n10;int n11;int n12;int n13;

int HP;int START_DELAY;int WAVE_INTERVAL;int MAX_ROUNDS;int SP;
int nextWave;int now;int w;int S;int lv;int t;int n;int i;int idx;int k;
int A;int spawnCount;int sa;int sb;int si;
int warn30;int warn3;int warn2;int warn1;int nextRound;

HP=12;
START_DELAY=0;
WAVE_INTERVAL=120000;
MAX_ROUNDS=40;
SP=55;

stateList=Group("CapitalForum_P1").GetObjList();
stateList.ClearDead();
if(stateList.count!=1){while(1)Sleep(60000);}
state=stateList[0].AsBuilding();

q=Group("HordeSpawn_01").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s1=q[0].pos;
q=Group("HordeSpawn_02").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s2=q[0].pos;
q=Group("HordeSpawn_03").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s3=q[0].pos;
q=Group("HordeSpawn_04").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s4=q[0].pos;
q=Group("HordeSpawn_05").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s5=q[0].pos;
q=Group("HordeSpawn_06").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s6=q[0].pos;
q=Group("HordeSpawn_07").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s7=q[0].pos;
q=Group("HordeSpawn_08").GetObjList();q.ClearDead();if(q.count!=1){while(1)Sleep(60000);}else s8=q[0].pos;

w=0;
nextWave=GetTime()+START_DELAY;
warn30=0;warn3=0;warn2=0;warn1=0;

while(1)
{
    Sleep(250);
    now=GetTime();

    if(w>=MAX_ROUNDS)
        continue;

    // ========================================================
    // AVISOS PREVIOS — visibles pero no permanentes
    // ========================================================
    if(now<nextWave)
    {
        nextRound=w+1;

        if(now>=nextWave-30000&&warn30==0)
        {
            for(k=1;k<=8;k+=1)
                UserNotification("RONDA "+nextRound+"/40 - Nueva horda en 30 segundos","",s7,k);
            warn30=1;
        }

        if(now>=nextWave-3000&&warn3==0)
        {
            if(nextRound>=33)
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - DOS HORDAS EN 3...","",s7,k);
            }
            else
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - NUEVA HORDA EN 3...","",s7,k);
            }
            warn3=1;
        }

        if(now>=nextWave-2000&&warn2==0)
        {
            if(nextRound>=33)
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - DOS HORDAS EN 2...","",s7,k);
            }
            else
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - NUEVA HORDA EN 2...","",s7,k);
            }
            warn2=1;
        }

        if(now>=nextWave-1000&&warn1==0)
        {
            if(nextRound>=33)
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - DOS HORDAS EN 1...","",s7,k);
            }
            else
            {
                for(k=1;k<=8;k+=1)
                    UserNotification("RONDA "+nextRound+"/40 - NUEVA HORDA EN 1...","",s7,k);
            }
            warn1=1;
        }

        continue;
    }

    // ========================================================
    // COMIENZA LA RONDA
    // ========================================================
    w+=1;

    if(w>=33)
    {
        for(k=1;k<=8;k+=1)
            UserNotification("RONDA "+w+"/40 - ¡DOS HORDAS HAN LLEGADO!","",s7,k);
        spawnCount=2;
    }
    else
    {
        for(k=1;k<=8;k+=1)
            UserNotification("RONDA "+w+"/40 - ¡LA HORDA HA LLEGADO!","",s7,k);
        spawnCount=1;
    }

    // Elegir dos spawns distintos. En R1..R32 sólo se usa sa.
    sa=rand(8)+1;
    sb=rand(8)+1;
    while(sb==sa)sb=rand(8)+1;

    for(A=0;A<spawnCount;A+=1)
    {
        si=sa;
        if(A==1)si=sb;

        if(si==1)p=s1;
        if(si==2)p=s2;
        if(si==3)p=s3;
        if(si==4)p=s4;
        if(si==5)p=s5;
        if(si==6)p=s6;
        if(si==7)p=s7;
        if(si==8)p=s8;

        // Mapeo de ronda a ID interno de horda:
        // R1..R32 -> H1..H32
        // R33 -> H33,H34
        // ...
        // R40 -> H47,H48
        if(w<=32)
            S=w;
        else
            S=33+(w-33)*2+A;

        c1="";c2="";c3="";c4="";c5="";c6="";c7="";c8="";c9="";c10="";c11="";c12="";c13="";
        n1=0;n2=0;n3=0;n4=0;n5=0;n6=0;n7=0;n8=0;n9=0;n10=0;n11=0;n12=0;n13=0;
        lv=1;

if(w==1){lv=6;c1="TMaceman";n1=50;c2="RHastatus";n2=40;c3="GAxeman";n3=20;c4="ISlinger";n4=10;}
if(w==2){lv=6;c1="TMaceman";n1=45;c2="GAxeman";n2=40;c3="RHastatus";n3=25;c4="RArcher";n4=20;}
if(w==3){lv=7;c1="RHastatus";n1=45;c2="CLibyanFootman";n2=40;c3="BBronzeSpearman";n3=25;c4="ISlinger";n4=20;c5="CJavelinThrower";n5=10;}
if(w==4){lv=7;c1="TMaceman";n1=50;c2="GAxeman";n2=30;c3="RHastatus";n3=30;c4="EGuardian";n4=20;c5="RArcher";n5=20;}
if(w==5){lv=8;c1="TMaceman";n1=55;c2="RHastatus";n2=35;c3="GAxeman";n3=25;c4="EGuardian";n4=20;c5="ISlinger";n5=15;c6="GHorseman";n6=10;}
if(w==6){lv=8;c1="CLibyanFootman";n1=55;c2="TMaceman";n2=35;c3="BBronzeSpearman";n3=30;c4="EGuardian";n4=20;c5="CJavelinThrower";n5=20;c6="CNumidianRider";n6=10;}
if(w==7){lv=9;c1="RHastatus";n1=60;c2="GAxeman";n2=40;c3="TMaceman";n3=30;c4="EGuardian";n4=20;c5="ISlinger";n5=15;c6="GHorseman";n6=15;}
if(w==8){lv=9;c1="TMaceman";n1=60;c2="CLibyanFootman";n2=40;c3="RHastatus";n3=30;c4="BBronzeSpearman";n4=20;c5="RArcher";n5=20;c6="CNumidianRider";n6=20;}
if(w==9){lv=10;c1="TMaceman";n1=65;c2="RHastatus";n2=45;c3="GAxeman";n3=30;c4="EGuardian";n4=20;c5="CJavelinThrower";n5=20;c6="GHorseman";n6=20;}
if(w==10){lv=11;c1="TMaceman";n1=65;c2="RHastatus";n2=50;c3="GAxeman";n3=35;c4="EGuardian";n4=25;c5="ISlinger";n5=20;c6="CJavelinThrower";n6=15;c7="GHorseman";n7=10;c8="RPraetorian";n8=15;}
if(w==11){lv=11;c1="CLibyanFootman";n1=70;c2="TMaceman";n2=50;c3="RHastatus";n3=35;c4="EGuardian";n4=25;c5="CJavelinThrower";n5=20;c6="CNumidianRider";n6=15;c7="RPraetorian";n7=10;c8="RArcher";n8=20;}
if(w==12){lv=12;c1="RHastatus";n1=70;c2="TMaceman";n2=55;c3="GAxeman";n3=35;c4="EGuardian";n4=25;c5="ISlinger";n5=20;c6="CJavelinThrower";n6=20;c7="GHorseman";n7=20;c8="IEliteGuard";n8=10;}
if(w==13){lv=12;c1="TMaceman";n1=75;c2="RHastatus";n2=55;c3="CLibyanFootman";n3=40;c4="GAxeman";n4=25;c5="EGuardian";n5=25;c6="RArcher";n6=20;c7="CNumidianRider";n7=15;c8="BHighlander";n8=10;}
if(w==14){lv=13;c1="CLibyanFootman";n1=75;c2="TMaceman";n2=55;c3="RHastatus";n3=40;c4="EGuardian";n4=25;c5="ISlinger";n5=20;c6="CJavelinThrower";n6=20;c7="GHorseman";n7=15;c8="EAnubisWarrior";n8=15;c9="RArcher";n9=10;}
if(w==15){lv=14;c1="TMaceman";n1=80;c2="RHastatus";n2=60;c3="GAxeman";n3=35;c4="CLibyanFootman";n4=25;c5="EGuardian";n5=20;c6="ISlinger";n6=20;c7="CJavelinThrower";n7=10;c8="GHorseman";n8=15;c9="RPraetorian";n9=10;c10="IEliteGuard";n10=10;}
if(w==16){lv=14;c1="RHastatus";n1=80;c2="TMaceman";n2=60;c3="CLibyanFootman";n3=40;c4="GAxeman";n4=25;c5="EGuardian";n5=20;c6="RArcher";n6=20;c7="CJavelinThrower";n7=25;c8="CNumidianRider";n8=15;c9="TValkyrie";n9=10;}
if(w==17){lv=15;c1="TMaceman";n1=85;c2="RHastatus";n2=65;c3="GAxeman";n3=40;c4="EGuardian";n4=25;c5="ISlinger";n5=20;c6="RArcher";n6=20;c7="CJavelinThrower";n7=15;c8="GHorseman";n8=15;c9="GTridentWarrior";n9=10;c10="BHighlander";n10=10;}
if(w==18){lv=15;c1="CLibyanFootman";n1=85;c2="TMaceman";n2=65;c3="RHastatus";n3=45;c4="GAxeman";n4=20;c5="EGuardian";n5=25;c6="ISlinger";n6=20;c7="CJavelinThrower";n7=20;c8="CNumidianRider";n8=15;c9="EAnubisWarrior";n9=10;c10="EHorusWarrior";n10=10;}
if(w==19){lv=16;c1="TMaceman";n1=90;c2="RHastatus";n2=65;c3="GAxeman";n3=50;c4="CLibyanFootman";n4=30;c5="EGuardian";n5=20;c6="RArcher";n6=20;c7="ISlinger";n7=15;c8="GHorseman";n8=15;c9="CNoble";n9=15;c10="RPraetorian";n10=10;}
if(w==20){lv=17;c1="TMaceman";n1=95;c2="RHastatus";n2=70;c3="GAxeman";n3=40;c4="EGuardian";n4=25;c5="ISlinger";n5=25;c6="CJavelinThrower";n6=25;c7="GHorseman";n7=15;c8="TValkyrie";n8=15;c9="BHighlander";n9=15;c10="EAnubisWarrior";n10=15;}
if(w==21){lv=17;c1="TMaceman";n1=90;c2="RHastatus";n2=70;c3="GAxeman";n3=50;c4="CLibyanFootman";n4=35;c5="ISlinger";n5=25;c6="CJavelinThrower";n6=20;c7="CNumidianRider";n7=15;c8="RPraetorian";n8=15;c9="IEliteGuard";n9=15;c10="EAnubisWarrior";n10=15;}
if(w==22){lv=18;c1="CLibyanFootman";n1=95;c2="TMaceman";n2=75;c3="RHastatus";n3=55;c4="EGuardian";n4=30;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="EChariot";n7=15;c8="CNoble";n8=15;c9="BHighlander";n9=15;c10="EHorusWarrior";n10=15;}
if(w==23){lv=18;c1="TMaceman";n1=95;c2="RHastatus";n2=75;c3="GAxeman";n3=55;c4="EGuardian";n4=30;c5="ISlinger";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=20;c8="TValkyrie";n8=20;c9="GTridentWarrior";n9=15;c10="IEliteGuard";n10=15;}
if(w==24){lv=19;c1="RHastatus";n1=100;c2="TMaceman";n2=80;c3="CLibyanFootman";n3=55;c4="EGuardian";n4=30;c5="CJavelinThrower";n5=25;c6="CNumidianRider";n6=20;c7="EAnubisWarrior";n7=20;c8="EHorusWarrior";n8=20;c9="CNoble";n9=15;c10="BHighlander";n10=15;}
if(w==25){lv=20;c1="TMaceman";n1=100;c2="RHastatus";n2=80;c3="GAxeman";n3=55;c4="ISlinger";n4=30;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=20;c8="TValkyrie";n8=20;c9="IEliteGuard";n9=20;c10="EAnubisWarrior";n10=20;}
if(w==26){lv=20;c1="CLibyanFootman";n1=105;c2="TMaceman";n2=85;c3="RHastatus";n3=60;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=20;c8="BHighlander";n8=20;c9="EHorusWarrior";n9=15;c10="GTridentWarrior";n10=15;}
if(w==27){lv=20;c1="TMaceman";n1=105;c2="RHastatus";n2=85;c3="GAxeman";n3=60;c4="EGuardian";n4=35;c5="ISlinger";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=20;c8="TValkyrie";n8=20;c9="IEliteGuard";n9=20;c10="EAnubisWarrior";n10=20;}
if(w==28){lv=20;c1="RHastatus";n1=110;c2="TMaceman";n2=90;c3="CLibyanFootman";n3=65;c4="EGuardian";n4=35;c5="CJavelinThrower";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=20;c8="BHighlander";n8=20;c9="EHorusWarrior";n9=20;c10="GTridentWarrior";n10=15;}
if(w==29){lv=20;c1="TMaceman";n1=115;c2="RHastatus";n2=90;c3="GAxeman";n3=65;c4="ISlinger";n4=35;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=25;c8="TValkyrie";n8=20;c9="IEliteGuard";n9=20;c10="EAnubisWarrior";n10=20;}
if(w==30){lv=20;c1="CLibyanFootman";n1=120;c2="TMaceman";n2=90;c3="RHastatus";n3=65;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=25;c8="BHighlander";n8=25;c9="EHorusWarrior";n9=20;c10="GTridentWarrior";n10=20;}
if(w==31){lv=20;c1="TMaceman";n1=120;c2="RHastatus";n2=95;c3="GAxeman";n3=65;c4="ISlinger";n4=35;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=25;c8="TValkyrie";n8=25;c9="IEliteGuard";n9=25;c10="EAnubisWarrior";n10=20;}
if(w==32){lv=20;c1="RHastatus";n1=125;c2="TMaceman";n2=95;c3="CLibyanFootman";n3=70;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=25;c8="BHighlander";n8=25;c9="EHorusWarrior";n9=25;c10="GTridentWarrior";n10=20;}
if(w==33){lv=20;c1="TMaceman";n1=121;c2="RHastatus";n2=100;c3="GAxeman";n3=70;c4="ISlinger";n4=35;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=25;c8="TValkyrie";n8=25;c9="IEliteGuard";n9=25;c10="EAnubisWarrior";n10=25;c11="CWarElephant";n11=4;}
if(w==34){lv=20;c1="CLibyanFootman";n1=126;c2="TMaceman";n2=100;c3="RHastatus";n3=70;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=30;c8="BHighlander";n8=25;c9="EHorusWarrior";n9=25;c10="GTridentWarrior";n10=25;c11="CWarElephant";n11=4;}
if(w==35){lv=20;c1="TMaceman";n1=125;c2="RHastatus";n2=105;c3="GAxeman";n3=75;c4="ISlinger";n4=35;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=30;c8="TValkyrie";n8=25;c9="IEliteGuard";n9=25;c10="EAnubisWarrior";n10=25;c11="CWarElephant";n11=5;}
if(w==36){lv=20;c1="RHastatus";n1=130;c2="TMaceman";n2=105;c3="CLibyanFootman";n3=75;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=30;c8="BHighlander";n8=30;c9="EHorusWarrior";n9=25;c10="GTridentWarrior";n10=25;c11="CWarElephant";n11=5;}
if(w==37){lv=20;c1="TMaceman";n1=129;c2="RHastatus";n2=110;c3="GAxeman";n3=80;c4="ISlinger";n4=35;c5="CJavelinThrower";n5=25;c6="GHorseman";n6=20;c7="RPraetorian";n7=30;c8="TValkyrie";n8=30;c9="IEliteGuard";n9=25;c10="EAnubisWarrior";n10=25;c11="CWarElephant";n11=6;}
if(w==38){lv=20;c1="CLibyanFootman";n1=134;c2="TMaceman";n2=110;c3="RHastatus";n3=80;c4="EGuardian";n4=35;c5="RArcher";n5=25;c6="CNumidianRider";n6=20;c7="CNoble";n7=30;c8="BHighlander";n8=30;c9="EHorusWarrior";n9=30;c10="GTridentWarrior";n10=25;c11="CWarElephant";n11=6;}
if(w==39){lv=20;c1="TMaceman";n1=143;c2="RHastatus";n2=115;c3="GAxeman";n3=85;c4="ISlinger";n4=40;c5="CJavelinThrower";n5=30;c6="GHorseman";n6=20;c7="RPraetorian";n7=30;c8="TValkyrie";n8=30;c9="IEliteGuard";n9=25;c10="EAnubisWarrior";n10=25;c11="CWarElephant";n11=7;}
if(w==40){lv=20;c1="TMaceman";n1=112;c2="RHastatus";n2=90;c3="GAxeman";n3=60;c4="CLibyanFootman";n4=45;c5="ISlinger";n5=35;c6="CJavelinThrower";n6=30;c7="GHorseman";n7=20;c8="CNumidianRider";n8=20;c9="RPraetorian";n9=40;c10="TValkyrie";n10=40;c11="IEliteGuard";n11=40;c12="EAnubisWarrior";n12=35;c13="CWarElephant";n13=8;}

        idx=0;

        for(t=1;t<=13;t+=1)
        {
            cls="";n=0;
        if(t==1){cls=c1;n=n1;}
        if(t==2){cls=c2;n=n2;}
        if(t==3){cls=c3;n=n3;}
        if(t==4){cls=c4;n=n4;}
        if(t==5){cls=c5;n=n5;}
        if(t==6){cls=c6;n=n6;}
        if(t==7){cls=c7;n=n7;}
        if(t==8){cls=c8;n=n8;}
        if(t==9){cls=c9;n=n9;}
        if(t==10){cls=c10;n=n10;}
        if(t==11){cls=c11;n=n11;}
        if(t==12){cls=c12;n=n12;}
        if(t==13){cls=c13;n=n13;}

            if(n<=0)
                continue;

            for(i=0;i<n;i+=1)
            {
                u=Place(
                    cls,
                    Point(
                        p.x+(idx%20)*SP-10*SP,
                        p.y+(idx/20)*SP-6*SP
                    ),
                    HP
                ).AsUnit();

                u.SetLevel(lv);
                u.SetFeeding(false);
                u.SetNoAIFlag(true);
                u.AddToGroup("HW_H"+S);

                idx+=1;
            }
        }

        EnvWriteInt(state,"HW_ACTIVE"+S,1);
        EnvWriteInt(state,"HW_ROUND"+S,w);
        EnvWriteInt(state,"HW_TX"+S,0);
        EnvWriteInt(state,"HW_TY"+S,0);
        EnvWriteInt(state,"HW_OWNER"+S,0);
        EnvWriteInt(state,"HW_REWARDED"+S,0);
    }

    nextWave+=WAVE_INTERVAL;

    warn30=0;
    warn3=0;
    warn2=0;
    warn1=0;
}
