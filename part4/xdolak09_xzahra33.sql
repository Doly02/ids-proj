-- 4. část - SQL skript pro vytvoření pokročilých objektů schématu databáze
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

DROP MATERIALIZED VIEW "zastupce_dite_count";

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


----- netriviální triggery -----

-- Kontroluje, zda deti mají věk mezi 3 až 6 let při nástupu do školky

CREATE OR REPLACE TRIGGER Check_Dite_Vek
BEFORE INSERT ON "Dite"
FOR EACH ROW
DECLARE
    vek NUMBER;
BEGIN
    SELECT EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM o."datum_narozeni") INTO vek
    FROM "Osoba" o
    WHERE o."rodne_cislo" = :NEW."rodne_cislo_ditete";

    IF vek < 3 OR vek > 6 THEN
        RAISE_APPLICATION_ERROR(-2069, 'Dítě musí být ve věku 3 až 6 let pro nástup do školky.');
    END IF;
END;

-- Kontroluje, zda třída neobsahuje víc než 15 detí.

CREATE OR REPLACE TRIGGER Limit_Children_In_Class
BEFORE INSERT ON "Dite-Trida"
FOR EACH ROW
DECLARE
    child_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO child_count
    FROM "Dite-Trida"
    WHERE "c_tridy" = :NEW."c_tridy";

    IF child_count >= 15 THEN
        RAISE_APPLICATION_ERROR(-2070, 'Třída již má maximální počet dětí (15). Nemůžete přidat další dítě.');
    END IF;
END;

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

