# BASIX IP Marketplace - Complete Demo & Testing Guide

## Overview of Architecture Flow

**Frontend → Backend → MeTTa → Blockchain**

1. **Streamlit Frontend** collects user input and sends HTTP requests
2. **FastAPI Backend** receives requests and formats data for MeTTa
3. **MeTTa Knowledge Base** (via Hyperon) processes AI reasoning and stores knowledge
4. **Vyper Smart Contracts** handle blockchain transactions and ownership

## Installation & Setup

### 1. Install Dependencies

```bash
# Create virtual environment
python -m venv basix_env
source basix_env/bin/activate  # On Windows: basix_env\Scripts\activate

# Install Python packages
pip install fastapi uvicorn streamlit web3 eth-account vyper pandas requests hyperon

# Verify Hyperon installation
python -c "from hyperon import MeTTa; print('MeTTa available')"
```

### 2. Setup Local Blockchain

```bash
# Install Ganache CLI
npm install -g ganache-cli

# Start local blockchain
ganache-cli --deterministic --accounts 10 --host 0.0.0.0 --port 8545
```

### 3. Deploy Smart Contract

Create `deploy_contract.py`:

```python
from web3 import Web3
from vyper import compile_code
import json

# Connect to Ganache
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
accounts = w3.eth.accounts

# Compile Vyper contract
with open('basix_marketplace.vy', 'r') as f:
    contract_source = f.read()

compiled = compile_code(contract_source, output_formats=['abi', 'bytecode'])

# Deploy contract
contract = w3.eth.contract(abi=compiled['abi'], bytecode=compiled['bytecode'])
tx_hash = contract.constructor().transact({'from': accounts[0]})
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

print(f"Contract deployed at: {tx_receipt.contractAddress}")

# Save contract info
contract_info = {
    'address': tx_receipt.contractAddress,
    'abi': compiled['abi']
}

with open('contract_info.json', 'w') as f:
    json.dump(contract_info, f, indent=2)
```

### 4. Create MeTTa Knowledge Base File

Save the MeTTa knowledge base code as `basix_metta_kb.metta`

### 5. Start Services

```bash
# Terminal 1: Start FastAPI backend
python main.py

# Terminal 2: Start Streamlit frontend
streamlit run basix_streamlit_app.py

# Terminal 3: Keep Ganache running
ganache-cli --deterministic --accounts 10 --host 0.0.0.0 --port 8545
```

## Complete End-to-End Demo Walkthrough

### Phase 1: System Health Check

#### 1.1 Backend Health Check

```bash
curl http://localhost:8000/health
```

**Expected Response:**

```json
{
  "status": "healthy",
  "metta_available": true,
  "metta_initialized": true,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

#### 1.2 Frontend Access

Open browser to `http://localhost:8501` - should show BASIX IP Marketplace interface

#### 1.3 MeTTa Spaces Check

```bash
curl http://localhost:8000/api/metta/spaces
```

**Expected Response:**

```json
{
  "success": true,
  "message": "MeTTa spaces information retrieved",
  "data": {
    "spaces": {
      "creators": { "atom_count": 0, "status": "active" },
      "assets": { "atom_count": 0, "status": "active" },
      "marketplace": { "atom_count": 0, "status": "active" },
      "ownership": { "atom_count": 0, "status": "active" },
      "transactions": { "atom_count": 0, "status": "active" },
      "funding": { "atom_count": 0, "status": "active" }
    }
  }
}
```

### Phase 2: Creator Registration Demo

#### 2.1 Register First Creator (Alice) - API Direct

```bash
curl -X POST http://localhost:8000/api/creators \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Creator",
    "email": "alice@example.com",
    "wallet_address": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    "bio": "Digital artist specializing in NFTs"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Creator registered successfully with ID: 1000",
  "data": {
    "creator_id": 1000,
    "name": "Alice Creator",
    "wallet_address": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    "metta_query": "!(registerCreator \"Alice Creator\" \"alice@example.com\" \"0x90F79bf6EB2c4f870365E785982E1f101E93b906\")"
  },
  "timestamp": "2024-01-15T10:31:00.000Z"
}
```

#### 2.2 Register Second Creator (Bob) - Frontend

1. Go to "Creator Management" tab in Streamlit
2. Fill in creator details:
   - Name: "Bob Artist"
   - Email: "bob@example.com"
   - Wallet: "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
3. Click "Register Creator"
4. Should see success message

#### 2.3 Verify Creator Registration

```bash
curl http://localhost:8000/api/creators/1000
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Creator retrieved successfully",
  "data": {
    "creator_id": 1000,
    "creator_info": [
      "creatorInfo",
      1000,
      "Alice Creator",
      "alice@example.com",
      "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    ],
    "metta_query": "!(getCreator 1000)"
  }
}
```

### Phase 3: Asset Creation Demo

#### 3.1 Create NFT Asset - API

