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
  LinearProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Snackbar,
  Alert,
  CircularProgress,
  Chip,
} from "@mui/material";
import { Add, TrendingUp, AccountBalanceWallet } from "@mui/icons-material";
import { fundingAPI } from "../utils/api";
import { useWeb3 } from "../contexts/Web3Context";

const Funding = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(false);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [contributeDialogOpen, setContributeDialogOpen] = useState(false);
  const [selectedCampaign, setSelectedCampaign] = useState(null);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "info",
  });

  const [campaignData, setCampaignData] = useState({
    title: "",
    description: "",
    target_amount: "",
    duration_days: 30,
    min_contribution: 0.01,
  });

  const [contributionData, setContributionData] = useState({
    amount: "",
  });

  const { account, connected } = useWeb3();

  useEffect(() => {
    fetchCampaigns();
  }, []);

  const fetchCampaigns = async () => {
    setLoading(true);
    try {
      // Mock campaigns for demo
      const mockCampaigns = [
        {
          id: 1,
          title: "Digital Art Series",
          description: "Creating a new series of digital artworks",
          target_amount: 10.0,
          current_amount: 3.2,
          creator: "Alice",
          days_left: 15,
        },
        {
          id: 2,
          title: "Music Album Production",
          description: "Recording and producing a new music album",
          target_amount: 25.0,
          current_amount: 18.5,
          creator: "Bob",
          days_left: 8,
        },
        {
          id: 3,
          title: "Documentary Film",
          description: "Creating a documentary about local artists",
          target_amount: 50.0,
          current_amount: 12.3,
          creator: "Carol",
          days_left: 22,
        },
      ];
      setCampaigns(mockCampaigns);
    } catch (error) {
      showSnackbar("Failed to fetch funding campaigns", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleCreateCampaign = async (e) => {
    e.preventDefault();
    if (!connected) return;

    setLoading(true);
    try {
      const response = await fundingAPI.createCampaign({
        creator_wallet: account,
        ...campaignData,
        target_amount: parseFloat(campaignData.target_amount),
      });

      if (response.success) {
        showSnackbar(
          `Campaign created successfully! ID: ${response.data.campaign_id}`,
          "success"
        );
        setCreateDialogOpen(false);
        setCampaignData({
          title: "",
          description: "",
          target_amount: "",
          duration_days: 30,
          min_contribution: 0.01,
        });
        fetchCampaigns();
      }
    } catch (error) {
      showSnackbar(error.message || "Campaign creation failed", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleContribute = async (e) => {
    e.preventDefault();
    if (!connected || !selectedCampaign) return;

    setLoading(true);
    try {
      const response = await fundingAPI.contribute({
        contributor_wallet: account,
        campaign_id: selectedCampaign.id,
        amount: parseFloat(contributionData.amount),
      });

      if (response.success) {
        showSnackbar("Contribution successful!", "success");
        setContributeDialogOpen(false);
        setContributionData({ amount: "" });
        fetchCampaigns();
      }
    } catch (error) {
      showSnackbar(error.message || "Contribution failed", "error");
    } finally {
      setLoading(false);
    }
  };

  const showSnackbar = (message, severity) => {
    setSnackbar({ open: true, message, severity });
  };

  const openContributeDialog = (campaign) => {
    setSelectedCampaign(campaign);
    setContributeDialogOpen(true);
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
          Funding Campaigns
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setCreateDialogOpen(true)}
          disabled={!connected}
        >
          Create Campaign
        </Button>
      </Box>

      {!connected && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Please connect your wallet to create or contribute to funding
          campaigns
        </Alert>
      )}

      {loading && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 4 }}>
          <CircularProgress />
        </Box>
      )}

      <Grid container spacing={3}>
        {campaigns.map((campaign) => {
          const progress =
            (campaign.current_amount / campaign.target_amount) * 100;
          return (
            <Grid item xs={12} md={6} key={campaign.id}>
              <Card
                sx={{
                  height: "100%",
                  display: "flex",
                  flexDirection: "column",
                }}
              >
                <CardContent sx={{ flexGrow: 1 }}>
                  <Typography variant="h6" fontWeight="bold" gutterBottom>
                    {campaign.title}
                  </Typography>

                  <Typography
                    variant="body2"
                    color="text.secondary"
                    sx={{ mb: 2 }}
                  >
                    {campaign.description}
                  </Typography>

                  <Box sx={{ mb: 2 }}>
                    <Box
                      sx={{
                        display: "flex",
                        justifyContent: "space-between",
                        mb: 1,
                      }}
                    >
                      <Typography variant="body2" fontWeight="bold">
                        {campaign.current_amount} ETH raised
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {campaign.target_amount} ETH goal
                      </Typography>
                    </Box>
                    <LinearProgress
                      variant="determinate"
                      value={Math.min(progress, 100)}
                      sx={{ height: 8, borderRadius: 4 }}
                    />
                    <Typography variant="caption" color="text.secondary">
                      {Math.round(progress)}% funded
                    </Typography>
                  </Box>

                  <Box
                    sx={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                    }}
                  >
                    <Chip label={`Creator: ${campaign.creator}`} size="small" />
                    <Typography variant="body2" color="text.secondary">
                      {campaign.days_left} days left
                    </Typography>
                  </Box>
                </CardContent>

                <CardActions>
                  <Button
                    size="small"
                    variant="contained"
                    startIcon={<AccountBalanceWallet />}
                    onClick={() => openContributeDialog(campaign)}
                    disabled={!connected}
                    fullWidth
                  >
                    Contribute
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          );
        })}
      </Grid>

      {/* Create Campaign Dialog */}
      <Dialog
        open={createDialogOpen}
        onClose={() => setCreateDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <form onSubmit={handleCreateCampaign}>
          <DialogTitle>Create Funding Campaign</DialogTitle>
          <DialogContent>
            <TextField
              autoFocus
              margin="dense"
              label="Campaign Title"
              type="text"
              fullWidth
              variant="outlined"
              value={campaignData.title}
              onChange={(e) =>
                setCampaignData((prev) => ({ ...prev, title: e.target.value }))
              }
              required
              sx={{ mb: 2 }}
            />

            <TextField
              margin="dense"
              label="Description"
              type="text"
              fullWidth
              variant="outlined"
              multiline
              rows={4}
              value={campaignData.description}
              onChange={(e) =>
                setCampaignData((prev) => ({
                  ...prev,
                  description: e.target.value,
                }))
              }
              required
              sx={{ mb: 2 }}
            />

            <Box sx={{ display: "flex", gap: 2 }}>
              <TextField
                margin="dense"
                label="Target Amount (ETH)"
                type="number"
                variant="outlined"
                value={campaignData.target_amount}
                onChange={(e) =>
                  setCampaignData((prev) => ({
                    ...prev,
                    target_amount: e.target.value,
                  }))
                }
                required
                inputProps={{ min: 0.1, step: 0.1 }}
                sx={{ flex: 1 }}
              />

              <TextField
                margin="dense"
                label="Duration (days)"
                type="number"
                variant="outlined"
                value={campaignData.duration_days}
                onChange={(e) =>
                  setCampaignData((prev) => ({
                    ...prev,
                    duration_days: parseInt(e.target.value),
                  }))
                }
                required
                inputProps={{ min: 1, max: 365 }}
                sx={{ flex: 1 }}
              />
            </Box>

            <TextField
              margin="dense"
              label="Minimum Contribution (ETH)"
              type="number"
              fullWidth
              variant="outlined"
              value={campaignData.min_contribution}
              onChange={(e) =>
                setCampaignData((prev) => ({
                  ...prev,
                  min_contribution: parseFloat(e.target.value),
                }))
              }
              inputProps={{ min: 0.01, step: 0.01 }}
              sx={{ mt: 2 }}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setCreateDialogOpen(false)}>Cancel</Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? <CircularProgress size={20} /> : "Create Campaign"}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Contribute Dialog */}
      <Dialog
        open={contributeDialogOpen}
        onClose={() => setContributeDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <form onSubmit={handleContribute}>
          <DialogTitle>Contribute to Campaign</DialogTitle>
          <DialogContent>
            {selectedCampaign && (
              <Box>
                <Typography variant="h6" gutterBottom>
                  {selectedCampaign.title}
                </Typography>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {selectedCampaign.description}
                </Typography>

                <TextField
                  autoFocus
                  margin="dense"
                  label="Contribution Amount (ETH)"
                  type="number"
                  fullWidth
                  variant="outlined"
                  value={contributionData.amount}
                  onChange={(e) =>
                    setContributionData({ amount: e.target.value })
                  }
                  required
                  inputProps={{
                    min: selectedCampaign.min_contribution || 0.01,
                    step: 0.01,
                  }}
                  sx={{ mt: 2 }}
                />
              </Box>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setContributeDialogOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? <CircularProgress size={20} /> : "Contribute"}
            </Button>
          </DialogActions>
        </form>
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
export default Funding;
//
