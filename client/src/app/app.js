import React from "react";
import { StyleSheet, View, Text } from "react-native";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import Routes from "./routes.js";
import rootReducer from "./reducers";
import { ThemeProvider } from "./themeContext";

const store = configureStore({
  reducer: rootReducer,
});

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Log error messages to an error reporting service here
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.fallbackContainer}>
          <Text style={styles.fallbackText}>Something went wrong.</Text>
        </View>
      );
    }

    return this.props.children;
  }
}

export default function App() {
  return (
    <Provider store={store}>
      <ThemeProvider>
        <ErrorBoundary>
          <View style={styles.container}>
            <Routes />
          </View>
        </ErrorBoundary>
      </ThemeProvider>
    </Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000",
  },
  fallbackContainer: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#000",
  },
  fallbackText: {
    color: "white",
  },
});
