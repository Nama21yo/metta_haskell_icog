# @version 0.3.10
"""
BASIX IP Marketplace Smart Contract
A comprehensive marketplace for digital assets with collaborative ownership, 
dynamic pricing, and automated royalty distribution.
"""

# Events for logging blockchain activities
event CreatorRegistered:
    creator_id: indexed(uint256)
    creator_address: indexed(address)
    name: String[100]

event AssetCreated:
    asset_id: indexed(uint256)
    creator_id: indexed(uint256)
    asset_type: String[50]
    price: uint256
    royalty_percentage: uint256

event AssetPurchased:
    asset_id: indexed(uint256)
    buyer: indexed(address)
    seller: indexed(address)
    price: uint256
    royalty_amount: uint256

event OwnershipTransferred:
    asset_id: indexed(uint256)
    from_address: indexed(address)
    to_address: indexed(address)
    percentage: uint256

event FundingCampaignCreated:
    campaign_id: indexed(uint256)
    creator_id: indexed(uint256)
    target_amount: uint256
    deadline: uint256

event FundingContribution:
    campaign_id: indexed(uint256)
    contributor: indexed(address)
    amount: uint256

# Structs for data organization
struct Creator:
    creator_address: address
    name: String[100]
    email: String[100]
    reputation: uint256
    is_active: bool
    registration_time: uint256

struct Asset:
    creator_id: uint256
    asset_type: String[50]
    title: String[200]
    description: String[500]
    metadata_uri: String[200]
    price: uint256
    royalty_percentage: uint256
    is_active: bool
    created_time: uint256

struct Ownership:
    owner_address: address
    asset_id: uint256
    percentage: uint256

struct FundingCampaign:
    creator_id: uint256
    description: String[500]
    target_amount: uint256
    current_amount: uint256
    deadline: uint256
    min_contribution: uint256
    is_active: bool

struct Transaction:
    from_address: address
    to_address: address
    asset_id: uint256
    transaction_type: String[50]
    amount: uint256
    timestamp: uint256

# Storage variables
owner: public(address)
creators: public(HashMap[uint256, Creator])
assets: public(HashMap[uint256, Asset])
ownership_records: public(HashMap[uint256, DynArray[Ownership, 100]])
funding_campaigns: public(HashMap[uint256, FundingCampaign])
transactions: public(HashMap[uint256, Transaction])

# Mappings for efficient lookups
creator_by_address: public(HashMap[address, uint256])
asset_owners: public(HashMap[uint256, HashMap[address, uint256]])
creator_assets: public(HashMap[uint256, DynArray[uint256, 1000]])
campaign_contributors: public(HashMap[uint256, HashMap[address, uint256]])

# Counters
creator_counter: public(uint256)
asset_counter: public(uint256)
campaign_counter: public(uint256)
transaction_counter: public(uint256)

# Constants
MAX_ROYALTY: constant(uint256) = 20  # 20% maximum royalty
MIN_PRICE: constant(uint256) = 1000000000000000  # 0.001 ETH minimum
REPUTATION_PURCHASE_BONUS: constant(uint256) = 10
REPUTATION_SALE_BONUS: constant(uint256) = 5

@external
def __init__():
    """Initialize the contract with the deployer as owner"""
    self.owner = msg.sender
    self.creator_counter = 0
    self.asset_counter = 0
    self.campaign_counter = 0
    self.transaction_counter = 0

@external
def register_creator(name: String[100], email: String[100]) -> uint256:
    """
    Register a new creator in the marketplace
    Returns the creator ID
    """
    assert len(name) > 0, "Name cannot be empty"
    assert len(email) > 0, "Email cannot be empty"
    assert self.creator_by_address[msg.sender] == 0, "Creator already registered"
    
    self.creator_counter += 1
    creator_id: uint256 = self.creator_counter
    
    self.creators[creator_id] = Creator({
        creator_address: msg.sender,
        name: name,
        email: email,
        reputation: 0,
        is_active: True,
        registration_time: block.timestamp
    })
    
    self.creator_by_address[msg.sender] = creator_id
    
    log CreatorRegistered(creator_id, msg.sender, name)
    return creator_id

