persistentVolumes:
    - name: nginx-config
      mountPath: "/etc/nginx/templates/default.conf.template"
      subPath: "default.conf.template"

  init:
    containers:
    - name: "nginx-config"
      image:
        repository: "cloud-registry.kapitalbank.az/baseimages/alphyn/busybox"
        tag: "1.36.1"
      imagePullPolicy: IfNotPresent
      command:
        - /bin/sh
        - -c
      args:
        - |
          cat <<\EOF > /nginx-config/default.conf.template
          server {
              listen       8080;
              server_name  localhost;

              location /apps/bf {
                  alias   /usr/share/nginx/html;
                  index  index.html index.htm;
              }

              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   /usr/share/nginx/html;
              }
          }
annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
Postgres OS - postgres - lUNnISmDDIUWKDHU6RSH


Postgres СУБД - postgres - OyKKLPQTuX7G77nlvvNj
helm repo add openebs https://openebs.github.io/charts
helm repo update


Установите Helm chart и передайте ему необходимые переменные и имя неймспейса:

helm install --namespace openebs openebs openebs/openebs --set localprovisioner.basePath=/pvs/openebs
vi smb-test-pod.yaml
Copy
apiVersion: v1
kind: Pod
metadata:
  name: smb-test-pod
spec:
  containers:
  - name: app
    image: busybox
    command: [ "sh", "-c", "echo 'Hello from Kubernetes PVC' > /mnt/smb/hello.txt; sleep 3600" ]
    volumeMounts:
    - mountPath: "/mnt/smb"
      name: smb-volume
  volumes:
  - name: smb-volume
    persistentVolumeClaim:
      claimName: smb-pvc

vi smb-pvc.yaml
Copy
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: smb-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: smb-csi
  resources:
    requests:
      storage: 1Gi
helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm repo update
helm install csi-driver-smb csi-driver-smb/csi-driver-smb --namespace kube-system
vi smb-secret.yaml
Copy
apiVersion: v1
kind: Secret
metadata:
  name: smb-secret
  namespace: default
type: Opaque
data:
  username: azhzLXNhbWJh
  password: bXktc2VjdXJlLXB3
vi smb-storageclass.yaml
Copy
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: smb-csi
provisioner: smb.csi.k8s.io
parameters:
  source: "//192.168.30.90/k8s-share"  # Define Samba share
  csi.storage.k8s.io/node-stage-secret-name: "smb-secret" # Define Samba credential secret
  csi.storage.k8s.io/node-stage-secret-namespace: "default" # Define Samba credential secret namespace
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - vers=3.0  # Define Samba version
reclaimPolicy: Delete
helm install my-release oci://registry-1.docker.io/bitnamicharts/keycloak

https://files.pythonhosted.org/packages/70/8e/0e2d847013cb52cd35b38c009bb167a1a26b2ce6cd6965bf26b47bc0bf44/requests-2.31.0-py3-none-any.whl
https://files.pythonhosted.org/packages/bc/4f/9f94808ebac790cc3edba502cb9a1cc29a3f8262f7e2961aed2a159692b5/packaging-14.0-py2.py3-none-any.whl
https://files.pythonhosted.org/packages/db/be/3032490fa33b36ddc8c4b1da3252c6f974e7133f1a50de00c6b85cca203a/docker-6.1.3-py3-none-any.whl
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
https://files.pythonhosted.org/packages/e3/26/57c6fb270950d476074c087527a558ccb6f4436657314bfb6cdf484114c4/docker-7.1.0-py3-none-any.whl
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner


Установите чарт, указав необходимые параметры:

helm install nfs-subdir-external-provisioner \
nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
--set nfs.server=192.168.2.239 \
--set nfs.path=/pvs/k8s \
--set storageClass.onDelete=true

# Metallb address pool
  apiVersion: metallb.io/v1beta1
  kind: IPAddressPool
  metadata:
    name: picluster-pool
    namespace: metallb
  spec:
    addresses:
    - 10.0.0.100-10.0.0.200

  ---
  # L2 configuration
  apiVersion: metallb.io/v1beta1
  kind: L2Advertisement
  metadata:
    name: example
    namespace: metallb
  spec:
    ipAddressPools:
    - picluster-pool
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

