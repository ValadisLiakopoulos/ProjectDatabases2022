DROP DATABASE IF EXISTS travel_agency;
CREATE DATABASE travel_agency;

USE travel_agency;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(branch_code INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
branch_street VARCHAR(30) NOT NULL,
branch_num INT(4) UNSIGNED NOT NULL,
branch_city VARCHAR(30) NOT NULL,
PRIMARY KEY(branch_code));

DROP TABLE IF EXISTS phones;
CREATE TABLE phones
(phones_br_code INT(11) UNSIGNED NOT NULL,
phones_number CHAR(10) NOT NULL,
PRIMARY KEY(phones_br_code,phones_number),
CONSTRAINT BRANCHPHONES 
FOREIGN KEY(phones_br_code) REFERENCES branch(branch_code)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS worker;
CREATE TABLE worker
(worker_AT CHAR(10) NOT NULL, 
worker_name VARCHAR(20) DEFAULT 'unknown' NOT NULL,
worker_lname VARCHAR(20) DEFAULT 'unknown' NOT NULL,
worker_salary FLOAT(7,2) UNSIGNED NOT NULL, 
worker_br_code INT(11) UNSIGNED NOT NULL, 
PRIMARY KEY(worker_AT),
CONSTRAINT WORKERBRANCH
FOREIGN KEY(worker_br_code) REFERENCES branch(branch_code)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS admin;
CREATE TABLE admin
(admin_AT CHAR(10) NOT NULL,
admin_type ENUM('LOGISTICS','ADMINISTRATIVE','ACCOUNTING') NOT NULL,
admin_diploma VARCHAR(200) NOT NULL,
PRIMARY KEY(admin_AT),
CONSTRAINT ADMINWORKER 
FOREIGN KEY(admin_AT) REFERENCES worker(worker_AT)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS manages;
CREATE TABLE manages
(mng_adm_AT CHAR(10) NOT NULL,
mng_br_code INT(11) UNSIGNED NOT NULL,
PRIMARY KEY(mng_adm_AT,mng_br_code),
CONSTRAINT ADMINMANAGES
FOREIGN KEY(mng_adm_AT) REFERENCES admin(admin_AT),
CONSTRAINT MANAGESBRANCH
FOREIGN KEY(mng_br_code) REFERENCES branch(branch_code)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS driver;
CREATE TABLE driver
(driver_AT CHAR(10) NOT NULL,
driver_licence ENUM('A','B','C','D') NOT NULL,
driver_route ENUM('LOCAL','ABROAD') NOT NULL,
driver_experience TINYINT(4) UNSIGNED NOT NULL,
PRIMARY KEY(driver_AT),
CONSTRAINT DRIVERWORKER 
FOREIGN KEY(driver_AT) REFERENCES worker(worker_AT)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS guide;
CREATE TABLE guide
(guide_AT CHAR(10) NOT NULL,
guide_cv TEXT,
PRIMARY KEY(guide_AT),
CONSTRAINT GUIDEWORKER 
FOREIGN KEY(guide_AT) REFERENCES worker(worker_AT)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS languages;
CREATE TABLE languages
(lng_guide_AT CHAR(10) NOT NULL,
lng_language VARCHAR(30) NOT NULL,
PRIMARY KEY(lng_guide_AT,lng_language),
CONSTRAINT GUIDELNGS 
FOREIGN KEY(lng_guide_AT) REFERENCES guide(guide_AT)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS trip;
CREATE TABLE trip
(tr_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
tr_departure DATETIME NOT NULL,
tr_return DATETIME NOT NULL,
tr_maxseats TINYINT(4) UNSIGNED NOT NULL,
tr_cost FLOAT(7,2) UNSIGNED NOT NULL,
tr_br_code INT(11) UNSIGNED NOT NULL,
tr_gui_AT CHAR(10) NOT NULL,
tr_drv_AT CHAR(10) NOT NULL,
PRIMARY KEY(tr_id),
CONSTRAINT BRANCHTRIP
FOREIGN KEY(tr_br_code) REFERENCES branch(branch_code),
CONSTRAINT GUIDETRIP
FOREIGN KEY(tr_gui_AT) REFERENCES guide(guide_AT),
CONSTRAINT DRIVERTRIP
FOREIGN KEY(tr_drv_AT) REFERENCES driver(driver_AT)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS event;
CREATE TABLE event
(ev_tr_id INT(11) UNSIGNED NOT NULL,
ev_start DATETIME NOT NULL,
ev_end DATETIME NOT NULL,
ev_descr TEXT NOT NULL,
PRIMARY KEY(ev_tr_id,ev_start),
CONSTRAINT TRIPEVENT
FOREIGN KEY(ev_tr_id) REFERENCES trip(tr_id)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS reservation;
CREATE TABLE reservation
(res_tr_id INT(11) UNSIGNED NOT NULL,
res_seatnum TINYINT(4) UNSIGNED NOT NULL,
res_name VARCHAR(20) DEFAULT 'unknown' NOT NULL,
res_lname VARCHAR(20) DEFAULT 'unknown' NOT NULL,
res_isadult ENUM('ADULT','MINOR') NOT NULL,
PRIMARY KEY(res_tr_id,res_seatnum),
CONSTRAINT TRIPRESERVED
FOREIGN KEY(res_tr_id) REFERENCES trip(tr_id)
ON DELETE CASCADE ON UPDATE CASCADE);

DROP TABLE IF EXISTS destination;
CREATE TABLE destination
(dst_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
dst_name VARCHAR(50) NOT NULL,
dst_descr  TEXT NOT NULL,
dst_rtype ENUM('LOCAL','ABROAD') NOT NULL,
dst_language VARCHAR(30) NOT NULL,
dst_location INT(11) UNSIGNED,
PRIMARY KEY(dst_id));
   
   /* ADD SELF REFERENCE OF DESTINATION*/
   
ALTER TABLE destination
ADD CONSTRAINT DESTSELFREFERENCE
FOREIGN KEY(dst_location) REFERENCES destination(dst_id);

DROP TABLE IF EXISTS travel_to;
CREATE TABLE travel_to
(to_tr_id INT(11) UNSIGNED NOT NULL,
to_dst_id INT(11) UNSIGNED NOT NULL,
to_arrival DATETIME NOT NULL,
to_departure DATETIME NOT NULL,
PRIMARY KEY(to_tr_id),
CONSTRAINT TRIPTRAVELTO
FOREIGN KEY(to_tr_id) REFERENCES trip(tr_id),
CONSTRAINT TRAVELTODESTINATION
FOREIGN KEY(to_dst_id) REFERENCES destination(dst_id)
ON DELETE CASCADE ON UPDATE CASCADE);

/* 3.1.2.1 IT supervisor TABLE */

DROP TABLE IF EXISTS it_supervisor;
CREATE TABLE it_supervisor
(IT_AT CHAR(10) NOT NULL,
 IT_password CHAR(10) DEFAULT 'password' NOT NULL,
 IT_start_date DATE NOT NULL,
 IT_end_date DATE,
 PRIMARY KEY(IT_AT),
 CONSTRAINT ITWORKING
 FOREIGN KEY(IT_AT) REFERENCES worker(worker_AT)
 ON DELETE CASCADE ON UPDATE CASCADE);

/* 3.1.2.2 IT log table */

DROP TABLE IF EXISTS log;
CREATE TABLE log
(log_datetime DATETIME NOT NULL,
 log_action ENUM('INSERT','UPDATE','DELETE') NOT NULL,
 log_table ENUM('trip','reservation','event','travel_to','destination'),
 log_userid VARCHAR(10) NOT NULL,
 PRIMARY KEY(log_datetime,log_userid));

/* OFFERS TABLES */
DROP TABLE IF EXISTS offers;
CREATE TABLE offers
(offer_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
 offer_start DATE NOT NULL,
 offer_end DATE NOT NULL,
 offer_cost FLOAT(7,2) NOT NULL,
 offer_dst INT(11) UNSIGNED NOT NULL,
 PRIMARY KEY(offer_id),
 CONSTRAINT DESTINATIONOFFER
 FOREIGN KEY(offer_dst) REFERENCES destination(dst_id));

DROP TABLE IF EXISTS reservation_offers;
CREATE TABLE reservation_offers
(res_off_id INT(10) UNSIGNED NOT NULL,
 res_off_name VARCHAR(50),
 res_off_lname VARCHAR(50),
 res_off_off_id INT(10)UNSIGNED NOT NULL,
 res_off_payminadv INT(10) NOT NULL,
 PRIMARY KEY(res_off_id),
 CONSTRAINT reservationtooffer
 FOREIGN KEY(res_off_off_id) REFERENCES offers(offer_id));



/* INSERTIONS INTO THE REQUESTED TABLES */

/* BRANCH INSERTIONS */

INSERT INTO branch(branch_street,branch_num,branch_city) VALUES
("KWSTH PALAMA",30,"AGIOI THEODOROI"), #1
("KASTORIAS",35,"ATHINA"), #2
("LEWFOROS KIFHSOY",97,"ATHINA"), #3
("MONEMVASIAS",36,"ATHINA"), #4
("PRAKSIOY",10,"ATHINA"), #5
("PAGASWN",99,"VOLOS"), #6
("AGOURIDOU",3,"ITEA"), #7
("FARWN",128,"KALAMATA"), #8
("ETHNIKIS ANTISTASEWS",38,"KORINTHOS"), #9
("ATHANASIADH NOVA",90,"NAUPAKTOS"), #10
("AKRWTHRIOY",120,"PATRA"), #11
("PANEPISTIMIOY",200,"PATRA"), #12
("RHGA FERAIOY",35,"PATRA"), #13
("DELHGIWRGH",25,"PEIRAIAS"), #14
("YMHTTOY",88,"PEIRAIAS"), #15
("TSIMISKI",90,"THESSALONIKH"), #16
("LEWFOROS NIKHS",130,"THESSALONIKH"), #17
("ARISTOTELOYS",200,"THESSALONIKH"), #18
("VRASIDOU",32,"SPARTH"), #19
("SALAMINOS",10,"XALKIDA"); #20


/* INSERTIONS INTO PHONES */

INSERT INTO phones VALUES
(1,"2104350697"),
(2,"2119570000"),
(3,"2108899318"),
(4,"2421033567"),
(5,"2265010020"),
(6,"2721055790"),
(7,"2741033051"),
(8,"2634000910"),
(9,"2610993122"),
(10,"2610990077"),
(11,"2610230080"),
(12,"2108090078"),
(13,"2104545633"),
(14,"2310708000"),
(15,"2310334477"),
(16,"2310324856"),
(17,"2731060700"),
(18,"2221099310"),
(19,"2821067059"),
(20,"2271070500");

/* INSERTIONS IN WORKER */

/* WORKERS OF BRANCH 1*/

INSERT INTO worker VALUES
("AB102210","GEWRGIOS","HLIOPOULOS",800,1), /* driver */
("AN272428","HLIANNA","GEWRGAKOPOYLOY",800,1), /* driver */
("AI212134","IWANNIS","ANASTASIOU",1500,1), /* admin */
("AH987765","PANAGIWTHS","TSAROUXIS",1100,1), /* guide */
("AN108809","VALADIS","LIAKOPOYLOS",1300.50,1), /* IT */
/* WORKERS OF BRANCH 2 */

("AI584736","VASILIKI","MAXA",1500,2), /*ADMIN*/
("AK101314","AGGELOS","KOYMANIWTHS",800,2), /*DRIVER */
("AH171822","ANTREAS","NTOFIS",800,2), /* DRIVER */
("AM232341","GEWRGIOS","SARIDAKIS",1100,2), /* GUIDE */

/* WORKERS OF BRANCH 3 */


("AY756512","PANAGIWTA","VELISSARH",800,3), /* DRIVER */
("P918213","IWANNIS","KYRIAKOPOYLOS",800,3), /* DRIVER */
("AB121314","XRHSTOS","ANDRIKOPOULOS",1600,3), /* ADMIN */
("AX676865","MARIA","NIASTH",1130,3), /* GUIDE */

/* WORKERS OF BRANCH 4 */ 

("AX908878","XRISTINA","KONTOGEWRGOU",870.35,4),    /* DRIVER */
("ΑΔ120099","PARASKEYH","LINARDOY",835.60,4),       /*DRIVER*/
("AN272481","PERIKLIS","PAPADOPOYLOS",1120.80,4),   /*GUIDE*/
("AI991111","VASILEIOS","DHMHTROPOYLOS",1832.42,4), /*ADMIN*/
("AH321100","XRYSANTHOS","VASILEIOU",1900.33,4),

/* WORKERS OF BRANCH 5 */

("ΑΛ886578","ANASTASIOS","PAPADHMHTRIOY",930.21,5), /*DRIVER*/
("AY108760","DESPOINA","OIKONOMOY",876,5), /*DRIVER*/
("AI867544","GEWRGIOS","PATRINOS",1050.23,5), /*GUIDE*/
("AO125677","DHMHTRIOS","PAPAXRHSTOY",1543.88,5),/*ADMIN*/

/* WORKERS OF BRANCH 6 */

("AN990122","DIONYSIOS","THEODWROPOYLOS",870,6), /*DRIVER*/
("AI543473","AGGELIKH","VASILEIADOY",1140.87,6), /*GUIDE*/
("AM456097","XRISTINA","KATRITZOGLOY",830,6),/*DRIVER*/
("Π314121","XRHSTOS","PERROS",1670,6),/*ADMIN*/
("AM113499","IOYLIA","PALAIOLOGOY",1765.56,6),

/* WORKERS OF BRANCH 7 */ 

("AK465732","KWNSTANTINOS","XRHSTAKHS",854.90,7), /*DRIVER*/
("AB758699","TRYFWN","DELOGLOY",890,7), /*DRIVER*/
("AH654535","HLIAS","PAPADOPOYLOS",1700.32,7),/*ADMIN*/
("AY121365","ANTONIA","THRYPSIALLH",1070.90,7), /*GUIDE*/

/* WORKES OF BRANCH 8 */

("AE252632","PANAGIWTHS","KOYVELAS",900.44,8), /*DRIVER*/
("AM657533","DHMHTRA","MWRAITH",910.65,8), /*DRIVER*/
("AN989766","NIKOLAOS","KANELLOPOYLOS",1900.34,8),/*ADMIN*/
("AT990233","KATERINA","PAPAIWANNOY",997.33,8), /*GUIDE*/
("AX331685","GEWRGIOS","DIAZIKHS",1102.50,8),

/*WORKERS OF BRANCH 9 */

("AI237345","ANASTASIA","PAPADOPOYLOY",2013.38,9),/*ADMIN*/
("AT673566","DHMHTRIOS","KALOGHROY",837.23,9),    /*DRIVER*/
("P939302","IWANNA","KYVELLH",1120,9),            /*GUIDE*/
("AN271815","MARIOS","KIOYTOYTSKAS",1024.47,9),   /*DRIVER*/
("AI201332","HLIAS","XRISTODOYLOS",1450,9),

/* WORKERS OF BRANCH 10 */
 
("AB905543","GEWRGIOS","DHMHTRIOY",785.76,10),  /*DRIVER*/
("AI892193","PETROS","RAFAHLIDHS",1670.66,10),  /*ADMIN*/
("AM892191","MHNAS","ASTERIWTHS",822,10),       /*DRIVER*/
("AI921012","EYAGGELIA","TOYMPESH",1034.65,10), /*GUIDE*/

/* WORKERS OF BRANCH 11 */

("AO873465","EIRHNH","TRYFWNIADOY",911,11),  /*DRIVER*/
("I912133","ANASTASIOS","LIOKAS",891.22,11),  /*DRIVER*/
("X721843","AGAPH","FOYNTAKH",1930.34,11), /*ADMIN*/
("AY734190","VASILEIOS","NIKAS",1000.30,11), /*GUIDE*/
("P084934","IWANNIS","KWNSTANTINIDHS",1430.39,11),

/* WORKERS OF BRANCH 12 */

("AO125334","APOSTOLOS","NTOLEVAS",1990,12), /*ADMIN*/   
("AB374839","IWANNIS","DELHGIWRGHS",1002.34,12),  /*GUIDE*/
("P192122","PAVLOS","XANIWTHS",800.32,12), /*DRIVER*/
("X673720","ELPIDA","XARMANI",789.39,12),  /*DRIVER*/

/* WORKERS OF BRANCH 13 */

("AP289910","GEWRGIOS","PAPASTAVROY",1880.11,13),         /*ADMIN*/
("AP198283","KWNSTANTINOS-MARIOS","IWANNOY",812.22,13),  /*DRIVER*/
("AM882391","ANTIGONH","PAPADOPOYLOY",810,13),           /*DRIVER*/
("AI910113","GEWRGIOS","MIXAHLIDHS",980,13),             /*GUIDE*/

/* WORKERS OF BRANCH 14 */

("AO384322","SWTHRIOS","GEWRGAKOPOYLOS",1900,14),  /*ADMIN*/
("AX381223","GEWRGIOS","NIKOLETSEAS",830.34,14),   /*DRIVER*/
("AI095543","MARIA","SWTHROPOYLOY",843.11,14),     /*DRIVER*/
("AH383899","ELENH","STAYRIDOY",954.87,14),        /*GUIDE*/
("AY379943","GEWRGIOS","ADAMOPOULOS",1800,14),

/* WORKERS OF BRANCH 15 */

("AI290344","KWSTANTINOS","DHMHTROPOYLOS",1600.45,15), /*ADMIN*/
("AM949312","AGGELIKH-MARIA","DENDRINOY",1020.55,15), /*GUIDE*/
("AN946755","HLIAS","PAPAGOY",884.54,15), /*DRIVER*/
("AI883019","NIKOLAOS","OIKONOMOY",877.28,15), /*DRIVER*/

/* WORKERS OF BRANCH 16 */

("AY480223","EYAGGELOS","KOYTSOMHTROPOYLOS",2030.54,16),/*ADMIN*/
("AM453743","AMALIA","KALOMOIRH",830.76,16), /*DRIVER*/
("AI903323","MARIOS","AGGELOY",900.20,16), /*DRIVER*/
("AK391875","GEWRGIOS","PAPAIWANNOY",1000.45,16), /*GUIDE*/

/* WORKERS OF BRANCH 17 */

("AH856654","GEWRGIA","KONTOGIANNH",839.67,17), /*DRIVER*/
("X848323","IWANNA","PAPADOPOYLOY",990.56,17), /*GUIDE*/
("AB493300","GEWRGIOS","MERMIGKHS",1700.65,17),/*ADMIN*/
("AO380193","ALDO","BOGDANI",815.65,17), /*DRIVER*/

/* WORKERS OF BRANCH 18 */

("AY465904","ELEYTHERIOS","MEGALOOIKONOMOY",860,18), /*DRIVER*/
("AM996506","GRHGORIOS","ELEYTHERIADHS",1800.75,18),/*ADMIN*/
("AT348890","XRYSOYLA","MANTA",990.11,18), /*GUIDE*/
("X995032","XARALAMPOS","PAPADOPOYLOS",800,18), /*DRIVER*/

/* WORKERS OF BRANCH 19 */

("AI568848","KATERINA","HLIOPOYLOY",1900.55,19),/*ADMIN*/
("AY884833","XRISTOFOROS","KAPLANIS",880,19), /*DRIVER*/
("AN884431","ORESTIOS","GEWRGIOY",830.65,19), /*DRIVER*/
("AO105629","GEWRGIOS","XRISTOPOYLOS",1100,19), /*GUIDE*/

/* WORKERS OF BRANCH 20 */

("AM347762","MIXALITSA","PAPPA",1960.87,20), /*ADMIN*/
("AT209934","KWNSTANTINOS","PAPASTAVROY",1000,20), /*GUIDE*/
("AM904431","MARIA-ELENH","KARAMHTSOY",800.65,20), /*DRIVER*/
("AI774301","IWANNIS","XATZHSTAYRIOY",810.65,20); /*DRIVER*/

/*INSERTIONS INTO ADMIN */

INSERT INTO admin VALUES
("AI212134",'ADMINISTRATIVE',"MASTER ECONOMICS ANS LOGISTICS"), #1
("AI584736",'ADMINISTRATIVE',"PHD LOGISTICS"), #2
("AB121314",'ADMINISTRATIVE',"PHD ASOEE ECONOMICS"), #3
("AI991111",'ACCOUNTING',"DEGREE IN ECONOMICS AND LOGISTICS UOP"), #4
("AO125677",'ADMINISTRATIVE',"DEGREE IN LOGISTICS AUTH"), #5
("Π314121",'ACCOUNTING',"DEGREE IN BUSINESS ADMINISTRATION"), #6
("AH654535",'ADMINISTRATIVE',"DEGREE IN INFORMATICS AND PHD IN DIGITAL ECONOMY"), #7
("AN989766",'LOGISTICS',"DEGREE IN LOGISTICS UOP"), #8
("AI237345",'ACCOUNTING',"MASTER IN ECONOMICS AND LOGISTICS UOP"), #9
("AI892193",'ADMINISTRATIVE',"ECONOMICS DEGREE"), #10
("X721843",'LOGISTICS',"PHD IN LOGISTICS"), #11
("AO125334",'ADMINISTRATIVE',"PHD IN LOGISTICS ASOEE"), #12
("AP289910",'ADMINISTRATIVE',"DEGREE IN ECONOMICS AND BUSINESS ADMINISTRATION"), #13
("AO384322",'LOGISTICS',"DEGREE IN LOGISTICS UOP"), #14
("AI290344",'ADMINISTRATIVE',"DEGREE IN ECONOMICS AND LOGISTICS"), #15
("AY480223",'ADMINISTRATIVE',"PHD IN ECONOMICS"), #16
("AB493300",'ADMINISTRATIVE',"PHD IN ECONOMICS UOP"), #17
("AM996506",'ADMINISTRATIVE',"DEGREE IN LOGISTICS"), #18
("AI568848",'ADMINISTRATIVE',"PHD IN ECONOMICS AND LOGISTICS"), #19
("AM347762",'ADMINISTRATIVE',"PHD IN LOGISTICS UOC"), #20
("AH321100",'ADMINISTRATIVE',"PHD IN ECONOMICS UOP"),#4
("AM113499",'ADMINISTRATIVE',"PHD IN LOGISTICS AND ECONOMICS"),#6
("AX331685",'ADMINISTRATIVE',"PHD IN ECONOMICS"),#8
("AI201332",'ADMINISTRATIVE',"PHD IN LOGISTICS"),#9
("P084934",'ADMINISTRATIVE',"PHD IN LOGISTICS AND ECONOMICS"),#11
("AY379943",'ADMINISTRATIVE',"PHD IN BUSINESS ADMINISTRATION");#14



INSERT INTO worker VALUES
("999999","VASILIKI","MAXA",1500,2), /*ADMIN*/
("101012","AGGELOS","KOYMANIWTHS",800,3), /*DRIVER */
("203044","ANTREAS","NTOFIS",800,4), /* DRIVER */
("232345","GEWRGIOS","SARIDAKIS",1100,5), /* GUIDE */
("856623","GEWRGIA","KONTOGIANNH",839.67,6), /*DRIVER*/
("8483233","IWANNA","PAPADOPOYLOY",990.56,7), /*GUIDE*/
("493300","GEWRGIOS","MERMIGKHS",1700.65,8),/*ADMIN*/
("380193","ALDO","BOGDANI",815.65,9), /*DRIVER*/
("347762","MIXALITSA","PAPPA",1960.87,10), /*ADMIN*/
("209934","KWNSTANTINOS","PAPASTAVROY",1000,11), /*GUIDE*/
("904431","MARIA-ELENH","KARAMHTSOY",800.65,12), /*DRIVER*/
("774301","IWANNIS","XATZHSTAYRIOY",810.65,13), /*DRIVER*/
("480223","EYAGGELOS","KOYTSOMHTROPOYLOS",2030.54,14),/*ADMIN*/
("453743","AMALIA","KALOMOIRH",830.76,15), /*DRIVER*/
("903323","MARIOS","AGGELOY",900.20,16), /*DRIVER*/
("391875","GEWRGIOS","PAPAIWANNOY",1000.45,17), /*GUIDE*/
("873465","EIRHNH","TRYFWNIADOY",911,18),  /*DRIVER*/
("12133","ANASTASIOS","LIOKAS",891.22,19),  /*DRIVER*/
("21843","AGAPH","FOYNTAKH",1930.34,20); /*ADMIN*/



INSERT INTO driver VALUES
("999999",'A','LOCAL',10),
("101012",'A','LOCAL',10),
("203044",'A','LOCAL',10),
("232345",'A','LOCAL',10),
("856623",'A','LOCAL',10),
("8483233",'A','LOCAL',10),
("493300",'A','LOCAL',10),
("380193",'A','LOCAL',10),
("347762",'A','LOCAL',10),
("209934",'A','LOCAL',10),
("904431",'A','LOCAL',10),
("774301",'A','LOCAL',10),
("480223",'A','LOCAL',10),
("453743",'A','LOCAL',10),
("903323",'A','LOCAL',10),
("391875",'A','LOCAL',10),
("873465",'A','LOCAL',10),
("12133",'A','LOCAL',10),
("21843",'A','LOCAL',10);


/* INSERTIONS IN MANAGES */

INSERT INTO manages VALUES
("AI212134",1),
("AI584736",2),
("AB121314",3),
("AI991111",4),
("AO125677",5),
("Π314121",6),
("AH654535",7),
("AN989766",8),
("AI237345",9),
("AI892193",10),
("X721843",11),
("AO125334",12),
("AP289910",13),
("AO384322",14),
("AI290344",15),
("AY480223",16),
("AB493300",17),
("AM996506",18),
("AI568848",19),
("AM347762",20),
("AH321100",4),
("AM113499",6),
("AX331685",8),
("AI201332",9),
("P084934",11),
("AY379943",14);

/* Insertions in driver */

INSERT INTO driver VALUES
/* Branch 1 */
("AB102210",'B','LOCAL',8),
("AN272428",'C','ABROAD',11),
/*BRANCH 2*/
("AK101314",'A','LOCAL',9),
("AH171822",'B','ABROAD',8),
/*BRANCH 3*/
("AY756512",'A','ABROAD',19),
("P918213",'B','LOCAL',14),
/*BRANCH 4*/
("AX908878",'C','LOCAL',6),
("ΑΔ120099",'A','ABROAD',11),
/* BRANCH 5 */
("ΑΛ886578",'C','LOCAL',10),
("AY108760",'A','ABROAD',16),
/* BRANCH 6 */
("AN990122",'A','LOCAL',10),
("AM456097",'B','ABROAD',12),
/* BRANCH 7 */
("AK465732",'A','LOCAL',20),
("AB758699",'B','ABROAD',21),
/* BRANCH  8*/
("AE252632",'D','LOCAL',6),
("AM657533",'C','ABROAD',10),
/* BRANCH 9 */
("AT673566",'A','LOCAL',29),
("AN271815",'C','ABROAD',18),
/* BRANCH 10*/
("AB905543",'B','LOCAL',11),
("AM892191",'A','ABROAD',30),
/* BRANCH 11 */
("AO873465",'A','ABROAD',19),
("I912133",'C','LOCAL',12),
/* BRANCH 12 */
("X673720",'C','LOCAL',9),
("P192122",'D','ABROAD',17),
/* BRANCH 13 */
("AM882391",'A','LOCAL',8),
("AP198283",'B','ABROAD',15),
/* BRANCH 14 */
("AX381223",'D','LOCAL',10),
("AI095543",'A','ABROAD',17),
/* BRANCH 15 */
("AN946755",'D','LOCAL',11),
("AI883019",'A','ABROAD',20),
/* BRANCH 16 */
("AM453743",'C','LOCAL',23),
("AI903323",'B','ABROAD',19),
/* BRANCH 17 */
("AH856654",'B','LOCAL',11),
("AO380193",'D','ABROAD',20),
/* BRANCH 18 */
("AY465904",'C','LOCAL',29),
("X995032",'D','ABROAD',19),
/* BRANCH 19 */
("AY884833",'B','LOCAL',16),
("AN884431",'C','ABROAD',20),
/* BRANCH 20 */
("AM904431",'D','LOCAL',19),
("AI774301",'A','ABROAD',17);

/* INSERTIONS IN GUIDE */

INSERT INTO guide VALUES
("AH987765","He speaks english fluently and he likes winter and christmas places."), #1
("AM232341","He speaks german and he knows a lot about european history."), #2
("AX676865","She speaks english and she knows a lot about ancient greece. She likes greek museums."), #3
("AN272481","He speaks french ands he knows about roman empire."), #4
("AI867544","He speaks english."), #5
("AI543473","She speaks chinese and she knows a lot about chinese culture."), #6
("AY121365","She speaks english"), #7
("AT990233","She speaks spanish. She likes spain in general"), #8
("P939302","She speaks english. She likes travelling inside greece."), #9
("AI921012","She speaks english and german. She likes travelling and going to ancient temples."), #10
("AY734190","He speaks russian. He likes eastern european culture and he knows about slavic history"), #11
("AB374839","He speaks english. He knows about greek revolution."), #12
("AI910113","He speaks german. He likes a lot going to German for octoberfest."), #13
("AH383899","She speaks english and knows about english culture.She goes to great britain frequently."), #14
("AM949312","She speaks english and she knows a lot about minoan culture."), #15
("AK391875","He speaks italian. He loves italian history and culture. Travels to italy a lot"), #16
("X848323","She speaks turkish. She knows about pontian history."), #17
("AT348890","She speaks swedish."), #18
("AO105629","He speaks english and he used to work in the athenian museum of Acropolis."), #19
("AT209934","He speaks german. He likes Bavarian culture."); #20

/* INSERTION IN LANGUAGES */

INSERT INTO languages VALUES
("AH987765","GREEK,ENGLISH"), #1
("AM232341","GREEK,GERMAN"), #2 
("AX676865","GREEK,ENGLISH"), #3 
("AN272481","GREEK,FRENCH"), #4 
("AI867544","GREEK,ENGLISH"), #5
("AI543473","GREEK,CHINESE"), #6 
("AY121365","GREEK,ENGLISH"), #7
("AT990233","GREEK,SPANISH"), #8 
("P939302","GREEK,ENGLISH"), #9
("AI921012","GREEK,ENGLISH,GERMAN"), #10 
("AY734190","GREEK,RUSSIAN"), #11 
("AB374839","GREEK,ENGLISH"), #12
("AI910113","GREEK,GERMAN"), #13 
("AH383899","GREEK,ENGLISH"), #14
("AM949312","GREEK,FRENCH"), #15
("AK391875","GREEK,ITALIAN"), #16 
("X848323","GREEK,SPANISH"), #17 
("AT348890","GREEK,SWEDISH"), #18
("AO105629","GREEK,ENGLISH"), #19
("AT209934","GREEK,GERMAN"); #20 

/* INSERTIONS IN TRIP */

INSERT INTO trip(tr_departure,tr_return,tr_maxseats,tr_cost,tr_br_code,tr_gui_AT,tr_drv_AT) VALUES
('2022-10-22 13:00:00','2022-10-28 17:00:00','120','5405.79','1','AH987765','AB102210'), #local #1
('2022-7-12 09:00:00','2022-7-14 12:30:00','50','5000.83','2','AM232341','AH171822'), #abroad #2
('2022-1-16 07:00:00','2022-1-27 21:00:00','80','8724.42','3','AX676865','AY756512'), #abroad #3
('2022-10-30 08:00:00','2022-11-2 14:00:00','150','8242.53','4','AN272481','AX908878'), #local #4
('2022-6-3 07:00:00','2022-6-3 22:30:00','100','8782.61','5','AI867544','ΑΛ886578'), #local #5
('2022-12-10 05:30:00','2022-12-17 17:00:00','99','2454.55','6','AI543473','AM456097'), #abroad #6
('2022-9-16 12:00:00','2022-9-16 23:00:00','13','5445.28','7','AY121365','AK465732'), #local #7
('2022-9-9 7:30:00','2022-9-9 19:00:00','6','2203.53','8','AT990233','AE252632'), #local #8
('2022-3-4 06:45:00','2022-3-12 08:30:00','8','5452.38','9','P939302','AN271815'), #abroad #9
('2022-6-23 15:00:00','2022-7-1 09:50:00','61','4245.21','10','AI921012','AM892191'), #abroad #10
('2022-10-25 11:20:00','2022-10-30 18:25:00','51','1879.21','11','AY734190','AO873465'), #abroad #11
('2022-12-17 08:45:00','2022-12-19 13:00:00','57','1681.23','12','AB374839','X673720'), #local #12
('2022-11-9 06:45:00','2022-11-9 20:15:00','112','2435.03','13','AI910113','AM882391'), #local #13
('2022-11-17 08:30:00','2022-11-17 21:45:00','95','2025.27','14','AH383899','AX381223'), #local #14
('2022-8-3 17:15:00','2022-8-10 15:20:00','69','1674.59','15','AM949312','AI883019'), #abroad #15
('2022-5-18 10:15:00','2022-5-23 17:00:00','124','2567.58','16','AK391875','AI903323'), #abroad #16
('2022-4-13 07:25:00','2022-4-18 17:30:00','78','1847.43','17','X848323','AO380193'), #abroad #17
('2022-6-8 7:30:00','2022-6-8 01:30:00','89','2045.09','18','AT348890','AY465904'), #local #18
('2022-11-13 09:00:00','2022-11-15 12:30:00','101','2651.68','19','AO105629','AY884833'), #local #19
('2022-10-12 06:45:00','2022-10-20 11:35:00','112','2314.27','20','AT209934','AI774301'); #abroad #20

/* INSERTIONS IN EVENT */

INSERT INTO event VALUES
(1,'2022-10-23 12:00:00','2022-10-23 14:30:00','Visiting Cretaquarium.'),
(2,'2022-7-12 15:00:00','2022-7-12 17:00:00','Visiting Brandenburg Gate.'),
(3,'2022-1-17 11:00:00','2022-1-17 15:00:00','Visiting Empire State.'),
(4,'2022-11-1 09:45:00','2022-11-1 12:30:00','Visiting Patras Castle.'),
(5,'2022-6-3 11:15:00','2022-6-3 14:20:00','Visiting Tirnithas Tomb.'),
(6,'2022-12-12 13:35:00','2022-12-12 16:35:00','Visiting Central Dongcheng.'),
(7,'2022-9-16 16:00:00','2022-9-16 18:00:00','Visiting waterfalls.'),
(8,'2022-9-9 12:00:00','2022-9-9 15:00:00','Visiting Portara.'),
(9,'2022-3-6 10:00:00','2022-3-6 13:00:00','Visiting Big Ben.'),
(10,'2022-6-25 11:25:00','2022-6-25 14:15:00','Visiting Marienplatz Square.'),
(11,'2022-10-27 12:00:00','2022-10-27 16:00:00','Visiting Red Square.'),
(12,'2022-12-19 10:15:00','2022-12-19 13:30:00','Visiting Panagia Paraportiani.'),
(13,'2022-11-9 12:20:00','2022-11-9 13:45:00','Visiting Acropolis.'),
(14,'2022-11-17 14:15:00','2022-11-17 16:20:00','Visiting White Tower.'),
(15,'2022-8-5 11:20:00','2022-8-5 12:45:00','Visiting Eiffel Tower.'),
(16,'2022-5-20 9:30:00 ','2022-5-20 13:30:00','Visiting Pantheon.'),
(17,'2022-4-16 11:15:00','2022-4-16 14:20:00','Visiting Prado museum'),
(18,'2022-6-8 17:20:00','2022-6-8 19:00:00','Visiting Archaelogical Museum.'),
(19,'2022-11-14 09:25:00','2022-11-14 13:10:00','Visiting shipreck beach.'),
(20,'2022-10-16 08:45:00','2022-10-16 12:15:00','Visiting Römerberg.');

/* INSERTIONS IN RESERVATION */

INSERT INTO reservation VALUES
(1,5,'KOSTAS','PAPAFILIPPOY','MINOR'),
(2,28,'GIANNIS','THEODOSIOU','ADULT'),
(3,30,'ALEXIA','KARAKOSTA','MINOR'),
(4,44,'MARIA','PAPADOPOULOY','ADULT'),
(5,20,'SOFIA','STERGIOY','ADULT'),
(6,35,'IOANNA','ALEXIOY','MINOR'),
(7,42,'NIKOLAS','AVRAMAKOS','MINOR'),
(8,4,'MARIOS','PANAGIOTIDIS','ADULT'),
(9,5,'ALEXANDROS','AGALANIOTIS','ADULT'),
(10,23,'THEOFILOS','DIAMANTIS','MINOR'),
(11,5,'FANIS','PAPASTERGIANOPOYLOS','ADULT'),
(12,25,'FOTIS','PALOYKHS','MINOR'),
(13,7,'EIRHNH','AYGERH','MINOR'),
(14,48,'KONSTANTINA','KONSTANTINIDIS','ADULT'),
(15,25,'APOSTOLOS','VELLIDIS','ADULT'),
(16,5,'GIORGOS','VERMIDIS','MINOR'),
(17,40,'SPYROS','VAVOULIS','ADULT'),
(18,16,'SPILIOS','APOSTOLAKIS','MINOR'),
(19,23,'PANOREA','VAKALIDI','ADULT'),
(20,9,'IAKOBOS','ANAGNOSTOS','ADULT');
  
 /* INSERTIONS IN DESTINATION */
 
 INSERT INTO destination(dst_name,dst_descr,dst_rtype,dst_language,dst_location) VALUES
('Greece','European country located in the balkanic region.','LOCAL','GREEK',NULL), #1
('Germany','European country located in central Europe.','ABROAD','GERMAN',NULL), #2
('France','Western european country.','ABROAD','FRENCH',NULL), #3
('Spain','Western european country.','ABROAD','SPANISH',NULL), #4
('Italy','Southern european country.','ABROAD','ITALIAN',NULL), #5
('United Kingdom','Nothern european country.','ABROAD','ENGLISH',NULL), #6
('Sweden','Nothern european country.','ABROAD','SWEDISH',NULL), #7
('Russia','Eurasian country. One of the biggest countries in the world.','ABROAD','RUSSIAN',NULL), #8
('China','Asian country. One of the biggest countries in the world.','ABROAD','CHINESE',NULL),#9
('USA','United States of America.','ABROAD','ENGLISH',NULL),#10
('Athens','Capital of grece, known for acropolis,greek culture etc.','LOCAL','GREEK',1), #11 ----
('Thessaloniki','Second largest town in greece. Known for the white tower etc.','LOCAL','GREEK',1), #12 -----
('Patra','Third largest town of greece. Has historical value.','LOCAL','GREEK',1), #13 ------
('Mykonos','Famous greek island in Aegean sea.','LOCAL','GREEK',1), #14 -------
('Heraklion','Biggest town in Crete island,has historical value.','LOCAL','GREEK',1), #15  ----
('Naxos','Capital island of Cyclades,Greece.','LOCAL','GREEK',1), #16 ---
('Mycenae','Archaelogical place in Argolis','LOCAL','GREEK',1), #17 -----
('Zakynth',"Famous greek island in Ionian sea known for it's shipreck.",'LOCAL','GREEK',1), #18 ------
('Edessa',"Small greek town known for it's waterfalls.",'LOCAL','GREEK',1), #19 -------
('Olympia',"The birthplace of the olympic games. Huge historical value.",'LOCAL','GREEK',1), #20 ------
('Berlin',"The capital city of Germany. Has historical value",'ABROAD','GERMAN',2), #21  -----
('Munich',"Bavarian city known for its large breweries and oktoberfest.",'ABROAD','GERMAN',2), #22 ------
('Frankfurt',"Fifth largest town in Germany, known for its sausages.",'ABROAD','GERMAN',2), #23
('Paris',"Capital city of France, known for Eiffel tower and beautiful culture.",'ABROAD','FRENCH',3), #24  -------
('Madrid','Capital city of Spain, has historical value,','ABROAD','SPANISH',4), #25 ---
('Rome',"Capital city of Italy. Has huge historical and cultural value.",'ABROAD','ITALIAN',5), #26 -------
('London','Capital city of UK. Known for its culture and history.','ABROAD','ENGLISH',6), #27 -------
('Stockholm',"Capital city of Sweden. Known for the Abba museum and its city hall.",'ABROAD','SWEDISH',7), #28
('Moscow',"Capital city of Russia, known for it's history and russian culture.",'ABROAD','RUSSIAN',8), #29 =======
('Beijing',"Capital city of China. Has historical value and its known for the chinese culture.",'ABROAD','CHINESE',9), #30 ------
('New York',"Most popular city in the united states. Famous tourist attraction.",'ABROAD','ENGLISH',10); #31 -----

 /* INSERTIONS IN TRAVEL_TO */
 
 INSERT INTO travel_to VALUES
(1,15,'2022-10-22 20:00:00','2022-10-28 10:00:00'),
(2,21,'2022-7-12 12:45:00','2022-7-14 03:45:00'),
(3,31,'2022-1-16 15:00:00','2022-7-14 10:30:00'),
(4,13,'2022-10-30 11:00:00','2022-11-2 11:00:00'),
(5,17,'2022-6-3 09:35:00','2022-6-3 00:30:00'),
(6,30,'2022-12-10 15:30:00','2022-12-17 22:00:00'),
(7,19,'2022-9-16 16:20:00','2022-9-16 19:00:00'),
(8,16,'2022-9-9 11:30:00','2022-9-9 16:30:00'),
(9,27,'2022-3-4 10:45:00','2022-3-12 04:30:00'),
(10,22,'2022-6-23 18:00:00','2022-7-1 13:00:00'),
(11,29,'2022-10-25 16:30:00','2022-10-30 13:25:00'),
(12,14,'2022-12-17 13:45:00','2022-12-19 9:00:00'),
(13,11,'2022-11-9 09:45:00','2022-11-9 17:15:00'),
(14,12,'2022-11-17 12:30:00','2022-11-17 19:45:00'),
(15,24,'2022-8-3 20:15:00','2022-8-10 11:20:00'),
(16,26,'2022-5-18 12:15:00','2022-5-23 15:00:00'),
(17,25,'2022-4-13 11:25:00','2022-4-18 13:30:00'),
(18,20,'2022-6-8 12:30:00','2022-6-8 20:30:00'),
(19,18,'2022-11-13 14:00:00','2022-11-15 9:00:00'),
(20,23,'2022-10-12 10:10:00','2022-10-20 8:13:00');
 
INSERT INTO offers(offer_start,offer_end,offer_cost,offer_dst) VALUES
("2023-01-10","2023-01-20",1500,16),
("2023-02-11","2023-02-25",2500,13),
("2023-03-05","2023-03-05",1300,19);

INSERT INTO it_supervisor VALUES
("1088096","12345","2023-01-01",NULL);


 /* ------ END OF INSERTS ---------*/

DROP PROCEDURE IF EXISTS userlogin;
DELIMITER $
CREATE PROCEDURE userlogin(IN username VARCHAR(10), IN password VARCHAR(10))
BEGIN
   DECLARE usercheck VARCHAR(10);
   DECLARE passwordcheck VARCHAR(10);
   DECLARE workingcheck DATE;
   SELECT IT_AT,IT_password,IT_end_date INTO usercheck,passwordcheck,workingcheck 
   FROM it_supervisor WHERE IT_AT=username AND IT_password=password;
   IF(workingcheck IS NOT NULL) THEN
      SELECT "This IT supervisor isn't working in this trave agency anymore. Login unsuccessful.";
   ELSEIF(usercheck IS NULL AND @travelagency_user IS NULL) THEN
      SELECT IT_AT INTO usercheck FROM it_supervisor where IT_AT=username;
      IF(usercheck IS NOT NULL) THEN
         SELECT 'The password is wrong. Try again.';
      ELSE
         SELECT 'User not found';
      END IF;
   ELSEIF(@travelagency_user IS NOT NULL) THEN
      SELECT 'Another user is logged in. You have to logout first to re-log in.';
   ELSE   
      SELECT 'Login successful. Logged as:',usercheck AS username;
      SET @travelagency_user = usercheck;
   END IF;
END$

DELIMITER ;

DROP PROCEDURE IF EXISTS userlogout;
DELIMITER $
CREATE PROCEDURE userlogout()
BEGIN
   IF(@travelagency_user IS NOT NULL) THEN
      SELECT "You logged out.";
      SET @travelagency_user=NULL;
   ELSE
      SELECT "There is no supervisor logged in the database.";
   END IF;
END$
DELIMITER ;

DROP PROCEDURE IF EXISTS showuser;
DELIMITER $
CREATE PROCEDURE showuser()
BEGIN
   DECLARE truser VARCHAR(10);
   SET truser=@travelagency_user;
   IF(truser IS NULL) THEN
      SELECT "An IT supervisor is not logged in the database.";
   ELSE
      SELECT 'Current IT supervisor logged in:',worker_AT AS Username,worker_name AS First_Name,worker_lname AS Last_Name
      FROM worker WHERE worker_AT=truser;
   END IF;
END $
DELIMITER ;

/* TRIGGERS FOR TRIP TABLE */

DROP TRIGGER IF EXISTS log_tripinsert;
DELIMITER $
CREATE TRIGGER log_tripinsert
BEFORE INSERT ON trip
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do insertions.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'INSERT','trip',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_tripdelete;
DELIMITER $
CREATE TRIGGER log_tripdelete
BEFORE DELETE ON trip
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do deletes.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'DELETE','trip',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_tripupdate;
DELIMITER $
CREATE TRIGGER log_tripupdate
BEFORE UPDATE ON trip
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do updates.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'UPDATE','trip',@travelagency_user);
END $
DELIMITER ;

/* TRIGGERS FOR RESERVATION TABLE */

DROP TRIGGER IF EXISTS log_reservationinsert;
DELIMITER $
CREATE TRIGGER log_reservationinsert
BEFORE INSERT ON reservation
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do insertions.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'INSERT','reservation',@travelagency_user);
END $
DELIMITER ; 

DROP TRIGGER IF EXISTS log_reservationdelete;
DELIMITER $
CREATE TRIGGER log_reservationdelete
BEFORE DELETE ON reservation
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do deletes.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'DELETE','reservation',@travelagency_user);
END $
DELIMITER ; 

DROP TRIGGER IF EXISTS log_reservationupdate;
DELIMITER $
CREATE TRIGGER log_reservationupdate
BEFORE UPDATE ON reservation
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do updates.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'UPDATE','reservation',@travelagency_user);
END $
DELIMITER ; 

/* TRIGGERS IN EVENT TABLE */

DROP TRIGGER IF EXISTS log_eventinsert;
DELIMITER $
CREATE TRIGGER log_eventinsert
BEFORE INSERT ON event
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do insertions.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'INSERT','event',@travelagency_user);
END $
DELIMITER ; 

DROP TRIGGER IF EXISTS log_eventdelete;
DELIMITER $
CREATE TRIGGER log_eventdelete
BEFORE DELETE ON event
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do deletes.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'DELETE','event',@travelagency_user);
END $
DELIMITER ; 

DROP TRIGGER IF EXISTS log_eventupdate;
DELIMITER $
CREATE TRIGGER log_eventupdate
BEFORE UPDATE ON event
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do updates.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'UPDATE','event',@travelagency_user);
END $
DELIMITER ; 

/* TRIGGERS IN TRAVEL_TO TABLE */
DROP TRIGGER IF EXISTS log_traveltoinsert;
DELIMITER $
CREATE TRIGGER log_traveltoinsert
BEFORE INSERT ON travel_to
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do insertions.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'INSERT','travel_to',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_traveltodelete;
DELIMITER $
CREATE TRIGGER log_traveltodelete
BEFORE DELETE ON travel_to
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do deletes.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'DELETE','travel_to',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_traveltoupdate;
DELIMITER $
CREATE TRIGGER log_traveltoupdate
BEFORE UPDATE ON travel_to
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do updates.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'UPDATE','travel_to',@travelagency_user);
END $
DELIMITER ;

/* TRIGGERS IN DESTINATION */
DROP TRIGGER IF EXISTS log_destinationinsert;
DELIMITER $
CREATE TRIGGER log_destinationinsert
BEFORE INSERT ON destination
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do insertions.';
   END IF;
   SET @getdatetime=NOW();
   INSERT INTO log VALUES(@getdatetime,'INSERT','destination',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_destinationdelete;
DELIMITER $
CREATE TRIGGER log_destinationdelete
BEFORE DELETE ON destination
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do deletes.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'DELETE','destination',@travelagency_user);
END $
DELIMITER ;

DROP TRIGGER IF EXISTS log_destinationupdate;
DELIMITER $
CREATE TRIGGER log_destinationupdate
BEFORE UPDATE ON destination
FOR EACH ROW
BEGIN
   DECLARE userid VARCHAR(10);
   SET userid=@travelagency_user;
   IF(userid IS NULL) THEN
      SIGNAL SQLSTATE VALUE '50000'
      SET MESSAGE_TEXT = 'You have to login as IT supervisor to do updates.';
   END IF;
SET @getdatetime=NOW();
INSERT INTO log VALUES(@getdatetime,'UPDATE','destination',@travelagency_user);
END $
DELIMITER ;

/* 3.1.4.2 TRIGGER THAT STOPS UPDATING TRIPS WITH RESERVATIONS */

DROP TRIGGER IF EXISTS datetimecosthold;
DELIMITER $
CREATE TRIGGER datetimecosthold
BEFORE UPDATE ON trip
FOR EACH ROW
BEGIN
   DECLARE reservecount INT;
   IF(NEW.tr_return<>OLD.tr_return OR NEW.tr_departure<>OLD.tr_departure OR NEW.tr_cost<>OLD.tr_cost) THEN
      SELECT count(*) INTO reservecount FROM reservation
      WHERE res_tr_id=NEW.tr_id;
      IF (reservecount>0) THEN
         SIGNAL SQLSTATE VALUE '45000'
         SET MESSAGE_TEXT = "You can't update departure and return dates or trip costs with reservations on the trip";
      END IF;
   END IF;
END $
DELIMITER ;

/* 3.1.4.4 TRIGGER THAT PREVENTS SALARY DECREASE */

DROP TRIGGER IF EXISTS salarydecreaseprevention;
DELIMITER $
CREATE TRIGGER salarydecreaseprevention
BEFORE UPDATE ON worker
FOR EACH ROW
BEGIN
   IF(NEW.worker_salary<OLD.worker_salary) THEN
      SIGNAL SQLSTATE VALUE '45000'
      SET MESSAGE_TEXT = "You can't decrease salaries of workers.";
   END IF;
END $
DELIMITER ;





DROP PROCEDURE IF EXISTS gettrip;
DELIMITER $
CREATE PROCEDURE gettrip(IN code INT(11), IN date1 DATETIME, IN date2 DATETIME)
BEGIN
DECLARE seats INT;
DECLARE resseats INT;
DECLARE bsum INT;
DECLARE bid INT;
DECLARE cflag INT;
DECLARE departure DATETIME;
DECLARE tripfinder CURSOR FOR
   SELECT tr_id FROM trip INNER JOIN branch ON tr_br_code=branch_code WHERE tr_br_code=code;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET cflag=1;
SET seats=0;
SET bsum=0;
SET cflag=0;
OPEN tripfinder;
 REPEAT
  FETCH tripfinder INTO bid;
 SELECT tr_departure INTO departure
FROM trip
INNER JOIN branch ON tr_br_code=branch_code
WHERE tr_br_code=code AND tr_id=bid;
 
 IF(departure>=date1 AND departure<=date2)
THEN
  SELECT tr_cost AS TRIP_COST,tr_maxseats AS MAXIMUM_SEATS,tr_departure AS DEPARTURE_DATE,tr_return AS RETURN_DATE
  FROM trip
  INNER JOIN branch ON tr_br_code=branch_code
  WHERE tr_br_code=code;
  
  SELECT count(*),tr_maxseats INTO bsum,resseats
  FROM reservation
  INNER JOIN trip ON res_tr_id=tr_id
  WHERE res_tr_id=bid
  group by res_tr_id;
  
  SELECT worker_name AS Driver_Name,worker_lname AS Driver_Lastname 
  FROM worker
  INNER JOIN guide ON worker_AT=guide_AT
  INNER JOIN trip ON guide_AT=tr_gui_AT
  WHERE tr_br_code=code;

  SET seats=resseats-bsum;
  SELECT seats AS AVAILABLE_SEATS,bsum AS RESERVED_SEATS;

 END IF;
 /*END IF;*/
UNTIL(cflag=0)
END REPEAT;
CLOSE tripfinder;

END$
DELIMITER ;


DROP PROCEDURE IF EXISTS newdriver;
DELIMITER $
CREATE PROCEDURE newdriver(IN AT CHAR(10), IN firstname VARCHAR(20), IN lastname VARCHAR(20), IN salary FLOAT(7,2), IN license ENUM('A','B','C','D'),IN route ENUM("LOCAL","ABROAD"), IN experience TINYINT(4))
BEGIN

DECLARE code INT; 
DECLARE driverscount INT;
SELECT count(*), worker_br_code INTO driverscount,code FROM driver
INNER JOIN worker ON driver_AT=worker_AT
GROUP BY worker_br_code
ORDER BY count(*) LIMIT 0,1;

INSERT INTO worker 
VALUES(AT,firstname,lastname,salary,code);

INSERT INTO driver 
VALUES(AT,license,route,experience);


END$
DELIMITER ;

DROP PROCEDURE IF EXISTS admindelete;
DELIMITER $
CREATE PROCEDURE admindelete(IN adminname VARCHAR(20),IN adminlname VARCHAR(20))
BEGIN
   DECLARE adminAT VARCHAR(10);
   DECLARE adminTYPE ENUM('LOGISTICS','ADMINISTRATIVE','ACCOUNTING');
   DECLARE adminFinishedFlag INT;
   DECLARE adminCursor CURSOR FOR
      SELECT admin_AT,admin_type FROM worker 
      INNER JOIN admin ON worker_AT=admin_AT 
      WHERE worker_name=adminname AND worker_lname=adminlname;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET adminFinishedFlag=1;
   SET adminFinishedFlag=0;
   OPEN adminCursor;
   REPEAT
      FETCH adminCursor INTO adminAT,adminTYPE;
      IF(adminTYPE='ADMINISTRATIVE') THEN
         SELECT 'Cannot delete administrative admins';
      ELSE
         SELECT 'Deleting the admin',adminname,adminlname,adminAT;
         DELETE FROM admin WHERE admin_AT=adminAT;
      END IF;
   UNTIL(adminFinishedFlag=0)
   END REPEAT;
   CLOSE adminCursor;
   END $
   DELIMITER ;


   DROP PROCEDURE IF EXISTS reservationfinder;
   DELIMITER $
   CREATE PROCEDURE reservationfinder(IN lowvalue INT,IN highvalue INT)
      BEGIN
      SELECT res_off_lname,res_off_name FROM reservation_offers 
      WHERE res_off_payminadv BETWEEN lowvalue AND highvalue;
      END $
   DELIMITER ;

   CREATE INDEX reservationoff_index
   ON reservation_offers(res_off_payminadv);












