SET SERVEROUTPUT ON

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CHERCHEUR CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table CHERCHEUR inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE CHERCHEUR (
  id_chercheur    NUMBER PRIMARY KEY,
  nom             VARCHAR2(100) NOT NULL,
  prenom          VARCHAR2(100) NOT NULL,
  specialite      VARCHAR2(50) NOT NULL,
  date_embauche   DATE NOT NULL,

  CONSTRAINT ck_chercheur_specialite CHECK (specialite IN (''Biotech'', ''IA'', ''Physique'', ''Chimie'', ''Mathématiques'', ''Autre''))
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de CHERCHEUR : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PROJET CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table PROJET inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE PROJET (
  id_projet  NUMBER PRIMARY KEY,
  titre      VARCHAR2(100) NOT NULL,
  domaine    VARCHAR2(100) NOT NULL,
  budget     NUMBER NOT NULL,
  date_debut DATE NOT NULL,
  date_fin   DATE NOT NULL,
  id_chercheur_resp NUMBER NOT NULL,

  CONSTRAINT ck_projet_budget CHECK (budget > 0),
  CONSTRAINT ck_projet_dates CHECK (date_fin > date_debut),
  CONSTRAINT fk_projet_chercheur FOREIGN KEY (id_chercheur_resp) REFERENCES CHERCHEUR(id_chercheur)
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de PROJET : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE EQUIPEMENT CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table EQUIPEMENT inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE EQUIPEMENT (
  id_equipement NUMBER PRIMARY KEY,
  nom              VARCHAR2(100) NOT NULL,
  categorie        VARCHAR2(100) NOT NULL,
  date_acquisition DATE NOT NULL,
  etat             VARCHAR2(100) DEFAULT ''Disponible'' NOT NULL

  CONSTRAINT ck_equipement_etat CHECK (etat IN (''Disponible'', ''En maintenance'', ''Hors service''))
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de EQUIPEMENT : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE AFFECTATION_EQUIP CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table AFFECTATION_EQUIP inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE AFFECTATION_EQUIP (
  id_affect         NUMBER PRIMARY KEY,
  id_projet         NUMBER NOT NULL,
  id_equipement     NUMBER NOT NULL,
  date_affectation  DATE NOT NULL,
  duree_jours       NUMBER NOT NULL,

  CONSTRAINT ck_affectation_duree CHECK (duree_jours > 0),
  CONSTRAINT fk_affectation_projet FOREIGN KEY (id_projet) REFERENCES PROJET(id_projet),
  CONSTRAINT fk_affectation_equipement FOREIGN KEY (id_equipement) REFERENCES EQUIPEMENT(id_equipement)
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de AFFECTATION_EQUIP : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE EXPERIENCE CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table EXPERIENCE inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE EXPERIENCE (
  id_exp            NUMBER PRIMARY KEY,
  id_projet         NUMBER NOT NULL,
  titre_exp         VARCHAR2(200) NOT NULL,
  date_realisation  DATE NOT NULL,
  resultat          VARCHAR2(500),
  statut            VARCHAR2(20) DEFAULT ''En cours'' NOT NULL,

  CONSTRAINT ck_experience_statut CHECK (statut IN (''En cours'', ''Terminée'', ''Annulée'')),
  CONSTRAINT fk_experience_projet FOREIGN KEY (id_projet) REFERENCES PROJET(id_projet)
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de EXPERIENCE : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ECHANTILLON CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table ECHANTILLON inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE ECHANTILLON (
  id_echantillon      NUMBER PRIMARY KEY,
  id_exp              NUMBER NOT NULL,
  type_echantillon    VARCHAR2(100) NOT NULL,
  date_prelevement    DATE NOT NULL,
  mesure              NUMBER NOT NULL,

  CONSTRAINT ck_echantillon_mesure CHECK (mesure >= 0),
  CONSTRAINT ck_echantillon_type CHECK (type_echantillon IS NOT NULL),
  CONSTRAINT fk_echantillon_experience FOREIGN KEY (id_exp) REFERENCES EXPERIENCE(id_exp)
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de ECHANTILLON : ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE LOG_OPERATION CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('Table LOG_OPERATION inexistante.');
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    CREATE TABLE LOG_OPERATION (
  id_log            NUMBER PRIMARY KEY,
  table_concernee   VARCHAR2(50) NOT NULL,
  operation         VARCHAR2(10) NOT NULL,
  utilisateur       VARCHAR2(50) DEFAULT USER NOT NULL,
  date_op           DATE DEFAULT SYSDATE NOT NULL,
  description       VARCHAR2(500),

  CONSTRAINT ck_log_operation CHECK (operation IN (''INSERT'', ''UPDATE'', ''DELETE''))
)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erreur lors de la création de LOG_OPERATION : ' || SQLERRM);
END;
/