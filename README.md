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
└── README.md          # Mode d'emploi
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

   - Copiez ou téléchargez ce dossier
   - Renommez le dossier avec le nom de votre projet

   ```bash
   orchestrate-adk-starter → my-project
   ```
   
   - Placez-vous ensuite dans le dossier du projet

   ```bash
   cd my-project
   ```

2. **Configurer les variables d'environnement**
   
   Ouvrez le fichier [`template_projet/.env.sdk`](template_projet/.env.sdk) et complétez les placeholders avec vos informations :
   
   ```bash
   # Exemple de variables à configurer
   WO_DEVELOPER_EDITION_SOURCE=orchestrate
   WO_INSTANCE_ALIAS=...
   WO_INSTANCE=...
   WO_API_KEY=...
   ```

   ⚠️ **Attention** : Ce fichier peut contenir des secrets. Il est local uniquement et ne doit jamais être partagé ni versionné.

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

### Commande d'aide

Pour voir toutes les commandes disponibles :

```bash
make help
```

---

## 🛠️ Personnalisation de l'installation

Le comportement de l'installation Orchestrate ADK est contrôlé directement dans le [`Makefile`](template_projet/Makefile).

Avant de lancer `make bootstrap`, vous pouvez adapter les paramètres suivants selon le type d'installation souhaité :

```make
WXO_VERSION ?= 2.3.0

OBSERVABILITY_TOOL ?= --with-langfuse
# Alternatives possibles :
#   --with-ibm-telemetry
#   (laisser vide pour désactiver)

OPTIONAL_TOOLS ?= --with-langflow
# Alternatives possibles :
#   --with-doc-processing
#   (laisser vide pour désactiver)
```

### Description des paramètres

**`WXO_VERSION`**
- Correspond à la version du package Python `ibm-watsonx-orchestrate`

**`OBSERVABILITY_TOOL`**
- Active les outils d'observabilité lors du démarrage du serveur Orchestrate
- Une seule option doit être utilisée à la fois

**`OPTIONAL_TOOLS`**
- Active des outils optionnels supplémentaires (ex : Langflow, document processing)

Ces paramètres sont globaux au projet et permettent d'adapter l'environnement sans modifier les commandes `make`.

---

## 🔧 Configuration

### Fichier .env.sdk

Le fichier [`.env.sdk`](template_projet/.env.sdk) contient toutes les variables d'environnement nécessaires au fonctionnement de l'ADK.

**Important** :
- Complétez tous les placeholders avant de lancer les commandes
- Ne commitez jamais vos clés API réelles dans Git
- Le fichier [`.gitignore`](.gitignore) est configuré pour ignorer les fichiers `.env.sdk`

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

Ce projet est un starter template. N'hésitez pas à :
- L'adapter à vos besoins spécifiques
- Partager vos améliorations
- Contribuer au projet

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