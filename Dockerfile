# Dockerfile

# Stage 1: 빌드 단계 (종속성 설치)
FROM python:3.10-alpine AS builder

# Alpine Linux의 패키지 관리자를 사용하여 빌드에 필요한 시스템 종속성 설치
RUN apk add --no-cache build-base linux-headers libffi-dev

# 작업 디렉토리 설정
WORKDIR /app

# requirements-tests.txt 파일을 복사하고 Python 종속성 설치
COPY requirements-tests.txt .
RUN pip install --no-cache-dir -r requirements-tests.txt

# Stage 2: 최종 이미지 (런타임)
FROM python:3.10-alpine

# 런타임에 필요한 최소한의 시스템 패키지 설치
RUN apk add --no-cache libffi

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 스테이지에서 설치된 Python 패키지들을 복사
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 'tests' 폴더만 컨테이너의 작업 디렉토리로 복사
# 프로젝트 루트 디렉토리에 'tests' 폴더가 있다고 가정합니다.
COPY tests ./tests

# 애플리케이션이 실행될 포트를 노출합니다.
EXPOSE 8080

# Gunicorn을 사용하여 FastAPI 애플리케이션을 실행합니다.
# 단일 노드 환경에 맞게 워커 수를 1개로 설정했습니다.
# tests/main.py 파일 내에서 'app' 객체가 FastAPI 애플리케이션 인스턴스라고 가정합니다.
CMD ["gunicorn", "tests.main:app", "--workers", "1", "--bind", "0.0.0.0:8080"]
