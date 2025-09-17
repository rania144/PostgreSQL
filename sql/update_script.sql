-- Exemple : ajouter une colonne à la table users
ALTER TABLE users ADD COLUMN last_login TIMESTAMP;

-- Exemple : insérer un utilisateur test
INSERT INTO users (username, last_login) VALUES ('test', now());