INSERT INTO "Dite" (
    "rodne_cislo_ditete", "datum_nastupu"
) VALUES (
    -- Adam Petrik
    '1901010056',       -- Rodne cislo -> Musi odpovidat hodnote v 'Osoba'
    DATE '2022-09-01'
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

INSERT INTO "Zakonny_zastupce" (
    "rodne_cislo_zastupce"
) VALUES (
    -- Jana Petrikova
    '8153120008'
);

INSERT INTO "Zastupce-Dite" (
    "rc_zastupce", "rc_ditete"
) VALUES (
    '8153120008', -- Jana Petrikova
    '1901010056'  -- Adam Petrik
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

----------- ZASTUPCE DITE -----------------


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

----- Explained plan ------
-- DOTAZ: Ktere deti se prijmenim Vlneny/Vlnena maji alespon jedno povoleni k vyzvednuti a kolik jich maji?
EXPLAIN PLAN FOR
SELECT
    o."prijmeni" AS "prijmeni",
    COUNT(p."cislo_pokynu") AS "pocet_povoleni"
FROM "Dite" d
JOIN "Osoba" o ON d."rodne_cislo_ditete" = o."rodne_cislo"
JOIN "Pokyn_k_vyzvednuti" p ON d."rodne_cislo_ditete" = p."rc_ditete"
WHERE o."prijmeni" LIKE 'Vlnen%'            -- Filter pro prijmeni na vyhledani "vlneny/a"
GROUP BY o."rodne_cislo", o."prijmeni"      -- Seskupeni podle rodneho cisla a prijmeni
HAVING COUNT(p."cislo_pokynu") > 0          -- Alespon jedno povoleni
ORDER BY o."prijmeni";                      -- Razeni podle prijmeni
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoreni indexu
CREATE INDEX "idx_osoba_prijmeni" ON "Osoba" ("prijmeni");

EXPLAIN PLAN FOR
SELECT
    o."prijmeni" AS "prijmeni",
    COUNT(p."cislo_pokynu") AS "pocet_povoleni"
FROM "Dite" d
JOIN "Osoba" o ON d."rodne_cislo_ditete" = o."rodne_cislo"
JOIN "Pokyn_k_vyzvednuti" p ON d."rodne_cislo_ditete" = p."rc_ditete"
WHERE o."prijmeni" LIKE 'Vlnen%'                    -- Filter na prijmeni (vyhledani) "vlneny/a"
GROUP BY o."rodne_cislo", o."prijmeni"              -- Seskupeni podle rod. cisla a prijmeni
HAVING COUNT(p."cislo_pokynu") > 0                  -- alespon jedno povoleni
ORDER BY o."prijmeni";                              -- serazeni podle prijmeni
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);            -- zobrazeni vystupu funkce DBMS_XPLAIN.DISPLAY


----- Materialized View -----
-- pohled na vsechny zastupce na zastupce a deti ktere zastupuji
-- umoznuje zjistit kolik ma dane dite zastupcu
CREATE MATERIALIZED VIEW "zastupce_dite_count" AS
SELECT
    z."rodne_cislo_zastupce" AS "zastupce_id",
    o."jmeno" AS "first_name",
    o."prijmeni" AS "last_name",
    COUNT(d."rc_ditete") AS "children_count"
FROM "Zakonny_zastupce" z
JOIN "Osoba" o ON z."rodne_cislo_zastupce" = o."rodne_cislo"
LEFT JOIN "Zastupce-Dite" d ON z."rodne_cislo_zastupce" = d."rc_zastupce"
GROUP BY z."rodne_cislo_zastupce", o."jmeno", o."prijmeni";

-- Pohled pred aktualizaci (MATVIEW)
SELECT * FROM "zastupce_dite_count";

-- Aktualizace dat, uprave existujicich udaju v tabulce
-- RC zastupce bude upraveno hodnotou z novy_rc_zastupce
-- WHERE klauzule zde omezuje radky ktere budou zmeneny
UPDATE "Zastupce-Dite" SET "rc_zastupce" = 'nove_rc_zastupce' WHERE "rc_ditete" = 'exist_rc_ditete';

-- Kontrola pohledu po aktualizaci
SELECT * FROM "zastupce_dite_count";

------- netriviální procedúry -------
-- 1. procedúra, která aktualizuje telefónni číslo osoby, jestli existuje v databáze
CREATE OR REPLACE PROCEDURE Aktualizuj_telefonne_cislo_osoby (param_rodne_cislo IN "Osoba"."rodne_cislo"%TYPE, param_nove_tel_cislo IN "Osoba"."telefonni_cislo"%TYPE) AS
BEGIN
    UPDATE "Osoba"
    SET "telefonni_cislo" = param_nove_tel_cislo
    WHERE "rodne_cislo" = param_rodne_cislo;

    -- Kontrola, zda byl aktualizován nějaký řádek
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nenašla se osoba s daným rodným číslem.');
    END IF;

    -- Potvrzení změn v databázi
    COMMIT;
EXCEPTION
    -- -- Zpracování chyby, která nastane při vykonávání procedury
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Chyba: ' || SQLERRM);
        ROLLBACK;
END;

-- Volání
BEGIN
    --Hana Vlnena
    Aktualizuj_telefonne_cislo_osoby('5559030004', '792555555');
END;


-- 2. procedůra, která vymaže všechny souhlasy spojené s danou aktivitou
CREATE OR REPLACE PROCEDURE Vymaz_souhlasy_pro_aktivitu(param_nazev_aktivity VARCHAR2) IS
  -- Definice kurzoru
    CURSOR s_cursor IS
    SELECT "cislo_aktivity"
    FROM "Aktivita"
    WHERE "nazev_aktivity" = param_nazev_aktivity;

  -- Deklerace promenne pro uchovavani dat ziskanych kurzorem
  c_aktivity_tab s_cursor%ROWTYPE;
BEGIN
  OPEN s_cursor;

  -- projiti vsech radku kurzorem
  LOOP
    -- nacteni radku do promenne
    FETCH s_cursor INTO c_aktivity_tab;
    -- ukonceni smycky, kdyz jsou vsechny radky spracovane
    EXIT WHEN s_cursor%NOTFOUND;

    -- vymazani souhlasu
    DELETE FROM "Souhlas"
    WHERE "c_aktivity" = c_aktivity_tab."cislo_aktivity";
  END LOOP;

  CLOSE s_cursor;
  -- potvrzeni smen v databaze
  COMMIT;
END;


-- Volání
BEGIN
  Vymaz_souhlasy_pro_aktivitu('Sportovni den');
END;


----- privelegia ------
-- prava na tabulky (select, insert, update,delete, index,referece, triggery,alter)
GRANT ALL ON "Osoba" TO XZAHRA33;
GRANT ALL ON "Pedagogicky_pracovnik" TO XZAHRA33;
GRANT ALL ON "Dite" TO XZAHRA33;
GRANT ALL ON "Zakonny_zastupce" TO XZAHRA33;
GRANT ALL ON "Trida" TO XZAHRA33;
GRANT ALL ON "Funkce" TO XZAHRA33;
GRANT ALL ON "Aktivita" TO XZAHRA33;
GRANT ALL ON "Pokyn_k_vyzvednuti" TO XZAHRA33;
GRANT ALL ON "Souhlas" TO XZAHRA33;
GRANT ALL ON "Zastupce-Dite" TO XZAHRA33;
GRANT ALL ON "Dite-Trida" TO XZAHRA33;

-- prava pro procedury
GRANT EXECUTE ON Aktualizuj_telefonne_cislo_osoby TO XZAHRA33;
GRANT EXECUTE ON Vymaz_souhlasy_pro_aktivitu TO XZAHRA33;
-- Prava pro materialovy pohled
GRANT ALL ON "zastupce_dite_count" TO XZAHRA33;

