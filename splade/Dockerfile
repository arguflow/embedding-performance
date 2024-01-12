FROM python:3.10
WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY embeddings.py /app/embeddings.py
EXPOSE 7070

CMD ["granian", "embeddings:app", "--interface", "asgi", "--host", "0.0.0.0", "--port", "7070"]
