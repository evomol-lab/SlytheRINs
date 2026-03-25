# Use lightweight Python image
FROM python:3.10-slim

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system dependencies (common for bio/plotting libs)
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    git \
    curl \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy repo
COPY . /app

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

# Install Python dependencies
# Prefer repo requirements if available
RUN if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt ; \
    else \
        pip install --no-cache-dir \
            streamlit \
            pandas \
            numpy \
            scipy \
            matplotlib \
            seaborn \
            networkx \
            plotly ; \
    fi

# Expose Streamlit port
EXPOSE 8501

# Streamlit config (avoid CORS / headless issues)
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0

# Default command (adjust entrypoint if needed)
CMD ["streamlit", "run", "SlytheRINs.py", "--server.port=8501", "--server.address=0.0.0.0"]