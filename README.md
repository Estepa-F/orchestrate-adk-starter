# watsonx Orchestrate ADK – Starter Folder

Ce dossier fournit un environnement de travail **watsonx Orchestrate ADK** prêt à l'emploi, basé sur un [`Makefile`](Makefile) unique et un fichier [`.env.sdk`](.env.sdk) local.

**Objectif** : permettre à n'importe qui de partir de zéro et de lancer Orchestrate ADK localement avec une seule commande.

---

## 📁 Contenu du dossier

```
.
├── Makefile           # Automatisation des commandes ADK
├── .env.sdk           # Configuration locale (avec placeholders à compléter)
├── .env.example       # Exemple de configuration
├── .gitignore         # Fichiers à ignorer par Git
└── README.md          # mode d’emploi.
```

### Fichiers principaux

- **[`Makefile`](Makefile)** : automatise l'installation, le serveur local, le chat, le copilot, le déploiement et le diagnostic
- **[`.env.sdk`](.env.sdk)** : configuration locale avec placeholders à compléter (clés API, URLs, etc.)
- **[`.env.example`](.env.example)** : modèle de configuration pour référence
- **[`workspace_config.yaml`](workspace_config.yaml)** : configuration de l'espace de travail ADK

---

## 🚀 Démarrage rapide

### Prérequis

- Un compte IBM watsonx avec accès à Orchestrate
- Python 3.12 installé et accessible dans le PATH

### Installation

1. **Cloner ou télécharger ce dossier**

- Copie ou télécharge ce dossier
- Renomme le dossier avec le nom de ton projet

   ```bash
    orchestrate-adk-starter → my-project
   ```

2. **Configurer les variables d'environnement**
   
   Ouvrez le fichier [`.env.example`](.env.example) et complétez les placeholders avec vos informations et renommer le fichier par ".env.sdk":
   
   ```bash
   # Exemple de variables à configurer
   WATSONX_API_KEY=votre_clé_api
   WATSONX_URL=https://votre-instance.watsonx.cloud.ibm.com
   # ... autres variables selon vos besoins
   ```

3. **Installer Orchestrate et commencer le projet**
   
   ```bash
   make bootstrap
   ```

---

## 📋 Commandes disponibles

Le [`Makefile`](Makefile) fournit plusieurs commandes pour faciliter le développement :

### Commandes principales

```bash
# Installer les dépendances
make install

# Démarrer le serveur local
make server

# Lancer le chat interactif
make chat

# Lancer le copilot
make copilot

# Déployer l'application
make deploy

# Diagnostiquer les problèmes
make diagnose
```

### Aide

Pour voir toutes les commandes disponibles :

```bash
make help
```

---

## 🔧 Configuration

### Fichier .env.sdk

Le fichier [`.env.sdk`](.env.sdk) contient toutes les variables d'environnement nécessaires au fonctionnement de l'ADK. Assurez-vous de compléter tous les placeholders avant de lancer les commandes.

**Important** : Ne commitez jamais vos clés API réelles dans Git. Le fichier [`.gitignore`](.gitignore) est configuré pour ignorer [`.env.sdk`](.env.sdk).

---

## 📚 Ressources

- [Documentation watsonx Orchestrate](https://www.ibm.com/docs/en/watsonx/watson-orchestrate)
- [Guide ADK](https://www.ibm.com/docs/en/watsonx/watson-orchestrate/adk)
- [IBM watsonx](https://www.ibm.com/watsonx)

---

## 🤝 Contribution

Ce projet est un starter template. N'hésitez pas à l'adapter à vos besoins spécifiques et à partager vos améliorations.

---

## 📝 Licence

Ce projet est fourni tel quel, sans garantie. Consultez les conditions d'utilisation d'IBM watsonx pour plus d'informations.

---

## 💡 Support

Pour toute question ou problème :

1. Vérifiez la configuration dans [`.env.sdk`](.env.sdk)
2. Lancez `make diagnose` pour identifier les problèmes
3. Consultez la documentation officielle IBM watsonx
4. Contactez le support IBM si nécessaire

---

**Bonne utilisation de watsonx Orchestrate ADK ! 🎉**