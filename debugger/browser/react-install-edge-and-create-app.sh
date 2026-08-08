#!/bin/bash

echo "Installing Edge"
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod a+r /etc/apt/keyrings/microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge-stable.list
sudo apt update
sudo apt install -y microsoft-edge-stable

echo "Make React app"

mkdir ~/react-app/
cd ~/react-app/

# Create package.json
cat > package.json << 'EOF'
{
  "name": "react-app",
  "version": "1.0.0",
  "description": "React app",
  "main": "index.js",
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  }
}
EOF

mkdir ~/react-app/public

# Create public/index.html
cat > ~/react-app/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Simple React App</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

# Create src directory
mkdir ~/react-app/src

# Create src/index.js
cat > ~/react-app/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

# Create src/App.js
cat > ~/react-app/src/App.js << 'EOF'
import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState('Hello, React!');
  const [count, setCount] = useState(0);

  const changeMessage = () => {
    const messages = [
      'Hello, React!',
      'Welcome to my app!',
      'React is awesome!',
      'Click the button to change me!',
      'You clicked ' + (count + 1) + ' times!'
    ];
    const randomIndex = Math.floor(Math.random() * messages.length);
    setMessage(messages[randomIndex]);
  };

  const incrementCount = () => {
    setCount(count + 1);
    setMessage('You clicked ' + (count + 1) + ' times!');
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>{message}</h1>
        <p>Count: {count}</p>
        <button onClick={changeMessage}>
          Change Message
        </button>
        <button onClick={incrementCount}>
          Increment Count
        </button>
      </header>
    </div>
  );
}

export default App;
EOF

# Create src/App.css
cat > ~/react-app/src/App.css << 'EOF'
.App {
  text-align: center;
}

.App-header {
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
}

button {
  margin: 10px;
  padding: 10px 20px;
  font-size: 16px;
  background-color: #61dafb;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

button:hover {
  background-color: #4fa8c7;
}

p {
  margin: 20px 0;
}
EOF

cd ~/react-app/
npm install