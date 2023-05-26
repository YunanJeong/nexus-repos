# nexus-repos
nexus 구축 과정 정리


0. 목표
- Helm Chart와 K3s로 nexus를 배포하고, 도커 레지스트리 프록시를 구성한다

1. Helm 및 K3s 설치
    ```
    # Helm - K3s 연결
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    # K3s
    curl -sfL https://get.k3s.io | sh -
    sudo chmod -R 777 /etc/rancher/k3s/k3s.yaml  # kubectl에 sudo 없애기, 작업때만 임시로 전체 허용

    # Helm
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    ```

2. Helm Chart 추가
    ```
    # 링크는 nexus 개발사에서 배포하는 공식 레포지토리다. 헬름 허브에 개인이 만든 다른 nexus 차트도 있다.
    helm repo add sonatype https://sonatype.github.io/helm3-charts/
    helm repo update
    ```
    - 확인
    ```
    helm repo list
    helm search repo sonatype
    ```
        - 출력항목 중 `sonatype/nexus-repository-manager`가 가장 기본적인 nexus에 해당한다.
        - 나머지는 사용목적에 따라 다른 설치버전이거나 추가 기능이다.

3. value 확인
    ```
    # 디폴트로 적용되는 value 파일 확인
    helm show values sonatype/nexus-repository-manager > value_default.yaml
    ```

4. value 파일 커스텀
    - 다음 항목들 정도만 우선 신경써서 value_defalut.yaml을 수정한다.

    - nexus.docker 하위항목
        - docker registry 접근을 위한 K8s ingress 설정을 하는 부분
    - ingress 하위항목
        - nexus 서버 접근을 위한 K8s ingress 설정을 하는 부분
    - 시스템 요구사항
        - [공식](https://help.sonatype.com/repomanager3/product-information/sonatype-nexus-repository-system-requirements)
        - 보통 헬름차트 기본값은 테스트실행용 최소한도로 설정되어 있다.
        - nexus.envs에서 자바 힙사이즈 조절
        - nexus.resources에서 컴퓨팅 리소스 조절
            - 단, Pod가 cpu 부족 로그를 찍으며 Pending 상태에 머무를 때는 이 제한을 해제한다.
        - persistence.stroageSize에서 k8s pv 사이즈 조절
    
5. nexus 실행
    ```
    # 실행
    helm install -f value_custom.yaml my-nexus sonatype/nexus-repository-manager

    # 배포 확인
    helm list
    ```

6. 접속 준비
    - 다음과 같이 hosts 파일에 추가
        ```
        X.X.X.X nexus.wai
        X.X.X.X docker.wai
        ```
    - 리눅스의 경우: `/etc/hosts`
    - 윈도우의 경우(WSL포함): `C:\Windows\System32\drivers\etc\hosts`

7. 브라우저로 nexus 접속 후 설정
    - 이전까지는 최소한의 배포에 대한 내용이었고, nexus 내 앱 설정이 필요하다.
    - 여기서부터는 블로그 검색 자료가 매우 많다.

    - https://mtijhof.wordpress.com/2018/07/23/using-nexus-oss-as-a-proxy-cache-for-docker-images/
    - Foreign Layer Caching
        - 3.19버전 부터 등장한 옵션
        - Repository 설정에서 이걸 활성화 해줘야 docker pull 할 때 캐시가 프록시 레포지토리에 남는다.
        - [1](https://community.sonatype.com/t/caching-images-on-docker-proxy-repository/3496/4)
        - [2](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/foreign-layers)



# 활용
## nexus 저장소에서 docker pull 하기
- 도커 V2 (API Version 1.10 이상)부터 항상 https의 저장소만 쓰게 되어 있다.
- nexus 레포지토리도 외부 배포한다면, 인증서를 받아서 https로 적용하는 것이 가장 바람직하다.
- 그러나 내부망에서 간편하게 쓸 용도라면 다른 방법도 있다.
    - nexus는 http 기준으로 설정해놓는다.
    - 도커 설정에서 해당 nexus 서버는 보안 예외 사항으로 적용할 수 있다.
    - `/etc/docker/daemon.json`으로 다음 내용 파일을 생성한다.
    ```
    {
        "insecure-registries": ["docker.wai"],
        "registry-mirrors": ["http://docker.wai"]
    }
    ```
    - 도커 재시작
        ```
        sudo systemctl restart docker
        ```
- 로그인
    - `docker login {저장소 URL}`
    - 이 때 저장소 URL은 nexus 웹페이지 설정에 있는 URL이 아니고, ingress설정 및 hosts 파일에 기입해놓은 URL을 적어야 한다.
        - e.g. docker login docker.wai



- K3s에서 로그인
