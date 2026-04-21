# Marker_ENV

## Install

```pwsh
./task/Install.ps1
```

## Usage

```pwsh
./task/Process-File.ps1 "file.path.pdf"
```

or

```pwsh
./task/Process-File.ps1 "file1.path.pdf" "file2.path.pdf"
```

or

```pwsh
./task/Process-File.ps1 @(
  "file1.path.pdf"
  "file2.path.pdf"
)
```

or

```pwsh
./task/Process-Folder.ps1 "folder.path/"
```

or

```pwsh
./task/Process.ps1 "file.path.pdf" "folder.path/" -DisableTqdm -UseLlm -OpenAiBaseUrl "http://192.168.98.39:1234/v1" -OpenAiModel "google/gemma-4-e4b" -OpenAiApiKey "apikey"
```
