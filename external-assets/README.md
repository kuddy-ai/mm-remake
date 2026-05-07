# External Assets Storage

此目录用于存放原始设计文件和大文件，**不会提交到 Git**。

## 目录结构

```text
external-assets/
├── original-images/         # 原始设计图、高清大图、AI生成原图
├── art-source/              # PSD、Aseprite、Krita、Clip Studio源文件
├── audio-source/            # 音频母带 WAV、工程文件
├── audio-stems/             # 音频分轨文件
├── ai-generated-originals/  # AI 生成的原始文件
└── references/              # 外部参考资料
```

## 存放内容

- PSD、AI、KRA、CLIP、Aseprite 等源文件
- TIFF、超大 PNG 原始设计图
- 音频母带 WAV、分轨文件
- FL Studio、Ableton、Logic 工程文件
- 高清视频素材
- 其他不适合提交的大型素材

## 压缩后的参考图

压缩后的参考图放在 `docs/concept-art/wasteland_hunter_design_images/`。

## 注意

- 此目录已加入 `.gitignore`
- 请勿将此目录提交到 Git
- 源文件格式（*.psd, *.aseprite 等）也被 gitignore 排除