// src/utils/api.js
import axios from "axios";

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";

// Create axios instance with default config
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    "Content-Type": "application/json",
  },
});

// Response interceptor for standardized error handling
api.interceptors.response.use(
  (response) => response.data,
  (error) => {
    console.error("API Error:", error.response?.data || error.message);
    throw error.response?.data || { message: error.message };
  }
);

// Health check
export const healthCheck = async () => {
  // eslint-disable-next-line no-useless-catch
  try {
    const response = await api.get("/health");
    return response;
  } catch (error) {
    throw error;
  }
};

// Creator Management APIs
export const creatorAPI = {
  register: async (creatorData) => {
    return await api.post("/api/creators", creatorData);
  },

  getById: async (creatorId) => {
    return await api.get(`/api/creators/${creatorId}`);
  },

  list: async () => {
    return await api.get("/api/creators");
  },

  updateReputation: async (creatorId, delta) => {
    return await api.patch(`/api/creators/${creatorId}/reputation`, { delta });
  },
};

// Asset Management APIs
export const assetAPI = {
  create: async (assetData) => {
    return await api.post("/api/assets", assetData);
  },

  getById: async (assetId) => {
    return await api.get(`/api/assets/${assetId}`);
  },

  list: async () => {
    return await api.get("/api/assets");
  },

  updatePrice: async (assetId, newPrice) => {
    return await api.patch(`/api/assets/${assetId}/price`, {
      new_price: newPrice,
    });
  },

  getByCreator: async (creatorId) => {
    return await api.get(`/api/creators/${creatorId}/assets`);
  },
};

// Transaction APIs
export const transactionAPI = {
  purchase: async (purchaseData) => {
    return await api.post("/api/transactions/purchase", purchaseData);
  },

  getHistory: async (walletAddress) => {
    return await api.get(`/api/transactions/history/${walletAddress}`);
  },
};

// Ownership APIs
export const ownershipAPI = {
  get: async (walletAddress, assetId) => {
    return await api.get(`/api/ownership/${walletAddress}/${assetId}`);
  },

  transfer: async (transferData) => {
    return await api.post("/api/ownership/transfer", transferData);
  },
};

// Funding Campaign APIs
export const fundingAPI = {
  createCampaign: async (campaignData) => {
    return await api.post("/api/funding/campaigns", campaignData);
  },

  getCampaign: async (campaignId) => {
    return await api.get(`/api/funding/campaigns/${campaignId}`);
  },

  listCampaigns: async () => {
    return await api.get("/api/funding/campaigns");
  },

  contribute: async (contributionData) => {
    return await api.post("/api/funding/contribute", contributionData);
  },
};

// AI Agents APIs
export const agentsAPI = {
  autoApprove: async (assetId) => {
    return await api.post(`/api/agents/auto-approve/${assetId}`);
  },

  dynamicPricing: async (assetId) => {
    return await api.post(`/api/agents/dynamic-pricing/${assetId}`);
  },
};

// Analytics APIs
export const analyticsAPI = {
  getMarketplaceStats: async () => {
    return await api.get("/api/analytics/marketplace");
  },

  getCreatorStats: async (creatorId) => {
    return await api.get(`/api/analytics/creators/${creatorId}`);
  },
};

// MeTTa Debug APIs (for development)
export const mettaAPI = {
  executeQuery: async (query) => {
    return await api.get("/api/metta/query", { params: { query } });
  },

  getSpaces: async () => {
    return await api.get("/api/metta/spaces");
  },
};

// Blockchain Integration APIs
export const blockchainAPI = {
  getContractInfo: async () => {
    return await api.get("/api/blockchain/contract-info");
  },

  estimateGas: async (functionName) => {
    return await api.get(`/api/blockchain/gas-estimate/${functionName}`);
  },
};

export default api;
