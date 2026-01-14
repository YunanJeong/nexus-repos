# Ubuntu APT debian package 프록시 사용방법

- ubuntu 24.04 기준, 다음 파일 추가
- `/etc/apt/source.list.d/nexus.sources`
- `sudo apt update` 실행하여 적용

## 파일 예시

```/etc/apt/source.list.d/nexus.sources
Types: deb
URIs: http://nexus.wai/repository/apt-wai-proxy/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

## 파일 예시 (일반 포맷)

```/etc/apt/source.list.d/nexus.sources
Types: deb
URIs: http://<NEXUS-URL>/repository/<REPOSITORY-NAME>/
Suites: <DISTRIBUTION-NAME> <DISTRIBUTION-NAME>-updates <DISTRIBUTION-NAME>-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```
- NEXUS-URL: nexus 레포지토리 설정에서 확인가능
- REPOSITORY-NAME: nexus에서 설정한 레포지토리 이름
- DISTRIBUTION-NAME: noble, jammy 등 클라이언트 실제 OS의 코드명을 기술한다. (lsb_release -a로 조회가능)
  - 참고: nexus 레포지토리 설정에서 distribution 이름을 지정한 것은 아무 의미 없음. 거긴 그냥 아무 텍스트나 적어도 됨.
  - distribution 이름 설정은 원래는 저장소 별 특정 OS버전에 대응하게 하려고 만들어진 부분인데, 그것 없이도 요즘은 한 저장소가 여러 OS버전에 대응가능하기 때문
  - 클라이언트 측에서 요구하는 OS코드명에 따라 알아서 잘 처리됨