```bash
curl -X POST http://localhost:8000/api/assets \
  -H "Content-Type: application/json" \
  -d '{
    "creator_wallet": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    "asset_type": "NFT",
    "title": "Digital Art #1",
    "description": "Beautiful abstract digital artwork",
    "metadata_uri": "ipfs://QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG",
    "price": 0.5,
    "royalty_percentage": 10,
    "tags": ["art", "abstract", "digital"]
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Asset created successfully with ID: 2000",
  "data": {
    "asset_id": 2000,
    "creator_id": 1000,
    "title": "Digital Art #1",
    "asset_type": "NFT",
    "price": 0.5,
    "metta_query": "!(createAsset 1000 \"NFT\" \"Digital Art #1\" \"Beautiful abstract digital artwork\" \"ipfs://QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG\" 0.5 10)"
  }
}
```

#### 3.2 Create Video Asset - Frontend

1. Go to "Asset Management" tab
2. Fill asset details:
   - Creator Wallet: "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
   - Type: "Video"
   - Title: "Music Video - Sunrise"
   - Description: "Electronic music video with stunning visuals"
   - Price: 0.3 ETH
   - Royalty: 15%
3. Click "Create Asset"

#### 3.3 List All Assets

```bash
curl http://localhost:8000/api/assets
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Assets listed successfully",
  "data": {
    "assets": [
      ["creatorAsset", 2000, "NFT", "Digital Art #1"],
      ["creatorAsset", 2001, "Video", "Music Video - Sunrise"]
    ],
    "metta_query": "!(getMarketplaceAssets)"
  }
}
```

### Phase 4: Marketplace Transaction Demo

#### 4.1 Purchase Asset - API

```bash
curl -X POST http://localhost:8000/api/transactions/purchase \
  -H "Content-Type: application/json" \
  -d '{
    "buyer_wallet": "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
    "asset_id": 2000,
    "quantity": 1,
    "payment_amount": 0.5
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Purchase processed successfully",
  "data": {
    "purchase_result": ["purchaseSuccess", 3000, 0.05, 0.45],
    "buyer_id": 1002,
    "asset_id": 2000,
    "amount": 0.5,
    "metta_query": "!(purchaseAsset 1002 2000 0.5 1)"
  }
}
```

#### 4.2 Check Ownership

```bash
curl http://localhost:8000/api/ownership/0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc/2000
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Ownership retrieved successfully",
  "data": {
    "wallet_address": "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
    "asset_id": 2000,
    "ownership_percentage": 1,
    "metta_query": "!(getOwnership 1002 2000)"
  }
}
```

### Phase 5: Funding Campaign Demo

#### 5.1 Create Funding Campaign

```bash
curl -X POST http://localhost:8000/api/funding/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "creator_wallet": "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
    "title": "New Art Series Project",
    "description": "Creating a series of 10 unique digital artworks exploring themes of technology and nature",
    "target_amount": 5.0,
    "duration_days": 30,
    "min_contribution": 0.1
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Funding campaign created with ID: 4000",
  "data": {
    "campaign_id": 4000,
    "creator_id": 1000,
    "title": "New Art Series Project",
    "target_amount": 5.0,
    "deadline": 1704067200,
    "metta_query": "!(createFundingCampaign 1000 \"Creating a series of 10 unique digital artworks...\" 5.0 1704067200 0.1)"
  }
}
```

### Phase 6: AI Agents Demo

#### 6.1 Auto-Approval Agent

```bash
curl -X POST http://localhost:8000/api/agents/auto-approve/2000
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Auto-approval completed: approved",
  "data": {
    "asset_id": 2000,
    "approval_result": "approved",
    "metta_query": "!(autoApproveContent 2000)"
  }
}
```

#### 6.2 Dynamic Pricing Agent

```bash
curl -X POST http://localhost:8000/api/agents/dynamic-pricing/2000
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Dynamic pricing completed: priceAdjusted",
  "data": {
    "asset_id": 2000,
    "pricing_result": "priceAdjusted",
    "metta_query": "!(dynamicPricingAgent 2000)"
  }
}
```

### Phase 7: Analytics Demo

#### 7.1 Marketplace Analytics

```bash
curl http://localhost:8000/api/analytics/marketplace
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Analytics retrieved successfully",
  "data": {
    "marketplace_stats": ["marketplaceStats", 3, 2, 1],
    "timestamp": "2024-01-15T10:45:00.000Z",
    "metta_query": "!(getMarketplaceStats)"
  }
}
```

### Phase 8: Custom MeTTa Query Demo

#### 8.1 Custom Query Execution

```bash
curl "http://localhost:8000/api/metta/query?query=getTopCreators"
```

**Expected Response:**

```json
{
  "success": true,
  "message": "Custom query executed",
  "data": {
    "query": "!(getTopCreators)",
    "result": [
      ["creatorRank", 1000, 15],
      ["creatorRank", 1001, 5]
    ],
    "success": true
  }
}
```

