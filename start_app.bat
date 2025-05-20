
@echo off

REM Start the borrowed items application (backend and frontend)

cd /d %~dp0



echo === Starting Borrowed Items App ===



IF EXIST docker-compose.yml (

    echo docker-compose.yml found. Starting containers...

    docker-compose up -d

)



IF NOT EXIST .env (

    echo PORT=3001> .env

    echo Created default .env file

)



IF NOT EXIST borrowed_items_app\client\.env (

    echo REACT_APP_API_URL=http://localhost:3001> borrowed_items_app\client\.env

    echo Created default client .env file

)



IF EXIST borrowed_items_app\requirements.txt (

    echo Installing Python dependencies...

    pip install -r borrowed_items_app\requirements.txt

) ELSE IF EXIST requirements.txt (

    echo Installing Python dependencies...

    pip install -r requirements.txt

)



IF EXIST borrowed_items_app\server\package.json (

    IF NOT EXIST borrowed_items_app\server\node_modules (

        echo Installing backend dependencies...

        pushd borrowed_items_app\server

        npm install

        popd

    )

)



IF NOT EXIST borrowed_items_app\client\node_modules (

    echo Installing frontend dependencies...

    pushd borrowed_items_app\client

    npm install

    popd

)



pushd borrowed_items_app\client

npm list html-webpack-plugin >nul 2>&1

IF ERRORLEVEL 1 (

    echo Installing html-webpack-plugin...

    npm install html-webpack-plugin

)

popd



IF EXIST borrowed_items_app\app.py (

    start "python" cmd /c "python borrowed_items_app\app.py"

) ELSE IF EXIST borrowed_items_app\server\package.json (

    start "node" cmd /c "cd borrowed_items_app\server && npm start"

)



start "react" cmd /c "cd borrowed_items_app\client && npm start"



TIMEOUT /T 5 >nul

start http://localhost:3000

