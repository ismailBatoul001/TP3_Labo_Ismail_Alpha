CREATE OR REPLACE FUNCTION calculer_duree_projet(
    p_id_projet IN NUMBER
) RETURN NUMBER
IS
  v_date_debut DATE;
  v_date_fin DATE;
  v_duree NUMBER;
BEGIN
    SELECT date_debut, date_fin
    INTO v_date_debut, v_date_fin
    FROM PROJET
    WHERE id_projet = p_id_projet

    v_duree := v_date_fin - v_date_debut;

    RETURN v_duree;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Projet inexistant');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Erreur calculer_duree_projet: ' || SQLERRM);
END calculer_duree_projet;
/

CREATE OR REPLACE FUNCTION verifier_disponibilite_equipement(
    p_id_equipement IN NUMBER
) RETURN NUMBER
IS
    TYPE affect_rec IS RECORD (
        id_affect        NUMBER,
        id_projet        NUMBER,
        date_affectation DATE,
        duree_jours      NUMBER
    );

    TYPE affect_tab IS TABLE OF affect_rec;
    v_affectations affect_tab;

    v_etat VARCHAR2;
    v_dispo_return NUMBER := 1;
BEGIN
    SELECT etat
    INTO v_etat
    FROM EQUIPEMENT
    WHERE id_equipement = p_id_equipement;

    IF v_etat != 'Disponible' THEN
        v_dispo_return := 0;
        RETURN v_dispo_return;
    END IF;

    SELECT id_affect, id_projet, date_affectation, duree_jours
    BULK COLLECT INTO v_affectations
    FROM AFFECTATION_EQUIP
    WHERE id_equipement = p_id_equipement;

    FOR i IN 1 .. v_affectations.COUNT LOOP
        IF SYSDATE >= v_affectations(i).date_affectation
        AND
        SYSDATE <= (v_affectations(i).date_affectation + v_affectations(i).duree_jours)
        THEN
            v_dispo_return := 0;
        END IF;
    END LOOP;

    RETURN v_dispo_return;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20021, 'Équipement inexistant');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Erreur verifier_disponibilite_equipement: ' || SQLERRM);
END verifier_disponibilite_equipement;
/

CREATE OR REPLACE FUNCTION moyenne_mesures_experience(
    p_id_exp IN NUMBER
) RETURN NUMBER
IS
    v_moyenne NUMBER;
BEGIN
    SELECT AVG(mesure)
    INTO v_moyenne
    FROM ECHANTILLON
    WHERE id_exp = p_id_exp;

    RETURN v_moyenne;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20022, 'Erreur moyenne_mesures_experience: ' || SQLERRM);
END moyenne_mesures_experience;
/
