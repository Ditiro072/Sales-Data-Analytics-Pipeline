# Use official Python slim image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install system dependencies for pyodbc & SQL Server ODBC
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    build-essential \
    gcc \
    g++ \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    apt-transport-https \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft repo & install ODBC 18
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg \
    && curl https://packages.microsoft.com/config/debian/11/prod.list -o /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Run ETL script
CMD ["python", "etl.py"]