import React, { useState } from "react";
import { autoApproveContent, runDynamicPricing } from "../utils/api";

export default function AIAgents() {
  const [assetId, setAssetId] = useState("");
  const [result, setResult] = useState(null);

  const handleAutoApprove = async () => {
    if (!assetId) return;
    try {
      const res = await autoApproveContent(assetId);
      setResult(res);
    } catch (err) {
      console.error(err);
      alert("Auto-approval failed");
    }
  };

  const handleDynamicPricing = async () => {
    if (!assetId) return;
    try {
      const res = await runDynamicPricing(assetId);
      setResult(res);
    } catch (err) {
      console.error(err);
      alert("Dynamic pricing failed");
    }
  };

  return (
    <div className="max-w-7xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold">AI Agents</h1>

      <div className="bg-white p-4 rounded shadow space-y-4">
        <input
          type="number"
          placeholder="Asset ID"
          value={assetId}
          onChange={(e) => setAssetId(e.target.value)}
          className="w-full border p-2 rounded"
        />
        <div className="flex gap-2">
          <button
            onClick={handleAutoApprove}
            className="bg-blue-600 text-white px-4 py-2 rounded"
          >
            Auto Approve Content
          </button>
          <button
            onClick={handleDynamicPricing}
            className="bg-green-600 text-white px-4 py-2 rounded"
          >
            Run Dynamic Pricing
          </button>
        </div>
      </div>

      {result && (
        <pre className="bg-gray-100 p-4 rounded overflow-x-auto">
          {JSON.stringify(result, null, 2)}
        </pre>
      )}
    </div>
  );
}
