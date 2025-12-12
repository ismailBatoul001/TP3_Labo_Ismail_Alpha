CREATE OR REPLACE FUNCTION statistiques_equipements
RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT
            etat,
            COUNT(*) as nombre_equipements
        FROM EQUIPEMENT
        GROUP BY etat
        ORDER BY etat;

    RETURN v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20060, 'Erreur statistiques_equipements: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE rapport_projets_par_chercheur(
    p_id_chercheur IN NUMBER
)
IS
    v_nom_chercheur VARCHAR2(100);
    v_prenom_chercheur VARCHAR2(100);
    v_specialite VARCHAR2(50);
    v_budget_total NUMBER := 0;
    v_nb_projets NUMBER := 0;
    v_chercheur_existe NUMBER;

BEGIN
    BEGIN
        SELECT COUNT(*)
        INTO v_chercheur_existe
        FROM CHERCHEUR
        WHERE id_chercheur = p_id_chercheur;

        IF v_chercheur_existe = 0 THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Erreur: Aucun chercheur trouvé avec l''ID ' || p_id_chercheur);
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Erreur: Aucun chercheur trouvé avec l''ID ' || p_id_chercheur);
    END;

    SELECT nom, prenom, specialite
    INTO v_nom_chercheur, v_prenom_chercheur, v_specialite
    FROM CHERCHEUR
    WHERE id_chercheur = p_id_chercheur;

    DBMS_OUTPUT.PUT_LINE('Rapport des projets pour le chercheur: ' || v_nom_chercheur || ' ' || v_prenom_chercheur || ' (' || v_specialite || ')');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('----------------- Liste des projets --------------');

    FOR projet IN (
        SELECT
            titre,
            domaine,
            budget,
            date_debut,
            date_fin,
            (date_fin - date_debut) AS duree_jours
        FROM PROJET
        WHERE id_chercheur_resp = p_id_chercheur
        ORDER BY date_debut DESC
    ) LOOP
        v_nb_projets := v_nb_projets + 1;
        v_budget_total := v_budget_total + projet.budget;

        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Projet #' || v_nb_projets);
        DBMS_OUTPUT.PUT_LINE('  Titre: ' || projet.titre);
    END LOOP;

    IF v_nb_projets = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucun projet trouvé pour ce chercheur.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Nombre total de projets: ' || v_nb_projets);
        DBMS_OUTPUT.PUT_LINE('Budget total alloué: ' || v_budget_total);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erreur: Aucun chercheur trouvé avec l''ID ' || p_id_chercheur);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur lors de la génération du rapport: ' || SQLERRM);
END rapport_projets_par_chercheur;
/
