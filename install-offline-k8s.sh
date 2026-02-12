#!/bin/bash
set -eo pipefail

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
MAX_RETRIES=3
RETRY_DELAY=30
echo -e "${BLUE}=== Installing Kubernetes in offline mode ===${NC}"

# Очистка перед инициализацией
cleanup() {
    echo -e "${YELLOW}Очистка системы перед инициализацией...${NC}"
    sudo kubeadm reset -f >/dev/null 2>&1
    sudo rm -rf /etc/kubernetes/*
    sudo rm -rf /var/lib/etcd/*
    sudo rm -rf /var/lib/kubelet/*
    sudo rm -rf /var/lib/cni/*
    sudo rm -rf /etc/cni/net.d/*
    sudo rm -rf /run/flannel/*
    sudo rm -rf /var/run/kubernetes/*
    sudo rm -rf /var/lib/dockershim/*
    sudo rm -rf /var/lib/rook/*
    sudo rm -rf /var/lib/weave/*
    sudo rm -rf /var/lib/calico/*
    sudo rm -rf /var/log/containers/*
    sudo rm -rf /var/log/pods/*
    sudo rm -rf /var/log/kubernetes/*
    sudo rm -rf /var/lib/etcd/
    sudo mkdir -p /var/lib/etcd
    sudo chmod 700 /var/lib/etcd
    echo -e "${GREEN}Очистка завершена.${NC}"
}

# Убиваем процессы, занимающие порты
kill_processes_on_ports() {
    echo -e "${YELLOW}Проверка занятых портов...${NC}"
    PORTS=(10250 10251 10252 2379 2380 6443)
    for port in "${PORTS[@]}"; do
        if sudo lsof -i :$port >/dev/null 2>&1; then
            echo -e "${RED}Порт $port занят. Останавливаем процесс...${NC}"
            sudo kill -9 $(sudo lsof -ti :$port)
        fi
    done
}

# Установка базовых пакетов
echo -e "${YELLOW}Устанавливаем CRI-O и зависимости...${NC}"
sudo dpkg -i /opt/offline/pkgs/cri-o/*.deb
sudo dpkg -i /opt/offline/pkgs/kubernetes/*.deb

# Настройка CRI-O
echo -e "${YELLOW}Настраиваем CRI-O...${NC}"
sudo systemctl enable crio
sudo systemctl start crio

# Установка Docker (без containerd)
echo -e "${YELLOW}Устанавливаем Docker...${NC}"
sudo dpkg -i /opt/offline/pkgs/docker/*.deb

# Настройка Docker
if ! systemctl is-active --quiet docker; then
    echo -e "${YELLOW}Запуск Docker...${NC}"
    sudo systemctl enable --now docker
else
    echo -e "${GREEN}Docker уже запущен.${NC}"
fi

# Добавление пользователя в группу docker
if ! groups $USER | grep -q '\bdocker\b'; then
    echo -e "${YELLOW}Добавляем пользователя $USER в группу docker...${NC}"
    sudo usermod -aG docker $USER
    newgrp docker || true
fi

# Загрузка образов Kubernetes
echo -e "${YELLOW}Загружаем образы Kubernetes...${NC}"
sudo docker load -i /opt/offline/images/k8s-images.tar
sudo docker load -i /opt/offline/images/calico-images.tar

# Настройка локального реестра
if ! docker ps --format '{{.Names}}' | grep -q '^local-registry$'; then
    echo -e "${YELLOW}Запуск локального реестра...${NC}"
    sudo docker run -d \
        -p 5000:5000 \
        --restart=always \
        --name local-registry \
        -v /opt/offline/images/registry:/var/lib/registry \
        registry:2
fi

# Переименование и загрузка образов в локальный реестр
echo -e "${YELLOW}Подготовка образов для CRI-O...${NC}"
IMAGES=(
    "kube-apiserver:v1.30.9"
    "kube-controller-manager:v1.30.9"
    "kube-scheduler:v1.30.9"
    "kube-proxy:v1.30.9"
    "pause:3.9"  # Обратите внимание на правильный тег для pause
    "etcd:3.5.15-0"
    "coredns/coredns:v1.11.3"
    "coredns/coredns:v1.11.1"
)

for image in "${IMAGES[@]}"; do
    # Переименовываем образы для локального реестра
    sudo docker tag "registry.k8s.io/${image}" "localhost:5000/${image}"
    # Загружаем образы в локальный реестр
    sudo docker push "localhost:5000/${image}"
done

# Системные настройки
echo -e "${YELLOW}Настраиваем системные параметры...${NC}"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Загрузка модулей ядра
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Настройка сетевых параметров
cat <<EOF | sudo tee /etc/sysctl.d/99-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Функция инициализации кластера
init_cluster() {
    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        echo -e "${BLUE}Попытка инициализации кластера #$attempt${NC}"
        
        # Очистка перед каждой попыткой
        cleanup
        kill_processes_on_ports

        if sudo kubeadm init \
            --config=/opt/offline/kubeadm-config.yaml \
            --ignore-preflight-errors=Port-10250,DirAvailable--var-lib-etcd; then
            echo -e "${GREEN}Кластер успешно инициализирован!${NC}"
            return 0
        else
            echo -e "${RED}Ошибка инициализации. Попытка #$attempt из $MAX_RETRIES.${NC}"
            ((attempt++))
            sleep $RETRY_DELAY
        fi
    done
    return 1
}

# Основной процесс
if init_cluster; then
    # Настройка доступа
    echo -e "${YELLOW}Настраиваем доступ к кластеру...${NC}"
    sudo mkdir -p $HOME/.kube
    sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # Установка Calico
    echo -e "${YELLOW}Устанавливаем сетевой плагин Calico...${NC}"
    for i in {1..3}; do
        if kubectl apply -f /opt/offline/manifests/calico.yaml; then
            echo -e "${GREEN}Calico успешно установлен!${NC}"
            break
        else
            echo -e "${RED}Ошибка установки Calico. Попытка #$i${NC}"
            sleep 15
        fi
    done

    # Проверка состояния кластера
    echo -e "${YELLOW}Проверяем состояние кластера:${NC}"
    kubectl get nodes 
    timeout 59s kubectl get pods -A -w || true &
    wait $!
else
    echo -e "${RED}Не удалось инициализировать кластер после $MAX_RETRIES попыток.${NC}"
    exit 1
fi

echo -e "${GREEN}Настройка кластера завершена успешно!${NC}"
