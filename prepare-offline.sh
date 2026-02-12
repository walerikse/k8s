#!/bin/bash
set -e

# Configuration
CALICO_MANIFEST_URL="https://docs.projectcalico.org/manifests/calico.yaml"
KUBERNETES_VERSION="1.30.9"
CALICO_VERSION="v3.26.1"
REGISTRY_ADDRESS="localhost:5000"
POD_SUBNET="192.168.0.0/16"
OFFLINE_DIR="/opt/offline"

# Validation functions
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Ошибка: Некорректный формат версии: $1"
        exit 1
    fi
}

validate_url() {
    if ! curl --output /dev/null --silent --head --fail "$1"; then
        echo "Ошибка: Недоступный URL: $1"
        exit 1
    fi
}

confirm_action() {
    echo -e "\n\033[1;33m=== ПРОВЕРЬТЕ ПАРАМЕТРЫ ===\033[0m"
    echo "Версия Kubernetes: $KUBERNETES_VERSION"
    echo "Версия Calico: $CALICO_VERSION"
    echo "Pod Subnet: $POD_SUBNET"
    echo "Локальный registry: $REGISTRY_ADDRESS"
    echo "Директория для оффлайн пакетов: $OFFLINE_DIR"
    echo "URL манифеста Calico: $CALICO_MANIFEST_URL"
    
    read -p "Все параметры верны? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy] ]]; then
        echo "Отмена выполнения скрипта!"
        exit 0
    fi
}

# Main execution
validate_version "$KUBERNETES_VERSION"
validate_url "$CALICO_MANIFEST_URL"
confirm_action

echo -e "\n\033[1;32m=== Начало подготовки оффлайн пакетов ===\033[0m"

# Create directories
sudo mkdir -p "$OFFLINE_DIR"/{manifests,pkgs,images}
echo "Созданы директории в $OFFLINE_DIR"

# Download Calico manifest
echo "Загружаем манифест Calico..."
sudo curl -L -o "$OFFLINE_DIR/manifests/calico.yaml" "$CALICO_MANIFEST_URL"

# Generate kubeadm config
cat <<EOF | sudo tee "$OFFLINE_DIR/kubeadm-config.yaml" >/dev/null
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///var/run/crio/crio.sock
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v$KUBERNETES_VERSION
imageRepository: $REGISTRY_ADDRESS
networking:
  podSubnet: $POD_SUBNET
EOF

# Install dependencies
echo -e "\n\033[1;33m=== Установка базовых зависимостей ===\033[0m"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg wget

# Configure repositories
echo -e "\n\033[1;33m=== Настройка репозиториев ===\033[0m"
# Kubernetes
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# CRI-O
export OS=Debian_11
export VERSION=1.24
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

# Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo chmod a+r /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Package installation
echo -e "\n\033[1;33m=== Установка пакетов ===\033[0m"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt-get install -y conntrack=1:1.4.6-2 kubernetes-cni=1.4.0-1.1 cri-o cri-o-runc

# Download packages
echo -e "\n\033[1;33m=== Скачивание пакетов ===\033[0m"
sudo mkdir -p offline-pkgs/{kubernetes,cri-o,docker}
sudo chown -R _apt:root offline-pkgs/{kubernetes,cri-o,docker}
sudo chmod -R 777 offline-pkgs/{kubernetes,cri-o,docker}

# Kubernetes packages
cd offline-pkgs/kubernetes
sudo -u _apt apt-get download kubelet=$KUBERNETES_VERSION-1.1 kubeadm=$KUBERNETES_VERSION-1.1 kubectl=$KUBERNETES_VERSION-1.1 conntrack=1:1.4.6-2 kubernetes-cni=1.4.0-1.1
cd ../../

# CRI-O packages
cd offline-pkgs/cri-o
sudo -u _apt apt-get download cri-o cri-o-runc
cd ../../

# Docker packages
cd offline-pkgs/docker
sudo -u _apt apt-get download docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
cd ../../

# Download images
echo -e "\n\033[1;33m=== Скачивание Docker образов ===\033[0m"
images=(
    registry.k8s.io/kube-apiserver:v$KUBERNETES_VERSION
    registry.k8s.io/kube-controller-manager:v$KUBERNETES_VERSION
    registry.k8s.io/kube-scheduler:v$KUBERNETES_VERSION
    registry.k8s.io/kube-proxy:v$KUBERNETES_VERSION
    registry.k8s.io/pause:3.9
    registry.k8s.io/etcd:3.5.15-0
    registry.k8s.io/coredns/coredns:v1.11.3
    registry.k8s.io/coredns/coredns:v1.11.1
    registry:2
    calico/node:$CALICO_VERSION
)

for image in "${images[@]}"; do
    echo "Скачивание $image..."
    sudo docker pull $image
done

# Save images
echo -e "\n\033[1;33m=== Сохранение образов ===\033[0m"
sudo docker save -o k8s-images.tar ${images[@]:0:9}
sudo docker save -o calico-images.tar ${images[9]}

# Finalize
echo -e "\n\033[1;33m=== Финальная настройка ===\033[0m"
sudo cp -r offline-pkgs/* "$OFFLINE_DIR/pkgs/"
sudo cp *.tar "$OFFLINE_DIR/images/"

echo -e "\n\033[1;32m=== Подготовка завершена успешно! ===\033[0m"
echo "Оффлайн пакеты доступны в: $OFFLINE_DIR"
echo "Для переноса на целевые узлы выполните:"
echo "sudo rsync -av $OFFLINE_DIR/ целевой_узел:/opt/offline/"
