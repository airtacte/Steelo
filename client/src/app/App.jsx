import React, { Component } from "react";
import { StyleSheet, View } from "react-native";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";

import Routes from "./Routes";
import rootReducer from "./reducers";
import styles from "./styles";
import { ThemeProvider } from "./themeContext";

const store = configureStore({
  reducer: rootReducer,
});

class ErrorBoundary extends Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // You can log error messages to an error reporting service here
  }

  render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <View>
          <Text>Something went wrong.</Text>
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
});
