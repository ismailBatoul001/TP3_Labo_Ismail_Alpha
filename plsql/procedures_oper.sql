CREATE OR REPLACE PROCEDURE ajouter_projet(
  p_id_projet        IN NUMBER,
  p_titre            IN VARCHAR2,
  p_domaine          IN VARCHAR2,
  p_budget           IN NUMBER,
  p_date_debut       IN DATE,
  p_date_fin         IN DATE,
  p_id_chercheur_resp IN NUMBER
) IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM CHERCHEUR
  WHERE id_chercheur = p_id_chercheur_resp;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Chercheur inexistant' || SQLERRM);
  END IF;

  INSERT INTO PROJET VALUES (
    p_id_projet, p_titre, p_domaine, p_budget,
    p_date_debut, p_date_fin, p_id_chercheur_resp
  );

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002, 'id_projet déjà existant' || SQLERRM);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, 'Erreur de ajouter_projet: ' || SQLERRM);
END ajouter_projet;
/

CREATE OR REPLACE PROCEDURE affecter_equipement(
    p_id_affect         IN NUMBER,
    p_id_projet         IN NUMBER,
    p_id_equipement     IN NUMBER,
    p_date_affectation  IN DATE,
    p_duree_jours       IN NUMBER
) IS
    v_disponible NUMBER;
BEGIN
    v_disponible := verifier_disponibilite_equipement(p_id_equipement);
    IF v_disponible = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Équipement non disponible' || SQLERRM);
    END IF;

    INSERT INTO AFFECTATION_EQUIP VALUES (
        p_id_affect, p_id_projet, p_id_equipement,
        p_date_affectation, p_duree_jours
    );
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20011, 'id_affect déjà existant' || SQLERRM);

  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, 'Erreur affecter_equipement: ' || SQLERRM);
END affecter_equipement;
/

CREATE OR REPLACE PROCEDURE planifier_experience (
    p_id_exp            IN NUMBER,
    p_id_projet         IN NUMBER,
    p_titre_exp         IN VARCHAR2,
    p_date_realisation  IN DATE,
    p_id_equipement     IN NUMBER DEFAULT NULL,
    p_duree_jours       IN NUMBER DEFAULT NULL
) IS
    v_disponible NUMBER;
BEGIN
    INSERT INTO EXPERIENCE (
        id_exp,
        id_projet,
        titre_exp,
        date_realisation,
        resultat,
        statut
    ) VALUES (
        p_id_exp,
        p_id_projet,
        p_titre_exp,
        p_date_realisation,
        NULL,
        'En cours'
    );

    journaliser_action('EXPERIENCE', 'INSERT', 'Nouvelle expérience: ' || p_titre_exp);

    IF p_id_equipement IS NOT NULL THEN

        SAVEPOINT avant_affectation;

        BEGIN
            v_disponible := verifier_disponibilite_equipement(p_id_equipement);

            IF v_disponible = 0 THEN
                RAISE_APPLICATION_ERROR(-20040, 'Équipement non disponible');
            END IF;

            INSERT INTO AFFECTATION_EQUIP (
                id_projet,
                id_equipement,
                date_affectation,
                duree_jours
            ) VALUES (
                p_id_projet,
                p_id_equipement,
                p_date_realisation,
                p_duree_jours
            );

        EXCEPTION
            WHEN OTHERS THEN

                ROLLBACK TO avant_affectation;
                DBMS_OUTPUT.PUT_LINE('Avertissement: Équipement non affecté - ' || SQLERRM);
        END;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20041, 'Erreur planifier_experience: ' || SQLERRM);
END planifier_experience;
/


CREATE OR REPLACE PROCEDURE supprimer_projet (
    p_id_projet IN NUMBER
) IS
    CURSOR c_experiences IS
        SELECT id_exp
        FROM EXPERIENCE
        WHERE id_projet = p_id_projet
        FOR UPDATE;

    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM PROJET
    WHERE id_projet = p_id_projet;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20050, 'Projet inexistant');
    END IF;

    FOR exp_rec IN c_experiences LOOP
        DELETE FROM ECHANTILLON
        WHERE id_exp = exp_rec.id_exp;

        DBMS_OUTPUT.PUT_LINE('Échantillons supprimés pour expérience ' || exp_rec.id_exp);
    END LOOP;

    DELETE FROM EXPERIENCE
    WHERE id_projet = p_id_projet;

    DELETE FROM AFFECTATION_EQUIP
    WHERE id_projet = p_id_projet;

    DELETE FROM PROJET
    WHERE id_projet = p_id_projet;

    journaliser_action('PROJET', 'DELETE', 'Projet supprimé: ' || p_id_projet);

    DBMS_OUTPUT.PUT_LINE('Projet ' || p_id_projet || ' supprimé avec succès');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20051, 'Erreur supprimer_projet: ' || SQLERRM);
END supprimer_projet;
/


CREATE OR REPLACE PROCEDURE journaliser_action (
    p_table_concernee IN VARCHAR2,
    p_operation       IN VARCHAR2,
    p_description     IN VARCHAR2 DEFAULT NULL
) IS
BEGIN
    INSERT INTO LOG_OPERATION (
        table_concernee,
        operation,
        utilisateur,
        date_op,
        description
    ) VALUES (
        p_table_concernee,
        p_operation,
        USER,
        SYSDATE,
        p_description
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20030, 'Erreur journaliser_action: ' || SQLERRM);
END journaliser_action;
/

