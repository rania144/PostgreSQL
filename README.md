# Documentation du déploiement Ansible

## Introduction

Cette documentation décrit le processus d’automatisation du déploiement d’un environnement PostgreSQL complet avec Ansible.

## Prérequis

- **Infrastructure fonctionnelle** comme présenté dans le README.md
- **Ansible** : Installer Ansible . [Documentation Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)

## Fonctionnement du déploiement

Le déploiement fonctionne comme suit :

##  Fichier d'inventaire Ansible (`inventory.ini`)

Le fichier `inventory.ini` définit les serveurs que **Ansible** va gérer et les variables associées.

### Ce qu’il fait :

- Indique **l’adresse IP ou le nom d’hôte** du serveur cible : `192.168.21.134`.  
- Précise **l’utilisateur SSH** à utiliser pour se connecter : `rania4`.  
- Fournit le **chemin vers la clé privée SSH** pour l’authentification sans mot de passe : `~/.ssh/id_rsa`.  
- Définit des **variables globales** pour tous les serveurs, ici pour forcer l’utilisation de Python 3 : `ansible_python_interpreter=/usr/bin/python3`.

#  Documentation des Playbooks Ansible

Cette documentation décrit chaque playbook utilisé pour automatiser l'installation, la configuration, la supervision, la sauvegarde et le benchmarking d'une instance PostgreSQL.

---

## 1 Playbook : Installation de PostgreSQL 17

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

## 2 Playbook : Activer pg_stat_statements

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

## 3 Playbook : Sauvegarde avec pgBackRest

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

## 4 Playbook : Benchmark PostgreSQL avec pgBench

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

---

## 5 Playbook : Installation de Prometheus, Grafana et PostgreSQL Exporter

**But :**  
Installer et configurer un système de supervision complet pour PostgreSQL incluant Prometheus, Grafana et PostgreSQL Exporter.

**Ce qu’il fait :**  
- Installe Prometheus, le démarre et configure le job `postgres` pour scraper les métriques PostgreSQL.  
- Installe Grafana avec les dépôts officiels, démarre le service et l’active.  
- Crée un utilisateur système et un utilisateur PostgreSQL pour `postgres_exporter`.  
- Télécharge et décompresse l’exécutable `postgres_exporter`.  
- Crée un service systemd pour l’exporter et l’active afin qu’il démarre automatiquement.  
- Fournit un handler pour redémarrer Prometheus si la configuration change, garantissant que les métriques PostgreSQL sont collectées correctement.

**Résultat attendu :**  
Un environnement de supervision complet où Prometheus collecte les métriques PostgreSQL et Grafana les affiche via des dashboards.

---

##  Utilisation

Pour exécuter un playbook :  

```bash
ansible-playbook -i hosts mon_playbook.yml

```bash
ansible-playbook -i inventory.ini mon_playbook.yml
