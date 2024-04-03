-- 3. část - SQL skript pro vytvoření objektů schématu databáze a s příklady na dotazy SELECT
-- Téma Školka
-- Autor: Tomáš Dolák (xdolak09)
-- Autor: Monika Záhradníková (xzahra33)


-- Reprezentace GENERALIZACE/SPECIALIZACE:
    -- Z přednášky jsme vybrali možnost 1: tabulka pro nadtyp + pro podtypy s primárním klíčem nadtypu.
    -- Důvod: V naší databázi je třeba uchovávat nejen zákonné zástupce, děti a pedagogické pracovníky,
    --        ale i osoby jako takové, které budou oprávněny vyzvedávat dané dítě. Z tohoto důvodu je
    --        třeba vytvořit také samostatnou tabulku Osoby.


----- mazani tabulek -----

DROP TABLE "Dite-Trida";
DROP TABLE "Zastupce-Dite";

DROP TABLE "Pokyn_k_vyzvednuti";
DROP TABLE "Souhlas";

DROP TABLE "Aktivita";
DROP TABLE "Funkce";
DROP TABLE "Trida";

DROP TABLE "Pedagogicky_pracovnik";
DROP TABLE "Dite";
DROP TABLE "Zakonny_zastupce";

DROP TABLE "Osoba";

----- vytvoreni tabulek -----


CREATE TABLE "Osoba" (
    "rodne_cislo" VARCHAR2(10) NOT NULL PRIMARY KEY,
        CHECK(MOD(TO_NUMBER("rodne_cislo"), 11) = 0),
    "jmeno" VARCHAR2(50) NOT NULL,
    "prijmeni" VARCHAR2(50) NOT NULL,
    "datum_narozeni" DATE NOT NULL,
    "pohlavi" VARCHAR2(10)
        CHECK ("pohlavi" IN ('muž', 'žena')),
    "adresa_bydliste" VARCHAR2(100) NOT NULL,
    "telefonni_cislo" VARCHAR2(20),
	"e-mail" VARCHAR2(100)
);


CREATE TABLE "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika" VARCHAR2(10) NOT NULL PRIMARY KEY,

    -- specializace osoby
    CONSTRAINT "Pracovnik_Osoba_FK"
        FOREIGN KEY ("rodne_cislo_pracovnika")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Dite" (
    "rodne_cislo_ditete" VARCHAR2(10) NOT NULL PRIMARY KEY,

    "datum_nastupu" DATE NOT NULL,
    "datum_ukonceni" DATE,

    -- zastupuje
    CONSTRAINT "Dite_Osoba_FK"
        FOREIGN KEY ("rodne_cislo_ditete")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Zakonny_zastupce" (
    "rodne_cislo_zastupce" VARCHAR2(10) NOT NULL PRIMARY KEY ,

    -- specializace osoby
    CONSTRAINT "Zastupce_Osoba_FK"
        FOREIGN KEY ("rodne_cislo_zastupce")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Trida" (
    "cislo_tridy" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,

    "oznaceni" VARCHAR2(20) NOT NULL,
    "kmenova_ucebna" VARCHAR2(20)
);


