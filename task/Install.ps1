uv venv .venv ;

./.venv/Scripts/activate.ps1 ;

git clone --branch v1.10.2 --depth 1 https://github.com/datalab-to/marker ./lib/marker ;
# edit `marker\marker\services\openai.py`: `OpenAIService.openai_image_format` defult to `jpeg`, ref [issuecomment](https://github.com/datalab-to/marker/issues/794#issuecomment-3641887065).
(Get-Content -Path "./lib/marker/marker/services/openai.py") -replace 'webp', 'jpeg' | Set-Content -Path "./lib/marker/marker/services/openai.py" -Encoding utf8 ;

uv pip install . ;
