#!/bin/bash

# Fonction pour obtenir la dernière version stable de Helm
get_latest_helm_version() {
    curl -s https://api.github.com/repos/helm/helm/releases/latest | grep tag_name | cut -d '"' -f 4
}

# Obtenir la dernière version stable de Helm
LATEST_VERSION=$(get_latest_helm_version)

# URL du téléchargement
DOWNLOAD_URL="https://get.helm.sh/helm-${LATEST_VERSION}-linux-amd64.tar.gz"

# Téléchargement de la dernière version
echo "Téléchargement de Helm version ${LATEST_VERSION}..."
wget -q ${DOWNLOAD_URL} -O helm-${LATEST_VERSION}-linux-amd64.tar.gz

# Extraction du binaire
echo "Extraction du binaire Helm..."
tar -zxvf helm-${LATEST_VERSION}-linux-amd64.tar.gz

# Déplacement du binaire dans /usr/local/bin
echo "Mise à jour de Helm vers la version ${LATEST_VERSION}..."
sudo mv linux-amd64/helm /usr/local/bin/helm

# Vérification de la version installée
echo "La version de Helm installée est maintenant :"
helm version

# Nettoyage des fichiers téléchargés
echo "Nettoyage..."
rm -f helm-${LATEST_VERSION}-linux-amd64.tar.gz
rm -rf linux-amd64

echo "Mise à jour terminée avec succès."
