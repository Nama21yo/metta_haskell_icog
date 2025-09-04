import React, { useState, useEffect } from "react";
import {
  Container,
  Typography,
  Box,
  Paper,
  Grid,
  Card,
  CardContent,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  CircularProgress,
} from "@mui/material";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { TrendingUp, Person, Palette, Store } from "@mui/icons-material";
import { analyticsAPI } from "../utils/api";

const Analytics = () => {
  const [loading, setLoading] = useState(false);
  const [marketplaceStats, setMarketplaceStats] = useState(null);

  useEffect(() => {
    fetchAnalytics();
  }, []);

  const fetchAnalytics = async () => {
    setLoading(true);
    try {
      const response = await analyticsAPI.getMarketplaceStats();
      if (response.success) {
        setMarketplaceStats(response.data);
      }
    } catch (error) {
      console.error("Failed to fetch analytics:", error);
    } finally {
      setLoading(false);
    }
  };

  // Mock data for demonstration
  const salesData = [
    { name: "Jan", sales: 4000, assets: 240, revenue: 12.5 },
    { name: "Feb", sales: 3000, assets: 139, revenue: 9.2 },
    { name: "Mar", sales: 2000, assets: 980, revenue: 15.8 },
    { name: "Apr", sales: 2780, assets: 390, revenue: 18.3 },
    { name: "May", sales: 1890, assets: 480, revenue: 22.1 },
    { name: "Jun", sales: 2390, assets: 380, revenue: 25.6 },
  ];

  const assetTypeData = [
    { name: "NFT", value: 45, color: "#667eea" },
    { name: "Video", value: 32, color: "#764ba2" },
    { name: "Audio", value: 28, color: "#f093fb" },
    { name: "Ticket", value: 15, color: "#4facfe" },
    { name: "Course", value: 12, color: "#fa709a" },
  ];

  const topCreators = [
    { name: "Alice", sales: 25.6, assets: 12, reputation: 95 },
    { name: "Bob", sales: 18.3, assets: 8, reputation: 87 },
    { name: "Carol", sales: 15.2, assets: 6, reputation: 82 },
    { name: "David", sales: 12.8, assets: 5, reputation: 76 },
    { name: "Eve", sales: 9.4, assets: 4, reputation: 71 },
  ];

  return (
    <Container maxWidth="lg">
      <Typography variant="h4" fontWeight="bold" sx={{ mb: 4 }}>
        Analytics Dashboard
      </Typography>

      {loading && (
        <Box sx={{ display: "flex", justifyContent: "center", py: 4 }}>
          <CircularProgress />
        </Box>
      )}

      {/* Key Metrics */}
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
                <Typography variant="h6">Total Creators</Typography>
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
                <Typography variant="h6">Total Assets</Typography>
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
                <Typography variant="h6">Avg. Asset Price</Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                0.28 ETH
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +5% from last month
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} lg={8}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Sales & Revenue Trends
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={salesData}>
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
                  dataKey="revenue"
                  stroke="#764ba2"
                  strokeWidth={2}
                />
              </LineChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} lg={4}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Asset Distribution
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={assetTypeData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {assetTypeData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>

      {/* Top Creators Table */}
      <Paper sx={{ p: 3 }}>
        <Typography variant="h6" gutterBottom>
          Top Creators Leaderboard
        </Typography>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Creator</TableCell>
                <TableCell align="right">Total Sales (ETH)</TableCell>
                <TableCell align="right">Assets Created</TableCell>
                <TableCell align="right">Reputation Score</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {topCreators.map((creator, index) => (
                <TableRow key={creator.name}>
                  <TableCell component="th" scope="row">
                    <Box sx={{ display: "flex", alignItems: "center" }}>
                      <Typography
                        variant="body1"
                        fontWeight={index < 3 ? "bold" : "normal"}
                      >
                        #{index + 1} {creator.name}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell align="right">{creator.sales}</TableCell>
                  <TableCell align="right">{creator.assets}</TableCell>
                  <TableCell align="right">{creator.reputation}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>
    </Container>
  );
};
export default Analytics;
//
