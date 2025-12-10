--Bloc de test pour la procédure ajouter_projet
SET SERVEROUTPUT ON;

DECLARE
  v_id_chercheur NUMBER := 9001;
BEGIN
  INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche)
  VALUES (v_id_chercheur, 'BATOUL', 'ISMAIL', 'IA', SYSDATE);

  ajouter_projet(7001, 'Projet Test', 'IA', 10000, SYSDATE, SYSDATE+30, v_id_chercheur);
  DBMS_OUTPUT.PUT_LINE('Projet ajouté avec succès.');

  ROLLBACK;
END;
/

--Bloc de test pour la procédure affecter_equipement
SET SERVEROUTPUT ON;

DECLARE
  p_id_projet NUMBER := 7001;
  p_id_equipement NUMBER := 5001;
BEGIN
    INSERT INTO PROJET (id_projet, titre, domaine, budget, date_debut, date_fin, id_chercheur_resp)
    VALUES (p_id_projet, 'Projet Equipement Test', 'Physique', 20000, SYSDATE, SYSDATE+60, 9001);

    INSERT INTO EQUIPEMENT (id_equipement, nom, categorie, date_acquisition, etat)
    VALUES (p_id_equipement, 'Equipement Test', 'Aventure', SYSDATE, 'Disponible');

    affecter_equipement(8001, p_id_projet, p_id_equipement, SYSDATE, 15);
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
    DBMS_OUTPUT.PUT_LINE('Disponibilité avant affectation: ' || v_disponibilite);

    ROLLBACK;
END;
/
