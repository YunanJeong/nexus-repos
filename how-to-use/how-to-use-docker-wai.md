# 도커 사설 및 프록시 레지스트리 사용방법

## Docker Runtime에서 사용법

### http 저장소 보안 허용

- `/etc/docker/daemon.json`에 보안 예외 등록(파일 없으면 생성)
- Indent에 매우 민감하므로 복사해서 이용 추천

```conf
{
  "insecure-registries": ["private.docker.wai", "docker.wai"],
  "registry-mirrors": ["http://private.docker.wai","http://docker.wai"]
}
```

- 도커 재시작

```sh
# docker-cli 기준
sudo systemctl restart docker
```

### Pull (docker.wai, 로그인 필요없음)

```sh
# e.g. 저장소 URL 표기 필수
docker pull docker.wai/hello-world:latest
```

### Push (private.docker.wai)

```sh
# docker login {저장소 URL}
docker login private.docker.wai

# e.g. 대상 저장소에 맞게 이미지 이름 변경
docker tag docker.wai/hello-world:latest private.docker.wai/hello-world:pushtest

# e.g. private.docker.wai에 push
docker push private.docker.wai/hello-world:pushtest
```

### docker 참고

- Push는 private.docker.wai, Pull은 docker.wai를 사용하면 됨
- Anonymous Pull 허용
  - Pull은 로그인 없이 가능
  - EC2 보안그룹 등 네트워크 보안환경설정이 있을 때만 추천

- private.docker.wai (hosted)
  - **커스텀 이미지를 Push/Pull** 가능
  - 업로드된 커스텀 이미지는 **docker.wai를 통해서도 Pull 가능**

- docker.wai (group)
  - **Pull 전용**
  - [도커 공식 허브](https://registry-1.docker.io)의 이미지 Pull 가능 (proxy)
  - private.docker.wai의 커스텀 이미지 Pull 가능

## Minikube에서 사용법

### minikube 설정

```sh
# 0. container runtime으로 docker를 사용하는 것으로 가정

# 1. 위 docker 설정을 완료

# 2. 기존 minikube 클러스터 삭제
minikube stop
minikube delete

# 3. http 저장소 보안 허용
# minikube start --insecure-registry="{저장소URL:PORT}"
minikube start --insecure-registry="docker.wai, private.docker.wai"

# 4. Pull Test
minikube image pull docker.wai/hello-world:latest

# 5. 확인
minikube image ls
```

### minikube 내 이미지 관리
  
```sh
# minikube 내부 docker정보 확인
minikube docker-env

# minikube 내부 접근 후 docker cli 사용
minikube ssh
docker info

# 'minikube image' 커맨드는 비추천. 일부 기능이 docker와 다르게 동작함.
```

### minikube 참고

- **반드시 기존 클러스터 지우고(delete) 새로 시작 필요**
- minikube는 **"클러스터 최초 생성시 호스트 docker login"** 정보를 내부 docker에서 그대로 사용함
- minikube addons의 registry는 minikube자체에서 사설 registry를 구축하는 용도라서, 외부 사설 저장소 연결과는 무관한 기능임
- KUBECONFIG 오류시, 로그인 정보가 비활성화 될 수 있음

## K3s에서 사용법

### K3s 참고

- [K3s에서 private registry 사용법(공식)](https://docs.k3s.io/installation/private-registry)
- K3s의 컨테이너 런타임으로 docker사용시, docker에 대한 private registry 설정만 하면 된다. 별도 K3s 설정은 필요없다.
- K3s default인 containerd 사용시 아래 절차를 따른다.

### K3s 설정

- `/etc/rancher/k3s/registries.yaml` 파일 추가

```conf
# /etc/rancher/k3s/registries.yaml
mirrors:
  docker.wai:
    endpoint:
      - "http://docker.wai"
configs:
  "docker.wai":
    auth:
      username: xxxxxx  # nexus 아이디 입력 필요
      password: xxxxxx  # nexus 비번 입력 필요
```

- 설정 반영 및 확인

```sh
# K3s 재시작
sudo systemctl restart k3s

# Pull Test
sudo k3s crictl image pull docker-wai/hello-world

# 확인
sudo k3s crictl images
```

### 컨트롤 플레인이 아닌 노드(k3s-agent)만 실행되는 호스트에서 설정방법

- `/etc/rancher/k3s/registries.yaml` 경로 및 파일을 위 과정과 동일하게 생성
- 서비스 재실행

```sh
sudo systemctl restart k3s-agent
```
