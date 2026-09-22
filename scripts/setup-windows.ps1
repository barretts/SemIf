param(
    [ValidateSet('cu126', 'cu128', 'cu130')]
    [string]$CudaWheel = 'cu128'
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$python = Join-Path $repoRoot '.venv\Scripts\python.exe'

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    throw 'Install uv from https://docs.astral.sh/uv/getting-started/installation/ and rerun this script.'
}
if (-not (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) {
    throw 'NVIDIA driver tools were not found. Install an NVIDIA driver before setting up CUDA.'
}

Push-Location $repoRoot
try {
    if (-not (Test-Path $python)) {
        uv venv --python 3.12 .venv
        if ($LASTEXITCODE -ne 0) { throw 'Could not create the Python 3.12 environment.' }
    }
    & $python -c 'import sys; assert sys.version_info[:2] == (3, 12)'
    if ($LASTEXITCODE -ne 0) { throw 'Existing .venv does not contain Python 3.12.' }

    uv pip install --python $python "torch==2.10.0+$CudaWheel" --index-url "https://download.pytorch.org/whl/$CudaWheel"
    if ($LASTEXITCODE -ne 0) { throw 'Could not install the CUDA PyTorch wheel.' }

    uv pip install --python $python -e '.[test]'
    if ($LASTEXITCODE -ne 0) { throw 'Could not install SemIf.' }

    & $python -c 'import torch; assert torch.cuda.is_available(), "CUDA is unavailable"; assert torch.cuda.device_count() == 1, "Expose exactly one CUDA GPU"; print(f"PyTorch {torch.__version__}; CUDA {torch.version.cuda}; GPU {torch.cuda.get_device_name(0)}")'
    if ($LASTEXITCODE -ne 0) { throw 'PyTorch cannot access exactly one CUDA GPU.' }
}
finally {
    Pop-Location
}
