# Windows and NVIDIA GPU

Install a current NVIDIA driver and uv. From PowerShell in the repository root:

```powershell
.\scripts\setup-windows.ps1
```

The script creates a Python 3.12 environment, installs pinned PyTorch with
CUDA 12.8, installs SemIf, and checks CUDA. It was tested on a 16 GB GeForce
RTX 4060 Ti. An 8 GB card needs a smaller model or a quantized backend.

Run the included decisions from the repository root:

```powershell
$env:HF_HOME = "$env:USERPROFILE\.cache\huggingface"
$env:CUDA_VISIBLE_DEVICES = '0'
& .\.venv\Scripts\python.exe -m semif_phase1.cli `
  --mode direct `
  --device cuda `
  --model Qwen/Qwen3.5-4B `
  --revision 851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a `
  --input examples/decisions.jsonl `
  --output results-windows.jsonl
```

The first run downloads the model into `HF_HOME`. Output files are
create-only, so choose a new `--output` path for each run. Longer states and
shared batches require more VRAM.