@external
def create_asset(
    asset_type: String[50],
    title: String[200], 
    description: String[500],
    metadata_uri: String[200],
    price: uint256,
    royalty_percentage: uint256
) -> uint256:
    """
    Create a new digital asset
    Returns the asset ID
    """
    creator_id: uint256 = self.creator_by_address[msg.sender]
    assert creator_id > 0, "Creator not registered"
    assert self.creators[creator_id].is_active, "Creator not active"
    assert price >= MIN_PRICE, "Price below minimum"
    assert royalty_percentage <= MAX_ROYALTY, "Royalty percentage too high"
    assert len(title) > 0, "Title cannot be empty"
    
    self.asset_counter += 1
    asset_id: uint256 = self.asset_counter
    
    self.assets[asset_id] = Asset({
        creator_id: creator_id,
        asset_type: asset_type,
        title: title,
        description: description,
        metadata_uri: metadata_uri,
        price: price,
        royalty_percentage: royalty_percentage,
        is_active: True,
        created_time: block.timestamp
    })
    
    # Set initial ownership to creator (100%)
    self.asset_owners[asset_id][msg.sender] = 100
    self.ownership_records[asset_id].append(Ownership({
        owner_address: msg.sender,
        asset_id: asset_id,
        percentage: 100
    }))
    
    # Add to creator's asset list
    self.creator_assets[creator_id].append(asset_id)
    
    log AssetCreated(asset_id, creator_id, asset_type, price, royalty_percentage)
    return asset_id

@external
@payable
def purchase_asset(asset_id: uint256, quantity: uint256) -> bool:
    """
    Purchase an asset with automatic royalty distribution
    """
    assert self.assets[asset_id].is_active, "Asset not active"
    assert quantity > 0, "Quantity must be positive"
    
    asset: Asset = self.assets[asset_id]
    total_cost: uint256 = asset.price * quantity
    assert msg.value >= total_cost, "Insufficient payment"
    
    # Calculate royalty
    royalty_amount: uint256 = total_cost * asset.royalty_percentage / 100
    seller_amount: uint256 = total_cost - royalty_amount
    
    # Get creator address
    creator: Creator = self.creators[asset.creator_id]
    
    # Transfer payments
    if royalty_amount > 0:
        send(creator.creator_address, royalty_amount)
    
    # For simplicity, assuming creator gets the seller amount
    # In a real marketplace, this would go to current owner(s)
    send(creator.creator_address, seller_amount)
    
    # Update reputation
    self.creators[asset.creator_id].reputation += REPUTATION_SALE_BONUS
    
    # Add ownership record for buyer
    if self.asset_owners[asset_id][msg.sender] == 0:
        self.ownership_records[asset_id].append(Ownership({
            owner_address: msg.sender,
            asset_id: asset_id,
            percentage: quantity
        }))
    
    self.asset_owners[asset_id][msg.sender] += quantity
    
    # Log transaction
    self.transaction_counter += 1
    self.transactions[self.transaction_counter] = Transaction({
        from_address: msg.sender,
        to_address: creator.creator_address,
        asset_id: asset_id,
        transaction_type: "purchase",
        amount: total_cost,
        timestamp: block.timestamp
    })
    
    log AssetPurchased(asset_id, msg.sender, creator.creator_address, total_cost, royalty_amount)
    
    # Refund excess payment
    if msg.value > total_cost:
        send(msg.sender, msg.value - total_cost)
    
    return True

@external
def transfer_ownership(
    asset_id: uint256,
    to_address: address,
    percentage: uint256
) -> bool:
    """
    Transfer ownership percentage to another address
    """
    assert self.assets[asset_id].is_active, "Asset not active"
    assert to_address != empty(address), "Invalid recipient address"
    assert percentage > 0 and percentage <= 100, "Invalid percentage"
    assert self.asset_owners[asset_id][msg.sender] >= percentage, "Insufficient ownership"
    
    # Update ownership records
    self.asset_owners[asset_id][msg.sender] -= percentage
    self.asset_owners[asset_id][to_address] += percentage
    
    # Add to ownership records if new owner
    if self.asset_owners[asset_id][to_address] == percentage:
        self.ownership_records[asset_id].append(Ownership({
            owner_address: to_address,
            asset_id: asset_id,
            percentage: percentage
        }))
    
    # Log transaction
    self.transaction_counter += 1
    self.transactions[self.transaction_counter] = Transaction({
        from_address: msg.sender,
        to_address: to_address,
        asset_id: asset_id,
        transaction_type: "transfer",
        amount: percentage,
        timestamp: block.timestamp
    })
    
    log OwnershipTransferred(asset_id, msg.sender, to_address, percentage)
    return True

