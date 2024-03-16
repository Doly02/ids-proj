-- 2. část - SQL skript pro vytvoření objektů schématu databáze
-- Téma Školka
-- Autor: Tomáš Dolák (xdolak09)
-- Autor: Monika Záhradníková (xzahra33)


-- Reprezentace GENERALIZACE/SPECIALIZACE:
    -- Z přednášky jsme vybrali možnost 1: tabulka pro nadtyp + pro podtypy s primárním klíčem nadtypu.
    -- Důvod: V naší databázi je třeba uchovávat nejen zákonné zástupce, děti a pedagogické pracovníky,
    --        ale i osoby jako takové, které budou oprávněny vyzvedávat dané dítě. Z tohoto důvodu je
    --        třeba vytvořit také samostatnou tabulku Osoby.


----- mazani tabulek -----

--DROP TABLE "Osoba";

--DROP TABLE "Pedagogicky_pracovnik";
--DROP TABLE "Dite";
--DROP TABLE "Zakonny_zastupce";

--DROP TABLE "Trida";
--DROP TABLE "Funkce";
--DROP TABLE "Aktivita";

--DROP TABLE "Pokyn_k_vyzvednuti";
--DROP TABLE "Souhlas";

--DROP TABLE "Zastupce-Dite";
--DROP TABLE "Dite-Trida";


----- vytvoreni tabulek -----


CREATE TABLE "Osoba" (
    "rodne_cislo" VARCHAR2(10) NOT NULL PRIMARY KEY,
        CHECK(MOD(TO_NUMBER("rodne_cislo"), 11) = 0),

    "jmeno" VARCHAR2(50) NOT NULL,
    "prijmeni" VARCHAR2(50) NOT NULL,
    "datum_narozeni" DATE NOT NULL,
    "pohlavi" VARCHAR2(10) CHECK ("pohlavi" IN ('muž', 'žena')),
    "adresa_bydliste" VARCHAR2(100) NOT NULL,
    "telefonni_cislo" VARCHAR2(20),
	"e-mail" VARCHAR2(100) NOT NULL
		CHECK(REGEXP_LIKE(
		    "e-mail", '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', 'i'
        )),


    CONSTRAINT kontakt_neprazdny
        CHECK ("telefonni_cislo" IS NOT NULL OR "e-mail" IS NOT NULL)
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

    "zacatek_platnosti" DATE NOT NULL,        -- TODO opravit v ERD
    "konec_platnosti" DATE NOT NULL ,

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

    "zacatek_platnosti" DATE NOT NULL,  -- TODO opravit v ERD
    "konec_platnosti" DATE NOT NULL,

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
----------- DITE ---------------------------
INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8106026883',           -- Rodne cislo
    'Adam',                 -- Jmeno
    'Petrik',             -- Prijmeni
    DATE '2007-03-11',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Husitska 202/47, Brno',   -- Adresa bydlište
    '-',            -- Tel. cislo
    '-'   -- E-mail
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    '8106026883',       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
    DATE '2022-09-01'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '7905017894',           -- Rodne cislo
    'Anna',                 -- Jmeno
    'Vlnena',             -- Prijmeni
    DATE '2008-02-27',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Vlnena 124/47 10a, Brno',   -- Adresa bydlište
    '-',            -- Tel. cislo
    '-'   -- E-mail
);

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu", "datum_ukonceni"
) VALUES (
    '8106026883',       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
    DATE '2019-09-01',
    DATE '2023-05-01'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni", "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '1005051234',
    'Jakub',
    'Vlneny',
    DATE '2010-05-05',
    'muž',
    'Vlnena 124/47 10a, Brno',
    '-',
    '-'
);

----------- ZAKONNY ZASTUPCE ---------------
INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8451286208',           -- Rodne cislo
    'Katerina',                 -- Jmeno
    'Vlnena',             -- Prijmeni
    DATE '1982-05-12',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Vlnena 124/47 10a, Brno',   -- Adresa bydlište
    '774776753',            -- Tel. cislo
    'katerina.vlnena@gmail.com'   -- E-mail
);

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    '8451286208'       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8401286208',           -- Rodne cislo
    'Petr',                 -- Jmeno
    'Vlneny',             -- Prijmeni
    DATE '1980-07-18',      -- Datum narozeni
    'muž',                 -- Pohlavi
    'Vlnena 124/47 10a, Brno',   -- Adresa bydlište
    '777556009',            -- Tel. cislo
    'vlnka123@gmail.com'   -- E-mail
);

