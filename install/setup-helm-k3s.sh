# Helm - K3s 연결
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# K3s
curl -sfL https://get.k3s.io | sh -
sudo chmod -R 644 /etc/rancher/k3s/k3s.yaml

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# 헬름 쓸 때는 sudo 없이 쓰는게 낫다.
helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm repo update
helm repo list
helm search repo sonatype
