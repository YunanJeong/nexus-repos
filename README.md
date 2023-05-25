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
        - docker registry 접근을 위한 K8s ingress 설정
    - ingress 하위항목
        - nexus 서버 접근을 위한 K8s ingress 설정
    - resources 하위항목
        - 컴퓨팅 리소스 점유율 조절

5. nexus 실행
    ```
    # 실행
    helm install -f value_custom.yaml my-nexus sonatype/nexus-repository-manager

    # 배포 확인
    helm list
    ```
6. 브라우저로 nexus 접속 후 설정
    - 여기서부터는 블로그 자료가 매우 많다.

    - https://mtijhof.wordpress.com/2018/07/23/using-nexus-oss-as-a-proxy-cache-for-docker-images/
    - Foreign Layer Caching
        - 3.19버전 부터 등장한 옵션
        - Repository 설정에서 이걸 활성화 해줘야 docker pull 할 때 캐시가 프록시 레포지토리에 남는다.
        - [1](https://community.sonatype.com/t/caching-images-on-docker-proxy-repository/3496/4)
        - [2](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/foreign-layers)



# 활용
- 도커에서 로그인

- K3s에서 로그인
