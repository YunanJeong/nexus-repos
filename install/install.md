# 설치 및 설정 방법

## 0. 목표

- Helm Chart와 K3s로 nexus를 배포하고, 개별 레포지토리를 구성한다
- 도커 레지스트리에 초점을 맞춰 작성
- Pypi 등 다른 레포지토리는 더 쉽거나 비슷한 과정을 거치므로 별도 검색 활용

## 1. Requirement

- [Install K3s](https://docs.k3s.io/quick-start)
- [Install Helm](https://helm.sh/docs/intro/install/)
- [시스템 요구사항](https://help.sonatype.com/repomanager3/product-information/sonatype-nexus-repository-system-requirements)

## 2. Helm Chart 추가

```sh
# 링크는 nexus 개발사에서 배포하는 공식 레포지토리다. 헬름 허브에 개인이 만든 다른 nexus 차트도 있다.
helm repo add sonatype https://sonatype.github.io/helm3-charts/
helm repo update

# 확인
helm repo list
helm search repo sonatype

# 확인시, 출력항목 중 `sonatype/nexus-repository-manager`가 가장 기본적인 nexus에 해당한다.
# 나머지는 사용목적에 따라 다른 설치버전이거나 추가 기능이다.
```

## 3. value 확인

```sh
# 디폴트로 적용되는 value 파일 확인
helm show values sonatype/nexus-repository-manager > value_default.yaml
```

## 4. value 파일 커스텀

- 다음 항목들 정도만 우선 신경써서 value_defalut.yaml을 수정한다.

- nexus.docker 하위항목
  - docker registry 접근을 위한 K8s ingress 설정을 하는 부분
- ingress 하위항목
  - nexus 서버 접근을 위한 K8s ingress 설정을 하는 부분
- [시스템 요구사항](https://help.sonatype.com/repomanager3/product-information/sonatype-nexus-repository-system-requirements)에 맞춰서 자바 힙메모리, Pod 리소스 등을 조절
  - 보통 헬름차트 기본값은 테스트실행용 최소한도로 설정됨
  - nexus.envs에서 자바 힙사이즈
  - nexus.resources에서 컴퓨팅 리소스
    - 단, Pod가 cpu 부족 로그를 찍으며 Pending 상태에 머무를 때는 이 제한을 해제한다.
  - persistence.stroageSize에서 k8s pv 사이즈 조절

## 5. nexus 실행

```sh
# 실행  # --version=54.1.0
helm install -f value_custom.yaml my-nexus sonatype/nexus-repository-manager

# 배포 확인
helm list
```

## 6. 접속 준비

- 접속할 클라이언트 PC에서 다음과 같이 hosts 파일에 내용 추가
- 이는 로컬용 도메인네임을 등록하는 과정임

```conf
# 리눅스: /etc/hosts
# 윈도우: C:\Windows\System32\drivers\etc\hosts
# 윈도우 적용시 WSL에 자동반영됨
X.X.X.X nexus.wai
X.X.X.X docker.wai
X.X.X.X private.docker.wai
```

## 7. 브라우저로 nexus 접속 후 설정

- 이전까지는 Helm과 K8s로 최소한의 배포를 하기 위한 내용이었다.
- 지금부터 nexus 내 앱 설정이 필요한데, 잘 정리된 블로그 검색 자료가 매우 많다.

- [docker-proxy registry(repository) 만들기](https://mtijhof.wordpress.com/2018/07/23/using-nexus-oss-as-a-proxy-cache-for-docker-images/)
  - 프록시 서버가 필요한 경우 docker-proxy 부분만 따라만들면 된다.
  - docker-hosted는 완전히 개인용 hub이고, 프록시만 만들 땐 필요없음
  - docker-all은 docker-proxy와 docker-hosted를 하나의 URL로 접근하기 위해 사용한 것이라 필요없음
    - 다른 컨테이너 런타임은 안그런데 도커는 한 번에 하나의 저장소URL만 참조하기 때문

- Foreign Layer Caching
  - 3.19버전 부터 등장한 옵션
  - Repository 설정에서 이걸 활성화 해줘야 docker pull 할 때 캐시가 프록시 레포지토리에 남는다.
  - [[1] 최근 버전 관련 이슈](https://community.sonatype.com/t/caching-images-on-docker-proxy-repository/3496/4)
  - [[2] 공홈 Foreign Layer 설명](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/foreign-layers)

## 기타 nexus 설정 시 참고사항

- [Proxy Repo엔 Push 불가](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/pushing-images)
- [Group Repo에 Push 기능은 Nexus Pro버전에서 허용](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/pushing-images-to-a-group-repository)
- 무료 버전에서 사설 레지스트리와 프록시 레지스트리를 하나의 group port로 운용할 수는 없다. Hosted Repo에 개별 포트를 열어서 Push 해야한다.
- Hosted Repo에 Push한 이미지를 Group Repo에서 Pull하는 것은 가능
- https (외부 배포시)
  - 도커 V2 (API Version 1.10 이상)의 도커 런타임들은 https 저장소만 쓰길 강제한다.
  - 인증서를 받아서 nexus에 https를 적용하는 것이 바람직하다.
- nexus의 메모리 사용량
  - `k top nodes`, `k9s`, `호스트의 top`, `컨테이너 내부 top`` 모두 극단적으로 다르게 표기될 수 있다.
  - nexus는 캐시메모리를 많이 사용하고, 이는 측정툴에 따라 포함되기도하고 안되기도 하기 때문이다.
  - `메모리가 널널해보이더라도 함부로 서버 사양을 스케일다운하지말고, 공식홈페이지 사양을 참고하여 세팅`하도록 한다.
