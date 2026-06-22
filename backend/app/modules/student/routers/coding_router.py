import subprocess
import tempfile
import os
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/coding", tags=["coding"])

class RunRequest(BaseModel):
    code: str

class RunResponse(BaseModel):
    output: str
    error: str

@router.post("/run", response_model=RunResponse)
def run_code(payload: RunRequest):
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(
            mode='w', suffix='.py', delete=False, encoding='utf-8'
        ) as f:
            f.write(payload.code)
            tmp_path = f.name

        result = subprocess.run(
            ['python', tmp_path],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return RunResponse(
            output=result.stdout.strip(),
            error=result.stderr.strip(),
        )
    except subprocess.TimeoutExpired:
        return RunResponse(output='', error='Code timed out (5s limit)')
    except Exception as e:
        return RunResponse(output='', error=str(e))
    finally:
        if tmp_path:
            try:
                os.unlink(tmp_path)
            except Exception:
                pass