CREATE TABLE "Funkce" (
    "cislo_funkce" INT GENERATED AS IDENTITY PRIMARY KEY,

    "c_tridy" INT NOT NULL,
    "rc_pracovnika" VARCHAR2(10) NOT NULL,

    "název" VARCHAR2(30) NOT NULL,
    "datum_zacatku" DATE NOT NULL,
    "datum_ukonceni" DATE,

    -- Funkce v dane tride
    CONSTRAINT "Funkce_Trida_FK"
        FOREIGN KEY ("c_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE CASCADE,

    -- Funkci zastava dany pedag. pracovnik
    CONSTRAINT "Funkce_Pracovnik_FK"
        FOREIGN KEY ("rc_pracovnika")
        REFERENCES "Pedagogicky_pracovnik" ("rodne_cislo_pracovnika")
        ON DELETE CASCADE
);


CREATE TABLE "Aktivita" (
    "cislo_aktivity" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,

    "typ_aktivity" VARCHAR(50) NOT NULL,
    "nazev_aktivity" VARCHAR(50) NOT NULL

);


CREATE TABLE "Pokyn_k_vyzvednuti" (
    "cislo_pokynu" INT GENERATED AS IDENTITY NOT NULL,

    "rc_osoby" VARCHAR2(10) NOT NULL,
    "rc_zastupce" VARCHAR2(10) NOT NULL,
    "rc_ditete" VARCHAR2(10) NOT NULL,

    CONSTRAINT "Pokyn_Zastupca_PK"
        PRIMARY KEY ("cislo_pokynu", "rc_zastupce"),

    "zacatek_platnosti" DATE NOT NULL,
    "konec_platnosti" DATE,

    -- Pokyn k vyzvednuti udeluje dany zakonny zastupce
    CONSTRAINT "Pokyn_Zastupce_FK"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE CASCADE,

    -- Pokyn k vyzvednuti zmocnuje danou osobu
    CONSTRAINT "Pokyn_Osoba_FK"
        FOREIGN KEY ("rc_osoby")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE,

    -- Pokyn k vyzvednuti daneho ditete
    CONSTRAINT "Pokyn_Dite_FK"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE
);


CREATE TABLE "Souhlas" (
    "cislo_souhlasu"  INT GENERATED AS IDENTITY NOT NULL,

    "rc_ditete" VARCHAR2(10) NOT NULL,
    "rc_zastupce" VARCHAR2(10) NOT NULL,
    "c_aktivity" INT NOT NULL,

    CONSTRAINT "Souhlas_Zastupce_PK"
        PRIMARY KEY ("cislo_souhlasu", "rc_zastupce"),

    "zacatek_platnosti" DATE NOT NULL,

    -- Souhlas s danou aktivitou
    CONSTRAINT "Souhlas_Aktivita_FK"
        FOREIGN KEY ("c_aktivity")
        REFERENCES "Aktivita" ("cislo_aktivity")
        ON DELETE CASCADE,

    -- Souhlas vyjadruje dany zakonny zastupce
    CONSTRAINT "Souhlas_Zastupce_FK"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE CASCADE,

    -- Souhlas se vztahuje na dane dite
    CONSTRAINT "Souhlas_Dite_FK"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE
);


-- Tabulka k vztahu M:N
CREATE TABLE "Zastupce-Dite" (
    "rc_zastupce" VARCHAR2(10) NOT NULL,
    "rc_ditete"   VARCHAR2(10) NOT NULL,

    CONSTRAINT "Zastupce-Dite_PK"
        PRIMARY KEY ("rc_zastupce", "rc_ditete"),

    -- Zakonny zastupce zastupuje dane dite
    CONSTRAINT "Zastupce-Dite_Dite_FK"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE,

    -- Dite je zastoupeno danym zakonnym zastupcem
    CONSTRAINT "Zastupce-Dite_Zastupce_FK"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE CASCADE
);


-- Tabulka k vztahu M:N
CREATE TABLE "Dite-Trida" (
    "rc_ditete" VARCHAR2(10) NOT NULL,
    "c_tridy" INT NOT NULL,

    CONSTRAINT "Dite-Trida_PK"
        PRIMARY KEY ("rc_ditete", "c_tridy"),

    -- V tride je dane dite
    CONSTRAINT "Dite-Trida_Dite_FK"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE,

    -- Dite je v dane tride
    CONSTRAINT "Dite-Trida_Trida_FK"
        FOREIGN KEY ("c_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE CASCADE
);


----- naplneni tabulek ukazkovymi daty -----

----------- OSOBA ---------------------------
INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste"
) VALUES (
    '1901010056',           -- Rodne cislo
    'Adam',                 -- Jmeno
    'Petrik',             -- Prijmeni
    DATE '2019-01-01',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Husitska 202/47, Brno'   -- Adresa bydlište
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni", "pohlavi", "adresa_bydliste"
) VALUES (
    '2005050003',
    'Jakub',
    'Vlneny',
    DATE '2020-05-05',
    'muž',
    'Vlnena 124/47 10a, Brno'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni", "pohlavi", "adresa_bydliste"
) VALUES (
    '1856060008',
    'Anna',
    'Vlnena',
    DATE '2018-06-06',
    'žena',
    'Vlnena 124/47 10a, Brno'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste"
) VALUES (
    '2062060000',           -- Rodne cislo
    'Michaela Erika',         -- Jmeno
    'Svobodova',             -- Prijmeni
    DATE '2020-12-06',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Videnska 273/64 Brno'   -- Adresa bydlište
);


INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste"
) VALUES (
    '2110110002',           -- Rodne cislo
    'Vojtech',         -- Jmeno
    'Labuda',             -- Prijmeni
    DATE '2021-10-11',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Palackeho trida 123/5 Brno-Kralovo Pole'   -- Adresa bydlište
);



INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8451280002',           -- Rodne cislo
    'Katerina',                 -- Jmeno
    'Vlnena',             -- Prijmeni
    DATE '1984-01-28',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Vlnena 124/47 10a, Brno',   -- Adresa bydlište
    '774776753',            -- Tel. cislo
    'katerina.vlnena@gmail.com'   -- E-mail
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8007180005',
    'Petr',
    'Vlneny',
    DATE '1980-07-18',
    'muž',
    'Vlnena 124/47 10a, Brno',
    '777556009',
    'vlnka123@gmail.com'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8153120008',
    'Jana',
    'Petrikova',
    DATE '1981-03-12',
    'žena',
    'Husitska 202/47, Brno',
    '773522019',
    'janapetrik6@zoznam.cz'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8857070002',
    'Andrea',
    'Svobodova',
    DATE '1988-07-07',
    'žena',
    'Videnska 273/64 Brno',
    '792111003',
    'svobodova452@zoznam.cz'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '7505220008',           -- Rodne cislo
    'Jan',                 -- Jmeno
    'Labuda',             -- Prijmeni
    DATE '1975-05-22',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Palackeho trida 123/5 Brno-Kralovo Pole',   -- Adresa bydlište
    '722546789',            -- Tel. cislo
    'labuda.j@gmail.com'   -- E-mail
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8957020006',           -- Rodne cislo
    'Martina',                 -- Jmeno
    'Sedlackova',             -- Prijmeni
    DATE '1989-07-02',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Riegrova 1, Brno-Kralovo Pole',   -- Adresa bydlište
    '776914753',            -- Tel. cislo
    'martinka61@yahoo.com'   -- E-mail
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8005020001',           -- Rodne cislo
    'Milan',                 -- Jmeno
    'Varga',                -- Prijmeni
    DATE '1980-05-02',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Palackeho trida 460/2, Brno',   -- Adresa bydlište
    '770034413',            -- Tel. cislo
    'varga222@yahoo.com'   -- E-mail
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8757280004',           -- Rodne cislo
    'Anna',                 -- Jmeno
    'Sedlackova',             -- Prijmeni
    DATE '1987-07-28',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Riegrova 1, Brno-Kralovo Pole',   -- Adresa bydlište
    '733123785',            -- Tel. cislo
    'sedlackova.anna@gmail.com'   -- E-mail
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8011030005',           -- Rodne cislo
    'Lukas',                 -- Jmeno
    'Hajek',             -- Prijmeni
    DATE '1980-11-03',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Janska 2, Kurim',   -- Adresa bydlište
    '793444561',            -- Tel. cislo
    'luki22@zoznam.cz'   -- E-mail
);


INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo"
) VALUES (
    '5559030004',           -- Rodne cislo
    'Hana',                -- Jmeno
    'Vlnena',             -- Prijmeni
    DATE '1955-09-03',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Videnska 200/2 Brno',   -- Adresa bydlište
    '792945128'              -- Telefonni cislo
);

----------- DITE ---------------------------------

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    -- Adam Petrik
    '1901010056',       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
    DATE '2022-09-01'
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    -- Jakub Vlneny
    '2005050003',
    DATE '2023-09-01'
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    --  Anna Vlnena
    '1856060008',
    DATE '2021-09-01'
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    -- Michaela Erika Svobodova
    '2062060000',
    DATE '2023-09-01'
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    -- Vojtech Labuda
    '2110110002',
    DATE '2023-09-01'
);

----------- ZAKONNY ZASTUPCE ---------------

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    -- Katerina Vlnena
    '8451280002'       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (      -- Rodne cislo -> Musi odpovidat hodnote v 'Osob
    -- Petr Vlneny
    '8007180005'
);

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    -- Jana Petrikova
    '8153120008'
);

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    -- Andrea Svobodova
    '8857070002'
);

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    -- Jan Labuda
    '7505220008'
);

----------- TRIDA --------------------------
INSERT INTO "Trida" (
    "oznaceni","kmenova_ucebna"
) VALUES (
    'Berusky',
    'B055'
);

INSERT INTO "Trida" (
    "oznaceni","kmenova_ucebna"
) VALUES (
    'Kvetinky',
    'A113'
);

INSERT INTO "Trida" (
    "oznaceni","kmenova_ucebna"
) VALUES (
    'Komari',
    'C099'
);

