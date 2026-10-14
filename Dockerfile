# SlytheRINs: Residue Interaction Network analysis dashboard (Streamlit)
#
# Build: docker build -t evomol/slytherins .
# Run:   docker run --rm -p 8501:8501 evomol/slytherins
#        then open http://localhost:8501
FROM python:3.12-slim-trixie

LABEL org.opencontainers.image.title="SlytheRINs" \
      org.opencontainers.image.description="Residue Interaction Network (RIN) analysis dashboard" \
      org.opencontainers.image.source="https://github.com/evomol-lab/SlytheRINs" \
      org.opencontainers.image.vendor="EvoMol-Lab, BioME, UFRN"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore \
    STREAMLIT_SERVER_PORT=8501 \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0 \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false

# Kaleido (>= 1) needs Chromium to export Plotly figures as PNG (plot downloads, PDF and ZIP reports).
# fonts-liberation provides the fonts Chromium uses to draw the plot text.
RUN apt-get update \
    && apt-get install -y --no-install-recommends chromium fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installed before copying the app, so code changes don't trigger a reinstall of the dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Only the files the app reads at runtime
COPY SlytheRINs.py SlytheRINs-logo2.png documentation.md ./
COPY fonts/ fonts/
COPY example_data/ example_data/

RUN useradd --create-home --uid 1000 slytherins
USER slytherins

EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8501/_stcore/health')"

CMD ["streamlit", "run", "SlytheRINs.py"]
