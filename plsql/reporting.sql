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