nano metallb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.19.255.1-172.19.255.250

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.4/manifests/metallb.yaml

Шаг 3: Устанавливаем необходимый секрет Kubernetes.

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace -n ingress-nginx --set controller.service.loadBalancerIP=<Внешний IP>

helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb
A values file may be specified on installation. This is recommended for providing configs in Helm values:

helm install metallb metallb/metallb -f values.yaml
helm repo add ds-rens https://registry.datasapience.ru/chartrepo/rens --username=ds-rens
yj5uVtmm75NTSuW5mzpImbWOJtHxfrkz
helm add datasapience https://registry.datasapience.ru/chartrepo/rsb --username=<Логин> --password=<ПАРОЛЬ
https://api.k8slens.dev/binaries/Lens%20Setup%202025.10.230725-latest.exe
https://github.com/MuhammedKalkan/OpenLens/releases/download/v6.5.2.286/OpenLens-6.5.2.286.exe
ZHMtdnRibnBmOmdkd05SSGsyR1VwS0ViWnpSTWlGdzhSQ3BlWXZaeFEw
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system

helm repo add projectcalico https://docs.tigera.io/calico/charts --kubeconfig=./capi-quickstart.kubeconfig && \
helm install calico projectcalico/tigera-operator --kubeconfig=./capi-quickstart.kubeconfig -f https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-azure/main/templates/addons/calico/values.yaml --namespace tigera-operator --create-namespace

sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

/etc/docker/daemon.json, добавив туда прокси-настройки.

{
  "proxies": {
    "default": {
      "httpProxy": "http://user:password@proxy-server:port",
      "httpsProxy": "https://user:password@proxy-server:port",
      "noProxy": "localhost,127.0.0.1,*.mydomain.com"
    }
  }
}



curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
Добавляем репозиторий

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
Устанавливаем модули Kubernetes

sudo apt-get update

sudo apt-get install -y kubelet kubeadm kubectl
Инструкция по развертыванию k8s кластера
(k8s, monitoring, logging)

Оглавление
История документа	3
1. Предварительная конфигурация узлов	4
1.1. Настройка автозагрузки и запуск модуля ядра br_netfilter и overlay	4
1.2. Разрешение маршрутизации IP-трафика	4
1.3. Отключение файла подкачки	4
2. Установка компонентов	4
3. Инициализация узлов 	6
3.1. Настраиваем kubeconfig	7
3.2.Устанавливаем Calico	8
3.3. Проверка подключения	8
3.4. Установка metallb	9
3.5. Установка ingress-nginx	10
4. Настройка системы Логирования 	11
5. Настройка системы Мониторинга	14
5.1. Установка kube-state-metric в microk8s	14
5.2. Настройка мониторинга серверных метрик хоста	15
5.3. Настройка мониторинга метрик postgresql	16
5.4. Настройка передачи метрик (серверных и БД) в Prometheus	17
6. Обновление Kubernetes с помощью Kubeadm	18
6.1. Процесс обновления первой Master node	18
6.2. Процесс обновления второй и последующих Master node	19
6.3. Процесс обновления лобой Worker node	19
7. Backup	20
7.1. Backup Kubernetes Resources	20
7.2. Восстановить etcd из бэкапа	20
8. Создание\обновление токена для подключения к Prometheus	21
8. Замена репозитория образов	21

 
	История документа
Версия	Изменения	Дата	Автор
01	Первая версия документа	06.10.2025	Горелов А.А.
			
			
 
	1. Предварительная конфигурация узлов
Перед развертыванием кластера необходимо выполнить конфигурацию узлов. Для каждого узла выполните шаги, приведенные ниже:
	1.1. Настройка автозагрузки и запуск модуля ядра br_netfilter и overlay
	$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
	overlay
	br_netfilter
	EOF
	
	$ sudo modprobe overlay
	$ sudo modprobe br_netfilter
	1.2. Разрешение маршрутизации IP-трафика
	$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
	net.bridge.bridge-nf-call-iptables = 1
	net.bridge.bridge-nf-call-ip6tables = 1
	net.ipv4.ip_forward = 1
	EOF
	
	$ sudo sysctl --system
	1.3. Отключение файла подкачки
