import React, { useState, useEffect } from "react";
import {
  Container,
  Typography,
  Box,
  Paper,
  Grid,
  Card,
  CardContent,
  Button,
  Chip,
  LinearProgress,
} from "@mui/material";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { TrendingUp, Person, Palette, Store } from "@mui/icons-material";
import { healthCheck } from "../utils/api";
import { useWeb3 } from "../contexts/Web3Context";

const Home = () => {
  const [systemHealth, setSystemHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const { connected, account } = useWeb3();

  useEffect(() => {
    const fetchSystemStatus = async () => {
      try {
        const health = await healthCheck();
        setSystemHealth(health);
      } catch (error) {
        console.error("Failed to fetch system status:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchSystemStatus();
  }, []);

  const mockMetrics = [
    { name: "Jan", sales: 4000, assets: 240 },
    { name: "Feb", sales: 3000, assets: 139 },
    { name: "Mar", sales: 2000, assets: 980 },
    { name: "Apr", sales: 2780, assets: 390 },
    { name: "May", sales: 1890, assets: 480 },
    { name: "Jun", sales: 2390, assets: 380 },
  ];

  if (loading) {
    return (
      <Container>
        <LinearProgress />
        <Typography variant="h6" sx={{ mt: 2 }}>
          Loading system status...
        </Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg">
      <Box sx={{ mb: 4 }}>
        <Typography
          variant="h3"
          component="h1"
          sx={{
            fontWeight: "bold",
            background: "linear-gradient(90deg, #667eea 0%, #764ba2 100%)",
            WebkitBackgroundClip: "text",
            WebkitTextFillColor: "transparent",
            textAlign: "center",
            mb: 2,
          }}
        >
          BASIX IP Marketplace
        </Typography>
        <Typography variant="h6" color="text.secondary" textAlign="center">
          AI-powered marketplace with MeTTa knowledge representation and Vyper
          smart contracts
        </Typography>
      </Box>

      {/* System Status */}
      <Paper sx={{ p: 3, mb: 4 }}>
        <Typography variant="h5" gutterBottom>
          System Status
        </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} md={3}>
            <Chip
              label={`API: ${systemHealth?.status || "Unknown"}`}
              color={systemHealth?.status === "healthy" ? "success" : "error"}
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Chip
              label={`MeTTa: ${
                systemHealth?.metta_initialized ? "Ready" : "Not Ready"
              }`}
              color={systemHealth?.metta_initialized ? "success" : "error"}
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Chip
              label={`Blockchain: ${connected ? "Connected" : "Disconnected"}`}
              color={connected ? "success" : "warning"}
              variant="outlined"
            />
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Chip
              label={`Wallet: ${account ? "Connected" : "Not Connected"}`}
              color={account ? "success" : "warning"}
              variant="outlined"
            />
          </Grid>
        </Grid>
      </Paper>

      {/* Quick Stats */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
              color: "white",
            }}
          >
            <CardContent>
              <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                <Person sx={{ mr: 1 }} />
                <Typography variant="h6">Creators</Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                1,234
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +12% from last month
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              background: "linear-gradient(135deg, #f093fb 0%, #f5576c 100%)",
              color: "white",
            }}
          >
            <CardContent>
              <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                <Palette sx={{ mr: 1 }} />
                <Typography variant="h6">Assets</Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                5,678
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +23% from last month
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              background: "linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)",
              color: "white",
            }}
          >
            <CardContent>
              <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                <Store sx={{ mr: 1 }} />
                <Typography variant="h6">Sales Volume</Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                142.5 ETH
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +8% from last month
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              background: "linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
              color: "white",
            }}
          >
            <CardContent>
              <Box sx={{ display: "flex", alignItems: "center", mb: 1 }}>
                <TrendingUp sx={{ mr: 1 }} />
                <Typography variant="h6">Active Campaigns</Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                89
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +15% from last month
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Marketplace Performance
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={mockMetrics}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="sales"
                  stroke="#667eea"
                  strokeWidth={2}
                />
                <Line
                  type="monotone"
                  dataKey="assets"
                  stroke="#764ba2"
                  strokeWidth={2}
                />
              </LineChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: "fit-content" }}>
            <Typography variant="h6" gutterBottom>
              Quick Actions
            </Typography>
            <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
              <Button variant="contained" fullWidth>
                Register as Creator
              </Button>
              <Button variant="outlined" fullWidth>
                Create New Asset
              </Button>
              <Button variant="outlined" fullWidth>
                Browse Marketplace
              </Button>
              <Button variant="outlined" fullWidth>
                Start Funding Campaign
              </Button>
            </Box>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
};
export default Home;
//
