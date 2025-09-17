# Documentation du déploiement Ansible

## Introduction

Cette documentation décrit le processus d’automatisation du déploiement d’un environnement PostgreSQL complet avec Ansible.

## Prérequis

- **Infrastructure fonctionnelle** comme présenté dans le README.md
- **Ansible** : Installer Ansible sur votre machine bastion. [Documentation Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

## Fonctionnement du déploiement

Le déploiement fonctionne comme suit :

# 📌 Documentation des Playbooks Ansible

Cette documentation décrit chaque playbook utilisé pour automatiser l'installation, la configuration, la supervision, la sauvegarde et le benchmarking d'une instance PostgreSQL.

---

## 1️⃣ Playbook : Installation de PostgreSQL 17 (postgres.yml)

**But :**  
Installer PostgreSQL, créer un utilisateur, une base de données, et configurer l’accès distant.

**Ce qu’il fait :**  
- Installe les prérequis (`wget`, `ca-certificates`, `gnupg`, etc.).  
- Ajoute la clé et le dépôt officiel PostgreSQL.  
- Installe PostgreSQL version 17.  
- Vérifie que le service PostgreSQL est lancé et activé.  
- Crée un utilisateur PostgreSQL (`myuser`) avec un mot de passe et la capacité de créer des bases.  
- Crée une base de données (`mydb`) pour cet utilisateur.  
- Modifie `pg_hba.conf` pour autoriser toutes les IP à se connecter avec MD5.  
- Modifie `postgresql.conf` pour écouter sur toutes les adresses (`*`).  
- Redémarre PostgreSQL si nécessaire.

**Résultat attendu :**  
Une instance PostgreSQL 17 fonctionnelle, sécurisée, avec un utilisateur et une base accessibles à distance.

---

## 2️⃣ Playbook : Installation et configuration de Prometheus & Grafana ( monintoring.yml)

**But :**  
Mettre en place un système de supervision pour PostgreSQL.

**Ce qu’il fait :**  
- Installe Prometheus et met à jour son cache.  
- Démarre et active le service Prometheus.  
- Modifie le fichier `/etc/prometheus/prometheus.yml` pour ajouter le job `postgres` qui collecte les métriques de PostgreSQL via le `postgres_exporter`.  
- Installe les prérequis pour Grafana (`wget`, `software-properties-common`, `apt-transport-https`).  
- Ajoute la clé GPG et le dépôt officiel Grafana.  
- Installe Grafana et démarre le service.

**Résultat attendu :**  
- Prometheus collecte les métriques PostgreSQL.  
- Grafana fournit des dashboards pour visualiser les performances du serveur.

---

## 3️⃣ Playbook : Activer pg_stat_statements 

**But :**  
Activer l’extension PostgreSQL `pg_stat_statements` pour analyser les requêtes SQL.

**Ce qu’il fait :**  
- Installe `postgresql-contrib` qui contient l’extension.  
- Modifie `postgresql.conf` pour ajouter `pg_stat_statements` dans `shared_preload_libraries`.  
- Redémarre PostgreSQL.  
- Crée l’extension dans la base de données cible (`mydb`).

**Résultat attendu :**  
PostgreSQL peut enregistrer et analyser les requêtes SQL exécutées, ce qui permet d’optimiser les performances.

---

## 4️⃣ Playbook : Sauvegarde avec pgBackRest

**But :**  
Mettre en place un système de sauvegarde fiable pour PostgreSQL.

**Ce qu’il fait :**  
- Installe pgBackRest.  
- Crée les dossiers pour les backups et la configuration.  
- Crée le fichier `pgbackrest.conf` avec les chemins et paramètres de rétention.  
- Crée une **stanza**, qui correspond à la configuration de sauvegarde du cluster PostgreSQL.  
- Lance un premier backup complet.

**Résultat attendu :**  
Un système de sauvegarde automatisé, capable de restaurer PostgreSQL en cas de problème.

---

## 5️⃣ Playbook : Benchmark PostgreSQL avec pgBench

**But :**  
Tester les performances du serveur PostgreSQL sous charge.

**Ce qu’il fait :**  
- Installe `pgbench`.  
- Initialise une base de test (`pgbench -i`).  
- Lance un benchmark en simulant plusieurs clients (`-c`) pendant un temps donné (`-T`).  
- Sauvegarde le rapport dans `/tmp/pgbench_report.txt`.  
- Affiche le rapport dans la sortie Ansible.

**Résultat attendu :**  
Un rapport détaillé sur les performances du serveur (transactions par seconde, latence, etc.), permettant d’évaluer la capacité de PostgreSQL.
