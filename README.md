# 아이곁에

지역 아동돌봄 기관 정보와 후원·봉사·물품기부 참여를 연결하는 웹앱 MVP입니다.

## 실행

```bash
python3 -m http.server 8000
```

브라우저에서 `http://127.0.0.1:8000` 을 열면 됩니다.

## 현재 포함 기능

- 지역/기관유형/참여방식 기준 탐색
- 기관 카드 선택 시 우측 상세 패널 표시
- 검증 상태, 출처, 업데이트 주기 안내
- 지금 필요한 도움 카드 피드
- 처음 참여하는 사용자를 위한 3단계 가이드
- 탐색 결과 요약 통계 카드

## 파일 구성

- `index.html` : 단일 파일 웹앱
- `tests/test_app_contract.py` : 계약 테스트
- `scripts/publish-cloudflare-tunnel.sh` : Cloudflare 로그인 후 고정 hostname용 named tunnel 실행 스크립트

## 고정 Cloudflare 주소로 열기

현재는 Quick Tunnel 임시 주소만 바로 열 수 있고, **고정 주소**는 Cloudflare 계정 인증이 먼저 필요합니다.

1. 이 Mac에서 Cloudflare 로그인 실행
   ```bash
   cloudflared tunnel login
   ```
2. 로그인 완료 후 로컬 서버 실행
   ```bash
   python3 -m http.server 8000
   ```
3. 고정 hostname으로 named tunnel 실행
   ```bash
   ./scripts/publish-cloudflare-tunnel.sh aigyeote <원하는-호스트명> 8000
   ```

예:
```bash
./scripts/publish-cloudflare-tunnel.sh aigyeote aigyeote.example.com 8000
```
