CREATE OR REPLACE PROCEDURE ajouter_projet(
    p_titre IN VARCHAR2,
    p_domaine IN VARCHAR2,
    p_budget IN NUMBER,
    p_date_debut IN DATE,
    p_date_fin IN DATE,
    p_id_chercheur_resp IN NUMBER
) AS
    v_count NUMBER;
    v_count_table NUMBER;
    v_id_projet NUMBER;
    ex_chercheur_inexistant EXCEPTION;
    ex_budget_invalide EXCEPTION;
    ex_dates_invalides EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM CHERCHEUR
    WHERE id_chercheur = p_id_chercheur_resp;

    IF v_count = 0 THEN
        RAISE ex_chercheur_inexistant;
    END IF;

    IF p_budget <= 0 THEN
        RAISE ex_budget_invalide;
    END IF;

    IF p_date_fin < p_date_debut THEN
        RAISE ex_dates_invalides;
    END IF;

    SELECT COUNT(*) INTO v_count_table FROM PROJET;
    IF v_count_table = 0 THEN
        v_id_projet := 1;
    ELSE
        SELECT MAX(id_projet) + 1 INTO v_id_projet FROM PROJET;
    END IF;

    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (v_id_projet, p_titre, p_domaine, p_budget, p_date_debut, p_date_fin, p_id_chercheur_resp);

    journaliser_action('PROJET', 'INSERT', 'Ajout du projet: ' || p_titre);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Projet ajoute avec succes. ID: ' || v_id_projet);

EXCEPTION
    WHEN ex_chercheur_inexistant THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erreur: Le chercheur specifie n''existe pas.');
    WHEN ex_budget_invalide THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Erreur: Le budget doit etre superieur a 0.');
    WHEN ex_dates_invalides THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Erreur: La date de fin doit etre >= a la date de debut.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Erreur lors de l''ajout du projet: ' || SQLERRM);
END ajouter_projet;
/

CREATE OR REPLACE PROCEDURE affecter_equipement(
    p_id_projet IN NUMBER,
    p_id_equipement IN NUMBER,
    p_date_affectation IN DATE,
    p_duree_jours IN NUMBER
) AS
    v_disponible NUMBER;
    v_id_affect NUMBER;
    v_count_projet NUMBER;
    v_count_table NUMBER;
    ex_equipement_indisponible EXCEPTION;
    ex_projet_inexistant EXCEPTION;
    ex_duree_invalide EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_count_projet
    FROM PROJET
    WHERE id_projet = p_id_projet;

    IF v_count_projet = 0 THEN
        RAISE ex_projet_inexistant;
    END IF;

    IF p_duree_jours <= 0 THEN
        RAISE ex_duree_invalide;
    END IF;

    v_disponible := verifier_disponibilite_equipement(p_id_equipement);

    IF v_disponible = 0 THEN
        RAISE ex_equipement_indisponible;
    END IF;

    SELECT COUNT(*) INTO v_count_table FROM AFFECTATION_EQUIP;
    IF v_count_table = 0 THEN
        v_id_affect := 1;
    ELSE
        SELECT MAX(id_affect) + 1 INTO v_id_affect FROM AFFECTATION_EQUIP;
    END IF;

    INSERT INTO AFFECTATION_EQUIP (id_affect, id_projet, id_equipement, date_affectation, duree_jours)
    VALUES (v_id_affect, p_id_projet, p_id_equipement, p_date_affectation, p_duree_jours);

    journaliser_action('AFFECTATION_EQUIP', 'INSERT',
                      'Affectation equipement ' || p_id_equipement || ' au projet ' || p_id_projet);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Equipement affecte avec succes. ID affectation: ' || v_id_affect);

EXCEPTION
    WHEN ex_projet_inexistant THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20010, 'Erreur: Le projet specifie n''existe pas.');
    WHEN ex_equipement_indisponible THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20011, 'Erreur: L''equipement n''est pas disponible.');
    WHEN ex_duree_invalide THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20012, 'Erreur: La duree doit etre superieure a 0.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20098, 'Erreur lors de l''affectation: ' || SQLERRM);
END affecter_equipement;
/

