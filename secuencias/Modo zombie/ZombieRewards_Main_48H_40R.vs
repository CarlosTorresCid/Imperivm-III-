// ZombieRewards_Main_48H_40R - Autorun
// Consume ZR_PENDING1..48 y entrega la recompensa fija de la ronda.
//
// CORREGIDO respecto a la version guardada en Carlos_GerraTotal2.BFHP (seq7.vs):
// el bucle original leia EnvReadInt(state,"ZR_PENDING"+H) con clave dinamica (string+int),
// el mismo patron que ya se sabe que produce "No matching function with name EnvReadInt"
// (ver ZOMBIE_MODE_RUNTIME_FAILURE_DIAGNOSIS.md seccion 3). Aqui se desenrolla el indice H
// a mano, exactamente como ya hacen ZombieTactical_Main y ZombieWaves_Main con sus propias
// lecturas de EnvReadInt (patron ya validado, EnvWriteInt con clave dinamica SI parece
// funcionar y no se ha tocado).
//
// Nuevo diseño:
 // - 40 hordas.
 // - recompensa pequeña en rondas normales.
 // - recompensa especial cada 5 rondas.
 // - héroes sólo en R20, R30 y R40.

ObjList stateList;ObjList forums;
Building state;Building forum;Building cand;
Unit u;
point pos;
str c1;str c2;str c3;str c4;str c5;str c6;str c7;str c8;str c9;str c10;str cls;
int n1;int n2;int n3;int n4;int n5;int n6;int n7;int n8;int n9;int n10;
int H;int owner;int roundNow;int x;int y;int lv;int t;int n;int i;int rp;int k;int foundForum;int pp;
int pending;

stateList=Group("CapitalForum_P1").GetObjList();stateList.ClearDead();
if(stateList.count!=1)
{
    UserNotification("ZombieRewards_Main: FALLO - grupo CapitalForum_P1 no resuelve a 1 objeto","",Point(0,0),1);
    while(1)Sleep(60000);
}
state=stateList[0].AsBuilding();

