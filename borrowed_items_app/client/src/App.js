import React, { useState } from 'react';

function App() {
  const [name, setName] = useState('');
  const [laptop, setLaptop] = useState(false);
  const [charger, setCharger] = useState(false);
  const [yonderpouch, setYonderpouch] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async () => {
    await fetch('/api/return', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, laptop, charger, yonderpouch }),
    });
    setSubmitted(true);
  };

  if (submitted) {
    return (
      <div>
        <h2>Thank you!</h2>
        <p>Your submission has been recorded.</p>
      </div>
    );
  }

  return (
    <div>
      <h2>Equipment Return Form</h2>
      <div>
        <label>
          Your Name:
          <input value={name} onChange={(e) => setName(e.target.value)} />
        </label>
      </div>
      <div>
        <label>
          <input
            type="checkbox"
            checked={laptop}
            onChange={() => setLaptop(!laptop)}
          />
          Laptop returned
        </label>
      </div>
      <div>
        <label>
          <input
            type="checkbox"
            checked={charger}
            onChange={() => setCharger(!charger)}
          />
          Charger returned
        </label>
      </div>
      <div>
        <label>
          <input
            type="checkbox"
            checked={yonderpouch}
            onChange={() => setYonderpouch(!yonderpouch)}
          />
          Yonder pouch returned
        </label>
      </div>
      <button onClick={handleSubmit}>Submit</button>
    </div>
  );
}

export default App;