----------- TRIDA --------------------------
INSERT INTO "Trida" (
    "oznaceni","kmenova_ucebna"
) VALUES (
    'Berusky',
    'B112'
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
----------- ZASTUPCE DITE -----------------
INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8451286208', -- Katerina Vlnena
    '7905017894'  -- Anna Vlnena
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8401286208', -- Petr Vlneny
    '7905017894'  -- Anna Vlnena
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8451286208',   -- Jakub Vlneny
    '1005051234'    -- Katerina Vlnena
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8401286208',   -- Jakub Vlneny
    '1005051234'    -- Petr Vlneny
);

----------- DITE-TRIDA ----------------------
INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '7905017894',  -- Anna Vlnena
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '8106026883',  -- Adam Petrik
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);

INSERT INTO "Dite-Trida" (
    "rc_ditete", "c_tridy"
) VALUES (
    '8451286208',  -- Jakub Vlneny
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Komari') -- Lepe to dosadit nejde kdyz nezname cislo tridy
);
----------- PEDAGOGICKY PRACOVNIK ----------
INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '1234567890',           -- Rodne cislo
    'Jan',                  -- Jmeno
    'Novák',                -- Prijmeni
    DATE '1999-05-04',      -- Datum narozeni
    'muž',                  -- Pohlavi
    'Ulice 123, Město',     -- Adresa bydlište
    '123456789',            -- Tel. cislo
    'jan.novak@email.cz'    -- E-mail
);

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    '1234567890' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

INSERT INTO "Osoba" (
    "rodne_cislo", "jmeno", "prijmeni", "datum_narozeni",
    "pohlavi", "adresa_bydliste", "telefonni_cislo", "e-mail"
) VALUES (
    '8451286219',           -- Rodne cislo
    'Jana',                 -- Jmeno
    'Novakova',             -- Prijmeni
    DATE '1989-07-02',      -- Datum narozeni
    'žena',                 -- Pohlavi
    'Semilaso 475, Brno',   -- Adresa bydlište
    '776914753',            -- Tel. cislo
    'janicka69@yahoo.com'   -- E-mail
);

INSERT INTO "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika"
) VALUES (
    '8451286219' -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
);

----------- FUNKCE -------------------------
INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Berusky'),
    '1234567890',       -- Jan Novak
    'ucitel',
    DATE '2023-09-01'
);

INSERT INTO "Funkce" (
    "c_tridy", "rc_pracovnika", "název", "datum_zacatku"
) VALUES (
    (SELECT "cislo_tridy" FROM "Trida" WHERE "oznaceni" = 'Kvetinky'),
    '8451286219',       -- Jana Novakova
    'ucitel',
    DATE '2022-09-01'
);

----------- AKTIVITA -----------------------
INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Skolni vylet', 'Brnenska prehrada'
);

INSERT INTO "Aktivita" (
    "typ_aktivity", "nazev_aktivity"
) VALUES (
    'Sport', 'Sportovni den'
);

----------- SOUHLAS ------------------------
INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti", "konec_platnosti"
) VALUES (
    '7905017894',  -- Anna Vlnena
    '8401286208',  -- Petr Vlneny
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Sportovni den'),
    DATE '2023-09-01',
    DATE '2023-09-30'   --TODO Podle me bychom tu nemeli davat konec platnosti -> Nema to smysl :D
);

INSERT INTO "Souhlas" (
    "rc_ditete", "rc_zastupce", "c_aktivity", "zacatek_platnosti", "konec_platnosti"
) VALUES (
    '8451286208',  -- Anna Vlnena
    '8451286208',  -- Katerina Vlneny
    (SELECT "cislo_aktivity" FROM "Aktivita" WHERE "nazev_aktivity" = 'Brnenska prehrada'),
    DATE '2023-09-03',
    DATE '2023-11-04'
);
