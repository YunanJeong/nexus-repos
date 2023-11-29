# nexus-repos

nexus 구축 과정, 설명 및 사용법 정리

## 레포지토리 구축방법

- [설치](https://github.com/YunanJeong/nexus-repos/blob/main/install/install.md)

## 레포지토리 활용방법

### 사전 준비(공통사항)

- 각 저장소는 URL로 접근 해야 함(IP로 접속불가)
- 접속할 클라이언트 PC에서 다음과 같이 hosts 파일에 내용 추가

```conf
# 리눅스: /etc/hosts
# 윈도우: C:\Windows\System32\drivers\etc\hosts
# 윈도우 적용시 WSL에 자동반영됨
X.X.X.X nexus.wai
X.X.X.X docker.wai
X.X.X.X private.docker.wai
```

- 브라우저에서 <http://nexus.wai>로 접속 후, 로그인하여 패스워드를 변경

### [사설+프록시 도커 레지스트리](https://github.com/YunanJeong/nexus-repos/blob/main/how-to-use/docker.wai.md)

### [PyPi 프록시](https://github.com/YunanJeong/nexus-repos/blob/main/how-to-use/pypi.wai.md)
