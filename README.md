# watsonx Orchestrate ADK – Starter Folder

Ce dossier fournit un environnement de travail **watsonx Orchestrate ADK** prêt à l'emploi, basé sur un [`Makefile`](template_projet/Makefile) unique et un fichier [`.env.sdk`](template_projet/.env.sdk) local.

**Objectif** : permettre à n’importe qui de partir de zéro, configurer son environnement, et lancer Orchestrate ADK localement avec une seule commande (`make bootstrap`), tout en simplifiant l’usage via des raccourcis `make`.

---

## 📁 Contenu du dossier

```
.
├── template_projet/
│   ├── Makefile       # Automatisation des commandes ADK
│   └── .env.sdk       # Configuration locale (avec placeholders à compléter)
├── .gitignore         # Fichiers à ignorer par Git
└── README.md          # mode d'emploi.
```

### Fichiers principaux

- **[`Makefile`](template_projet/Makefile)** : automatise l’installation, le serveur local, le chat, le copilot, le déploiement, le diagnostic et le reset
- **[`.env.sdk`](template_projet/.env.sdk)** : configuration locale avec placeholders à compléter (clés API, URLs, etc.)

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
   
   - Placez-vous ensuite dans le dossier du projet

   ```bash
   cd my-project
   ```

2. **Configurer les variables d'environnement**
   
   Ouvrez le fichier [`template_projet/.env.sdk`](template_projet/.env.sdk) et complétez les placeholders avec vos informations:
   
   ```bash
   # Exemple de variables à configurer
   WO_DEVELOPER_EDITION_SOURCE=orchestrate
   WO_INSTANCE_ALIAS=...
   WO_INSTANCE=...
   WO_API_KEY=...
   ```

   ⚠️ Ce fichier peut contenir des secrets.
   Il est local uniquement et ne doit jamais être partagé ni versionné.

3. **Installer Orchestrate et commencer le projet**
   
   ```bash
   make bootstrap
   ```

   Cette commande :
   - Vérifie l'environnement (doctor)
   - Crée le virtualenv Python
   - Installe watsonx Orchestrate ADK
   - Initialise la structure du projet
   - Démarre le serveur local
   - Lance le chat Orchestrate

---

## 📋 Commandes disponibles

Le [`Makefile`](template_projet/Makefile) fournit plusieurs commandes pour faciliter le développement :

### Commandes principales

```bash
make install      # Installer les dépendances
make start        # Démarrer le serveur local
make stop         # Arrêter le serveur
make logs         # Afficher les logs
make chat         # Lancer le chat
make copilot      # Lancer le copilot
make deploy       # Déployer agents et tools
make doctor       # Diagnostic de l’environnement
```

### Aide

Pour voir toutes les commandes disponibles :

```bash
make help
```

---

## 🔧 Configuration

### Fichier .env.sdk

Le fichier [`.env.sdk`](template_projet/.env.sdk) contient toutes les variables d'environnement nécessaires au fonctionnement de l'ADK. Assurez-vous de compléter tous les placeholders avant de lancer les commandes.

**Important** : Ne commitez jamais vos clés API réelles dans Git. Le fichier [`.gitignore`](.gitignore) est configuré pour ignorer les fichiers `.env.sdk`.

---

## 🔐 Sécurité

- `.env.sdk` contient des informations sensibles
- Il est ignoré par Git via `.gitignore`
- Chaque utilisateur gère son propre fichier local

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

1. Vérifiez la configuration dans [`.env.sdk`](template_projet/.env.sdk)
2. Lancez `make doctor` pour diagnostiquer l'environnement
3. Consultez la documentation officielle IBM watsonx Orchestrate
4. Contactez le support IBM si nécessaire

---

**Bonne utilisation de watsonx Orchestrate ADK ! 🎉**