# nexus-repos
nexus 구축 과정, 설명 및 사용법 정리

# 설치 및 설정 방법(Helm, K3s로 nexus 배포 후 개별 세부 설정)
- [설치](https://github.com/YunanJeong/nexus-repos/blob/main/install/install.md)

# 레포지토리 활용방법

## 사전준비(공통)
- 각 저장소는 IP가 아닌, URL로 접근해야 합니다.
    - 다음과 같이 hosts 파일에 추가
        ```
        X.X.X.X nexus.wai
        X.X.X.X docker.wai
        X.X.X.X private.docker.wai
        ```
    - 리눅스의 경우: `/etc/hosts`
    - 윈도우의 경우: `C:\Windows\System32\drivers\etc\hosts`
    - WSL: 윈도우 적용시 같이 적용됨

- 저장소 및 계정관리 웹 페이지(`http://nexus.wai`)
- 계정정보는 도커cli 로그인할 때 사용

## 도커
- [사설+프록시 도커 레지스트리](https://github.com/YunanJeong/nexus-repos/blob/main/how-to-use/how-to-use-docker-wai.md)

## 파이썬
- [PyPi 프록시](https://github.com/YunanJeong/nexus-repos/blob/main/how-to-use/how-to-use-pypi-wai.md)


