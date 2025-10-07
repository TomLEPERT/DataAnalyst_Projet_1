# Catalogue des KPI du projet

Ce document regroupe les définitions des indicateurs (KPI) calculés à partir de la base de données MySQL.

---

## KPI 1 — Monthly Active Users (MAU)

**Nom interne :** `kpi_monthly_active_users`  
**Fichier SQL :** `sql/kpis/kpi_monthly_active_users.sql`  
**Objectif métier :**
> Mesurer le nombre d’utilisateurs uniques ayant effectué au moins une action durant chaque mois.

**Formule / logique de calcul :**
```sql
SELECT
  DATE_FORMAT(action_date, '%Y-%m-01') AS month,
  COUNT(DISTINCT user_id) AS monthly_active_users
FROM user_actions
GROUP BY month;
