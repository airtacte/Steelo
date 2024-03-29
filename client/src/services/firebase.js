import React from "react";
import { StyleSheet, View } from "react-native";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import firebase from "@react-native-firebase/app";
import {
  REACT_APP_FIREBASE_API_KEY,
  REACT_APP_FIREBASE_AUTH_DOMAIN,
  REACT_APP_FIREBASE_PROJECT_ID,
  REACT_APP_FIREBASE_STORAGE_BUCKET,
  REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  REACT_APP_FIREBASE_APP_ID,
} from "react-native-dotenv";

import Routes from "./Routes";
import rootReducer from "./reducers";

const { firebaseConfig } = require('./config/config.js');

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

const store = configureStore({
  reducer: rootReducer,
});

export default function App() {
  return (
    <Provider store={store}>
      <View style={StyleSheet.flatten([styles.container])}>
        <Routes />
      </View>
    </Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#000",
  },
});