CREATE OR REPLACE PROCEDURE planifier_experience(
    p_id_projet IN NUMBER,
    p_titre_exp IN VARCHAR2,
    p_date_realisation IN DATE,
    p_statut IN VARCHAR2 DEFAULT 'En cours',
    p_id_equipement IN NUMBER DEFAULT NULL,
    p_duree_jours IN NUMBER DEFAULT NULL
) AS
    v_id_exp NUMBER;
    v_count_projet NUMBER;
    v_count_table NUMBER;
    ex_projet_inexistant EXCEPTION;
    ex_statut_invalide EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_count_projet
    FROM PROJET
    WHERE id_projet = p_id_projet;

    IF v_count_projet = 0 THEN
        RAISE ex_projet_inexistant;
    END IF;

    IF p_statut NOT IN ('En cours', 'Terminee', 'Annulee') THEN
        RAISE ex_statut_invalide;
    END IF;

    SELECT COUNT(*) INTO v_count_table FROM EXPERIENCE;
    IF v_count_table = 0 THEN
        v_id_exp := 1;
    ELSE
        SELECT MAX(id_exp) + 1 INTO v_id_exp FROM EXPERIENCE;
    END IF;

    INSERT INTO EXPERIENCE (id_exp, id_projet, titre_exp, date_realisation, statut)
    VALUES (v_id_exp, p_id_projet, p_titre_exp, p_date_realisation, p_statut);

    DBMS_OUTPUT.PUT_LINE('Experience creee avec succes. ID: ' || v_id_exp);

    SAVEPOINT avant_affectation_equipement;

    IF p_id_equipement IS NOT NULL THEN
        BEGIN
            affecter_equipement(
                p_id_projet => p_id_projet,
                p_id_equipement => p_id_equipement,
                p_date_affectation => p_date_realisation,
                p_duree_jours => p_duree_jours
            );

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO avant_affectation_equipement;
                DBMS_OUTPUT.PUT_LINE('ATTENTION: Impossible d''affecter l''equipement.');
                DBMS_OUTPUT.PUT_LINE('Raison: ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('L''experience a ete creee sans affectation d''equipement.');
        END;
    END IF;

    journaliser_action('EXPERIENCE', 'INSERT', 'Planification experience: ' || p_titre_exp || ' pour projet ' || p_id_projet);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Planification de l''experience terminee avec succes.');

EXCEPTION
    WHEN ex_projet_inexistant THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20020, 'Erreur: Le projet specifie n''existe pas.');
    WHEN ex_statut_invalide THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20021, 'Erreur: Statut invalide. Valeurs acceptees: En cours, Terminee, Annulee.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20097, 'Erreur lors de la planification: ' || SQLERRM);
END planifier_experience;
/

CREATE OR REPLACE PROCEDURE supprimer_projet(
    p_id_projet IN NUMBER
) AS
    v_count NUMBER;
    v_nb_experiences NUMBER := 0;
    v_nb_affectations NUMBER := 0;
    v_nb_echantillons NUMBER := 0;

    CURSOR c_experiences IS
        SELECT id_exp
        FROM EXPERIENCE
        WHERE id_projet = p_id_projet
        FOR UPDATE;

    CURSOR c_affectations IS
        SELECT id_affect, id_equipement
        FROM AFFECTATION_EQUIP
        WHERE id_projet = p_id_projet
        FOR UPDATE;

    ex_projet_inexistant EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM PROJET
    WHERE id_projet = p_id_projet;

    IF v_count = 0 THEN
        RAISE ex_projet_inexistant;
    END IF;

    FOR exp_rec IN c_experiences LOOP
        DELETE FROM ECHANTILLON
        WHERE id_exp = exp_rec.id_exp;

        v_nb_echantillons := v_nb_echantillons + SQL%ROWCOUNT;
    END LOOP;

    DELETE FROM EXPERIENCE
    WHERE id_projet = p_id_projet;
    v_nb_experiences := SQL%ROWCOUNT;

    FOR affect_rec IN c_affectations LOOP
        UPDATE EQUIPEMENT
        SET etat = 'Disponible'
        WHERE id_equipement = affect_rec.id_equipement;

        DELETE FROM AFFECTATION_EQUIP
        WHERE CURRENT OF c_affectations;

        v_nb_affectations := v_nb_affectations + 1;
    END LOOP;

    DELETE FROM PROJET
    WHERE id_projet = p_id_projet;

    journaliser_action('PROJET', 'DELETE', 'Suppression du projet ' || p_id_projet || ' avec ' || v_nb_experiences || ' experiences et ' || v_nb_affectations || ' affectations');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Projet supprime avec succes.');

EXCEPTION
    WHEN ex_projet_inexistant THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20030, 'Erreur: Le projet specifie n''existe pas.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20096, 'Erreur lors de la suppression du projet: ' || SQLERRM);
END supprimer_projet;
/

CREATE OR REPLACE PROCEDURE journaliser_action(
    p_table_concernee IN VARCHAR2,
    p_operation IN VARCHAR2,
    p_description IN VARCHAR2
) AS
    v_id_log NUMBER;
    v_utilisateur VARCHAR2(100);
    v_count_table NUMBER;
BEGIN
    v_utilisateur := USER;

    SELECT COUNT(*) INTO v_count_table FROM LOG_OPERATION;
    IF v_count_table = 0 THEN
        v_id_log := 1;
    ELSE
        SELECT MAX(id_log) + 1 INTO v_id_log FROM LOG_OPERATION;
    END IF;

    INSERT INTO LOG_OPERATION (id_log, table_concernee, operation, utilisateur, date_op, description)
    VALUES (v_id_log, p_table_concernee, UPPER(p_operation), v_utilisateur, SYSDATE, p_description);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Echec de journalisation - ' || SQLERRM);
END journaliser_action;
/