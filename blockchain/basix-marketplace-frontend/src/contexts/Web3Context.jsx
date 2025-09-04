// src/contexts/Web3Context.jsx
import React, { createContext, useContext, useState, useEffect } from "react";
import Web3 from "web3";
import { blockchainAPI } from "../utils/api";

const Web3Context = createContext();

// eslint-disable-next-line react-refresh/only-export-components
export const useWeb3 = () => {
  const context = useContext(Web3Context);
  if (!context) {
    throw new Error("useWeb3 must be used within a Web3Provider");
  }
  return context;
};

export const Web3Provider = ({ children }) => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [connected, setConnected] = useState(false);
  const [chainId, setChainId] = useState(null);
  const [contract, setContract] = useState(null);
  const [loading, setLoading] = useState(false);

  // Initialize Web3 and MetaMask connection
  const connectWallet = async () => {
    setLoading(true);
    try {
      if (typeof window.ethereum !== "undefined") {
        const web3Instance = new Web3(window.ethereum);

        // Request account access
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });

        if (accounts.length > 0) {
          setWeb3(web3Instance);
          setAccount(accounts[0]);
          setConnected(true);

          // Get chain ID
          const chainId = await web3Instance.eth.getChainId();
          setChainId(chainId);

          // Initialize contract
          await initializeContract(web3Instance);

          console.log("Wallet connected:", accounts[0]);
        }
      } else {
        throw new Error("MetaMask not detected. Please install MetaMask.");
      }
    } catch (error) {
      console.error("Failed to connect wallet:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Initialize smart contract
  const initializeContract = async (web3Instance) => {
    try {
      const contractInfo = await blockchainAPI.getContractInfo();

      if (contractInfo.contract_address && contractInfo.contract_abi) {
        const contractInstance = new web3Instance.eth.Contract(
          contractInfo.contract_abi,
          contractInfo.contract_address
        );
        setContract(contractInstance);
        console.log("Contract initialized:", contractInfo.contract_address);
      }
    } catch (error) {
      console.error("Failed to initialize contract:", error);
    }
  };

  // Disconnect wallet
  const disconnectWallet = () => {
    setWeb3(null);
    setAccount(null);
    setConnected(false);
    setChainId(null);
    setContract(null);
  };

  // Register creator on blockchain
  const registerCreatorOnBlockchain = async (name, email) => {
    if (!contract || !account) {
      throw new Error("Wallet not connected or contract not initialized");
    }

    try {
      const gasEstimate = await contract.methods
        .register_creator(name, email)
        .estimateGas({ from: account });

      const result = await contract.methods.register_creator(name, email).send({
        from: account,
        gas: gasEstimate,
      });

      return result.transactionHash;
    } catch (error) {
      console.error("Blockchain registration failed:", error);
      throw error;
    }
  };

  // Create asset on blockchain
  const createAssetOnBlockchain = async (assetData) => {
    if (!contract || !account) {
      throw new Error("Wallet not connected or contract not initialized");
    }

    try {
      const priceWei = Web3.utils.toWei(assetData.price.toString(), "ether");

      const gasEstimate = await contract.methods
        .create_asset(
          assetData.asset_type,
          assetData.title,
          assetData.description,
          assetData.metadata_uri,
          priceWei,
          assetData.royalty_percentage
        )
        .estimateGas({ from: account });

      const result = await contract.methods
        .create_asset(
          assetData.asset_type,
          assetData.title,
          assetData.description,
          assetData.metadata_uri,
          priceWei,
          assetData.royalty_percentage
        )
        .send({
          from: account,
          gas: gasEstimate,
        });

      return result.transactionHash;
    } catch (error) {
      console.error("Blockchain asset creation failed:", error);
      throw error;
    }
  };

  // Purchase asset on blockchain
  const purchaseAssetOnBlockchain = async (assetId, quantity, priceEth) => {
    if (!contract || !account) {
      throw new Error("Wallet not connected or contract not initialized");
    }

    try {
      const priceWei = Web3.utils.toWei(priceEth.toString(), "ether");

      const gasEstimate = await contract.methods
        .purchase_asset(assetId, quantity)
        .estimateGas({
          from: account,
          value: priceWei,
        });

      const result = await contract.methods
        .purchase_asset(assetId, quantity)
        .send({
          from: account,
          value: priceWei,
          gas: gasEstimate,
        });

      return result.transactionHash;
    } catch (error) {
      console.error("Blockchain purchase failed:", error);
      throw error;
    }
  };

  // Listen for account changes
  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      const handleAccountsChanged = (accounts) => {
        if (accounts.length === 0) {
          disconnectWallet();
        } else if (accounts[0] !== account) {
          setAccount(accounts[0]);
        }
      };

      const handleChainChanged = (chainId) => {
        setChainId(parseInt(chainId, 16));
        window.location.reload(); // Recommended by MetaMask
      };

      window.ethereum.on("accountsChanged", handleAccountsChanged);
      window.ethereum.on("chainChanged", handleChainChanged);

      return () => {
        if (window.ethereum.removeListener) {
          window.ethereum.removeListener(
            "accountsChanged",
            handleAccountsChanged
          );
          window.ethereum.removeListener("chainChanged", handleChainChanged);
        }
      };
    }
  }, [account]);

  const value = {
    web3,
    account,
    connected,
    chainId,
    contract,
    loading,
    connectWallet,
    disconnectWallet,
    registerCreatorOnBlockchain,
    createAssetOnBlockchain,
    purchaseAssetOnBlockchain,
  };

  return <Web3Context.Provider value={value}>{children}</Web3Context.Provider>;
};
