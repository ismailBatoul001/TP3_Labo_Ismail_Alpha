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
    RAISE_APPLICATION_ERROR(-20001, 'Chercheur inexistant');
  END IF;

  INSERT INTO PROJET VALUES (
    p_id_projet, p_titre, p_domaine, p_budget,
    p_date_debut, p_date_fin, p_id_chercheur_resp
  );

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, 'Erreur de ajouter_projet: ' || SQLERRM);
END;
/