while(1){
Sleep(250);

for(H=1;H<=48;H+=1){

pending=0;
if(H==1)pending=EnvReadInt(state,"ZR_PENDING1");
if(H==2)pending=EnvReadInt(state,"ZR_PENDING2");
if(H==3)pending=EnvReadInt(state,"ZR_PENDING3");
if(H==4)pending=EnvReadInt(state,"ZR_PENDING4");
if(H==5)pending=EnvReadInt(state,"ZR_PENDING5");
if(H==6)pending=EnvReadInt(state,"ZR_PENDING6");
if(H==7)pending=EnvReadInt(state,"ZR_PENDING7");
if(H==8)pending=EnvReadInt(state,"ZR_PENDING8");
if(H==9)pending=EnvReadInt(state,"ZR_PENDING9");
if(H==10)pending=EnvReadInt(state,"ZR_PENDING10");
if(H==11)pending=EnvReadInt(state,"ZR_PENDING11");
if(H==12)pending=EnvReadInt(state,"ZR_PENDING12");
if(H==13)pending=EnvReadInt(state,"ZR_PENDING13");
if(H==14)pending=EnvReadInt(state,"ZR_PENDING14");
if(H==15)pending=EnvReadInt(state,"ZR_PENDING15");
if(H==16)pending=EnvReadInt(state,"ZR_PENDING16");
if(H==17)pending=EnvReadInt(state,"ZR_PENDING17");
if(H==18)pending=EnvReadInt(state,"ZR_PENDING18");
if(H==19)pending=EnvReadInt(state,"ZR_PENDING19");
if(H==20)pending=EnvReadInt(state,"ZR_PENDING20");
if(H==21)pending=EnvReadInt(state,"ZR_PENDING21");
if(H==22)pending=EnvReadInt(state,"ZR_PENDING22");
if(H==23)pending=EnvReadInt(state,"ZR_PENDING23");
if(H==24)pending=EnvReadInt(state,"ZR_PENDING24");
if(H==25)pending=EnvReadInt(state,"ZR_PENDING25");
if(H==26)pending=EnvReadInt(state,"ZR_PENDING26");
if(H==27)pending=EnvReadInt(state,"ZR_PENDING27");
if(H==28)pending=EnvReadInt(state,"ZR_PENDING28");
if(H==29)pending=EnvReadInt(state,"ZR_PENDING29");
if(H==30)pending=EnvReadInt(state,"ZR_PENDING30");
if(H==31)pending=EnvReadInt(state,"ZR_PENDING31");
if(H==32)pending=EnvReadInt(state,"ZR_PENDING32");
if(H==33)pending=EnvReadInt(state,"ZR_PENDING33");
if(H==34)pending=EnvReadInt(state,"ZR_PENDING34");
if(H==35)pending=EnvReadInt(state,"ZR_PENDING35");
if(H==36)pending=EnvReadInt(state,"ZR_PENDING36");
if(H==37)pending=EnvReadInt(state,"ZR_PENDING37");
if(H==38)pending=EnvReadInt(state,"ZR_PENDING38");
if(H==39)pending=EnvReadInt(state,"ZR_PENDING39");
if(H==40)pending=EnvReadInt(state,"ZR_PENDING40");
if(H==41)pending=EnvReadInt(state,"ZR_PENDING41");
if(H==42)pending=EnvReadInt(state,"ZR_PENDING42");
if(H==43)pending=EnvReadInt(state,"ZR_PENDING43");
if(H==44)pending=EnvReadInt(state,"ZR_PENDING44");
if(H==45)pending=EnvReadInt(state,"ZR_PENDING45");
if(H==46)pending=EnvReadInt(state,"ZR_PENDING46");
if(H==47)pending=EnvReadInt(state,"ZR_PENDING47");
if(H==48)pending=EnvReadInt(state,"ZR_PENDING48");

if(pending!=1)continue;

if(H==1){EnvWriteInt(state,"ZR_PENDING1",0);owner=EnvReadInt(state,"ZR_OWNER1");roundNow=EnvReadInt(state,"ZR_ROUND1");x=EnvReadInt(state,"ZR_X1");y=EnvReadInt(state,"ZR_Y1");}
if(H==2){EnvWriteInt(state,"ZR_PENDING2",0);owner=EnvReadInt(state,"ZR_OWNER2");roundNow=EnvReadInt(state,"ZR_ROUND2");x=EnvReadInt(state,"ZR_X2");y=EnvReadInt(state,"ZR_Y2");}
if(H==3){EnvWriteInt(state,"ZR_PENDING3",0);owner=EnvReadInt(state,"ZR_OWNER3");roundNow=EnvReadInt(state,"ZR_ROUND3");x=EnvReadInt(state,"ZR_X3");y=EnvReadInt(state,"ZR_Y3");}
if(H==4){EnvWriteInt(state,"ZR_PENDING4",0);owner=EnvReadInt(state,"ZR_OWNER4");roundNow=EnvReadInt(state,"ZR_ROUND4");x=EnvReadInt(state,"ZR_X4");y=EnvReadInt(state,"ZR_Y4");}
if(H==5){EnvWriteInt(state,"ZR_PENDING5",0);owner=EnvReadInt(state,"ZR_OWNER5");roundNow=EnvReadInt(state,"ZR_ROUND5");x=EnvReadInt(state,"ZR_X5");y=EnvReadInt(state,"ZR_Y5");}
if(H==6){EnvWriteInt(state,"ZR_PENDING6",0);owner=EnvReadInt(state,"ZR_OWNER6");roundNow=EnvReadInt(state,"ZR_ROUND6");x=EnvReadInt(state,"ZR_X6");y=EnvReadInt(state,"ZR_Y6");}
if(H==7){EnvWriteInt(state,"ZR_PENDING7",0);owner=EnvReadInt(state,"ZR_OWNER7");roundNow=EnvReadInt(state,"ZR_ROUND7");x=EnvReadInt(state,"ZR_X7");y=EnvReadInt(state,"ZR_Y7");}
if(H==8){EnvWriteInt(state,"ZR_PENDING8",0);owner=EnvReadInt(state,"ZR_OWNER8");roundNow=EnvReadInt(state,"ZR_ROUND8");x=EnvReadInt(state,"ZR_X8");y=EnvReadInt(state,"ZR_Y8");}
if(H==9){EnvWriteInt(state,"ZR_PENDING9",0);owner=EnvReadInt(state,"ZR_OWNER9");roundNow=EnvReadInt(state,"ZR_ROUND9");x=EnvReadInt(state,"ZR_X9");y=EnvReadInt(state,"ZR_Y9");}
if(H==10){EnvWriteInt(state,"ZR_PENDING10",0);owner=EnvReadInt(state,"ZR_OWNER10");roundNow=EnvReadInt(state,"ZR_ROUND10");x=EnvReadInt(state,"ZR_X10");y=EnvReadInt(state,"ZR_Y10");}
if(H==11){EnvWriteInt(state,"ZR_PENDING11",0);owner=EnvReadInt(state,"ZR_OWNER11");roundNow=EnvReadInt(state,"ZR_ROUND11");x=EnvReadInt(state,"ZR_X11");y=EnvReadInt(state,"ZR_Y11");}
if(H==12){EnvWriteInt(state,"ZR_PENDING12",0);owner=EnvReadInt(state,"ZR_OWNER12");roundNow=EnvReadInt(state,"ZR_ROUND12");x=EnvReadInt(state,"ZR_X12");y=EnvReadInt(state,"ZR_Y12");}
if(H==13){EnvWriteInt(state,"ZR_PENDING13",0);owner=EnvReadInt(state,"ZR_OWNER13");roundNow=EnvReadInt(state,"ZR_ROUND13");x=EnvReadInt(state,"ZR_X13");y=EnvReadInt(state,"ZR_Y13");}
if(H==14){EnvWriteInt(state,"ZR_PENDING14",0);owner=EnvReadInt(state,"ZR_OWNER14");roundNow=EnvReadInt(state,"ZR_ROUND14");x=EnvReadInt(state,"ZR_X14");y=EnvReadInt(state,"ZR_Y14");}
if(H==15){EnvWriteInt(state,"ZR_PENDING15",0);owner=EnvReadInt(state,"ZR_OWNER15");roundNow=EnvReadInt(state,"ZR_ROUND15");x=EnvReadInt(state,"ZR_X15");y=EnvReadInt(state,"ZR_Y15");}
if(H==16){EnvWriteInt(state,"ZR_PENDING16",0);owner=EnvReadInt(state,"ZR_OWNER16");roundNow=EnvReadInt(state,"ZR_ROUND16");x=EnvReadInt(state,"ZR_X16");y=EnvReadInt(state,"ZR_Y16");}
if(H==17){EnvWriteInt(state,"ZR_PENDING17",0);owner=EnvReadInt(state,"ZR_OWNER17");roundNow=EnvReadInt(state,"ZR_ROUND17");x=EnvReadInt(state,"ZR_X17");y=EnvReadInt(state,"ZR_Y17");}
if(H==18){EnvWriteInt(state,"ZR_PENDING18",0);owner=EnvReadInt(state,"ZR_OWNER18");roundNow=EnvReadInt(state,"ZR_ROUND18");x=EnvReadInt(state,"ZR_X18");y=EnvReadInt(state,"ZR_Y18");}
if(H==19){EnvWriteInt(state,"ZR_PENDING19",0);owner=EnvReadInt(state,"ZR_OWNER19");roundNow=EnvReadInt(state,"ZR_ROUND19");x=EnvReadInt(state,"ZR_X19");y=EnvReadInt(state,"ZR_Y19");}
if(H==20){EnvWriteInt(state,"ZR_PENDING20",0);owner=EnvReadInt(state,"ZR_OWNER20");roundNow=EnvReadInt(state,"ZR_ROUND20");x=EnvReadInt(state,"ZR_X20");y=EnvReadInt(state,"ZR_Y20");}
if(H==21){EnvWriteInt(state,"ZR_PENDING21",0);owner=EnvReadInt(state,"ZR_OWNER21");roundNow=EnvReadInt(state,"ZR_ROUND21");x=EnvReadInt(state,"ZR_X21");y=EnvReadInt(state,"ZR_Y21");}
if(H==22){EnvWriteInt(state,"ZR_PENDING22",0);owner=EnvReadInt(state,"ZR_OWNER22");roundNow=EnvReadInt(state,"ZR_ROUND22");x=EnvReadInt(state,"ZR_X22");y=EnvReadInt(state,"ZR_Y22");}
if(H==23){EnvWriteInt(state,"ZR_PENDING23",0);owner=EnvReadInt(state,"ZR_OWNER23");roundNow=EnvReadInt(state,"ZR_ROUND23");x=EnvReadInt(state,"ZR_X23");y=EnvReadInt(state,"ZR_Y23");}
if(H==24){EnvWriteInt(state,"ZR_PENDING24",0);owner=EnvReadInt(state,"ZR_OWNER24");roundNow=EnvReadInt(state,"ZR_ROUND24");x=EnvReadInt(state,"ZR_X24");y=EnvReadInt(state,"ZR_Y24");}
if(H==25){EnvWriteInt(state,"ZR_PENDING25",0);owner=EnvReadInt(state,"ZR_OWNER25");roundNow=EnvReadInt(state,"ZR_ROUND25");x=EnvReadInt(state,"ZR_X25");y=EnvReadInt(state,"ZR_Y25");}
if(H==26){EnvWriteInt(state,"ZR_PENDING26",0);owner=EnvReadInt(state,"ZR_OWNER26");roundNow=EnvReadInt(state,"ZR_ROUND26");x=EnvReadInt(state,"ZR_X26");y=EnvReadInt(state,"ZR_Y26");}
if(H==27){EnvWriteInt(state,"ZR_PENDING27",0);owner=EnvReadInt(state,"ZR_OWNER27");roundNow=EnvReadInt(state,"ZR_ROUND27");x=EnvReadInt(state,"ZR_X27");y=EnvReadInt(state,"ZR_Y27");}
if(H==28){EnvWriteInt(state,"ZR_PENDING28",0);owner=EnvReadInt(state,"ZR_OWNER28");roundNow=EnvReadInt(state,"ZR_ROUND28");x=EnvReadInt(state,"ZR_X28");y=EnvReadInt(state,"ZR_Y28");}
if(H==29){EnvWriteInt(state,"ZR_PENDING29",0);owner=EnvReadInt(state,"ZR_OWNER29");roundNow=EnvReadInt(state,"ZR_ROUND29");x=EnvReadInt(state,"ZR_X29");y=EnvReadInt(state,"ZR_Y29");}
if(H==30){EnvWriteInt(state,"ZR_PENDING30",0);owner=EnvReadInt(state,"ZR_OWNER30");roundNow=EnvReadInt(state,"ZR_ROUND30");x=EnvReadInt(state,"ZR_X30");y=EnvReadInt(state,"ZR_Y30");}
if(H==31){EnvWriteInt(state,"ZR_PENDING31",0);owner=EnvReadInt(state,"ZR_OWNER31");roundNow=EnvReadInt(state,"ZR_ROUND31");x=EnvReadInt(state,"ZR_X31");y=EnvReadInt(state,"ZR_Y31");}
if(H==32){EnvWriteInt(state,"ZR_PENDING32",0);owner=EnvReadInt(state,"ZR_OWNER32");roundNow=EnvReadInt(state,"ZR_ROUND32");x=EnvReadInt(state,"ZR_X32");y=EnvReadInt(state,"ZR_Y32");}
if(H==33){EnvWriteInt(state,"ZR_PENDING33",0);owner=EnvReadInt(state,"ZR_OWNER33");roundNow=EnvReadInt(state,"ZR_ROUND33");x=EnvReadInt(state,"ZR_X33");y=EnvReadInt(state,"ZR_Y33");}
if(H==34){EnvWriteInt(state,"ZR_PENDING34",0);owner=EnvReadInt(state,"ZR_OWNER34");roundNow=EnvReadInt(state,"ZR_ROUND34");x=EnvReadInt(state,"ZR_X34");y=EnvReadInt(state,"ZR_Y34");}
if(H==35){EnvWriteInt(state,"ZR_PENDING35",0);owner=EnvReadInt(state,"ZR_OWNER35");roundNow=EnvReadInt(state,"ZR_ROUND35");x=EnvReadInt(state,"ZR_X35");y=EnvReadInt(state,"ZR_Y35");}
if(H==36){EnvWriteInt(state,"ZR_PENDING36",0);owner=EnvReadInt(state,"ZR_OWNER36");roundNow=EnvReadInt(state,"ZR_ROUND36");x=EnvReadInt(state,"ZR_X36");y=EnvReadInt(state,"ZR_Y36");}
if(H==37){EnvWriteInt(state,"ZR_PENDING37",0);owner=EnvReadInt(state,"ZR_OWNER37");roundNow=EnvReadInt(state,"ZR_ROUND37");x=EnvReadInt(state,"ZR_X37");y=EnvReadInt(state,"ZR_Y37");}
if(H==38){EnvWriteInt(state,"ZR_PENDING38",0);owner=EnvReadInt(state,"ZR_OWNER38");roundNow=EnvReadInt(state,"ZR_ROUND38");x=EnvReadInt(state,"ZR_X38");y=EnvReadInt(state,"ZR_Y38");}
if(H==39){EnvWriteInt(state,"ZR_PENDING39",0);owner=EnvReadInt(state,"ZR_OWNER39");roundNow=EnvReadInt(state,"ZR_ROUND39");x=EnvReadInt(state,"ZR_X39");y=EnvReadInt(state,"ZR_Y39");}
if(H==40){EnvWriteInt(state,"ZR_PENDING40",0);owner=EnvReadInt(state,"ZR_OWNER40");roundNow=EnvReadInt(state,"ZR_ROUND40");x=EnvReadInt(state,"ZR_X40");y=EnvReadInt(state,"ZR_Y40");}
if(H==41){EnvWriteInt(state,"ZR_PENDING41",0);owner=EnvReadInt(state,"ZR_OWNER41");roundNow=EnvReadInt(state,"ZR_ROUND41");x=EnvReadInt(state,"ZR_X41");y=EnvReadInt(state,"ZR_Y41");}
if(H==42){EnvWriteInt(state,"ZR_PENDING42",0);owner=EnvReadInt(state,"ZR_OWNER42");roundNow=EnvReadInt(state,"ZR_ROUND42");x=EnvReadInt(state,"ZR_X42");y=EnvReadInt(state,"ZR_Y42");}
if(H==43){EnvWriteInt(state,"ZR_PENDING43",0);owner=EnvReadInt(state,"ZR_OWNER43");roundNow=EnvReadInt(state,"ZR_ROUND43");x=EnvReadInt(state,"ZR_X43");y=EnvReadInt(state,"ZR_Y43");}
if(H==44){EnvWriteInt(state,"ZR_PENDING44",0);owner=EnvReadInt(state,"ZR_OWNER44");roundNow=EnvReadInt(state,"ZR_ROUND44");x=EnvReadInt(state,"ZR_X44");y=EnvReadInt(state,"ZR_Y44");}
if(H==45){EnvWriteInt(state,"ZR_PENDING45",0);owner=EnvReadInt(state,"ZR_OWNER45");roundNow=EnvReadInt(state,"ZR_ROUND45");x=EnvReadInt(state,"ZR_X45");y=EnvReadInt(state,"ZR_Y45");}
if(H==46){EnvWriteInt(state,"ZR_PENDING46",0);owner=EnvReadInt(state,"ZR_OWNER46");roundNow=EnvReadInt(state,"ZR_ROUND46");x=EnvReadInt(state,"ZR_X46");y=EnvReadInt(state,"ZR_Y46");}
if(H==47){EnvWriteInt(state,"ZR_PENDING47",0);owner=EnvReadInt(state,"ZR_OWNER47");roundNow=EnvReadInt(state,"ZR_ROUND47");x=EnvReadInt(state,"ZR_X47");y=EnvReadInt(state,"ZR_Y47");}
if(H==48){EnvWriteInt(state,"ZR_PENDING48",0);owner=EnvReadInt(state,"ZR_OWNER48");roundNow=EnvReadInt(state,"ZR_ROUND48");x=EnvReadInt(state,"ZR_X48");y=EnvReadInt(state,"ZR_Y48");}

if(owner<1||owner>8||roundNow<1||roundNow>40)continue;

c1="";c2="";c3="";c4="";c5="";c6="";c7="";c8="";c9="";c10="";
n1=0;n2=0;n3=0;n4=0;n5=0;n6=0;n7=0;n8=0;n9=0;n10=0;lv=1;

if(roundNow==1){lv=4;c1="RPraetorian";n1=3;c2="BHighlander";n2=3;}
if(roundNow==2){lv=4;c1="IEliteGuard";n1=3;c2="CNoble";n2=3;}
if(roundNow==3){lv=5;c1="RLiberatus";n1=3;c2="EAnubisWarrior";n2=3;}
if(roundNow==4){lv=5;c1="TValkyrie";n1=3;c2="GTridentWarrior";n2=3;}
if(roundNow==5){lv=6;c1="RPraetorian";n1=5;c2="IEliteGuard";n2=5;c3="BHighlander";n3=5;}
if(roundNow==6){lv=6;c1="CNoble";n1=4;c2="EAnubisWarrior";n2=4;}
if(roundNow==7){lv=7;c1="RLiberatus";n1=4;c2="TValkyrie";n2=4;}
if(roundNow==8){lv=7;c1="GTridentWarrior";n1=4;c2="BHighlander";n2=4;}
if(roundNow==9){lv=8;c1="EHorusWarrior";n1=4;c2="IEliteGuard";n2=4;}
if(roundNow==10){lv=8;c1="RPraetorian";n1=5;c2="RLiberatus";n2=5;c3="TValkyrie";n3=5;c4="CWarElephant";n4=2;}
if(roundNow==11){lv=9;c1="CNoble";n1=5;c2="EAnubisWarrior";n2=5;}
if(roundNow==12){lv=9;c1="BHighlander";n1=5;c2="GTridentWarrior";n2=5;}
if(roundNow==13){lv=10;c1="IEliteGuard";n1=5;c2="EHorusWarrior";n2=5;}
if(roundNow==14){lv=10;c1="RLiberatus";n1=5;c2="RPraetorian";n2=5;}
if(roundNow==15){lv=11;c1="BHighlander";n1=5;c2="EAnubisWarrior";n2=5;c3="CNoble";n3=5;c4="IEliteGuard";n4=5;c5="CWarElephant";n5=2;}
if(roundNow==16){lv=11;c1="TValkyrie";n1=6;c2="GTridentWarrior";n2=6;}
if(roundNow==17){lv=12;c1="RLiberatus";n1=6;c2="EHorusWarrior";n2=6;}
if(roundNow==18){lv=12;c1="RPraetorian";n1=6;c2="CNoble";n2=6;}
if(roundNow==19){lv=13;c1="IEliteGuard";n1=6;c2="EAnubisWarrior";n2=6;}
if(roundNow==20){lv=13;c1="RLiberatus";n1=5;c2="TValkyrie";n2=5;c3="GTridentWarrior";n3=5;c4="BHighlander";n4=5;c5="CWarElephant";n5=3;c6="BHero1";n6=1;}
if(roundNow==21){lv=14;c1="EHorusWarrior";n1=7;c2="CNoble";n2=7;}
if(roundNow==22){lv=14;c1="RPraetorian";n1=7;c2="IEliteGuard";n2=7;}
if(roundNow==23){lv=15;c1="RLiberatus";n1=7;c2="EAnubisWarrior";n2=7;}
if(roundNow==24){lv=15;c1="TValkyrie";n1=7;c2="GTridentWarrior";n2=7;}
if(roundNow==25){lv=16;c1="RLiberatus";n1=6;c2="TValkyrie";n2=6;c3="BHighlander";n3=6;c4="IEliteGuard";n4=6;c5="CWarElephant";n5=4;}
if(roundNow==26){lv=16;c1="CNoble";n1=8;c2="EHorusWarrior";n2=8;}
if(roundNow==27){lv=17;c1="RPraetorian";n1=8;c2="GTridentWarrior";n2=8;}
if(roundNow==28){lv=17;c1="EAnubisWarrior";n1=8;c2="BHighlander";n2=8;}
if(roundNow==29){lv=18;c1="RLiberatus";n1=8;c2="TValkyrie";n2=8;}
if(roundNow==30){lv=18;c1="RLiberatus";n1=6;c2="TValkyrie";n2=6;c3="GTridentWarrior";n3=6;c4="IEliteGuard";n4=6;c5="EHorusWarrior";n5=6;c6="CWarElephant";n6=5;c7="CHero1";n7=1;}
if(roundNow==31){lv=19;c1="IEliteGuard";n1=9;c2="CNoble";n2=9;}
if(roundNow==32){lv=19;c1="BHighlander";n1=9;c2="EHorusWarrior";n2=9;}
if(roundNow==33){lv=20;c1="RPraetorian";n1=9;c2="EAnubisWarrior";n2=9;}
if(roundNow==34){lv=20;c1="RLiberatus";n1=9;c2="GTridentWarrior";n2=9;}
if(roundNow==35){lv=20;c1="RLiberatus";n1=8;c2="TValkyrie";n2=8;c3="IEliteGuard";n3=8;c4="EHorusWarrior";n4=8;c5="CWarElephant";n5=5;}
if(roundNow==36){lv=21;c1="CNoble";n1=10;c2="BHighlander";n2=10;}
if(roundNow==37){lv=21;c1="RPraetorian";n1=10;c2="EAnubisWarrior";n2=10;}
if(roundNow==38){lv=22;c1="RLiberatus";n1=10;c2="TValkyrie";n2=10;}
if(roundNow==39){lv=22;c1="GTridentWarrior";n1=10;c2="IEliteGuard";n2=10;}
if(roundNow==40){lv=22;c1="RLiberatus";n1=7;c2="TValkyrie";n2=7;c3="GTridentWarrior";n3=7;c4="BHighlander";n4=7;c5="IEliteGuard";n5=7;c6="EHorusWarrior";n6=7;c7="EAnubisWarrior";n7=7;c8="CWarElephant";n8=6;c9="MHero1";n9=1;c10="THero1";n10=1;}

foundForum=0;forums.Clear();forums=ClassPlayerObjs("BaseTownhall",owner).GetObjList();forums.ClearDead();
for(i=0;i<forums.count;i+=1){cand=forums[i].AsBuilding();if(cand.pos.x==x&&cand.pos.y==y){forum=cand;foundForum=1;i=forums.count;}}

rp=0;
for(t=1;t<=10;t+=1){cls="";n=0;
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
if(n<=0)continue;
for(i=0;i<n;i+=1){
if(rp<28)pos=Point(x+450+(rp%7)*110,y-330+(rp/7)*110);else{k=rp-28;pos=Point(x-1150+(k%7)*110,y-330+(k/7)*110);}
u=Place(cls,pos,owner).AsUnit();
u.SetLevel(lv);
if(foundForum==1)forum.settlement.ForceAddUnit(u);
rp+=1;
}
}

if(roundNow%5==0)
{
    for(k=1;k<=8;k+=1)UserNotification("HORDA ANIQUILADA - RECOMPENSA ESPECIAL RONDA "+roundNow+" para Player "+owner,"",Point(x,y),k);
}
else
{
    for(k=1;k<=8;k+=1)UserNotification("HORDA ANIQUILADA. Player "+owner+" recibe refuerzos de ronda "+roundNow,"",Point(x,y),k);
}

}
}
