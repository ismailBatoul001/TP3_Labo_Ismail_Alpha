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

CREATE OR REPLACE PROCEDURE rapport_activite_projets
IS
    v_nb_experiences NUMBER;
    v_nb_terminees NUMBER;
    v_taux_reussite NUMBER;
    v_moyenne_mesures NUMBER;
BEGIN
    FOR proj IN (
        SELECT
            p.id_projet,
            p.titre,
            p.domaine,
            p.budget
        FROM PROJET p
        ORDER BY p.titre
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('--- Projet: ' || proj.titre || ' ---');
        DBMS_OUTPUT.PUT_LINE('Domaine: ' || proj.domaine);
        DBMS_OUTPUT.PUT_LINE('Budget: ' || proj.budget || ' $');

        SELECT COUNT(*)
        INTO v_nb_experiences
        FROM EXPERIENCE
        WHERE id_projet = proj.id_projet;

        SELECT COUNT(*)
        INTO v_nb_terminees
        FROM EXPERIENCE
        WHERE id_projet = proj.id_projet
        AND statut = 'Terminée';

        DBMS_OUTPUT.PUT_LINE('Nombre d''expériences: ' || v_nb_experiences);
        DBMS_OUTPUT.PUT_LINE('Expériences terminées: ' || v_nb_terminees);

        IF v_nb_experiences > 0 THEN
            v_taux_reussite := ROUND((v_nb_terminees / v_nb_experiences) * 100, 2);
            DBMS_OUTPUT.PUT_LINE('Taux de réussite: ' || v_taux_reussite || '%');

            FOR exp IN (
                SELECT id_exp, titre_exp
                FROM EXPERIENCE
                WHERE id_projet = proj.id_projet
                AND statut = 'Terminée'
            ) LOOP
                v_moyenne_mesures := moyenne_mesures_experience(exp.id_exp);
                IF v_moyenne_mesures IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE('  └─ ' || exp.titre_exp ||
                                       ' | Moyenne mesures: ' ||
                                       ROUND(v_moyenne_mesures, 2));
                END IF;
            END LOOP;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Aucune expérience enregistrée');
        END IF;

        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20070, 'Erreur rapport_activite_projets: ' || SQLERRM);
END rapport_activite_projets;
/


CREATE OR REPLACE FUNCTION budget_moyen_par_domaine
RETURN NUMBER
IS
    TYPE budget_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    v_budgets budget_tab;

    TYPE count_tab IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    v_counts count_tab;

    v_domaine VARCHAR2(100);
    v_total_moyenne NUMBER := 0;
    v_nb_domaines NUMBER := 0;
BEGIN
    FOR proj IN (SELECT domaine, budget FROM PROJET) LOOP
        IF v_budgets.EXISTS(proj.domaine) THEN
            v_budgets(proj.domaine) := v_budgets(proj.domaine) + proj.budget;
            v_counts(proj.domaine) := v_counts(proj.domaine) + 1;
        ELSE
            v_budgets(proj.domaine) := proj.budget;
            v_counts(proj.domaine) := 1;
        END IF;
    END LOOP;

    v_domaine := v_budgets.FIRST;

    WHILE v_domaine IS NOT NULL LOOP
        v_total_moyenne := v_total_moyenne + (v_budgets(v_domaine) / v_counts(v_domaine));
        v_nb_domaines := v_nb_domaines + 1;
        v_domaine := v_budgets.NEXT(v_domaine);
    END LOOP;

    IF v_nb_domaines > 0 THEN
        RETURN ROUND(v_total_moyenne / v_nb_domaines, 2);
    ELSE
        RETURN 0;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20080, 'Erreur budget_moyen_par_domaine: ' || SQLERRM);
END budget_moyen_par_domaine;
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