INSERT INTO "Trida" (
    "oznaceni","kmenova_ucebna"
) VALUES (
    'Jesterky',
    'C091'
);
----------- ZASTUPCE DITE -----------------
INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8153120008', -- Jana Petrikova
    '1901010056'  -- Adam Petrik
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8857070002', -- Andrea Svobodova
    '2062060000'  -- Michaela Erika Svobodova
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '7505220008', -- Jan Labuda
    '2110110002'  -- Vojtech Labuda
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8451280002', -- Katerina Vlnena
    '2005050003'  -- Jakub Vlneny
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8007180005', -- Petr Vlneny
    '2005050003'  -- Jakub Vlneny
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8451280002', -- Katerina Vlnena
    '1856060008'  -- Anna Vlnena
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8007180005', -- Petr Vlneny
    '1856060008'  -- Anna Vlnena
);

----------- DITE-TRIDA ----------------------
INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '1901010056', -- Adam Petrik
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '2062060000', -- Michaela Erika Svobodova
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '2005050003', -- Jakub Vlneny
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '1856060008', -- Anna Vlnena
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Komari') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '2110110002', -- Vojtech Labuda
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

----------- PEDAGOGICKY PRACOVNIK ----------

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    -- Martina Sedlackova
    '8957020006' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    -- Milan Varga
    '8005020001' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    -- Anna Sedlackova
    '8757280004' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    -- Lukas Hajek
    '8011030005' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

----------- FUNKCE -------------------------
INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky'),
    '8957020006', -- Martina Sedlackova
    'tridny ucitel',
    DATE '2022-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Komari'),
    '8005020001', -- Milan Varga
    'tridny ucitel',
    DATE '2021-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky'),
    '8011030005', -- Lukas Hajek
    'tridny ucitel',
    DATE '2023-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky'),
    '8011030005', -- Lukas Hajek
    'vychovavatel',
    DATE '2023-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky'),
    '8011030005', -- Lukas Hajek
    'vychovavatel',
    DATE '2023-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Komari'),
    '8757280004', -- Anna Sedlackova
    'lektorka anglictiny',
    DATE '2023-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky'),
    '8757280004', -- Anna Sedlackova
    'lektorka anglictiny',
    DATE '2023-09-01'
);

----------- AKTIVITA -----------------------

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Sport', 'Sportovni den'
);

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Besidka', 'Vanocni besidka'
);

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Kurz', 'Plavecky kurz'
);

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Vylet', 'ZOO Brno'
);

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Vylet', 'Brnenska Prehrada'
);



----------- SOUHLAS ------------------------

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2005050003',  -- Jakub Vlneny
    '8007180005',  -- Petr Vlneny
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Sportovni den'),
    DATE '2023-09-01'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2005050003',  -- Jakub Vlneny
    '8007180005',  -- Petr Vlneny
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'ZOO Brno'),
    DATE '2023-09-01'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2005050003',  -- Jakub Vlneny
    '8007180005',  -- Petr Vlneny
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Plavecky kurz'),
    DATE '2023-09-01'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '1901010056',  -- Adam Petrik
    '8153120008',  -- Jana Petrikova
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Sportovni den'),
    DATE '2023-04-04'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '1901010056',  -- Adam Petrik
    '8153120008',  -- Jana Petrikova
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Brnenska Prehrada'),
    DATE '2023-04-04'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2062060000',  -- Michaela Erika Svobodova
    '8857070002',  -- Andrea Svobodova
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Vanocni besidka'),
    DATE '2023-04-04'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2062060000',  -- Michaela Erika Svobodova
    '8857070002',  -- Andrea Svobodova
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Plavecky kurz'),
    DATE '2023-04-04'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2110110002',  -- Vojtech Labuda
    '7505220008',  -- Jan Labuda
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Sportovni den'),
    DATE '2023-04-04'
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti"
) VALUES (
    '2110110002',  -- Vojtech Labuda
    '7505220008',  -- Jan Labuda
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Vanocni besidka'),
    DATE '2023-04-04'
);


----------- POKYN K VYZVEDNUTI ------------------------

INSERT INTO "Pokyn_k_vyzvednuti" (
    "rc_osoby", "rc_zastupce", "rc_ditete", "zacatek_platnosti"
) VALUES (
    '8153120008', -- Jana Petrikova
    '8857070002', -- Andrea Svobodova
    '2062060000', -- Michaela Erika Svobodova
    DATE '2023-10-30'
);

INSERT INTO "Pokyn_k_vyzvednuti" (
    "rc_osoby", "rc_zastupce", "rc_ditete", "zacatek_platnosti"
) VALUES (
    '8857070002', -- Andrea Svobodova
    '8153120008', -- Jana Petrikova
    '1901010056', -- Adam Petrik
    DATE '2023-10-31'
);