## MetaMask Integration Testing

### Setup MetaMask for Testing

1. **Install MetaMask** browser extension
2. **Import Ganache account**:
   - Copy private key from Ganache console
   - MetaMask → Import Account → Paste private key
3. **Add Local Network**:
   - Network Name: "Local Ganache"
   - RPC URL: "http://localhost:8545"
   - Chain ID: 1337
   - Currency: ETH

### MetaMask Transaction Flow Testing

#### 1. Connect Wallet (Frontend)

1. Open Streamlit app
2. Click "Connect MetaMask"
3. Approve connection in MetaMask
4. Verify wallet address displays

#### 2. Register Creator on Blockchain

1. Fill creator registration form
2. Click "Register on Blockchain"
3. Confirm transaction in MetaMask
4. Verify transaction success

#### 3. Create Asset on Blockchain

1. Create asset in frontend
2. Click "Create on Blockchain"
3. Confirm transaction in MetaMask
4. Check transaction hash

#### 4. Purchase with MetaMask

1. Select asset to purchase
2. Click "Pay with MetaMask"
3. Confirm payment transaction
4. Verify ownership transfer

## Error Testing Scenarios

### 1. Invalid Creator Registration

```bash
curl -X POST http://localhost:8000/api/creators \
  -H "Content-Type: application/json" \
  -d '{
    "name": "",
    "email": "invalid-email",
    "wallet_address": "invalid-address"
  }'
```

**Expected Response:**

```json
{
  "detail": [
    {
      "loc": ["body", "name"],
      "msg": "ensure this value has at least 1 characters",
      "type": "value_error.any_str.min_length"
    }
  ]
}
```

### 2. Asset Not Found

```bash
curl http://localhost:8000/api/assets/9999
```

**Expected Response:**

```json
{
  "detail": "Asset not found"
}
```

### 3. Insufficient Funds Purchase

```bash
curl -X POST http://localhost:8000/api/transactions/purchase \
  -H "Content-Type: application/json" \
  -d '{
    "buyer_wallet": "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc",
    "asset_id": 2000,
    "quantity": 1,
    "payment_amount": 0.1
  }'
```

**Expected Response:**

```json
{
  "detail": "Purchase failed: Insufficient payment"
}
```

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test creator registration endpoint
ab -n 100 -c 10 -H "Content-Type: application/json" \
   -p creator_data.json \
   http://localhost:8000/api/creators

# Test asset retrieval
ab -n 1000 -c 50 \
   http://localhost:8000/api/assets

# Test health endpoint
ab -n 1000 -c 100 \
   http://localhost:8000/health
```

### MeTTa Query Performance

```bash
# Time complex queries
time curl "http://localhost:8000/api/metta/query?query=getMarketplaceStats"
time curl "http://localhost:8000/api/metta/query?query=getTopCreators"
```

## Monitoring and Debugging

### 1. Backend Logs

```bash
# View FastAPI logs
tail -f uvicorn.log

# Check MeTTa execution logs
grep "MeTTa" uvicorn.log
```

### 2. MeTTa Space Inspection

```bash
# Check space contents
curl http://localhost:8000/api/metta/spaces

# Execute diagnostic queries
curl "http://localhost:8000/api/metta/query?query=get-atoms%20&creators"
```

### 3. Database State Verification

```bash
# Verify creator count
curl "http://localhost:8000/api/metta/query?query=getMarketplaceStats"

# Check specific creator
curl http://localhost:8000/api/creators/1000
```

## Expected Demo Flow Summary

1. **System Check** (2-3 minutes)

   - Verify all services running
   - Check MeTTa initialization
   - Confirm blockchain connection

2. **Creator Registration** (3-4 minutes)

   - Register 2-3 creators via API and frontend
   - Verify MeTTa knowledge storage
   - Check creator retrieval

3. **Asset Management** (4-5 minutes)

   - Create various asset types
   - Demonstrate AI-powered categorization
   - Show asset listing and search

4. **Marketplace Transactions** (5-6 minutes)

   - Purchase assets with automatic royalty calculation
   - Demonstrate ownership tracking
   - Show transaction history

5. **AI Agents** (3-4 minutes)

   - Auto-approve content based on creator reputation
   - Dynamic pricing based on demand
   - Show reasoning transparency

6. **Funding Campaigns** (3-4 minutes)

   - Create funding campaign
   - Process contributions
   - Track campaign progress

7. **MetaMask Integration** (5-6 minutes)

   - Connect wallet
   - Execute blockchain transactions
   - Verify on-chain state

8. **Analytics & Insights** (2-3 minutes)
   - Show marketplace statistics
   - Creator leaderboards
   - Revenue analytics

**Total Demo Time: 25-30 minutes**

This comprehensive testing approach ensures the complete integration between Frontend → Backend → MeTTa → Blockchain works correctly, with proper error handling and performance optimization.
