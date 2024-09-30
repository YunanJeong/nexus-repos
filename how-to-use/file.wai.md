# 파일 저장소 사용법

## 용도

- 개발망에서 플러그인 파일을 설치
  - connector, db driver 등
- helm 차트 아카이브 파일 URL로 설치 등

## 업로드

0. GUI(<http://nexus.wai>) 접속 후 저장소 목록에서 `file-wai` 선택
1. `Upload component`메뉴 진입
2. `Browse`로 로컬 파일 선택
3. `Directory`에 저장소 내 하위경로 입력

## 다운로드

- GUI 저장소에서 원하는 파일 클릭
- `우측 사이드바-Path` 에서 다운로드
- 다운로드용 URL에서 nexus.wai 대신 `{IP주소}:8081`로 접근가능(hosts 설정이 힘들 때 8081포트로 직접접근)

## 콘솔

```sh
# 업로드
# curl -u {아이디}:{비번} --upload-file {로컬파일} http://nexus.wai/repository/file-wai/{저장소 내 경로지정}/
# 마지막에 슬래시(/) 필수
curl -u yunan:passwd --upload-file ./file.txt http://nexus.wai/repository/file-wai/yunan/
```

```sh
# 다운로드
# URL은 GUI에서 링크복사가능
# http://nexus.wai/repository/file-wai/{파일경로 및 파일명}
curl -LO {URL}
wget {URl}
```
