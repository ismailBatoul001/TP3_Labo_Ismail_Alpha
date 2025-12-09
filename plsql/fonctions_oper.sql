CREATE OR REPLACE FUNCTION calculer_duree_projet(
    p_id_projet IN NUMBER
) RETURN NUMBER
IS
  v_date_debut DATE;
  v_date_fin DATE;
  v_duree NUMBER;
BEGIN
    SELECT date_debut, date_fin
    INTO v_date_debut, v_date_fin;
    FROM PROJET
    WHERE id_projet = p_id_projet

    v_duree := v_date_fin - v_date_debut;

    RETURN v_duree;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20020, 'Projet inexistant' || SQLERRM);
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Erreur calculer_duree_projet: ' || SQLERRM);
END;
