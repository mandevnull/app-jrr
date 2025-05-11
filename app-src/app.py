from flask import Flask, Response
import os
import base64

IMG_PATH = os.environ["IMG_PATH"]
IMG_NAME = os.environ["IMG_NAME"]
APP_VERSION = os.environ.get("APP_VERSION", "unknown")

app = Flask(__name__)

@app.route("/")
def serve_index():
    image_file_path = os.path.join(IMG_PATH, IMG_NAME)

    if not os.path.isfile(image_file_path):
        return Response("Image not found", status=404)

    with open(image_file_path, "rb") as image_file:
        image_data = base64.b64encode(image_file.read()).decode("utf-8")

    html = f"""
    <!DOCTYPE html>
    <html>
    <head><title>App JRR</title></head>
    <body>
        <h1>APP-JRR Version: {APP_VERSION}</h1>
        <img src="data:image/jpeg;base64,{image_data}" alt="App Image" style="max-width: 500px; height: auto;" />
    </body>
    </html>
    """
    return Response(html, mimetype="text/html")

@app.route("/healthz")
def health_check():
    image_file_path = os.path.join(IMG_PATH, IMG_NAME)
    if os.path.isfile(image_file_path):
        return Response("OK", status=200)
    return Response("Image not found", status=500)

if __name__ == "__main__":
    print(f"Starting app version: {APP_VERSION}")
    app.run(host="0.0.0.0", port=8080)

