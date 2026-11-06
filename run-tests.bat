@echo off
setlocal
for %%M in (mandatory-tags s3-secure-bucket security-group iam-least-privilege-role rds-secure-instance) do (
  echo.
  echo ===== testing %%M =====
  pushd modules\%%M
  terraform init -backend=false -input=false >nul
  terraform test
  if errorlevel 1 (
    popd
    echo.
    echo TESTS FAILED in %%M
    exit /b 1
  )
  popd
)
echo.
echo ALL TESTS PASSED
