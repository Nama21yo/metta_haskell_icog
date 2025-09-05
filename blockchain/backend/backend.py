"""
BASIX IP Marketplace - FastAPI Backend with MeTTa-Hyperon Integration
Proper integration flow: Frontend → FastAPI → MeTTa (via Hyperon) → Blockchain
"""

import asyncio
import json
import os
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Union
from decimal import Decimal
import uuid

from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator, EmailStr
from web3 import Web3
from eth_account import Account
import uvicorn

# MeTTa-Hyperon Integration
from hyperon import MeTTa, E, S, V, G, ValueAtom, OperationAtom, ExpressionAtom
from hyperon.atoms import AtomType, SymbolAtom

# Initialize FastAPI app
app = FastAPI(
    title="BASIX IP Marketplace API",
    description="AI-powered marketplace with MeTTa knowledge representation",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8501", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

# Configuration
class Config:
    ETHEREUM_RPC_URL = os.getenv("ETHEREUM_RPC_URL", "http://localhost:8545")
    CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS", "")
    PRIVATE_KEY = os.getenv("PRIVATE_KEY", "")
    METTA_KB_PATH = "./basix_kb.metta"

config = Config()

# MeTTa Knowledge Base Manager
class MeTTaKnowledgeManager:
    def __init__(self):
        self.metta = None
        self.initialized = False
        self.creators_space = None
        self.assets_space = None
        
        self.initialize_metta()
    
    def initialize_metta(self):
        """Initialize MeTTa interpreter and load knowledge base"""
        try:
            self.metta = MeTTa()
            
            # Load the knowledge base from file if it exists
            knowledge_path = os.path.join(os.path.dirname(__file__), 'basix_kb.metta')
            print("Metta path", knowledge_path)
            with open(knowledge_path, 'r') as f:
                kb_content = f.read()
            self.metta.run(kb_content)
            
            # Create dedicated spaces for different domains
            self.metta.run('''
                !(bind! &creators (new-space))
                !(bind! &assets (new-space))  
                !(bind! &marketplace (new-space))
                !(bind! &ownership (new-space))
                !(bind! &transactions (new-space))
                !(bind! &funding (new-space))
                
                !(bind! creatorIdCounter (new-state 1000))
                !(bind! assetIdCounter (new-state 2000))
                !(bind! transactionIdCounter (new-state 3000))
                !(bind! fundingCounter (new-state 4000))
            ''')
            
            # Register Python operations for complex calculations
            self.register_python_operations()
            
            self.initialized = True
            print("MeTTa Knowledge Base initialized successfully")
            
        except Exception as e:
            print(f"Failed to initialize MeTTa: {e}")
            self.initialized = False
    
    def register_python_operations(self):
        """Register Python operations that can be called from MeTTa"""
        if not self.metta:
            return
        
        # Register timestamp function
        def current_timestamp():
            return [ValueAtom(int(datetime.now().timestamp()), 'Number')]
        
        timestamp_op = OperationAtom("current-timestamp", current_timestamp, unwrap=False)
        self.metta.register_atom("current-timestamp", timestamp_op)
        
        # Register UUID generation
        def generate_uuid():
            return [ValueAtom(str(uuid.uuid4()), 'String')]
        
        uuid_op = OperationAtom("generate-uuid", generate_uuid, unwrap=False)
        self.metta.register_atom("generate-uuid", uuid_op)
        
        # Register reputation calculation
        def calculate_reputation(base_rep: int, transaction_bonus: int, review_score: int):
            new_rep = base_rep + transaction_bonus + (review_score * 2)
            return [ValueAtom(max(0, min(100, new_rep)), 'Number')]
        
        rep_op = OperationAtom("calculate-reputation", calculate_reputation)
        self.metta.register_atom("calculate-reputation", rep_op)
    
    def execute_query(self, query: str) -> Dict[str, Any]:
        """Execute MeTTa query and return structured result"""
        if not self.initialized or not self.metta:
            return {"success": False, "error": "MeTTa not initialized"}
        
        try:
            result = self.metta.run(query)
            print("Metta Execute Query Result", result)
            return {
                "success": True,
                "result": self.parse_metta_result(result),
                "query": query
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "query": query
            }
    
    def parse_metta_result(self, result: List) -> Any:
        """Parse MeTTa result into Python-friendly format"""
        if not result:
            return None
        
        parsed_results = []
        for item in result:
            if isinstance(item, list):
                parsed_item = []
                for atom in item:
                    parsed_item.append(self.atom_to_python(atom))
                parsed_results.append(parsed_item)
            else:
                parsed_results.append(self.atom_to_python(item))
        
        return parsed_results[0] if len(parsed_results) == 1 else parsed_results
    
    def atom_to_python(self, atom) -> Any:
        """Convert MeTTa atom to Python value"""
        if hasattr(atom, 'get_object'):
            # Grounded atom
            obj = atom.get_object()
            if hasattr(obj, 'value'):
                return obj.value
            return str(obj)
        elif hasattr(atom, 'get_name'):
            # Symbol or Variable atom
            return atom.get_name()
        elif hasattr(atom, 'get_children'):
            # Expression atom
            return [self.atom_to_python(child) for child in atom.get_children()]
        else:
            return str(atom)
    
    def python_to_metta_args(self, *args) -> str:
        """Convert Python arguments to MeTTa format"""
        metta_args = []
        for arg in args:
            if isinstance(arg, str):
                metta_args.append(f'"{arg}"')
            elif isinstance(arg, (int, float)):
                metta_args.append(str(arg))
            elif isinstance(arg, bool):
                metta_args.append("True" if arg else "False")
            elif isinstance(arg, dict):
                # Convert dict to MeTTa expression
                pairs = [f'({k} {self.python_to_metta_args(v)[0]})' for k, v in arg.items()]
                metta_args.append(f'({" ".join(pairs)})')
            else:
                metta_args.append(f'"{str(arg)}"')
        
        return " ".join(metta_args)

# Initialize MeTTa Knowledge Manager
metta_kb = MeTTaKnowledgeManager()

# Pydantic Models
class CreatorRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    wallet_address: str = Field(..., min_length=42, max_length=42)
    bio: Optional[str] = Field("", max_length=500)

class AssetRequest(BaseModel):
    creator_id: Optional[int] = None
    creator_wallet: str = Field(..., min_length=42, max_length=42)
    asset_type: str = Field(..., min_length=1, max_length=50)
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(default="", max_length=500)
    metadata_uri: str = Field(default="", max_length=200)
    price: float = Field(..., gt=0)
    royalty_percentage: int = Field(default=5, ge=0, le=20)
    tags: Optional[List[str]] = Field(default=[])

class PurchaseRequest(BaseModel):
    buyer_wallet: str
    asset_id: int = Field(..., gt=0)
    quantity: int = Field(default=1, gt=0)
    payment_amount: float = Field(..., gt=0)

class OwnershipTransferRequest(BaseModel):
    from_wallet: str
    to_wallet: str
    asset_id: int = Field(..., gt=0)
    percentage: int = Field(..., gt=0, le=100)

class FundingCampaignRequest(BaseModel):
    creator_wallet: str
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1, max_length=1000)
    target_amount: float = Field(..., gt=0)
    duration_days: int = Field(..., gt=0, le=365)
    min_contribution: float = Field(default=0.01, gt=0)

