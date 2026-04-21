param (
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Folders
)

foreach ($Folder in $Folders) {
  if (Test-Path $Folder) {
    Write-Host "Start processing `"$Folder`"..." -ForegroundColor Green
    marker "$Folder" --force_ocr --output_dir out --output_format markdown --use_llm --llm_service=marker.services.openai.OpenAIService --openai_base_url http://192.168.98.39:1234/v1 --openai_model google/gemma-4-e4b --openai_api_key openai_api_key
    Write-Host "Finished processing `"$Folder`"." -ForegroundColor Green
  }
  else {
    Write-Warning "Folder not found: $Folder"
  }
}