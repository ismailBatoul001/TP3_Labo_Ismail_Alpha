CREATE OR REPLACE PROCEDURE ajouter_projet (
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

  COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002, 'id_projet déjà existant' || SQLERRM);
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, 'Erreur de ajouter_projet: ' || SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE affecter_equipement (
    p_id_affect         IN NUMBER,
    p_id_projet         IN NUMBER,
    p_id_equipement     IN NUMBER,
    p_date_affectation  IN DATE,
    p_duree_jours       IN NUMBER
) IS
BEGIN
    v_disponible := verifier_disponibilite_equipement(p_id_equipement);
    IF v_disponible = FALSE THEN
        RAISE_APPLICATION_ERROR(-20010, 'Équipement non disponible' || SQLERRM);
    END IF;

    INSERT INTO AFFECTATION_EQUIP VALUES (
        p_id_affect, p_id_projet, p_id_equipement,
        p_date_affectation, p_duree_jours
    );
    COMMIT;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20011, 'id_affect déjà existant' || SQLERRM);

  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, 'Erreur affecter_equipement: ' || SQLERRM);
END;
/

