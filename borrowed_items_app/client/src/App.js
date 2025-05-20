import React, { useEffect, useState } from 'react';

function App() {
  const [user, setUser] = useState(null);
  const [items, setItems] = useState([]);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loginError, setLoginError] = useState('');

  const login = async () => {
    const res = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });
    if (res.ok) {
      const data = await res.json();
      setUser(data);
      setLoginError('');
    } else {
      const err = await res.json();
      setLoginError(err.error || 'Login failed');
    }
  };

  useEffect(() => {
    if (user) {
      fetch(`/api/items/${user.id}`)
        .then((res) => res.json())
        .then(setItems);
    }
  }, [user]);

  const returnItem = async (itemId) => {
    await fetch(`/api/items/${itemId}/return`, { method: 'POST' });
    setItems(items.map((i) => (i.id === itemId ? { ...i, returned: 1 } : i)));
  };

  if (!user) {
    return (
      <div>
        <h2>Login</h2>
        <input placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} />
        <input placeholder="Password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button onClick={login}>Login</button>
        {loginError && <p style={{ color: 'red' }}>{loginError}</p>}
      </div>
    );
  }

  return (
    <div>
      <h2>Borrowed Items</h2>
      <ul>
        {items.map((item) => (
          <li key={item.id}>
            {item.name} - {item.returned ? 'Returned' : 'Borrowed'}
            {!item.returned && <button onClick={() => returnItem(item.id)}>Return</button>}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
