# BASIX IP Marketplace - Setup & Deployment Guide

## Overview

This guide will help you set up and deploy the BASIX IP Marketplace, an AI-native platform powered by MeTTa's symbolic reasoning for intelligent asset management, autonomous agents, and collaborative ownership.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Streamlit     │    │    Fastify      │    │     MeTTa       │
│   Frontend      │◄──►│    Backend      │◄──►│  Knowledge Base │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Interface│    │  REST API       │    │ Symbolic AI     │
│   - Creator Reg │    │  - CRUD Ops     │    │ - Reasoning     │
│   - Asset Mgmt  │    │  - Transactions │    │ - Inference     │
│   - Marketplace │    │  - AI Agents    │    │ - Knowledge     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Prerequisites

### System Requirements

- Node.js >= 16.0.0
- Python >= 3.8
- MeTTa runtime (Hyperon implementation)
- Git

### Installing MeTTa

1. **Option A: From Source (Recommended)**

   ```bash
   git clone https://github.com/trueagi-io/hyperon-experimental.git
   cd hyperon-experimental
   cargo build --release
   ```

2. **Option B: Using Pre-built Binaries**
   Download from the Hyperon releases page and add to your PATH.

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/basix-ip-marketplace.git
cd basix-ip-marketplace
```

### 2. Install Dependencies

```bash
# Install Node.js dependencies
npm install

# Install Python dependencies
pip install -r requirements.txt
```

### 3. Setup MeTTa Knowledge Base

```bash
# Copy the MeTTa knowledge base file
cp basix_metta_kb.metta ./basix_kb.metta

# Ensure MeTTa runtime is accessible
which metta-runner  # Should return path to MeTTa executable
```

### 4. Configure Environment

Create a `.env` file:

```env
# Server Configuration
PORT=3000
HOST=0.0.0.0
NODE_ENV=development

# MeTTa Configuration
METTA_PATH=./metta-runner
METTA_KB_PATH=./basix_kb.metta

# Blockchain Configuration (Optional)
WEB3_PROVIDER_URL=https://mainnet.infura.io/v3/YOUR_PROJECT_ID
PRIVATE_KEY=your_private_key_here

# Frontend Configuration
STREAMLIT_SERVER_PORT=8501
```

## Running the Application

### Development Mode

1. **Start the Fastify Backend:**

   ```bash
   npm run dev
   ```

2. **Start the Streamlit Frontend (in another terminal):**

   ```bash
   npm run frontend
   # or directly: streamlit run frontend.py
   ```

3. **Access the Application:**
   - Frontend: http://localhost:8501
   - Backend API: http://localhost:3000
   - API Health Check: http://localhost:3000/health

### Production Mode

1. **Start the Backend:**

   ```bash
   npm start
   ```

2. **Start the Frontend:**
   ```bash
   streamlit run frontend.py --server.port 8501 --server.address 0.0.0.0
   ```

## API Endpoints

### Core Endpoints

| Method | Endpoint                     | Description             |
| ------ | ---------------------------- | ----------------------- |
| GET    | `/health`                    | Health check            |
| POST   | `/api/creators`              | Register new creator    |
| GET    | `/api/creators/:id`          | Get creator info        |
| POST   | `/api/assets`                | Create new asset        |
| GET    | `/api/assets/:id`            | Get asset info          |
| POST   | `/api/transactions/purchase` | Purchase asset          |
| POST   | `/api/funding/campaigns`     | Create funding campaign |
| POST   | `/api/funding/contribute`    | Contribute to campaign  |

### AI Agent Endpoints

| Method | Endpoint                               | Description              |
| ------ | -------------------------------------- | ------------------------ |
| POST   | `/api/agents/auto-approve/:assetId`    | Auto-approve content     |
| POST   | `/api/agents/dynamic-pricing/:assetId` | Dynamic pricing analysis |
| GET    | `/api/analytics/stats`                 | Marketplace statistics   |

## MeTTa Integration Details

### Knowledge Base Structure

The MeTTa knowledge base uses several atomspaces:

- `&creators` - Creator information and profiles
- `&assets` - Asset definitions and metadata
- `&ownership` - Ownership relationships
- `&transactions` - Transaction history
- `&funding` - Funding campaigns
- `&marketplace` - General marketplace data

### Key MeTTa Functions

```metta
;; Core Functions
!(registerCreator $name $email $walletAddress)
!(createAsset $creatorId $type $title $description $uri $price $royalty)
!(purchaseAsset $buyerId $assetId $price $quantity)
!(transferOwnership $fromId $toId $assetId $percentage)

;; AI Agent Functions
!(autoApproveContent $assetId)
!(dynamicPricingAgent $assetId)
!(checkFundingStatus $campaignId)
```

## Features Implemented

### ✅ Core Marketplace Features

- Creator registration and management
- Asset creation (NFTs, videos, tickets, etc.)
- Purchase and ownership tracking
- Collaborative ownership with percentage splits
- Funding campaigns with contribution tracking

### ✅ AI-Powered Features

- Autonomous content approval based on creator reputation
- Dynamic pricing based on demand analysis
- Intelligent recommendation system (MeTTa reasoning)
- Automated royalty distribution

### ✅ Blockchain Integration

- NFT minting simulation
- Ownership transfer tracking
- Transaction verification
- Smart contract integration hooks

## Testing

### Manual Testing

1. **Register a Creator:**

   ```bash
   curl -X POST http://localhost:3000/api/creators \
   -H "Content-Type: application/json" \
   -d '{"name":"Test Creator","email":"test@example.com","walletAddress":"0x123"}'
   ```

2. **Create an Asset:**

   ```bash
   curl -X POST http://localhost:3000/api/assets \
   -H "Content-Type: application/json" \
   -d '{"creatorId":1000,"assetType":"NFT","title":"Test NFT","description":"Test","price":1.0}'
   ```

3. **Test AI Agent:**
   ```bash
   curl -X POST http://localhost:3000/api/agents/auto-approve/2000
   ```

### Frontend Testing

1. Open http://localhost:8501
2. Navigate through different sections:
   - Register as a creator
   - Create assets
   - Test funding campaigns
   - Explore AI agents
   - View analytics

## Deployment

### Docker Deployment

```dockerfile
FROM node:16-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
EXPOSE 3000

CMD ["npm", "start"]
```

### Environment-Specific Configuration

- **Development**: Use local MeTTa runtime
- **Staging**: Use containerized MeTTa with persistent storage
- **Production**: Use clustered MeTTa with load balancing

## Troubleshooting

### Common Issues

1. **MeTTa Runtime Not Found:**

   - Ensure MeTTa is properly installed and in PATH
   - Check METTA_PATH environment variable

2. **Port Conflicts:**

   - Change ports in environment variables
   - Ensure no other services are using ports 3000/8501

3. **Dependency Issues:**
   - Clear node_modules and reinstall: `rm -rf node_modules && npm install`
   - Update Python packages: `pip install -r requirements.txt --upgrade`

### Debug Mode

Enable debug logging:

```bash
DEBUG=* npm run dev
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

- Documentation: [Link to docs]
- Issues: [GitHub Issues]
- Community: [Discord/Slack channel]
- Email: support@basix-marketplace.com

---

**Note**: This implementation demonstrates the core concepts of integrating MeTTa's symbolic AI with a modern web application. In a production environment, you would need to add proper error handling, authentication, data persistence, and comprehensive testing.
