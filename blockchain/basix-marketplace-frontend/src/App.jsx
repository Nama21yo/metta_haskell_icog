// src/App.jsx
import React from "react";
import { Routes, Route } from "react-router-dom";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { Web3Provider } from "./contexts/Web3Context";
import Layout from "./components/Layout";
import Home from "./pages/Home";
import Creators from "./pages/Creators";
import Assets from "./pages/Assets";
import Marketplace from "./pages/Marketplace";
import Funding from "./pages/Funding";
import Analytics from "./pages/Analytics";

const theme = createTheme({
  palette: {
    mode: "light",
    primary: {
      main: "#667eea",
    },
    secondary: {
      main: "#764ba2",
    },
    background: {
      default: "#f5f7fa",
    },
  },
  typography: {
    h4: {
      fontWeight: 600,
    },
    h5: {
      fontWeight: 600,
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Web3Provider>
        <Layout>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/creators" element={<Creators />} />
            <Route path="/assets" element={<Assets />} />
            <Route path="/marketplace" element={<Marketplace />} />
            <Route path="/funding" element={<Funding />} />
            <Route path="/analytics" element={<Analytics />} />
          </Routes>
        </Layout>
      </Web3Provider>
    </ThemeProvider>
  );
}

export default App;
