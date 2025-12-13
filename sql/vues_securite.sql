CREATE OR REPLACE VIEW V_PROJETS_PUBLICS AS
SELECT 
    id_projet,
    titre,
    domaine,
    budget,
    date_debut,
    date_fin,
    id_chercheur_resp
FROM 
    PROJET
WHERE 
    date_fin < SYSDATE;

CREATE OR REPLACE VIEW V_RESULTATS_EXPERIENCE AS
SELECT 
    e.id_exp,
    e.titre_exp,
    e.date_realisation,
    e.statut,
    p.titre AS titre_projet,
    p.domaine AS domaine_projet,
    c.nom AS nom_chercheur,
    c.prenom AS prenom_chercheur,
    COUNT(ech.id_echantillon) AS nb_echantillons,
    AVG(ech.mesure) AS moyenne_mesure,
    e.resultat AS resultat_exp,
    (p.date_fin - p.date_debut) AS duree_projet
FROM 
    EXPERIENCE e
    INNER JOIN PROJET p ON e.id_projet = p.id_projet
    INNER JOIN CHERCHEUR c ON p.id_chercheur_resp = c.id_chercheur
    LEFT JOIN ECHANTILLON ech ON e.id_exp = ech.id_exp
GROUP BY 
    e.id_exp,
    e.titre_exp,
    e.date_realisation,
    e.statut,
    p.titre,
    p.domaine,
    c.nom,
    c.prenom,
    e.resultat,
    p.date_fin,
    p.date_debut;

GRANT SELECT ON V_PROJETS_PUBLICS TO LECT_LAB;
GRANT SELECT ON V_RESULTATS_EXPERIENCE TO LECT_LAB;
