param (
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$TargetPaths, 
  
  [switch]$DisableTqdm,
  
  [switch]$UseLlm,
  
  [string]$OpenAiBaseUrl,
  
  [string]$OpenAiModel,
  
  [string]$OpenAiApiKey
)

# Centralized Logging Engine
function Write-Log {
  param (
    [Parameter(Mandatory=$true)]
    [string]$Message,
    
    [ValidateSet("INFO", "WARN", "ERROR")]
    [string]$Level = "INFO",
    
    [ConsoleColor]$Color = "White"
  )
  
  $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss,fff")
  $logOutput = "$timestamp [$Level] $Message"
  
  # Force format consistency by bypassing native Write-Warning prefixes
  if ($Level -eq "WARN" -and $Color -eq "White") { $Color = "Yellow" }
  if ($Level -eq "ERROR" -and $Color -eq "White") { $Color = "Red" }
  if ($Level -eq "INFO" -and $Color -eq "White") { $Color = "Green" }
  
  Write-Host $logOutput -ForegroundColor $Color
}

# Strict Parameter Validation
if ($UseLlm) {
  $missingParams = @()
  if ([string]::IsNullOrWhiteSpace($OpenAiBaseUrl)) { $missingParams += "-OpenAiBaseUrl" }
  if ([string]::IsNullOrWhiteSpace($OpenAiModel)) { $missingParams += "-OpenAiModel" }
  if ([string]::IsNullOrWhiteSpace($OpenAiApiKey)) { $missingParams += "-OpenAiApiKey" }
  
  if ($missingParams.Count -gt 0) {
    Write-Log -Message "Parameter validation failed. -UseLlm requires: $($missingParams -join ', ')" -Level "ERROR"
    exit 1
  }
}

# Define supported file extensions. Modify this array to restrict or expand support.
$SupportedExtensions = @(".pdf", ".epub", ".html", ".docx", "pptx", ".xlsx", ".png", ".jpg", ".jpeg")

# Pre-processing phase: Analyze parameters and gather all target file paths
$PendingFiles = @()

# Pre-processing Phase
foreach ($path in $TargetPaths) {
  if (Test-Path -Path $path -PathType Leaf) {
    $item = Get-Item -Path $path
    if ($SupportedExtensions -contains $item.Extension.ToLower()) {
      $PendingFiles += $item.FullName
    } else {
      Write-Log -Message "Skipped unsupported file type: $($item.FullName)" -Level "WARN"
    }
  } elseif (Test-Path -Path $path -PathType Container) {
    $folderFiles = Get-ChildItem -Path $path -File -Depth 0 | Where-Object { 
      $SupportedExtensions -contains $_.Extension.ToLower() 
    }
    
    if ($null -ne $folderFiles) {
      foreach ($file in $folderFiles) {
        $PendingFiles += $file.FullName
      }
    } else {
      Write-Log -Message "No supported files found in directory: $path" -Level "WARN"
    }
  } else {
    Write-Log -Message "Path not found or invalid: $path" -Level "ERROR"
  }
}

# Deduplication and Validation
$PendingFiles = $PendingFiles | Select-Object -Unique
$TotalFiles = $PendingFiles.Count

if ($TotalFiles -eq 0) {
  Write-Log -Message "Initialization aborted. No valid files found for processing." -Level "WARN"
  exit
}

Write-Log -Message "Target acquisition complete. Total unique files to process: $TotalFiles" -Level "INFO"
$CurrentIndex = 1
# Execution Phase
foreach ($filePath in $PendingFiles) {
  $fileObj = Get-Item -Path $filePath
  $outputDir = $fileObj.DirectoryName

  Write-Log -Message "[$CurrentIndex/$TotalFiles] Start processing `"$filePath`"..." -Level "INFO"
  
  # Constructing argument array for safe execution
  $exeArgs = @(
    $filePath,
    "--force_ocr",
    "--output_dir", $outputDir,
    "--output_format", "markdown"
  )

  if ($DisableTqdm) {
    $exeArgs += "--disable_tqdm"
  }

  if ($UseLlm) {
    $exeArgs += "--use_llm"
    $exeArgs += "--llm_service=marker.services.openai.OpenAIService"
    $exeArgs += "--openai_base_url"
    $exeArgs += $OpenAiBaseUrl
    $exeArgs += "--openai_model"
    $exeArgs += $OpenAiModel
    $exeArgs += "--openai_api_key"
    $exeArgs += $OpenAiApiKey
  }
  
  # Execute external process using the argument array
  & marker_single @exeArgs
  
  # Write-Log -Message "[$CurrentIndex/$TotalFiles] Finished processing `"$filePath`"." -Level "INFO"
  
  $CurrentIndex++
}

Write-Log -Message "Batch processing sequence terminated successfully." -Level "INFO"