$ sudo swapoff -a

$ sudo sed -i '/ swap / s/^/#/' /etc/fstab

	2. Установка компонентов 
# Установка kubeadm kubectl kubelet:
$ curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
$ sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

$ echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
$ sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list 

$ sudo apt-get update
$ sudo apt-get install -y kubeadm kubectl kubelet

# Запретим автоматическое обновление компонентов:
$ sudo apt-mark hold kubelet kubeadm kubectl

# Добавляем сервис в автозагрузку:
sudo systemctl enable kubelet.service

# Установка containerd на control plane nodes:
$ wget https://github.com/containerd/containerd/releases/download/v2.1.0/containerd-2.1.0-linux-amd64.tar.gz

$ sudo tar Cxzvf /usr/local containerd-2.1.0-linux-amd64.tar.gz
$ sudo rm containerd-2.1.0-linux-amd64.tar.gz

#Опционально в случае если предыдущая версия не запускается из-за несовместимости:
$ wget https://github.com/containerd/containerd/releases/download/v1.7.2/containerd-1.7.2-linux-amd64.tar.gz

$ sudo tar Cxzvf /usr/local containerd-1.7.2-linux-amd64.tar.gz
$ sudo rm containerd-1.7.2-linux-amd64.tar.gz

# Создание конфигурации по умолчанию для containerd:
$ mkdir /etc/containerd/ 
$ sudo sh -c 'containerd config default > /etc/containerd/config.toml'

