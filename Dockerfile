FROM barichello/godot-ci:4.3.0
WORKDIR /workspace
COPY . .
CMD ["godot", "--headless", "--path", ".", "--quit-after", "1000"]
