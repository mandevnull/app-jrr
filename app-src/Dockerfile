FROM python:3.11-slim

RUN useradd -m jrr

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

User jrr

EXPOSE 8080

CMD ["python", "app.py"]

