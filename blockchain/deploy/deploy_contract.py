from web3 import Web3
import json

# Connect to Anvil
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
print("Connected to blockchain:", w3.is_connected())

# Load compiled contract
with open("compiled_contract.json") as f:
    contract_data = json.load(f)

abi = contract_data["abi"]
bytecode = contract_data["bytecode"]

# Use first Anvil account
deployer_account = w3.eth.accounts[0]
print("Deploying with account:", deployer_account)

# Create contract instance
contract = w3.eth.contract(abi=abi, bytecode=bytecode)

# Deploy contract
tx_hash = contract.constructor().transact({
    "from": deployer_account,
    "gas": 3_000_000
})
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

print("Contract deployed at:", tx_receipt.contractAddress)
