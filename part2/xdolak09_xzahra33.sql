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

    -- specializace osoby
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

-- TODO