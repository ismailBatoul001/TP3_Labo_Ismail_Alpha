# TP3_Labo_Ismail_Alpha

Ismail Batoul (2349449)
Alpha Ngendandumwe (2349593)

# Répartition des tâches

Ismail
- creations_tables.sql
- transactions.sql
- procédures : ajouter_projet et affecter_equipement
- fonctions opérationelles : calculer_duree_projet(id_projet) et verifier_disponibilite_equipement(id_equipement)
- les blocs de tests pour les procédures et fonctions que j'ai réalisés
- procédure de reporting : rapport_projets_par_chercheur(p_id_chercheur)
- les triggers
- le rapport

Alpha 
- procédures : planifier_experience, supprimer_projet et journaliser_action
- fonction opérationelle : moyenne_mesures_experience(id_exp)
- fonctions de reporting : statistiques_equipements() et budget_moyen_par_domaine()
- procédure de reporting : rapport_activite_projets()
- les vues v_projets_public et v_resultats_experience

# Instructions d'exécution

1. Se connecter comme ADMIN_LAB
2. Exécuter les scripts dans l'ordre:
   - creation_tables.sql
   - insertions.sql
   - procedures_oper.sql
   - fonctions_oper.sql
   - triggers.sql
   - transactions.sql
   - vues_securite.sql
   - tests_blocs.sql

Si on veut tester les triggers, juste à executer l'insertion à la fin

## Informations projet

- Date de remise: 12 décembre 2025
- État: Complété
