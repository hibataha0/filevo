@echo off
echo Adding all files...
git add .
echo.
echo Committing changes...
git commit -m "Update project"
echo.
echo Pushing to GitHub...
git push origin main
echo.
echo Done!
pause







