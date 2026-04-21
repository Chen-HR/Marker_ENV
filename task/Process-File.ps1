param (
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Files
)

foreach ($file in $Files) {
  if (Test-Path $file) {
    Write-Host "Start processing `"$file`"..." -ForegroundColor Green
    marker_single "$file" --force_ocr --output_dir out --output_format markdown --use_llm --llm_service=marker.services.openai.OpenAIService --openai_base_url http://192.168.98.39:1234/v1 --openai_model google/gemma-4-e4b --openai_api_key openai_api_key
    Write-Host "Finished processing `"$file`"." -ForegroundColor Green
  }
  else {
    Write-Warning "File not found: $file"
  }
}