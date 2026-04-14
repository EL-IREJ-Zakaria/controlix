from controlix_agent import create_app

try:
    from waitress import serve
except ImportError as error:
    raise RuntimeError(
        "Waitress is required. Install dependencies with 'pip install -r agent/requirements.txt'."
    ) from error


app = create_app()


if __name__ == "__main__":
    settings = app.config["SETTINGS"]
    print(f"Starting Controlix agent on http://{settings.host}:{settings.port}")
    serve(app, host=settings.host, port=settings.port, threads=8)
