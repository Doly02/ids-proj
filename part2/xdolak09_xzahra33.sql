-- 2. část - SQL skript pro vytvoření objektů schématu databáze
-- Téma Školka
-- Autor: Tomáš Dolák (xdolak09)
-- Autor: Monika Záhradníková (xzahra33)


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
    "jmeno" VARCHAR2(50) NOT NULL,
    "prijmeni" VARCHAR2(50) NOT NULL,
    "datum_narozeni" DATE NOT NULL,
    "pohlavi" VARCHAR2(10) CHECK ("pohlavi" IN ('muž', 'žena')),
    "adresa" VARCHAR2(100) NOT NULL,
    "telefonni_cislo" VARCHAR2(20),
    "e-mail" VARCHAR2(100)
        -- TODO CHECK ( REGEXP_LIKE("e-mail", '^regex$') )

    CONSTRAINT kontakt_neprazdny
        CHECK ("telefonni_cislo" IS NOT NULL OR "e-mail" IS NOT NULL)
);


CREATE TABLE "Pedagogicky_pracovnik" (
    "rodne_cislo" VARCHAR2(10) NOT NULL,

    CONSTRAINT "Pedagogicky_pracovnik_PK"
        PRIMARY KEY ("rodne_cislo"),

    CONSTRAINT "Pedagogicky_pracovnik_Osoba_FK"
        FOREIGN KEY ("rodne_cislo")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Dite" (
    "rodne_cislo" VARCHAR2(10) NOT NULL,
    "datum_nastupu" DATE NOT NULL,
    "datum_ukonceni" DATE,

    CONSTRAINT "PK_Dite"
        PRIMARY KEY ("rodne_cislo"),

    CONSTRAINT "FK_Dite_Osoba"
        FOREIGN KEY ("rodne_cislo")
        REFERENCES "Osoba" ("rodne_cislo")
        ON DELETE CASCADE
);


CREATE TABLE "Trida" (
    "cislo_tridy" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY, -- automaticke generovani hodnot primarniho klíče
    "oznaceni" VARCHAR2(20) NOT NULL,
    "kmenova_ucebna" VARCHAR2(20)
);


CREATE TABLE "Funkce" (
    "cislo_funkce" INT GENERATED AS IDENTITY PRIMARY KEY,  -- TODO mame v diagrame, rozmyslam, ci nam to treba
    "cislo_tridy" INT NOT NULL,
    "rodne_cislo_pedag_pracovnika" VARCHAR2(10) NOT NULL,

    CONSTRAINT "FK_cislo_tridy"
        FOREIGN KEY ("cislo_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE CASCADE,

    CONSTRAINT "FK_rodne_cislo_pedag_pracovnika"
        FOREIGN KEY ("rodne_cislo_pedag_pracovnika")
        REFERENCES "Pedagogicky_pracovnik" ("rodne_cislo")
        ON DELETE CASCADE,

    "název" VARCHAR2(30) NOT NULL,
    "datum_zacatku" DATE NOT NULL,
    "datum_ukonceni" DATE
);


CREATE TABLE "Dite-Trida" (
    "rodne_cislo" VARCHAR2(10) NOT NULL,
    "cislo_tridy" INT NOT NULL,

    CONSTRAINT "PK_Dite-Trida"
        PRIMARY KEY ("rodne_cislo", "cislo_tridy"),

    CONSTRAINT "FK_Dite-Trida_Dite"
        FOREIGN KEY ("rodne_cislo")
        REFERENCES "Dite" ("rodne_cislo")
        ON DELETE SET NULL,

    CONSTRAINT "FK_Dite-Trida_Trida"
        FOREIGN KEY ("cislo_tridy")
        REFERENCES "Trida" ("cislo_tridy")
        ON DELETE SET NULL
)


-- TODO skontrolovat DELETE casti
-- TODO skontrolovat CHECK pre e-mail a ine atributy
-- TODO skontrolovat dlzky VARCHAR2
-- TODO skontrolovat a doplnit integritne obmedzenia (hlavne u rodneho cisla)
-- TODO doplnit koment pre dovod postupu generalizacie


----- naplneni tabulek ukazkovymi daty -----

-- TODO