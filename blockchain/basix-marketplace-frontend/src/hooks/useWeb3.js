import { useState } from "react";
import Web3 from "web3";

export default function useWeb3(contractABI, contractAddress) {
  const [account, setAccount] = useState(null);
  const [contract, setContract] = useState(null);

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);

        if (contractABI && contractAddress) {
          const c = new web3.eth.Contract(contractABI, contractAddress);
          setContract(c);
        }
      } catch (err) {
        console.error("MetaMask connection failed", err);
      }
    } else {
      alert("MetaMask not detected! Install it.");
    }
  };

  return { account, contract, connectWallet };
}