INSERT INTO "Pokyn_k_vyzvednuti" (
    "rc_osoby", "rc_zastupce", "rc_ditete", "zacatek_platnosti"
) VALUES (
    '5559030004', -- Hana Vlnena
    '8451280002',  -- Katerina Vlnena
    '2005050003',  -- Jakub Vlneny
    DATE '2023-09-10'
);


-------------- DOTAZY SELECT -------------------

-- 1. dotaz - Spojení dvou tabulek (Osoba, Zákonný zástupce)
-- Popis: Vypíše telefonní čísla zákonných zástupců.
SELECT
    "jmeno", "prijmeni", "telefonni_cislo"
FROM
    "Osoba" O
JOIN
    "Zakonny_zastupce" Zz ON O."rodne_cislo" = Zz."rodne_cislo_zastupce";


-- 2. dotaz - Spojení dvou tabulek (Osoba, Dite)
-- Popis: Vypíše jména a příjmení chlapců ve školce.
SELECT
    "jmeno", "prijmeni"
FROM
    "Osoba" O
JOIN
    "Dite" D ON O."rodne_cislo" = D."rodne_cislo_ditete"
WHERE
    O."pohlavi" = 'muž';


-- 3. dotaz - Spojeni trech tabulek (Osoba, Funkce, Trida)
-- Popis: Zobrazí jednotlivé pedagogické pracovníky a funkce, které zastávají ve třídach.
SELECT
    O."jmeno",
    O."prijmeni",
    F."název" AS funkce,
    F."datum_zacatku",
    F."datum_ukonceni",
    T."oznaceni" AS nazev_tridy
FROM
    "Pedagogicky_pracovnik" PP
JOIN
    "Osoba" O ON PP."rodne_cislo_pracovnika" = O."rodne_cislo"
JOIN
    "Funkce" F ON PP."rodne_cislo_pracovnika" = F."rc_pracovnika"
JOIN
    "Trida" T ON F."c_tridy" = T."cislo_tridy";


-- 4. dotaz - Dotaz s klauzuli GROUP BY a agregacni funkci
-- Popis: Spočítá počet zákonnných zástupců v jednotlivých věkových kategoriích (napr. 1970-1979,1980-1989).
SELECT
    TRUNC(EXTRACT(YEAR FROM "datum_narozeni") / 10) * 10 || 's' AS vekova_kategorie,
    COUNT(*) AS pocet_zastupcu
FROM
    "Osoba" O
JOIN
    "Zakonny_zastupce" ZZ ON O."rodne_cislo" = ZZ."rodne_cislo_zastupce"
GROUP BY
    TRUNC(EXTRACT(YEAR FROM "datum_narozeni") / 10) * 10
ORDER BY
    vekova_kategorie;


-- 5. dotaz - Dotaz s klauzuli GROUP BY a agregacni funkci
-- Popis: Vypíše počet detí v každé neprázdné třídě.
SELECT
    "oznaceni", COUNT(*) AS "pocet_deti"
FROM
    "Dite-Trida"
JOIN
    "Trida" T on "Dite-Trida"."c_tridy" = T."cislo_tridy"
GROUP BY
    "oznaceni"
ORDER BY
    "pocet_deti";


-- 6. dotaz - dotaz s predikatem EXISTS
-- Popis: Vypíše deti, které mají souhlas s aktivitou Plavecký kurz.
SELECT
    O."jmeno", O."prijmeni", D."rodne_cislo_ditete"
FROM
    "Osoba" O
JOIN
    "Dite" D ON O."rodne_cislo" = D."rodne_cislo_ditete"
WHERE EXISTS (
    SELECT 1
    FROM
        "Souhlas" S
    JOIN
        "Aktivita" A ON S."c_aktivity" = A."cislo_aktivity"
    WHERE
        S."rc_ditete" = D."rodne_cislo_ditete"
    AND
        A."nazev_aktivity" = 'Plavecky kurz'
);


-- 7. dotaz - dotaz s predikatem IN a s vnorenym SELECTem
-- Popis: Ktere tridy neobsahuji zadne deti?
SELECT
    T."oznaceni" AS "trida"
FROM
    "Trida" T
WHERE
    T."cislo_tridy" NOT IN (
        SELECT DISTINCT DT."c_tridy"
        FROM "Dite-Trida" DT
    )
ORDER BY
    "trida";