# Затем в файле /etc/containerd/config.toml
- добавим строку SystemdCgroup = true;
- сконфигурируем подключение к приватному репозиторию образов registry.monetks.org;
- изменим путь к образу pause на путь к приватному репозиторию: 
$ sudo nano /etc/containerd/config.toml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    [plugins.'io.containerd.cri.v1.images'.pinned_images]
      sandbox = 'registry.lg.org/assortiment/assort/pause:3.10'
  
          [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
            BinaryName = ''
            CriuImagePath = ''
            CriuWorkPath = ''
            IoGid = 0
            IoUid = 0
            NoNewKeyring = false
            Root = ''
            ShimCgroup = ''
            SystemdCgroup = true

     [plugins.'io.containerd.cri.v1.images'.registry.configs]
        [plugins.'io.containerd.cri.v1.images'.registry.configs.'registry.lg.org'.auth]
          auth = 'Z2l0bGFiLXJlZ2NyZWQtdG9rZW4tYXNydDpnbGR0LUxQR3dqMTNQNC1paG9DeWNzLVJW'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Установка systemd сервиса для containerd:
$ wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

$ sudo mv containerd.service /etc/systemd/system/

# Установка компонента runc:
$ wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64

$ sudo install -m 755 runc.amd64 /usr/local/sbin/runc
$ rm runc.amd64

# Установка сетевых плагинов:
$ wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz

$ mkdir -p /opt/cni/bin
$ sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz
$ rm cni-plugins-linux-amd64-v1.7.1.tgz

# Запуск сервиса containerd:
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now containerd

# Настройка конфигурации crictl:
$ sudo sh -c 'cat > /etc/crictl.yaml << _EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
_EOF'

	3. Инициализация узлов 
# Для установки Kubernetes на master узле выполните следующую команду:
$ sudo kubeadm init --upload-certs --config kubeadm-config.yaml  | tee -a kubeadm.log

kubeconfig.yaml:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
kind: InitConfiguration
apiVersion: kubeadm.k8s.io/v1beta4
---
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta4
kubernetesVersion: v1.32.7
controlPlaneEndpoint: assort-ctrl.lg.org
imageRepository: registry.lg.org/assortiment/assort
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
apiServer:
  certSANs:
    - "10.228.3.217"
    - "assort-ctrl.lg.org"
    - "assort-ctrl"
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
---
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
nodePortAddresses:
  - primary
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

--control-plane-endpoint параметр предоставлен заказчиком как DNS запись указывающая на NGINX сервер или на другой Load Balancer

Record Type	Name	Value (IP Address)	TTL
CNAME	assort-ctrl.lg.org	10.228.3.217	300


3.1. Настраиваем kubeconfig

Убеждаемся в наличии конфигурационного файла  /etc/kubernetes/admin.conf. Данный файл создается автоматически утилитой kubeadm на мастер ноде. Копируем его на нужные хосты :

# Копируем файл на нужный хост:
$ scp /etc/kubernetes/admin.conf user@<ctrl-plane-node>:/home/user/admin.conf

# На хосте применяем его как конфиг по умолчанию:
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

3.2.Устанавливаем Calico

# Устанавливаем Calico в качестве менеджера сетевых политик в кластере:
скачиваем манифест:
$ wget https://docs.projectcalico.org/manifests/calico.yaml

# Задаем значение согласно установленному в pod-network-cidr при инициализации кластера:
    - name: CALICO_IPV4POOL_CIDR
      value: "10.244.0.0/16"

# Устанавливаем в кластер:
$ kubectl apply -f calico.yaml

Затем берем команды из лога kubeadm.log 

# Для подключения мастер нод выполняем команду последовательно на каждой master ноде:
$ kubeadm join <MASTER-NODE-IP>:6443 --token <TOKEN> \
--discovery-token-ca-cert-hash <TOKEN-CERTHASH> \
--control-plain --certificate-key <TOKEN-CERTHASH> \
# --node-name control1  #если hostname не соответствует желаемому именованию в кластере

# Затем выполняем команду, последовательно на каждой worker ноде:
$ kubeadm join <MASTER-NODE-IP>:6443 --token <TOKEN> \
--discovery-token-ca-cert-hash <TOKEN-CERTHASH>
# --node-name worker1 #если hostname не соответствует желаемому именованию в кластере

3.3. Проверка подключения

# Для валидации установки можно использовать следующие команды:
	$ kubectl get --raw='/readyz?verbose'
	$ kubectl cluster-info
	
	3.4. Установка metallb
	
	# Действия ниже выполнять на одной из control plane нод, например, на assort-ctrl1.
	
	# Манифесты для установки metallb (metallb-native.yaml, metallb_l2atvertisement.yaml, metallb_init_conf.yaml) расположены в /opt/metallb

# Создать namespace metallb-system
$ kubectl create ns metallb-system

# Создать secret в неймспейсе metallb c данными токена gitlab:
$ kubectl create secret docker-registry -n metallb-system regcred --docker-username gitlab-regcred-token-asrt --docker-password gldt-LPGwj13P4-ihoCycs-RV --docker-server registry.lg.org

# Заменить дефолтный путь к образу на путь к репозиторию registry.lg.org в файле metallb-native.yaml и добавить наименование созданного secret:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
…
image: registry.lg.org/assortiment/assort/metallb-controller:v0.15.2
…
image: registry.lg.org/assortiment/assort/metallb-speaker:v0.15.2
…
imagePullSecrets:
  - name: regcred
…
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Установить манифест:
$ kubectl apply --namespace metallb-system -f metallb-native.yaml

# Установить манифест metallb_l2atvertisement.yaml
$ kubectl apply --namespace metallb-system -f metallb_l2atvertisement.yaml

# Установить манифест metallb_init_conf.yaml (тут задаются VIP)
$ kubectl apply --namespace metallb-system -f metallb_init_conf.yaml

# Внести изменения в сервис kubernetes: Добавляем externalIP для kubernetes-api-server - добавим аннотацию и изменим тип на LoadBalancer
$ kubectl edit svc kubernetes
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
annotations:
    metallb.io/loadBalancerIPs: 10.228.3.217

type: LoadBalancer
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	3.5. Установка ingress-nginx

# Действия ниже выполнять на одной из control plane нод, например, на assort-ctrl1.

# Helm-chart для установки ingress-nginx расположен в /opt/ingress-nginx

# Создать namespace ingress-nginx
$ kubectl create ns ingress-nginx

# Создать secret в неймспейсе ingress-nginx c данными токена gitlab:
$ kubectl create secret docker-registry -n ingress-nginx regcred --docker-username gitlab-regcred-token-asrt --docker-password gldt-LPGwj13P4-ihoCycs-RV --docker-server registry.lg.org

# Заменить дефолтный путь к образу на путь к репозиторию registry.lg.org в файле values.yaml, и добавить наименование созданного secret:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
…
registry: registry.lg.org/assortiment/assort
…
imagePullSecrets:
  - name: regcred
…
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Установить helm chart:
$ helm install ingress-nginx --namespace ingress-nginx -f values.yaml .

P.S. controller.service.loadBalancerIP="10.228.3.216" - Please note that spec.LoadBalancerIP is planned to be deprecated in k8s apis.
поэтому устанавливаем annotation для сервиса
annotations:
    metallb.io/loadBalancerIPs: 10.228.3.216

	4. Настройка системы Логирования 
Версия FluentBit: 4.0.1
Версия helm chart FluentBit: 0.49.0

Для установки FluentBit в kubernetes использован helm chart: https://github.com/fluent/helm-charts

# Скачайте и распакуйте архив:
$ sudo wget https://github.com/fluent/helm-charts/archive/refs/heads/main.zip
$ sudo unzip main.zip
$ sudo mv helm-charts-main/charts/fluent-bit .

# Основные параметры чарта, в том числе адрес образа для загрузки, расположены в файле values.yaml. В стандартном чарте использован image со ссылкой на загрузку cr.fluentbit.io/fluent/fluent-bit. Этот ресурс был заменён на репозиторий registry.lg.org/assortiment. Фрагмент настройки репозитория образов в файле values.yaml приведён ниже:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image:
  repository: registry.lg.org/assortiment/assort/fluent-bit
#cr.fluentbit.io/fluent/fluent-bit
  tag: "4.0.4"
  digest:
  pullPolicy: IfNotPresent
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# В файле values.yaml в блок “config” внести настройки для Inputs, Filters, Outputs, соответствующие текущей системе сбора и визуализации логов:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
config:
  service: |
    [SERVICE]
        Daemon Off
        Flush {{ .Values.flush }}
        Log_Level {{ .Values.logLevel }}
        Parsers_File /fluent-bit/etc/parsers.conf
        HTTP_Server On
        HTTP_Listen 0.0.0.0
        HTTP_Port {{ .Values.metricsPort }}
        Health_Check On

  inputs: |
    [INPUT]
        Name tail
        Path /var/log/containers/*kube-system*.log
        multiline.parser docker
        Tag kube.k8s.*
        Mem_buf_limit 5M
        Skip_Long_Lines On
        Read_from_Head True
   [INPUT]
        Name tail
        Path /var/log/containers/*.log
        exclude_path /var/log/containers/*_kube-system_*.log
        multiline.parser docker
        Tag kube.workload.*
        Mem_buf_limit 5M
        Skip_Long_Lines On
        Read_from_Head True

  filters: |
    [FILTER]
        Name kubernetes
        Match kube.k8s.*
        Kube_Tag_Prefix kube.k8s.var.log.containers.
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude Off
        Annotations On
        Labels On
    [FILTER]
        Name kubernetes
        Match kube.workload.*
        Kube_Tag_Prefix kube.workload.var.log.containers.
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude Off
        Annotations On
        Labels On
 
outputs: |
    [OUTPUT]
        Name es
        Match kube.k8s.*
        Host PRICING-LOGS.lg.org
        Port 443
        Path /logs
        HTTP_User admin
        HTTP_Passwd masterpassprod
        tls On
        tls.verify Off
        Retry_Limit False
        Suppress_Type_Name On
        Logstash_Format On
        Logstash_Prefix assort_prod_kube-system
    [OUTPUT]
        Name es
        Match kube.workload.*
        Host PRICING-LOGS.lg.org
        Port 443
        Path /logs
        HTTP_User admin
        HTTP_Passwd masterpassprod
        tls On
        tls.verify Off
        Retry_Limit False
        Suppress_Type_Name On
        Logstash_Format On
        Logstash_Prefix assort_prod_workload

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# В файле values.yaml блоки daemonSetVolumes и daemonSetVolumes сконфигурировать следующим образом:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
daemonSetVolumes:
  - name: varlogcontainers
    hostPath:
      path: /var/log/containers
  - name: varlogpods
    hostPath:
      path: /var/log/pods

daemonSetVolumeMounts:
  - name: varlogcontainers
    mountPath: /var/log/containers
  - name: varlogpods
    mountPath: /var/log/pods
    readOnly: true
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Создайте отдельный неймспейс k8s для fluentBit:
$ microk8s kubectl create namespace fluent-bit

# Запустить helm chart, находясь в папке fluent-bit чарта:
$ microk8s helm -n fluent-bit install fluentbit .

# Проверить, что поды находятся в статусе running:
$ microk8s kubectl -n fluent-bit get po


# ! Образ контейнера fluentbit размещён в хранилище образов gitlab:
-	registry.lg.org/assortiment/assort/fluent-bit:4.0.4

# Посмотреть логи можно по ссылке:
https://pricing-logs.lg.org (в индексах с префиксом assort-*)

	5. Настройка системы Мониторинга
	Настройка системы Мониторинга сводится к установке и настройке двух экспортёров метрик и правки конфига Prometheus (размещенного на хосте PRICING-METRIC, 10.228.3.186)
	5.1. Установка kube-state-metric в microk8s

# Манифесты для установки kube-state-metrics расположены в /opt/kube-state-metrics

# Создать secret в неймспейсе kube-system c данными токена gitlab:
$ kubectl create secret docker-registry -n kube-system regcred --docker-username gitlab-regcred-token-asrt --docker-password gldt-LPGwj13P4-ihoCycs-RV --docker-server registry.lg.org

# Заменить дефолтный путь к образу на путь к репозиторию registry.lg.org в файле values.yaml, и добавить наименование созданного secret:
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
…
registry: registry.lg.org
  repository: assortiment/assort/kube-state-metrics
…
   registry: registry.lg.org
    repository: assortiment/assort/kube-rbac-proxy
    tag: v0.19.1
…
imagePullSecrets:
  - name: regcred
…
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Установить helm chart:
$ helm install kube-state-metrics --namespace kube-system .
	5.2. Настройка мониторинга серверных метрик хоста
Шаги ниже повторить на каждом хосте, с которого планируется собирать метрики для мониторинга:

# Создать группу и пользователя для запуска prometheus
$ sudo groupadd --system prometheus
$ sudo useradd -s /sbin/nologin --system -g prometheus exporteruser

# Скачать архив node_exporter
$ cd /u01
$ sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.9.0/node_exporter-1.9.0.linux-amd64.tar.gz

# Распаковать архив
$ sudo tar -xzvf node_exporter-1.9.0.linux-amd64.tar.gz

# Переместить файл node_exporter; настроить права
$ sudo mv /u01/node_exporter*/node_exporter /usr/local/bin/node_exporter
$ sudo chown -R exporteruser:prometheus /usr/local/bin/node_exporter
$ sudo chmod a+x /usr/local/bin/node_exporter
$ sudo rm -R /u01/node_exporter*

# Создать юнит systemd
$ sudo nano /etc/systemd/system/node_exporter.service
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[Unit]
Description=node_exporter service
Wants=network-online.target
After=network-online.target

[Service]
User=exporteruser
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$ sudo systemctl daemon-reload
$ sudo systemctl enable node_exporter.service
$ sudo systemctl start node_exporter.service
$ sudo systemctl status node_exporter.service

# Метрики доступны на порту 9100

5.3. Настройка мониторинга метрик postgresql

Шаги ниже повторить на хостах, где установлена БД postgresql (10.228.3.214, 10.228.3.215):

# Скачать архив prometheus-postgres-exporter
$ cd /u01
$ sudo wget https://debusine.debian.net/debian/base/artifact/2094155/download/prometheus-postgres-exporter_0.17.1-1+b4_amd64.deb

# Распаковать архив
$ sudo dpkg --install prometheus-postgres-exporter_0.17.1-1+b4_amd64.deb

# Для подключения к postgresql и сбора метрик, нужно прописать строку подключения к БД в файле /etc/default/prometheus-postgres-exporter
$ sudo nano /etc/default/prometheus-postgres-exporter
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DATA_SOURCE_NAME='postgresql://login:pass@assort-db-1/assortment?sslmode=disable'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Проверить содержимое юнита systemd
$ sudo nano /usr/lib/systemd/system/prometheus-postgres-exporter.service
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[Unit]
Description=Prometheus exporter for PostgreSQL
Documentation=https://github.com/prometheus-community/postgres_exporter

[Service]
User=prometheus
EnvironmentFile=/etc/default/prometheus-postgres-exporter
ExecStart=/usr/bin/prometheus-postgres-exporter $ARGS
Restart=on-failure

[Install]
WantedBy=multi-user.target
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$ sudo systemctl daemon-reload
$ sudo systemctl enable prometheus-postgres-exporter.service
$ sudo systemctl start prometheus-postgres-exporter.service
$ sudo systemctl status prometheus-postgres-exporter.service

# Метрики доступны на порту 9187 
curl -v http://localhost:9187/metrics

5.4. Настройка передачи метрик (серверных и БД) в Prometheus
# На хосте с Prometheus (PRICING-METRIC, 10.228.3.186), в конфигурационный файл /etc/prometheus/prometheus.yml прописать для контуров DEV и TEST настройки:

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  - job_name: "ASRT_PROD"
    static_configs:
      - targets: ["10.228.3.208:9100", "10.228.3.209:9100", "10.228.3.210:9100", "10.228.3.211:9100", "10.228.3.212:9100", "10.228.3.214:9100", "10.228.3.215:9100"]
        labels:
          group: "asrt_prod_server"

  - job_name: "ASRT_PG_PROD"
    static_configs:
      - targets: ["10.228.3.213:9187", "10.228.3.215:9187"]

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

$ sudo systemctl restart prometheus.service

# Доски Grafana:
●	https://pricing-metric.lg.org/d/rYdddlPWk/servers-monitoring
●	https://pricing-metric.lg.org/d/000000039/postgresql-database
	6. Обновление Kubernetes с помощью Kubeadm
	Перед началом необходимо проверить:
1.	Наличие актуального бэкапа
2.	Порядок обновления версий и их совместимость 
3.	Стутус кластера

	6.1. Процесс обновления первой Master node
# Обновляем kubeadm до нужной версии:
$ apt-get install -y kubeadm=1.32.5-00

# upgrade kubeadm:
$ kubeadm upgrade plan
$ kubeadm upgrade apply v1.32.5

# Drain'им все рабочие нагрузки с master-1:
$ kubectl drain master-1 --ignore-daemonsets

#  Обновляем kubelet и kubectl:
$ apt-get install -y kubelet=1.32.5-00 kubectl=1.32.5-00

# Перезапускаем kubelet:
$ systemctl daemon-reload
$ systemctl restart kubelet

# Вводим ноду master-1 обратно в строй:
$ kubectl uncordon master-1
	6.2. Процесс обновления второй и последующих Master node
# Обновляем kubeadm до нужной версии:
$ apt-get install -y kubeadm=1.32.5-00

# upgrade kubeadm:
$ kubeadm upgrade node

# Drain'им все рабочие нагрузки с master-2:
$ kubectl drain master-2 --ignore-daemonsets

# Обновляем kubelet и kubectl:
$ apt-get install -y kubelet=1.32.5-00 kubectl=1.32.5-00

# Перезапускаем kubelet :
$ systemctl daemon-reload
$ systemctl restart kubelet

# Вводим ноду master-2 обратно в строй:
$ kubectl uncordon master-2

	6.3. Процесс обновления лобой Worker node
# Обновляем kubeadm до нужной версии:
$ apt-get install -y kubeadm=1.32.5-00

# upgrade kubeadm:
$ kubeadm upgrade node

# Drain'им все рабочие нагрузки с worker-1:
$ kubectl drain worker-1 --ignore-daemonsets

# Обновляем kubelet и kubectl:
$ apt-get install -y kubelet=1.32.5-00 kubectl=1.32.5-00

# Перезапускаем kubelet :
$ systemctl daemon-reload
$ systemctl restart kubelet

# Вводим ноду worker-1 обратно в строй:
$ kubectl uncordon worker-1

	7. Backup
	7.1. Backup Kubernetes Resources
# Создаем бэкап всех ресурсов в Kubernetes кластере:
$ kubectl get all --all-namespaces -o yaml > kubernetes-backup.yaml

# Устанавливаем etcd-client:
$ sudo apt install etcd-client

# Получить список etcd нод:
$ ETCDCTL_API=3 etcdctl --endpoints localhost:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  member list

# Cделать бэкап etcd:
$ ETCDCTL_API=3 etcdctl --endpoints localhost:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
snapshot save etcdbackup

# Проверить созданный Backup можно командой:
$ etcdctl snapshot status /path/to/backup.db

	7.2. Восстановить etcd из бэкапа
$ ETCDCTL_API=3 etcdctl --endpoints localhost:2379 \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--data-dir restore \
snapshot restore etcdbackup

# Остановить etcd:
$ sudo systemctl stop etcd

# Заменить /var/lib/etcd/member на etcdbackup:
$ sudo rm -rf /var/lib/etcd/member
$ sudo mv restore/member /var/lib/etcd/

# Запустить etcd:
$ sudo systemctl start etcd

	8. Создание\обновление токена для подключения к Prometheus
Токен для подключения к Prometheus необходим для сбора метрик из кластера k8s. При вводе в эксплуатацию 01.09.2025 он был создан с датой завершения использования через 365 дней. Таким образом его необходимо будет заменить до 28.09.2026. Либо это можно сделать ранее, по необходимости. Для этого потребуется пройти следующие шаги: 
# Создаем переменную для подключения к API на сервере ASSORT-CTRL1:
$ KUBE_API=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')

# Генерируем токен, устанавливая время его действия на 1 год (8760h) и выводим его в файл tkn:
$ kubectl -n kube-system  create token prometheus --duration 8760h) > tkn

