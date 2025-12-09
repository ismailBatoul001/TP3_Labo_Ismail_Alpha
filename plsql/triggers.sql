CREATE OR REPLACE TRIGGER trg_experience_after_insert
AFTER INSERT ON EXPERIENCE
FOR EACH ROW
BEGIN
  INSERT INTO LOG_OPERATION(table_concernee, operation, utilisateur, date_op, description)
  VALUES('EXPERIENCE', 'INSERT', USER, SYSDATE, 'Nouvelle expérience ajoutée');
END;
/

CREATE OR REPLACE TRIGGER trg_log_before_insert
BEFORE INSERT ON LOG_OPERATION
FOR EACH ROW
BEGIN
  :NEW.operation := UPPER(:NEW.operation);
END;
/

CREATE OR REPLACE TRIGGER trg_securite_after_update
AFTER UPDATE ON CHERCHEUR
FOR EACH ROW
BEGIN
  INSERT INTO LOG_OPERATION(table_concernee, operation, utilisateur, date_op, description)
  VALUES('CHERCHEUR', 'UPDATE', USER, SYSDATE, 'Modification du chercheur ');
END;
/

CREATE OR REPLACE TRIGGER trg_echantillon_before_insert
BEFORE INSERT ON ECHANTILLON
FOR EACH ROW
DECLARE
  v_date DATE;
BEGIN
  SELECT date_realisation INTO v_date
  FROM EXPERIENCE
  WHERE id_exp = :NEW.id_exp;
  IF :NEW.date_prelevement < v_date THEN
    RAISE_APPLICATION_ERROR(-20005, 'Date prélèvement plus petite que la date d''expérience');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_affectation_before_insert
BEFORE INSERT ON AFFECTATION_EQUIP
FOR EACH ROW
DECLARE
  v_etat VARCHAR2(100);
BEGIN
  SELECT etat INTO v_etat
  FROM EQUIPEMENT
  WHERE id_equipement = :NEW.id_equipement;
  IF v_etat != 'Disponible' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Équipement non disponible');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_affectation_after_insert
AFTER INSERT ON AFFECTATION_EQUIP
FOR EACH ROW
BEGIN
  UPDATE EQUIPEMENT
  SET etat = 'En maintenance'
  WHERE id_equipement = :NEW.id_equipement;
END;
/

CREATE OR REPLACE TRIGGER trg_affectation_after_delete
AFTER DELETE ON AFFECTATION_EQUIP
FOR EACH ROW
BEGIN
  UPDATE EQUIPEMENT
  SET etat = 'Disponible'
  WHERE id_equipement = :OLD.id_equipement;
END;
/

CREATE OR REPLACE TRIGGER trg_chercheur_date
BEFORE INSERT OR UPDATE ON CHERCHEUR
FOR EACH ROW
BEGIN
  IF :NEW.date_embauche > SYSDATE THEN
    RAISE_APPLICATION_ERROR(-20001, 'Date d''embauche ne peut pas être future');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_projet_before_insert
BEFORE INSERT OR UPDATE ON PROJET
FOR EACH ROW
BEGIN
  IF :NEW.budget <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Budget doit être > 0');
  END IF;
  IF :NEW.date_fin < :NEW.date_debut THEN
    RAISE_APPLICATION_ERROR(-20003, 'Date fin doit être >= date début');
  END IF;
END;
/