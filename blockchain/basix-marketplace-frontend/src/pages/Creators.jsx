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
  Avatar,
  CircularProgress,
} from "@mui/material";
import {
  Person,
  Email,
  AccountBalanceWallet,
  Add,
  Star,
} from "@mui/icons-material";
import { creatorAPI } from "../utils/api";
import { useWeb3 } from "../contexts/Web3Context";

const Creators = () => {
  const [creators, setCreators] = useState([]);
  const [loading, setLoading] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "info",
  });
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    wallet_address: "",
    bio: "",
  });

  const { account, connected, registerCreatorOnBlockchain } = useWeb3();

  useEffect(() => {
    if (connected && account) {
      setFormData((prev) => ({ ...prev, wallet_address: account }));
    }
  }, [account, connected]);

  useEffect(() => {
    fetchCreators();
  }, []);

  const fetchCreators = async () => {
    setLoading(true);
    try {
      const response = await creatorAPI.list();
      if (response.success) {
        setCreators(response.data?.creators || []);
      }
    } catch (error) {
      showSnackbar("Failed to fetch creators", "error");
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
    if (!formData.name || !formData.email || !formData.wallet_address) {
      showSnackbar("Please fill in all required fields", "error");
      return;
    }

    setLoading(true);
    try {
      // Register creator in backend/MeTTa
      const response = await creatorAPI.register(formData);

      if (response.success) {
        showSnackbar(
          `Creator registered successfully! ID: ${response.data.creator_id}`,
          "success"
        );

        // Optionally register on blockchain
        if (connected && account) {
          try {
            const txHash = await registerCreatorOnBlockchain(
              formData.name,
              formData.email
            );
            showSnackbar(
              `Blockchain registration successful! TX: ${txHash}`,
              "success"
            );
          } catch (blockchainError) {
            showSnackbar(
              "Backend registration successful, but blockchain registration failed",
              "warning"
            );
          }
        }

        setDialogOpen(false);
        setFormData({ name: "", email: "", wallet_address: "", bio: "" });
        fetchCreators();
      }
    } catch (error) {
      showSnackbar(error.message || "Registration failed", "error");
    } finally {
      setLoading(false);
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
          Creator Management
        </Typography>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={() => setDialogOpen(true)}
          disabled={!connected}
        >
          Register Creator
        </Button>
      </Box>

      {!connected && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Please connect your wallet to register as a creator
        </Alert>
      )}

      {loading && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 4 }}>
          <CircularProgress />
        </Box>
      )}

      <Grid container spacing={3}>
        {creators.map((creator, index) => (
          <Grid item xs={12} sm={6} md={4} key={creator.id || index}>
            <Card sx={{ height: "100%" }}>
              <CardContent>
                <Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
                  <Avatar sx={{ bgcolor: "#667eea", mr: 2 }}>
                    <Person />
                  </Avatar>
                  <Box>
                    <Typography variant="h6" fontWeight="bold">
                      {creator.name || "Unknown Creator"}
                    </Typography>
                    <Chip label={`ID: ${creator.id}`} size="small" />
                  </Box>
                </Box>

                <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                  <Email
                    sx={{ mr: 1, fontSize: 16, color: "text.secondary" }}
                  />
                  <Typography variant="body2" color="text.secondary">
                    {creator.email || "No email"}
                  </Typography>
                </Box>

                <Box sx={{ display: "flex", alignItems: "center", mb: 2 }}>
                  <AccountBalanceWallet
                    sx={{ mr: 1, fontSize: 16, color: "text.secondary" }}
                  />
                  <Typography variant="body2" color="text.secondary">
                    {creator.wallet_address
                      ? `${creator.wallet_address.slice(
                          0,
                          6
                        )}...${creator.wallet_address.slice(-4)}`
                      : "No wallet"}
                  </Typography>
                </Box>

                <Box sx={{ display: "flex", alignItems: "center" }}>
                  <Star sx={{ mr: 1, fontSize: 16, color: "gold" }} />
                  <Typography variant="body2">
                    Reputation: {creator.reputation || 0}
                  </Typography>
                </Box>
              </CardContent>

              <CardActions>
                <Button size="small" color="primary">
                  View Assets
                </Button>
                <Button size="small" color="secondary">
                  View Profile
                </Button>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* Registration Dialog */}
      <Dialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <form onSubmit={handleSubmit}>
          <DialogTitle>Register as Creator</DialogTitle>
          <DialogContent>
            <TextField
              autoFocus
              margin="dense"
              name="name"
              label="Creator Name"
              type="text"
              fullWidth
              variant="outlined"
              value={formData.name}
              onChange={handleInputChange}
              required
              sx={{ mb: 2 }}
            />
            <TextField
              margin="dense"
              name="email"
              label="Email Address"
              type="email"
              fullWidth
              variant="outlined"
              value={formData.email}
              onChange={handleInputChange}
              required
              sx={{ mb: 2 }}
            />
            <TextField
              margin="dense"
              name="wallet_address"
              label="Wallet Address"
              type="text"
              fullWidth
              variant="outlined"
              value={formData.wallet_address}
              onChange={handleInputChange}
              required
              disabled={connected}
              helperText={
                connected
                  ? "Auto-filled from connected wallet"
                  : "Connect wallet to auto-fill"
              }
              sx={{ mb: 2 }}
            />
            <TextField
              margin="dense"
              name="bio"
              label="Bio (Optional)"
              type="text"
              fullWidth
              variant="outlined"
              multiline
              rows={3}
              value={formData.bio}
              onChange={handleInputChange}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button type="submit" variant="contained" disabled={loading}>
              {loading ? <CircularProgress size={20} /> : "Register"}
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

export default Creators;
//
