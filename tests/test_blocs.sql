--Bloc de test pour la procédure ajouter_projet
SET SERVEROUTPUT ON;

DECLARE
  v_id_chercheur NUMBER := 9983;
BEGIN
  INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche)
  VALUES (v_id_chercheur, 'BATOUL', 'ISMAIL', 'IA', SYSDATE);

  ajouter_projet(7364, 'Projet Test', 'IA', 10000, SYSDATE, SYSDATE+30, v_id_chercheur);
  DBMS_OUTPUT.PUT_LINE('Projet ajouté avec succès.');

  ROLLBACK;
END;
/

--Bloc de test pour la procédure affecter_equipement
SET SERVEROUTPUT ON;

DECLARE
  p_id_projet NUMBER := 8201;
  p_id_equipement NUMBER := 6201;
BEGIN
    INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche)
    VALUES (9001, 'BATOUL', 'ISMAIL', 'IA', SYSDATE);

    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (p_id_projet, 'Projet Equipement Test', 'Physique', 20000, SYSDATE, SYSDATE+60, 9001);

    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (p_id_equipement, 'Equipement Test', 'Aventure', SYSDATE, 'Disponible');

    affecter_equipement(8201, p_id_projet, p_id_equipement, SYSDATE, 15);
    DBMS_OUTPUT.PUT_LINE('Affectation de l''équipement réussie.');

    ROLLBACK;
END;
/

--Bloc de test pour la fonction calculer_duree_projet
SET SERVEROUTPUT ON;

DECLARE
  v_id_projet NUMBER := 8101;
  v_duree     NUMBER;
BEGIN
  INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
  VALUES (v_id_projet, 'Projet Durée', 'Chimie', 15000, SYSDATE, SYSDATE+45, 1);

  v_duree := calculer_duree_projet(v_id_projet);
  DBMS_OUTPUT.PUT_LINE('Durée du projet (en jours) : ' || v_duree);

  ROLLBACK;
END;
/

--Bloc de test pour la fonction verifier_disponibilite_equipement
SET SERVEROUTPUT ON;
DECLARE
  v_id_equipement NUMBER := 5101;
  v_disponibilite NUMBER;
BEGIN
    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (v_id_equipement, 'Equipement Disponibilité', 'Biotech', SYSDATE, 'Disponible');

    v_disponibilite := verifier_disponibilite_equipement(v_id_equipement);
    IF v_disponibilite = 1 THEN
      DBMS_OUTPUT.PUT_LINE('Disponibilité avant affectation: TRUE');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Disponibilité avant affectation: FALSE');
    END IF;

    ROLLBACK;
END;
/
-- Test Procédure planifier_experience
SET SERVEROUTPUT ON;

DECLARE
    v_id_projet NUMBER := 9001;
    v_id_exp NUMBER := 9001;
    v_id_equipement NUMBER := 9001;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet, 'Projet Test Planification', 'Biotech', 30000, SYSDATE, SYSDATE+90, 1);

    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (v_id_equipement, 'Equipement Test Plan', 'Analyse', SYSDATE, 'Disponible');

    planifier_experience(
        p_id_exp => v_id_exp,
        p_id_projet => v_id_projet,
        p_titre_exp => 'Expérience Test SAVEPOINT',
        p_date_realisation => SYSDATE,
        p_id_equipement => v_id_equipement,
        p_duree_jours => 15
    );


    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/


-- Test Procédure supprimer_projet
SET SERVEROUTPUT ON;

DECLARE
    v_id_projet NUMBER := 9002;
    v_id_exp NUMBER := 9002;
    v_id_echantillon NUMBER := 9002;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet, 'Projet à Supprimer', 'Chimie', 20000, SYSDATE, SYSDATE+60, 2);

    INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (v_id_exp, v_id_projet, 'Exp à Supprimer', SYSDATE, 'En cours');

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (v_id_echantillon, v_id_exp, 'Échantillon Test', SYSDATE, 25.5);

    supprimer_projet(v_id_projet);


    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Procédure journaliser_action
SET SERVEROUTPUT ON;