class ContributionRequest(BaseModel):
    contributor_wallet: str
    campaign_id: int = Field(..., gt=0)
    amount: float = Field(..., gt=0)

# Response Models
class APIResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Dict[str, Any]] = None
    timestamp: str = Field(default_factory=lambda: datetime.now().isoformat())

# Utility Functions
def create_response(success: bool, message: str, data: Any = None) -> APIResponse:
    """Create standardized API response"""
    return APIResponse(success=success, message=message, data=data)

async def log_transaction(transaction_type: str, details: Dict[str, Any]):
    """Log transaction to MeTTa knowledge base"""
    if metta_kb.initialized:
        tx_data = metta_kb.python_to_metta_args(
            transaction_type,
            details.get("from", ""),
            details.get("to", ""),
            details.get("amount", 0),
            int(datetime.now().timestamp())
        )
        query = f"!(logTransaction {tx_data})"
        return metta_kb.execute_query(query)

# API Endpoints

@app.get("/health")
async def health_check():
    """Health check with detailed system status"""
    return {
        "status": "healthy",

        "metta_available": True,
        "metta_initialized": metta_kb.initialized,
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0"
    }

@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    if not metta_kb.initialized:
        metta_kb.initialize_metta()

# Creator Management Endpoints

@app.post("/api/creators", response_model=APIResponse)
async def register_creator(creator_data: CreatorRequest):
    """Register a new creator in the marketplace"""
    try:
        # Execute MeTTa query to register creator
        query_args = metta_kb.python_to_metta_args(
            creator_data.name,
            creator_data.email,
            creator_data.wallet_address
        )
        print("Query Args", query_args)
        query = f"!(registerCreator {query_args})"
        
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            creator_id = result["result"]
            
            # # Log the registration
            # await log_transaction("creator_registration", {
            #     "creator_id": creator_id,
            #     "wallet": creator_data.wallet_address,
            #     "name": creator_data.name
            # })
            
            return create_response(
                True,
                f"Creator registered successfully with ID: {creator_id}",
                {
                    "creator_id": creator_id,
                    "name": creator_data.name,
                    "wallet_address": creator_data.wallet_address,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"MeTTa registration failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/creators/{creator_id}", response_model=APIResponse)
async def get_creator(creator_id: int):
    """Get creator information by ID"""
    try:
        query = f"!(getCreator {creator_id})"
        result = metta_kb.execute_query(query)
        
        if result.get("success") and result.get("result"):
            creator_data = result["result"]
            return create_response(
                True,
                "Creator retrieved successfully",
                {
                    "creator_id": creator_id,
                    "creator_info": creator_data,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(status_code=404, detail="Creator not found")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/creators", response_model=APIResponse)
async def list_creators():
    """List all registered creators"""
    try:
        query = "!(getTopCreators)"
        result = metta_kb.execute_query(query)
        print("Metta get Creators", result)
        
        return create_response(
            True,
            "Creators listed successfully",
            {
                "creators": result.get("result", []),
                "metta_query": query
            }
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Asset Management Endpoints

@app.post("/api/assets", response_model=APIResponse)
async def create_asset(asset_data: AssetRequest):
    """Create a new digital asset"""
    try:
        # First, get or resolve creator ID from wallet address
        creator_query = f'!(getCreator {asset_data.creator_id})'
        creator_result = metta_kb.execute_query(creator_query)
        print("Creator Result", creator_result)
        
        if not creator_result.get("success"):
            raise HTTPException(status_code=400, detail="Creator wallet not found")
        
        creator_id = creator_result["result"][0][1]
        
        # Create asset
        query_args = metta_kb.python_to_metta_args(
            creator_id,
            asset_data.asset_type,
            asset_data.title,
            asset_data.description,
            asset_data.metadata_uri,
            asset_data.price,
            asset_data.royalty_percentage
        )

        print("Query Result", query_args)
        query = f"!(createAsset {query_args})"
        
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            asset_id = result["result"]
            
            # Log asset creation
            # await log_transaction("asset_creation", {
            #     "asset_id": asset_id,
            #     "creator_id": creator_id,
            #     "title": asset_data.title,
            #     "type": asset_data.asset_type,
            #     "price": asset_data.price
            # })
            
            return create_response(
                True,
                f"Asset created successfully with ID: {asset_id}",
                {
                    "asset_id": asset_id,
                    "creator_id": creator_id,
                    "title": asset_data.title,
                    "asset_type": asset_data.asset_type,
                    "price": asset_data.price,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Asset creation failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/assets/{asset_id}", response_model=APIResponse)
async def get_asset(asset_id: int):
    """Get asset information by ID"""
    try:
        query = f"!(getAsset {asset_id})"
        result = metta_kb.execute_query(query)
        
        if result.get("success") and result.get("result"):
            asset_data = result["result"]
            return create_response(
                True,
                "Asset retrieved successfully",
                {
                    "asset_id": asset_id,
                    "asset_info": asset_data,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(status_code=404, detail="Asset not found")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/assets", response_model=APIResponse)
async def list_assets():
    """List all available assets in marketplace"""
    try:
        query = "!(getMarketplaceAssets)"
        result = metta_kb.execute_query(query)
        
        return create_response(
            True,
            "Assets listed successfully",
            {
                "assets": result.get("result", []),
                "metta_query": query
            }
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Purchase and Transaction Endpoints

@app.post("/api/transactions/purchase", response_model=APIResponse)
async def purchase_asset(purchase_data: PurchaseRequest):
    """Process asset purchase with royalty distribution"""
    try:
        # Get buyer ID from wallet
        print("Purchase data", purchase_data)
        buyer_query = f'!(getCreatorByWallet "{purchase_data.buyer_wallet}")'
        buyer_result = metta_kb.execute_query(buyer_query)
        print("Buyer Output", buyer_result)
        
        # if not buyer_result.get("success"):
        #     # Register buyer as creator if not exists
        #     register_query_args = metta_kb.python_to_metta_args(
        #         f"User_{purchase_data.buyer_wallet[:8]}",
        #         f"{purchase_data.buyer_wallet}@marketplace.local",
        #         purchase_data.buyer_wallet
        #     )
        #     register_query = f"!(registerCreator {register_query_args})"
        #     buyer_result = metta_kb.execute_query(register_query)
        
        buyer_id = buyer_result["result"][0][1]
        print("Buyer result", buyer_id)
        
        # Process purchase
        query_args = metta_kb.python_to_metta_args(
            buyer_id,
            purchase_data.asset_id,
            purchase_data.payment_amount,
            purchase_data.quantity
        )
        query = f"!(purchaseAsset {query_args})"
        
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            purchase_result = result["result"]
            
            # Log purchase transaction
            # await log_transaction("purchase", {
            #     "buyer_id": buyer_id,
            #     "asset_id": purchase_data.asset_id,
            #     "amount": purchase_data.payment_amount,
            #     "quantity": purchase_data.quantity
            # })
            
            return create_response(
                True,
                "Purchase processed successfully",
                {
                    "purchase_result": purchase_result,
                    "buyer_id": buyer_id,
                    "asset_id": purchase_data.asset_id,
                    "amount": purchase_data.payment_amount,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=400,
                detail=f"Purchase failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Ownership Management Endpoints

@app.get("/api/ownership/{wallet_address}/{asset_id}", response_model=APIResponse)
async def get_ownership(wallet_address: str, asset_id: int):
    """Get ownership information for wallet and asset"""
    try:
        # Get user ID from wallet
        user_query = f'!(getCreatorByWallet "{wallet_address}")'
        user_result = metta_kb.execute_query(user_query)
        
        if not user_result.get("success"):
            return create_response(True, "No ownership found", {"ownership_percentage": 0})
        
        user_id = user_result["result"]
        
        query = f"!(getOwnership {user_id} {asset_id})"
        result = metta_kb.execute_query(query)
        
        ownership_percentage = result.get("result", 0) if result.get("success") else 0
        
        return create_response(
            True,
            "Ownership retrieved successfully",
            {
                "wallet_address": wallet_address,
                "asset_id": asset_id,
                "ownership_percentage": ownership_percentage,
                "metta_query": query
            }
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Funding Campaign Endpoints

@app.post("/api/funding/campaigns", response_model=APIResponse)
async def create_funding_campaign(campaign_data: FundingCampaignRequest):
    """Create a new funding campaign"""
    try:
        # Get creator ID from wallet
        creator_query = f'!(getCreatorByWallet "{campaign_data.creator_wallet}")'
        creator_result = metta_kb.execute_query(creator_query)
        
        if not creator_result.get("success"):
            raise HTTPException(status_code=400, detail="Creator wallet not found")
        
        creator_id = creator_result["result"]
        deadline = int((datetime.now() + timedelta(days=campaign_data.duration_days)).timestamp())
        
        query_args = metta_kb.python_to_metta_args(
            creator_id,
            campaign_data.description,
            campaign_data.target_amount,
            deadline,
            campaign_data.min_contribution
        )
        query = f"!(createFundingCampaign {query_args})"
        
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            campaign_id = result["result"]
            
            await log_transaction("campaign_creation", {
                "campaign_id": campaign_id,
                "creator_id": creator_id,
                "target_amount": campaign_data.target_amount
            })
            
            return create_response(
                True,
                f"Funding campaign created with ID: {campaign_id}",
                {
                    "campaign_id": campaign_id,
                    "creator_id": creator_id,
                    "title": campaign_data.title,
                    "target_amount": campaign_data.target_amount,
                    "deadline": deadline,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Campaign creation failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# AI Agents Endpoints

@app.post("/api/agents/auto-approve/{asset_id}", response_model=APIResponse)
async def auto_approve_content(asset_id: int):
    """Run autonomous content approval agent"""
    try:
        query = f"!(autoApproveContent {asset_id})"
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            approval_result = result["result"]
            
            await log_transaction("auto_approval", {
                "asset_id": asset_id,
                "result": approval_result
            })
            
            return create_response(
                True,
                f"Auto-approval completed: {approval_result}",
                {
                    "asset_id": asset_id,
                    "approval_result": approval_result,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Auto-approval failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/agents/dynamic-pricing/{asset_id}", response_model=APIResponse)
async def run_dynamic_pricing(asset_id: int):
    """Run dynamic pricing agent"""
    try:
        query = f"!(dynamicPricingAgent {asset_id})"
        result = metta_kb.execute_query(query)
        
        if result.get("success"):
            pricing_result = result["result"]
            
            await log_transaction("dynamic_pricing", {
                "asset_id": asset_id,
                "result": pricing_result
            })
            
            return create_response(
                True,
                f"Dynamic pricing completed: {pricing_result}",
                {
                    "asset_id": asset_id,
                    "pricing_result": pricing_result,
                    "metta_query": query
                }
            )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Dynamic pricing failed: {result.get('error', 'Unknown error')}"
            )
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Analytics Endpoints

@app.get("/api/analytics/marketplace", response_model=APIResponse)
async def get_marketplace_analytics():
    """Get comprehensive marketplace analytics"""
    try:
        query = "!(getMarketplaceStats)"
        result = metta_kb.execute_query(query)
        
        return create_response(
            True,
            "Analytics retrieved successfully",
            {
                "marketplace_stats": result.get("result", {}),
                "timestamp": datetime.now().isoformat(),
                "metta_query": query
            }
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Debug and Development Endpoints

@app.get("/api/metta/query")
async def execute_custom_metta_query(query: str):
    """Execute custom MeTTa query (for development/debugging)"""
    try:
        if not query.startswith("!(") and not query.startswith("("):
            query = f"!({query})"
            
        result = metta_kb.execute_query(query)
        
        return create_response(
            True,
            "Custom query executed",
            {
                "query": query,
                "result": result.get("result"),
                "success": result.get("success"),
                "error": result.get("error")
            }
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/metta/spaces")
async def get_metta_spaces():
    """Get information about MeTTa spaces"""
    try:
        spaces_info = {}
        
        # Query each space for atom count
        spaces = ["&creators", "&assets", "&marketplace", "&ownership", "&transactions", "&funding"]
        
        for space in spaces:
            query = f"!(get-atoms {space})"
            result = metta_kb.execute_query(query)
            spaces_info[space.replace("&", "")] = {
                "atom_count": len(result.get("result", [])) if result.get("success") else 0,
                "status": "active" if result.get("success") else "error"
            }
        
        return create_response(
            True,
            "MeTTa spaces information retrieved",
            {"spaces": spaces_info}
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(
        "main:app", 
        host="0.0.0.0", 
        port=8000, 
        reload=True,
        log_level="info"
    )
