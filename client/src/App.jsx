import { useEffect, useState } from "react";

const line = `frontend: hello world oxzoo-ruby-react_${import.meta.env.GREETING_TAG}`;

export default function App() {
  const [backend, setBackend] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch("/api/greeting")
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.text();
      })
      .then((text) => setBackend(text))
      .catch((err) => setError(err.message));
  }, []);

  return (
    <main>
      <h1>oxzoo-ruby-react</h1>
      <p>{line}</p>
      <p>
        {error
          ? `backend: error (${error})`
          : backend ?? "backend: loading..."}
      </p>
    </main>
  );
}
