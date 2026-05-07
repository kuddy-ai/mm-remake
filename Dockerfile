FROM docker.1ms.run/barichello/godot-ci:4.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-xserver-utils \
    libgl1 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    fonts-noto-cjk \
    fonts-wqy-zenhei \
    pulseaudio-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . .

CMD ["godot", "--path", ".", "--display-driver", "x11", "--rendering-driver", "opengl3"]
