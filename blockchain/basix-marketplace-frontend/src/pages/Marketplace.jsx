// src/pages/Marketplace.jsx
import React, { useState, useEffect } from "react";
import {
  Container,
  Typography,
  Box,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Snackbar,
  Alert,
  CircularProgress,
  Paper,
  Tabs,
  Tab,
} from "@mui/material";
import { ShoppingCart, Visibility, SwapHoriz } from "@mui/icons-material";
import { assetAPI, transactionAPI, ownershipAPI } from "../utils/api";
import { useWeb3 } from "../contexts/Web3Context";

const Marketplace = () => {
  const [tabValue, setTabValue] = useState(0);
  const [assets, setAssets] = useState([]);
  const [loading, setLoading] = useState(false);
  const [purchaseDialogOpen, setPurchaseDialogOpen] = useState(false);
  const [transferDialogOpen, setTransferDialogOpen] = useState(false);
  const [selectedAsset, setSelectedAsset] = useState(null);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "info",
  });
  const [purchaseData, setPurchaseData] = useState({
    quantity: 1,
    payment_amount: 0,
  });
  const [transferData, setTransferData] = useState({
    to_wallet: "",
    percentage: 25,
  });

  const { account, connected, purchaseAssetOnBlockchain } = useWeb3();

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
      showSnackbar("Failed to fetch marketplace assets", "error");
    } finally {
      setLoading(false);
    }
  };

  const handlePurchase = async () => {
    if (!selectedAsset || !connected) return;

    setLoading(true);
    try {
      const response = await transactionAPI.purchase({
        buyer_wallet: account,
        asset_id: selectedAsset.id || selectedAsset.asset_id,
        quantity: purchaseData.quantity,
        payment_amount: purchaseData.payment_amount,
      });

      if (response.success) {
        showSnackbar("Purchase processed successfully!", "success");

        if (connected) {
          try {
            const txHash = await purchaseAssetOnBlockchain(
              selectedAsset.id || selectedAsset.asset_id,
              purchaseData.quantity,
              purchaseData.payment_amount
            );
            showSnackbar(
              `Blockchain purchase successful! TX: ${txHash}`,
              "success"
            );
          } catch (blockchainError) {
            showSnackbar(
              "Backend purchase successful, but blockchain transaction failed",
              "warning"
            );
          }
        }

        setPurchaseDialogOpen(false);
        fetchAssets();
      }
    } catch (error) {
      showSnackbar(error.message || "Purchase failed", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleTransfer = async () => {
    if (!selectedAsset || !connected) return;

    setLoading(true);
    try {
      const response = await ownershipAPI.transfer({
        from_wallet: account,
        to_wallet: transferData.to_wallet,
        asset_id: selectedAsset.id || selectedAsset.asset_id,
        percentage: transferData.percentage,
      });

      if (response.success) {
        showSnackbar("Ownership transfer initiated!", "success");
        setTransferDialogOpen(false);
      }
    } catch (error) {
      showSnackbar(error.message || "Transfer failed", "error");
    } finally {
      setLoading(false);
    }
  };

  const showSnackbar = (message, severity) => {
    setSnackbar({ open: true, message, severity });
  };

  const openPurchaseDialog = (asset) => {
    setSelectedAsset(asset);
    setPurchaseData({
      quantity: 1,
      payment_amount: asset.price || asset.price_eth || 0,
    });
    setPurchaseDialogOpen(true);
  };

  const openTransferDialog = (asset) => {
    setSelectedAsset(asset);
    setTransferData({ to_wallet: "", percentage: 25 });
    setTransferDialogOpen(true);
  };

  // 🔹 Deduplicate assets by title (index 4)
  const uniqueAssets = Array.from(
    new Map(assets.map((asset) => [asset[4], asset])).values()
  );

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" fontWeight="bold" sx={{ mb: 4 }}>
        Marketplace
      </Typography>

      {!connected && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Please connect your wallet to purchase assets or transfer ownership
        </Alert>
      )}

      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={tabValue}
          onChange={(e, newValue) => setTabValue(newValue)}
        >
          <Tab label="Browse Assets" />
          <Tab label="My Purchases" />
          <Tab label="My Ownership" />
        </Tabs>
      </Paper>

      {loading && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 4 }}>
          <CircularProgress />
        </Box>
      )}

      {tabValue === 0 && (
        <Grid container spacing={3}>
          {uniqueAssets.map((asset, index) => (
            <Grid item xs={12} sm={6} md={4} key={asset[1] || index}>
              <Card
                sx={{
                  height: "100%",
                  display: "flex",
                  flexDirection: "column",
                }}
              >
                <CardContent sx={{ flexGrow: 1 }}>
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    {asset[4] || "Untitled Asset"}
                  </Typography>

                  <Box sx={{ display: "flex", gap: 1, mb: 2 }}>
                    <Chip
                      label={asset[3] || asset.asset_type || asset.type}
                      size="small"
                      color="primary"
                    />
                    {/* <Chip
                      label={`${asset[9] || asset.royalty_percentage || 5}% royalty`}
                      size="small"
                      variant="outlined"
                    /> */}
                  </Box>

                  <Typography
                    variant="body2"
                    color="text.secondary"
                    sx={{ mb: 2 }}
                  >
                    {asset[5] || asset.description || "No description available"}
                  </Typography>

                  <Typography variant="h5" color="primary" fontWeight="bold">
                    {asset[8] || asset.price || asset.price_eth || 0} ETH
                  </Typography>
                </CardContent>

                <CardActions sx={{ flexDirection: "column", gap: 1 }}>
                  <Box sx={{ display: "flex", gap: 1, width: "100%" }}>
                    <Button size="small" startIcon={<Visibility />} fullWidth>
                      Details
                    </Button>
                    <Button
                      size="small"
                      variant="contained"
                      startIcon={<ShoppingCart />}
                      onClick={() => openPurchaseDialog(asset)}
                      disabled={!connected}
                      fullWidth
                    >
                      Buy
                    </Button>
                  </Box>
                  <Button
                    size="small"
                    startIcon={<SwapHoriz />}
                    onClick={() => openTransferDialog(asset)}
                    disabled={!connected}
                    fullWidth
                  >
                    Transfer Ownership
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {tabValue === 1 && (
        <Box sx={{ textAlign: "center", py: 4 }}>
          <Typography variant="h6" color="text.secondary">
            Purchase history will be displayed here
          </Typography>
        </Box>
      )}

      {tabValue === 2 && (
        <Box sx={{ textAlign: "center", py: 4 }}>
          <Typography variant="h6" color="text.secondary">
            Your ownership stakes will be displayed here
          </Typography>
        </Box>
      )}

      {/* Purchase Dialog */}
      <Dialog
        open={purchaseDialogOpen}
        onClose={() => setPurchaseDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Purchase Asset</DialogTitle>
        <DialogContent>
          {selectedAsset && (
            <Box>
              <Typography variant="h6" gutterBottom>
                {selectedAsset[4] || selectedAsset.title}
              </Typography>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                {selectedAsset[5] || selectedAsset.description}
              </Typography>

              <Box sx={{ my: 2 }}>
                <TextField
                  fullWidth
                  label="Quantity"
                  type="number"
                  value={purchaseData.quantity}
                  onChange={(e) =>
                    setPurchaseData((prev) => ({
                      ...prev,
                      quantity: parseInt(e.target.value),
                      payment_amount:
                        (selectedAsset[8] ||
                          selectedAsset.price ||
                          0) * parseInt(e.target.value),
                    }))
                  }
                  inputProps={{ min: 1 }}
                  sx={{ mb: 2 }}
                />

                <TextField
                  fullWidth
                  label="Total Payment (ETH)"
                  type="number"
                  value={purchaseData.payment_amount}
                  onChange={(e) =>
                    setPurchaseData((prev) => ({
                      ...prev,
                      payment_amount: parseFloat(e.target.value),
                    }))
                  }
                  inputProps={{ min: 0, step: 0.01 }}
                />
              </Box>

              <Typography variant="body2" color="text.secondary">
                Royalty: {selectedAsset[9] || selectedAsset.royalty_percentage || 5}
                % will go to creator
              </Typography>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setPurchaseDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            onClick={handlePurchase}
            disabled={loading || !connected}
          >
            {loading ? <CircularProgress size={20} /> : "Purchase"}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Transfer Dialog */}
      <Dialog
        open={transferDialogOpen}
        onClose={() => setTransferDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Transfer Ownership</DialogTitle>
        <DialogContent>
          {selectedAsset && (
            <Box>
              <Typography variant="h6" gutterBottom>
                {selectedAsset[4] || selectedAsset.title}
              </Typography>

              <TextField
                fullWidth
                label="Recipient Wallet Address"
                value={transferData.to_wallet}
                onChange={(e) =>
                  setTransferData((prev) => ({
                    ...prev,
                    to_wallet: e.target.value,
                  }))
                }
                placeholder="0x..."
                sx={{ mb: 2, mt: 1 }}
              />

              <TextField
                fullWidth
                label="Ownership Percentage to Transfer"
                type="number"
                value={transferData.percentage}
                onChange={(e) =>
                  setTransferData((prev) => ({
                    ...prev,
                    percentage: parseInt(e.target.value),
                  }))
                }
                inputProps={{ min: 1, max: 100 }}
              />

              <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
                You can transfer partial ownership to enable collaborative
                ownership
              </Typography>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setTransferDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            onClick={handleTransfer}
            disabled={loading || !connected || !transferData.to_wallet}
          >
            {loading ? <CircularProgress size={20} /> : "Transfer"}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} sx={{ width: "100%" }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default Marketplace;
