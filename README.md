# ToothFairy Japan

[1.0 다운로드](https://github.com/leejg04133-create/ToothFairy_Japan/releases/tag/1.0)

처음 설치할 때는 `ToothFairyJapan-1.0-Windows.zip`을 받아 압축을 푼 뒤 `ToothFairyJapan.exe`를 실행하세요. 로컬 AI와 AivisSpeech 음성 엔진은 앱의 설치 화면에서 따로 설치합니다.

이전에 받은 1.00을 이번 1.0으로 교체할 때는 ZIP을 수동으로 받아 사용하세요. 같은 번호를 교체했으므로 이전 앱에 새 버전 알림은 뜨지 않습니다. 이전 업데이트 주소도 유효하지 않았습니다.

## 다음 버전 게시

1. EXE의 `FileVersion`을 새 번호로 빌드합니다. 예: `1.0.1.0` → 릴리스 태그 `1.0.1`, `1.1.0.0` → `1.1`.
2. GitHub Releases에서 같은 숫자 태그로 정식 릴리스를 만들고 `ToothFairyJapan.exe`를 첨부합니다. 신규 설치용 ZIP에는 EXE, config, 필요한 DLL도 포함합니다.
3. Publish 후 **Publish EXE update info** 작업이 성공하면 `latest.json`이 자동 갱신됩니다. 앱 설정의 업데이트에서 더 높은 번호를 감지하고, 크기·SHA-256·EXE 내부 버전을 검증한 뒤 적용합니다.

미리보기 릴리스, 버전 하향, 기존 번호의 다른 파일은 자동 게시하지 않습니다. 프로그램은 다운로드 검증 과정에서 실행하지 않습니다. 향후 DLL 구성도 바뀌는 릴리스는 EXE 단독 업데이트 호환성을 별도로 확인해야 합니다.
