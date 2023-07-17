# 사설 도커 레지스트리 활용 방법
## docker pull/push 하기
0. 로그인을 위한 사전 작업
    - https (외부 배포시)
        - 도커 V2 (API Version 1.10 이상)의 도커 런타임들은 https 저장소만 쓰길 강제한다.
        - 인증서를 받아서 nexus에 https를 적용하는 것이 바람직하다.
    - http (내부망 간편 용도)
        - `/etc/docker/daemon.json`에 다음과 같이 보안 예외 URL을 등록해준다. 파일 없으면 생성.
            ```
            {
                "insecure-registries": ["docker.wai"],
                "registry-mirrors": ["http://docker.wai"]
            }
            ```
        - 도커 런타임 재시작(docker-cli, docker-desktop 등)
            ```
            # docker-cli기준
            sudo systemctl restart docker
            ```
1. `docker login {저장소 URL}`
    ```
    # e.g.
    docker login docker.wai
    ```
    - 이 때 저장소 URL은 nexus 웹페이지 설정에 있는 subpath URL이 아니고, ingress설정 및 hosts 파일에 기입해놓은 URL을 적어야 한다.

2. `docker pull {저장소 URL}/{이미지}`
    ```
    # e.g.
    docker pull docker.wai/hello-world:latest
    ```
    - nexus에 해당 이미지가 있으면 그것을 pull하고, 아니면 nexus 저장소에서 바라보는 docker hub로부터 pull하게 된다.
    - **저장소 URL을 쓰지 않는 경우 동작방식**
        ```
        docker pull hello-world:latest
        ```
        - **docker cli에서 도커허브와 Proxy Repo 모두 로그인된 상태이면, 저장소 URL이 없을 때 docker hub를 default로 쓴다. 따라서 Proxy Repo에 캐시 이미지가 남지 않는다.**
        - Proxy Repo만 로그인된 상태이면, Proxy Repo에 캐시 이미지가 남으며, 로컬 이미지에는 docker.io접두어가 붙는다.
    

3. `docker push {저장소 URL}/{이미지}`
    ```
    # e.g.
    docker tag hello-world docker.wai/hello-world
    docker push docker.wai/hello-world
    ```
    - **push 할때는 tag 명령어로 이미지 이름(REPOSITORY) 앞에 저장소 URL을 붙여준 후 진행한다.**
    - [Proxy Repo엔 Push 불가](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/pushing-images)
    - [Group Repo에 Push 기능은 Nexus Pro버전에서 허용](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/pushing-images-to-a-group-repository)
    - 무료 버전에서 사설 레지스트리와 프록시 레지스트리를 하나의 group port로 운용할 수는 없다. Hosted Repo에 개별 포트를 열어서 Push 해야한다. 
    - Hosted Repo에 Push한 이미지를 Group Repo에서 Pull하는 것은 가능

## Minikube에서 저장소 사용법
0. container runtime으로 docker를 사용하는 것으로 가정
1. 위 docker 설정을 완료
2. 기존 minikube 클러스터 삭제
    ```
    minikube delete
    ```
3. minikube start --insecure-registry="{저장소URL:PORT}"
    ```
    # e.g.
    minikube start --insecure-registry="docker.wai"
    
    # e.g. 여러 개 등록하는 경우
    minikube start --insecure-registry="docker.wai, private.docker.wai"
    ``` 

4. pull
    ```
    minikube image pull docker.wai/hello-world:latest
    ```
5. 확인
    ```
    minikube image ls
    ```
6. 참고사항
    - 반드시 기존 클러스터 지우고 새로 시작해야 함
    - minikube addons의 registry는 minikube자체에서 사설 registry를 구축하는 용도라서, nexus 저장소 연결하는 것과는 다름
    - minikube image 커맨드로 push, tag 서브 커맨드를 사용하면 의도치 않게 작동한다.
        - minikube 내 이미지 관리는 `minikube ssh` 후 **minikube 컨트롤플레인 내부의 docker-cli**를 사용하는 것이 좋음. 해당 docker 정보는 `minikube docker-env`를 통해서도 확인가능

## K3s에서 저장소 사용법

- [K3s에서 private registry 사용법(공식)](https://docs.k3s.io/installation/private-registry)
- 단, K3s의 컨테이너 런타임으로 docker사용시, docker에 대한 private registry 설정만 하면 된다. 별도 K3s 설정은 필요없다.

0. `/ete/rancher/k3s/registries.yaml` 파일 추가
    ```
    # /etc/rancher/k3s/registries.yaml
    mirrors:
      docker.wai:
        endpoint:
          - "http://docker.wai"
    configs:
      "docker.wai":
        auth:
          username: xxxxxx # this is the registry username
          password: xxxxxx # this is the registry password
    ```
1. k3s 재시작
    ```
    sudo systemctl restart k3s
    ```
2. pull
    ```
    # e.g.
    sudo k3s crictl image pull docker-wai/hello-world
    ```
3. 확인
    ```
    sudo k3s crictl images
    ```

4. 쿠버네티스 노드(k3s-agent)만 실행되는 호스트인 경우 설정방법
    - 위 과정과 동일
    - `/ete/rancher/k3s/registries.yaml` 파일 추가 (경로가 없으면 똑같이 생성.)
    - 서비스 재실행
    ```
    sudo systemctl restart k3s-agent
    ```