DECLARE
    v_count_avant NUMBER;
    v_count_apres NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_avant FROM LOG_OPERATION;
    DBMS_OUTPUT.PUT_LINE('Nombre de logs avant : ' || v_count_avant);

    journaliser_action(
        p_table_concernee => 'TEST_TABLE',
        p_operation => 'INSERT',
        p_description => 'Test manuel de journalisation'
    );

    SELECT COUNT(*) INTO v_count_apres FROM LOG_OPERATION;
    DBMS_OUTPUT.PUT_LINE('Nombre de logs après : ' || v_count_apres);

    IF v_count_apres > v_count_avant THEN
        DBMS_OUTPUT.PUT_LINE('Journalisation réussie (' || (v_count_apres - v_count_avant) || ' entrée ajoutée)');
    END IF;

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Fonction moyenne_mesures_experience
SET SERVEROUTPUT ON;

DECLARE
    v_id_projet NUMBER := 9003;
    v_id_exp NUMBER := 9003;
    v_moyenne NUMBER;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet, 'Projet Test Moyenne', 'Physique', 25000, SYSDATE, SYSDATE+60, 3);

    INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (v_id_exp, v_id_projet, 'Exp Test Moyenne', SYSDATE, 'Terminée');

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (9003, v_id_exp, 'Éch 1', SYSDATE, 10.5);

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (9004, v_id_exp, 'Éch 2', SYSDATE, 15.5);

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (9005, v_id_exp, 'Éch 3', SYSDATE, 20.0);


    v_moyenne := moyenne_mesures_experience(v_id_exp);

    IF v_moyenne IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Moyenne calculée : ' || ROUND(v_moyenne, 2));
    ELSE
    END IF;

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Fonction statistiques_equipements
SET SERVEROUTPUT ON;

DECLARE
    v_cursor SYS_REFCURSOR;
    v_etat VARCHAR2(100);
    v_nombre NUMBER;
    v_id_equip1 NUMBER := 9006;
    v_id_equip2 NUMBER := 9007;
    v_id_equip3 NUMBER := 9008;
BEGIN
    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (v_id_equip1, 'Equip Test 1', 'Test', SYSDATE, 'Disponible');

    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (v_id_equip2, 'Equip Test 2', 'Test', SYSDATE, 'En maintenance');

    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (v_id_equip3, 'Equip Test 3', 'Test', SYSDATE, 'Disponible');

    v_cursor := statistiques_equipements();

    LOOP
        FETCH v_cursor INTO v_etat, v_nombre;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  ' || v_etat || ' : ' || v_nombre || ' équipement(s)');
    END LOOP;
    CLOSE v_cursor;

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Fonction budget_moyen_par_domaine
SET SERVEROUTPUT ON;

DECLARE
    v_id_projet1 NUMBER := 9004;
    v_id_projet2 NUMBER := 9005;
    v_id_projet3 NUMBER := 9006;
    v_budget_moyen NUMBER;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet1, 'Projet IA 1', 'IA', 100000, SYSDATE, SYSDATE+60, 2);

    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet2, 'Projet IA 2', 'IA', 200000, SYSDATE, SYSDATE+60, 2);

    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet3, 'Projet Biotech 1', 'Biotech', 300000, SYSDATE, SYSDATE+60, 1);

    v_budget_moyen := budget_moyen_par_domaine();

    DBMS_OUTPUT.PUT_LINE('Budget moyen par domaine calculé : ' || v_budget_moyen || ' $');

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test Procédure rapport_activite_projets
SET SERVEROUTPUT ON;

DECLARE
    v_id_projet NUMBER := 9007;
    v_id_exp1 NUMBER := 9009;
    v_id_exp2 NUMBER := 9010;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet, 'Projet Test Rapport', 'Mathématiques', 50000, SYSDATE, SYSDATE+90, 5);

    INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (v_id_exp1, v_id_projet, 'Exp Test 1', SYSDATE, 'Terminée');

    INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (v_id_exp2, v_id_projet, 'Exp Test 2', SYSDATE, 'En cours');

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (9009, v_id_exp1, 'Test', SYSDATE, 30.0);

    INSERT INTO ECHANTILLON (id_echantillon, id_exp, type_echantillon, date_prelevement, mesure)
    VALUES (9010, v_id_exp1, 'Test', SYSDATE, 40.0);


    rapport_activite_projets();

    ROLLBACK;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : ' || SQLERRM);
        ROLLBACK;
END;
/