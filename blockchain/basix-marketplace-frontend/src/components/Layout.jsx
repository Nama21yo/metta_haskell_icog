// src/components/Layout.jsx
import React, { useState } from "react";
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
  Drawer,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  IconButton,
  Chip,
  Alert,
  Snackbar,
} from "@mui/material";
import {
  Menu as MenuIcon,
  Home,
  Person,
  Palette,
  Store,
  TrendingUp,
  Analytics,
  AccountBalanceWallet,
} from "@mui/icons-material";
import { useNavigate, useLocation } from "react-router-dom";
import { useWeb3 } from "../contexts/Web3Context";

const menuItems = [
  { text: "Home", path: "/", icon: <Home /> },
  { text: "Creators", path: "/creators", icon: <Person /> },
  { text: "Assets", path: "/assets", icon: <Palette /> },
  { text: "Marketplace", path: "/marketplace", icon: <Store /> },
  { text: "Funding", path: "/funding", icon: <TrendingUp /> },
  { text: "Analytics", path: "/analytics", icon: <Analytics /> },
];

const Layout = ({ children }) => {
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [snackbar, setSnackbar] = useState({
    open: false,
    message: "",
    severity: "info",
  });
  const navigate = useNavigate();
  const location = useLocation();
  const { account, connected, connectWallet, disconnectWallet, loading } =
    useWeb3();

  const handleConnectWallet = async () => {
    try {
      await connectWallet();
      setSnackbar({
        open: true,
        message: "Wallet connected successfully!",
        severity: "success",
      });
    } catch (error) {
      setSnackbar({
        open: true,
        message: error.message || "Failed to connect wallet",
        severity: "error",
      });
    }
  };

  const handleDisconnectWallet = () => {
    disconnectWallet();
    setSnackbar({
      open: true,
      message: "Wallet disconnected",
      severity: "info",
    });
  };

  const handleMenuClick = (path) => {
    navigate(path);
    setDrawerOpen(false);
  };

  return (
    <Box sx={{ display: "flex", flexDirection: "column", minHeight: "100vh" }}>
      {/* Top App Bar */}
      <AppBar
        position="static"
        sx={{ background: "linear-gradient(90deg, #667eea 0%, #764ba2 100%)" }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            onClick={() => setDrawerOpen(true)}
            edge="start"
            sx={{ mr: 2 }}
          >
            <MenuIcon />
          </IconButton>

          <Typography
            variant="h6"
            component="div"
            sx={{ flexGrow: 1, fontWeight: "bold" }}
          >
            BASIX IP Marketplace
          </Typography>

          {/* Wallet Connection */}
          <Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
            {connected ? (
              <>
                <Chip
                  label={`${account?.slice(0, 6)}...${account?.slice(-4)}`}
                  color="secondary"
                  size="small"
                />
                <Button
                  color="inherit"
                  onClick={handleDisconnectWallet}
                  variant="outlined"
                  size="small"
                >
                  Disconnect
                </Button>
              </>
            ) : (
              <Button
                color="inherit"
                onClick={handleConnectWallet}
                disabled={loading}
                startIcon={<AccountBalanceWallet />}
                variant="outlined"
              >
                {loading ? "Connecting..." : "Connect Wallet"}
              </Button>
            )}
          </Box>
        </Toolbar>
      </AppBar>

      {/* Side Navigation Drawer */}
      <Drawer
        anchor="left"
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
        PaperProps={{
          sx: { width: 240 },
        }}
      >
        <Box
          sx={{
            p: 2,
            background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
            color: "white",
          }}
        >
          <Typography variant="h6" fontWeight="bold">
            Navigation
          </Typography>
        </Box>
        <List>
          {menuItems.map((item) => (
            <ListItem
              button
              key={item.text}
              onClick={() => handleMenuClick(item.path)}
              selected={location.pathname === item.path}
              sx={{
                "&.Mui-selected": {
                  backgroundColor: "rgba(102, 126, 234, 0.1)",
                },
              }}
            >
              <ListItemIcon
                sx={{
                  color:
                    location.pathname === item.path ? "#667eea" : "inherit",
                }}
              >
                {item.icon}
              </ListItemIcon>
              <ListItemText
                primary={item.text}
                sx={{
                  color:
                    location.pathname === item.path ? "#667eea" : "inherit",
                }}
              />
            </ListItem>
          ))}
        </List>
      </Drawer>

      {/* Main Content */}
      <Box
        component="main"
        sx={{ flexGrow: 1, p: 3, backgroundColor: "#f5f7fa" }}
      >
        {children}
      </Box>

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
    </Box>
  );
};

export default Layout;
