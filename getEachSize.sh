#!/bin/bash

# 저장소에서 개별 이미지 용량 확인 기능을 제공하지 않음
# 저장소 관리를 위해, 스크립트를 통해 간접적으로 파악해야 함

# 설정값 (사용자 환경에 맞게 수정)
REGISTRY="http://docker.wai"

# 로그인 필요시 각 curl 문에서 -u "$USERNAME:$PASSWORD" 추가
# USERNAME="<username>"
# PASSWORD="<password>"


# 1. 모든 이미지(레포지토리) 목록 조회
IMAGES=$(curl -s -k  "$REGISTRY/v2/_catalog" | jq -r '.repositories[]')

for IMAGE in $IMAGES; do
  # 2. 각 이미지의 태그 목록 조회
  TAGS=$(curl -s -k  "$REGISTRY/v2/$IMAGE/tags/list" | jq -r '.tags[]?')
  
  if [ -z "$TAGS" ]; then
    echo "[!] $IMAGE: 태그 없음"
    continue
  fi

  for TAG in $TAGS; do
    # 3. 매니페스트 조회 (v2 manifest 요청)
    MANIFEST=$(curl -s -k  \
      -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
      "$REGISTRY/v2/$IMAGE/manifests/$TAG")

    # 4. 멀티 아키텍처 이미지인지 확인
    if echo "$MANIFEST" | jq -e '.manifests' > /dev/null; then
      # Case 1: 멀티 아키텍처 이미지 (매니페스트 리스트)
      # hello-world:latest 와 같이 UI에서 단일 이미지로 보이지만,
      # 실제론 플랫폼 별 digest가 있어 멀티태그를 가진 경우가 있음. 이를 별도 처리
      TOTAL_SIZE=0
      DIGESTS=$(echo "$MANIFEST" | jq -r '.manifests[].digest')
      
      for DIGEST in $DIGESTS; do
        # 플랫폼별 매니페스트에서 레이어 크기 합산
        SIZE=$(curl -s -k  \
          -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
          "$REGISTRY/v2/$IMAGE/manifests/$DIGEST" \
          | jq '[.layers[].size] | add // 0')
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
      done
      echo -e "[MultiTag]\t$IMAGE:$TAG\t${TOTAL_SIZE}\t$(numfmt --to=iec $TOTAL_SIZE)"

    else
      # Case 2: 단일 아키텍처 이미지
      SIZE=$(echo "$MANIFEST" | jq '[.layers[].size] | add // 0')
      echo -e "[SingleTag]\t$IMAGE:$TAG\t${SIZE}\t$(numfmt --to=iec $SIZE)"
    fi
  done
done

# \t 으로 구분시,
# sort -k: (key) 특정 컬럼 기준으로 정렬
# sort -n: (numeric)숫자 크기 기준으로 정렬
# sort -r: (reverse)역순
# e.g.) sort -k3 -n -r mylist.txt => 세번 째 컬럼 기준으로, 문자가 아닌 숫자크기 기준으로, 내림차순으로 정렬
# e.g.) column -t -s $'\t' => 특정 구분자에 대하여 표 형태로 각 잡아서 출력
# cat mylist.txt | sort -k3 -n -r | column -t -s $'\t'