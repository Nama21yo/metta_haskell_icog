// src/pages/Assets.jsx
import React, { useState, useEffect } from "react";
import {
  Container,
  Typography,
  Box,
  Paper,
  Grid,
  TextField,
  Button,
  Card,
  CardContent,
  CardActions,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Snackbar,
  Alert,
  Chip,
  MenuItem,
  FormControl,
  InputLabel,
  Select,
  CircularProgress,
} from "@mui/material";
import { Palette, Add, PriceChange, SmartToy } from "@mui/icons-material";
import { assetAPI, agentsAPI } from "../utils/api";
import { useWeb3 } from "../contexts/Web3Context";

const assetTypes = [
  "NFT",
  "Video",
  "Audio",
  "Ticket",
  "eBook",
  "Course",
  "Art",
  "Photography",
];

const Assets = () => {
  const [assets, setAssets] = useState([]);
  const [loading, setLoading] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "info",
  });
  const [formData, setFormData] = useState({
    creator_wallet: "",
    asset_type: "",
    title: "",
    description: "",
    metadata_uri: "",
    price: "",
    royalty_percentage: 5,
    tags: [],
  });

  const { account, connected, createAssetOnBlockchain } = useWeb3();

  useEffect(() => {
    if (connected && account) {
      setFormData((prev) => ({ ...prev, creator_wallet: account }));
    }
  }, [account, connected]);

  useEffect(() => {
    fetchAssets();
  }, []);

  const fetchAssets = async () => {
    setLoading(true);
    try {
      const response = await assetAPI.list();
      if (response.success) {
        setAssets(response.data?.assets || []);
      }
    } catch (error) {
      showSnackbar("Failed to fetch assets", error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.title || !formData.asset_type || !formData.price) {
      showSnackbar("Please fill in all required fields", "error");
      return;
    }

    setLoading(true);
    try {
      // Create asset in backend/MeTTa
      const response = await assetAPI.create({
        ...formData,
        price: parseFloat(formData.price),
      });

      if (response.success) {
        showSnackbar(
          `Asset created successfully! ID: ${response.data.asset_id}`,
          "success"
        );

        // Optionally create on blockchain
        if (connected && account) {
          try {
            const txHash = await createAssetOnBlockchain(formData);
            showSnackbar(
              `Blockchain asset creation successful! TX: ${txHash}`,
              "success"
            );
          } catch (blockchainError) {
            showSnackbar(
              "Backend creation successful, but blockchain creation failed",
              blockchainError.message
            );
          }
        }

        setDialogOpen(false);
        setFormData({
          creator_wallet: account || "",
          asset_type: "",
          title: "",
          description: "",
          metadata_uri: "",
          price: "",
          royalty_percentage: 5,
          tags: [],
        });
        fetchAssets();
      }
    } catch (error) {
      showSnackbar(error.message || "Asset creation failed", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleAutoApprove = async (assetId) => {
    try {
      const response = await agentsAPI.autoApprove(assetId);
      if (response.success) {
        showSnackbar(
          `Auto-approval result: ${response.data.approval_result}`,
          "success"
        );
      }
    } catch (error) {
      showSnackbar("Auto-approval failed", error.message);
    }
  };

  const handleDynamicPricing = async (assetId) => {
    try {
      const response = await agentsAPI.dynamicPricing(assetId);
      if (response.success) {
        showSnackbar(
          `Dynamic pricing result: ${response.data.pricing_result}`,
          "success"
        );
        fetchAssets(); // Refresh to show updated prices
      }
    } catch (error) {
      showSnackbar("Dynamic pricing failed", "error");
    }
  };

  const showSnackbar = (message, severity) => {
    setSnackbar({ open: true, message, severity });
  };

  return (
    <Container maxWidth="lg">
      <Box
        sx={{
          mb: 4,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Typography variant="h4" fontWeight="bold">
          Asset Management
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setDialogOpen(true)}
          disabled={!connected}
        >
          Create Asset
        </Button>
      </Box>

      {!connected && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Please connect your wallet to create assets
        </Alert>
      )}

      {loading && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 4 }}>
          <CircularProgress />
        </Box>
      )}

      <Grid container spacing={3}>
        {assets.map((asset, index) => (
          <Grid item xs={12} sm={6} md={4} key={asset.id || index}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
                  <Palette sx={{ mr: 2, color: "#667eea" }} />
                  <Box>
                    <Typography variant="h6" fontWeight="bold">
                      {asset.title || "Untitled Asset"}
                    </Typography>
                    <Chip
                      label={asset.asset_type || asset.type || "Unknown"}
                      size="small"
                      color="primary"
                    />
                  </Box>
                </Box>

                <Typography
                  variant="body2"
                  color="text.secondary"
                  sx={{ mb: 2 }}
                >
                  {asset.description || "No description available"}
                </Typography>

                <Box
                  sx={{
                    display: "flex",
                    justifyContent: "space-between",
                    mb: 2,
                  }}
                >
                  <Typography variant="h6" color="primary" fontWeight="bold">
                    {asset.price || asset.price_eth || 0} ETH
                  </Typography>
                  <Chip
                    label={`${asset.royalty_percentage || 5}% royalty`}
                    size="small"
                    variant="outlined"
                  />
                </Box>

                <Typography variant="caption" color="text.secondary">
                  Asset ID: {asset.id || asset.asset_id || "Unknown"}
                </Typography>
              </CardContent>

              <CardActions sx={{ flexDirection: "column", gap: 1 }}>
                <Box sx={{ display: "flex", gap: 1, width: "100%" }}>
                  <Button size="small" color="primary" fullWidth>
                    View Details
                  </Button>
                  <Button size="small" color="secondary" fullWidth>
                    Edit
                  </Button>
                </Box>
                <Box sx={{ display: "flex", gap: 1, width: "100%" }}>
                  <Button
                    size="small"
                    startIcon={<SmartToy />}
                    onClick={() =>
                      handleAutoApprove(asset.id || asset.asset_id)
                    }
                    fullWidth
                  >
                    Auto Approve
                  </Button>
                  <Button
                    size="small"
                    startIcon={<PriceChange />}
                    onClick={() =>
                      handleDynamicPricing(asset.id || asset.asset_id)
                    }
                    fullWidth
                  >
                    Dynamic Price
                  </Button>
                </Box>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Asset Creation Dialog */}
      <Dialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        <form onSubmit={handleSubmit}>
          <DialogTitle>Create New Asset</DialogTitle>
          <DialogContent>
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6}>
                <FormControl fullWidth margin="dense">
                  <InputLabel>Asset Type</InputLabel>
                  <Select
                    name="asset_type"
                    value={formData.asset_type}
                    onChange={handleInputChange}
                    required
                  >
                    {assetTypes.map((type) => (
                      <MenuItem key={type} value={type}>
                        {type}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  margin="dense"
                  name="title"
                  label="Asset Title"
                  type="text"
                  fullWidth
                  variant="outlined"
                  value={formData.title}
                  onChange={handleInputChange}
                  required
                />
              </Grid>

              <Grid item xs={12}>
                <TextField
                  margin="dense"
                  name="description"
                  label="Description"
                  type="text"
                  fullWidth
                  variant="outlined"
                  multiline
                  rows={3}
                  value={formData.description}
                  onChange={handleInputChange}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  margin="dense"
                  name="price"
                  label="Price (ETH)"
                  type="number"
                  fullWidth
                  variant="outlined"
                  value={formData.price}
                  onChange={handleInputChange}
                  required
                  inputProps={{ min: 0, step: 0.01 }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  margin="dense"
                  name="royalty_percentage"
                  label="Royalty Percentage"
                  type="number"
                  fullWidth
                  variant="outlined"
                  value={formData.royalty_percentage}
                  onChange={handleInputChange}
                  inputProps={{ min: 0, max: 20, step: 1 }}
                />
              </Grid>

              <Grid item xs={12}>
                <TextField
                  margin="dense"
                  name="metadata_uri"
                  label="Metadata URI (IPFS/HTTP)"
                  type="text"
                  fullWidth
                  variant="outlined"
                  value={formData.metadata_uri}
                  onChange={handleInputChange}
                  placeholder="ipfs://... or https://..."
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? <CircularProgress size={20} /> : "Create Asset"}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Snackbar for notifications */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert
          onClose={() => setSnackbar({ ...snackbar, open: false })}
          severity={snackbar.severity}
          sx={{ width: "100%" }}
        >
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default Assets;
