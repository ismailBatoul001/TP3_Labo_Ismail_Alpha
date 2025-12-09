--Bloc de test pour la procédure ajouter_projet
SET SERVEROUTPUT ON;

DECLARE
  v_id_chercheur NUMBER := 9001;
BEGIN
  INSERT INTO CHERCHEUR (id_chercheur, nom, prenom, specialite, date_embauche)
  VALUES (v_id_chercheur, 'BATOUL', 'ISMAIL', 'IA', SYSDATE);

  ajouter_projet(7001, 'Projet Test', 'IA', 10000, SYSDATE, SYSDATE+30, v_id_chercheur);

  ROLLBACK;
END;
/