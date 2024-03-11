-- 2. část - SQL skript pro vytvoření objektů schématu databáze
-- Téma Školka
-- Autor: Tomáš Dolák (xdolak09)
-- Autor: Monika Záhradníková (xzahra33)

-- TODO: Komentar dopsat info ohledne generatizace speializace
    -- > vybrano protoze potrebujeme propojit osobu a pokyn k vyzvednuti navic nejuniverzalnejsi reseni

----- mazani tabulek -----

DROP TABLE "Osoba";
DROP TABLE "Pedagogicky_pracovnik";
DROP TABLE "Dite";

DROP TABLE "Trida";
DROP TABLE "Funkce";

DROP TABLE "Dite-Trida";


----- vytvoreni tabulek -----

CREATE TABLE "Osoba" (
    "rodne_cislo" VARCHAR2(10) NOT NULL PRIMARY KEY, -- TODO CHECK
		CHECK(REGEXP_LIKE(
			"rodne_cislo", '^[0-9]{10}$', 'i'
		)),
        --CHECK ( TO_NUMBER("rodne_cislo") MOD 11 = 0 ),
    "jmeno" VARCHAR2(50) NOT NULL,
    "prijmeni" VARCHAR2(50) NOT NULL,
    "datum_narozeni" DATE NOT NULL,
    "pohlavi" VARCHAR2(10) CHECK ("pohlavi" IN ('muž', 'žena')),
    "adresa_bydliste" VARCHAR2(100) NOT NULL,
    "telefonni_cislo" VARCHAR2(20),
	"e-mail" VARCHAR2(100) NOT NULL
		CHECK(REGEXP_LIKE(
			"e-mail", '^[a-zA-Z]+[a-zA-Z0-9.-]*@[a-z0-9.-]+\.[a-z]{2,3}$', 'i'
		)),
    CONSTRAINT kontakt_neprazdny
        CHECK ("telefonni_cislo" IS NOT NULL OR "e-mail" IS NOT NULL)
);


CREATE TABLE "Pedagogicky_pracovnik" (
    "rodne_cislo_pracovnika" VARCHAR2(10) NOT NULL,

    CONSTRAINT "Pedagogicky_pracovnik_PK"
        PRIMARY KEY ("rodne_cislo_pracovnika"),

    CONSTRAINT "Pedagogicky_pracovnik_Osoba_FK"
        FOREIGN KEY ("rodne_cislo_pracovnika")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Dite" (
    "rodne_cislo_ditete" VARCHAR2(10) NOT NULL,
    "datum_nastupu" DATE NOT NULL,
    "datum_ukonceni" DATE,

    CONSTRAINT "PK_Dite"                                --todo pk na koniec
        PRIMARY KEY ("rodne_cislo_ditete"),

    CONSTRAINT "FK_Dite_Osoba"
        FOREIGN KEY ("rodne_cislo_ditete")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Trida" (
    "cislo_tridy" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY, -- automaticke generovani hodnot primarniho klíče
    "oznaceni" VARCHAR2(20) NOT NULL,
    "kmenova_ucebna" VARCHAR2(20)
);


