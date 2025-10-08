-- Fichier template pour la connexion à la base de données
-- NE JAMAIS committer vos vrais identifiants

-- Nom d’hôte / host
SET @host = '51.178.25.157';

-- Port MySQL (par défaut 3306)
SET @port = '23456';

-- Nom d’utilisateur
SET @user = 'toyscie';

-- Mot de passe
SET @password = 'WILD4Rdata!';

-- Nom de la base de données
SET @database = 'toys_and_models';

-- Connexion depuis git bash
-- mysql -h 51.178.25.157 -P 23456 -u toyscie -p'WILD4Rdata!' toys_and_models