@external
def update_asset_price(asset_id: uint256, new_price: uint256) -> bool:
    """
    Update asset price (only by creator or majority owners)
    """
    assert self.assets[asset_id].is_active, "Asset not active"
    assert new_price >= MIN_PRICE, "Price below minimum"
    
    # Check if caller is creator
    creator_id: uint256 = self.assets[asset_id].creator_id
    creator_address: address = self.creators[creator_id].creator_address
    
    # Allow creator or majority owner to update price
    assert msg.sender == creator_address or self.asset_owners[asset_id][msg.sender] >= 51, "Unauthorized"
    
    self.assets[asset_id].price = new_price
    return True

@external
def create_funding_campaign(
    description: String[500],
    target_amount: uint256,
    deadline: uint256,
    min_contribution: uint256
) -> uint256:
    """
    Create a new funding campaign
    """
    creator_id: uint256 = self.creator_by_address[msg.sender]
    assert creator_id > 0, "Creator not registered"
    assert target_amount > 0, "Target amount must be positive"
    assert deadline > block.timestamp, "Deadline must be in future"
    assert min_contribution > 0, "Minimum contribution must be positive"
    
    self.campaign_counter += 1
    campaign_id: uint256 = self.campaign_counter
    
    self.funding_campaigns[campaign_id] = FundingCampaign({
        creator_id: creator_id,
        description: description,
        target_amount: target_amount,
        current_amount: 0,
        deadline: deadline,
        min_contribution: min_contribution,
        is_active: True
    })
    
    log FundingCampaignCreated(campaign_id, creator_id, target_amount, deadline)
    return campaign_id

@external
@payable
def contribute_funding(campaign_id: uint256) -> bool:
    """
    Contribute to a funding campaign
    """
    campaign: FundingCampaign = self.funding_campaigns[campaign_id]
    assert campaign.is_active, "Campaign not active"
    assert block.timestamp < campaign.deadline, "Campaign expired"
    assert msg.value >= campaign.min_contribution, "Contribution below minimum"
    
    # Update campaign amount
    self.funding_campaigns[campaign_id].current_amount += msg.value
    
    # Record contribution
    self.campaign_contributors[campaign_id][msg.sender] += msg.value
    
    # Transfer funds to creator
    creator: Creator = self.creators[campaign.creator_id]
    send(creator.creator_address, msg.value)
    
    log FundingContribution(campaign_id, msg.sender, msg.value)
    return True

@external
@view
def get_creator(creator_id: uint256) -> Creator:
    """Get creator information"""
    return self.creators[creator_id]

@external
@view
def get_asset(asset_id: uint256) -> Asset:
    """Get asset information"""
    return self.assets[asset_id]

@external
@view
def get_ownership_percentage(asset_id: uint256, owner_address: address) -> uint256:
    """Get ownership percentage for specific asset and owner"""
    return self.asset_owners[asset_id][owner_address]

@external
@view
def get_campaign(campaign_id: uint256) -> FundingCampaign:
    """Get funding campaign information"""
    return self.funding_campaigns[campaign_id]

@external
@view
def get_creator_assets(creator_id: uint256) -> DynArray[uint256, 1000]:
    """Get all assets created by a creator"""
    return self.creator_assets[creator_id]

@external
@view
def get_asset_owners(asset_id: uint256) -> DynArray[Ownership, 100]:
    """Get all owners of an asset"""
    return self.ownership_records[asset_id]

@external
def emergency_pause_asset(asset_id: uint256) -> bool:
    """Emergency pause asset (owner only)"""
    assert msg.sender == self.owner, "Only owner can pause"
    self.assets[asset_id].is_active = False
    return True

@external
def update_creator_reputation(creator_id: uint256, reputation_delta: int256) -> bool:
    """Update creator reputation (owner only)"""
    assert msg.sender == self.owner, "Only owner can update reputation"
    
    if reputation_delta < 0:
        reduction: uint256 = convert(-reputation_delta, uint256)
        if self.creators[creator_id].reputation >= reduction:
            self.creators[creator_id].reputation -= reduction
        else:
            self.creators[creator_id].reputation = 0
    else:
        self.creators[creator_id].reputation += convert(reputation_delta, uint256)
    
    return True
