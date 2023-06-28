# 프록시 PyPi 활용방법

- 다음 내용으로 `/etc/pip.conf`에 파일 추가
- index-url은 레포지토리 설정에서 제공된 url에 `/simple`을 붙인다.
```
# /ete/pip.conf 리눅스 기준
[global]
index-url=http://nexus.wai/repository/pypi-wai-proxy/simple
trusted-host=nexus.wai
```
- 실행
```
pip install XXXXX
```