CREATE TABLE "Funkce" (
    "cislo_funkce" INT GENERATED AS IDENTITY PRIMARY KEY,
    "cislo_tridy" INT NOT NULL,
    "rc_pracovnika" VARCHAR2(10) NOT NULL,

    CONSTRAINT "FK_cislo_tridy"
        FOREIGN KEY ("cislo_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE CASCADE,

    CONSTRAINT "FK_rodne_cislo_pedag_pracovnika"
        FOREIGN KEY ("rc_pracovnika")
        REFERENCES "Pedagogicky_pracovnik" ("rodne_cislo_pracovnika")
        ON DELETE CASCADE,

    "název" VARCHAR2(30) NOT NULL,
    "datum_zacatku" DATE NOT NULL,
    "datum_ukonceni" DATE
);


CREATE TABLE "Dite-Trida" (
    "rc_ditete" VARCHAR2(10) NOT NULL,
    "cislo_tridy" INT NOT NULL,

    CONSTRAINT "PK_Dite-Trida"
        PRIMARY KEY ("rc_ditete", "cislo_tridy"),

    CONSTRAINT "FK_Dite-Trida_Dite"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE,

    CONSTRAINT "FK_Dite-Trida_Trida"
        FOREIGN KEY ("cislo_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE CASCADE
);




CREATE TABLE "Zakonny_zastupce"
(
    "rodne_cislo_zastupce" VARCHAR2(10) NOT NULL,

    CONSTRAINT "Zakonny_zastupce_PK"
        PRIMARY KEY ("rodne_cislo_zastupce"),

    CONSTRAINT "Zakonny_zastupce_Osoba_FK"
        FOREIGN KEY ("rodne_cislo_zastupce")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);

CREATE TABLE "Pokyn_k_vyzvednuti"
(
    "cislo_pokynu"    INT GENERATED AS IDENTITY NOT NULL,
    "rc_zmocnitele"   VARCHAR2(10) NOT NULL,
    "rc_zastupce"     VARCHAR2(10) NOT NULL,
    "rc_ditete"       VARCHAR2(10) NOT NULL,
    "zacatek_platnosti"   DATE NOT NULL,        -- TODO upravit v ERD
    "konec_platnosti" DATE NOT NULL ,
    PRIMARY KEY ("rc_zastupce", "cislo_pokynu"),


        -- udeluje
    CONSTRAINT "rc_zastupce_FK"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE  CASCADE,

        -- udeleno
    CONSTRAINT "rc_zmocnitele_FK"
        FOREIGN KEY ("rc_zmocnitele")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE,

        -- ma
    CONSTRAINT "FK_rodne_cislo_ditete"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE
);

CREATE TABLE "Souhlas"
(
    "cislo_souhlasu"  INT GENERATED AS IDENTITY NOT NULL,
    "cislo_aktivity" INT NOT NULL,
    "zacatek_platnosti"   DATE NOT NULL,
    "konec_platnosti" DATE NOT NULL,
    "rc_ditete"       VARCHAR2(10) NOT NULL,
    "rc_zastupce"     VARCHAR2(10) NOT NULL,


    PRIMARY KEY ("rc_zastupce", "cislo_souhlasu"),

    FOREIGN KEY ("cislo_aktivity")
        REFERENCES "Aktivita" ("cislo_aktivity")
        ON DELETE CASCADE, -- pokud se smaze aktivita, smaze se i souhlas

    FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE CASCADE, -- to same

        -- udeli souhlas
    CONSTRAINT "FK_rodne_cislo_osoby"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE,

        -- s
    CONSTRAINT "FK_cislo_aktivity"
        FOREIGN KEY ("cislo_aktivity")
        REFERENCES "Aktivita" ("cislo_aktivity")
        ON DELETE CASCADE,

        -- ma
    CONSTRAINT "FK_rodne_cislo_ditete"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE
);


CREATE TABLE "Aktivita"
(
    "cislo_aktivity" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "typ_aktivity"   VARCHAR(50) NOT NULL,
    "nazev_aktivity" VARCHAR(50) NOT NULL

);

-- zastupuje
CREATE TABLE "Zastupce-Dite"
(
    "rc_zastupce" VARCHAR2(10) NOT NULL,
    "rc_ditete"   VARCHAR2(10) NOT NULL,

    CONSTRAINT "PK_Zastupce-Dite"
        PRIMARY KEY ("rc_zastupce", "rc_ditete"),

    CONSTRAINT "FK_Zastupce-Dite_Dite"
        FOREIGN KEY ("rc_ditete")
        REFERENCES "Dite" ("rodne_cislo_ditete")
        ON DELETE CASCADE,

    CONSTRAINT "FK_Zastupce-Dite_Zastupce"
        FOREIGN KEY ("rc_zastupce")
        REFERENCES "Zakonny_zastupce" ("rodne_cislo_zastupce")
        ON DELETE CASCADE
);

-- TODO skontrolovat DELETE casti
-- TODO skontrolovat CHECK pre e-mail a ine atributy
-- TODO skontrolovat dlzky VARCHAR2
-- TODO skontrolovat a doplnit integritne obmedzenia (hlavne u rodneho cisla)
-- TODO doplnit koment pre dovod postupu generalizacie


----- naplneni tabulek ukazkovymi daty -----

-- TODO