# Останавливаем сервис мониторинга на сервере PRICING-METRIC (prometheus для PROD развернут на хосте pricing-metric, 10.228.3.186): 
$ sudo systemctl stop prometheus

Копируем файл с сервера ASSORT-CTRL1 и заменяем им устаревший файл /etc/prometheus/tkn на сервере PRICING-METRIC

# Запускаем сервис мониторинга и убеждаемся что таргет K8s API находится в состоянии UP в консоли Prometheus -> Targets:
$ sudo systemctl start prometheus

8. Замена репозитория образов

# Прописать в конфиге containerd путь и креды к репозиторию образов:
$ nano /etc/containerd/config.toml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
…
sandbox_image = "registry.lg.org/assortiment/assort/pause:3.10"
…
    [plugins.'io.containerd.cri.v1.images'.registry.configs]
        [plugins.'io.containerd.cri.v1.images'.registry.configs.'registry.lg.org'.auth]
          auth = 'Z2l0bGFiLXJlZ2NyZWQtdG9rZW4tYXNydDpnbGR0LUxQR3dqMTNQNC1paG9DeWNzLVJW'
…
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Заменить в файле-манифесте статик-пода etcd путь к образу:
$ sudo nano /etc/kubernetes/manifests/etcd.yaml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/etcd:3.5.16-0
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Заменить в файле-манифесте статик-пода kube-apiserver путь к образу:
$ sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/kube-apiserver:v1.32.7
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Заменить в файле-манифесте статик-пода kube-controller-manager путь к образу:
$ sudo nano /etc/kubernetes/manifests/kube-controller-manager.yaml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/kube-controller-manager:v1.32.7
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Заменить в файле-манифесте статик-пода kube-scheduler путь к образу:
$ sudo nano /etc/kubernetes/manifests/kube-scheduler.yaml
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/kube-scheduler:v1.32.7
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Перечисленные до этого момента действия повторить на каждой ноде кластера k8s.

# Следующие действия выполнить только на одной ноде control plane, например, на assort-ctrl1:

# Заменить путь к образу kube-proxy: 
$ kubectl -n kube-system edit ds kube-proxy
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/kube-proxy:v1.32.7
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Обновить данные в daemonset kube-proxy:
$ kubectl -n kube-system rollout restart daemonset kube-proxy


# Заменить путь к образу coredns: 
$ kubectl -n kube-system edit deployments.apps coredns
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
image: registry.lg.org/assortiment/assort/coredns:v1.11.3	
